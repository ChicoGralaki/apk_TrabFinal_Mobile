import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/agenda_event_model.dart';

class PendingOperation {
  const PendingOperation({
    required this.eventId,
    required this.userId,
    required this.kind,
    required this.payload,
    required this.updatedAt,
    required this.attempts,
  });

  final String eventId;
  final String userId;
  final String kind;
  final Map<String, Object?>? payload;
  final String updatedAt;
  final int attempts;
}

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      p.join(root, 'hogwarts_explorer.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''CREATE TABLE agenda_events (
          id TEXT PRIMARY KEY, userId TEXT NOT NULL, title TEXT NOT NULL,
          description TEXT NOT NULL, eventAt TEXT NOT NULL, createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL, latitude REAL, longitude REAL, imagePath TEXT,
          deletedAt TEXT, isSynced INTEGER NOT NULL DEFAULT 0)''');
        await db.execute('''CREATE TABLE pending_operations (
          eventId TEXT NOT NULL, userId TEXT NOT NULL, kind TEXT NOT NULL,
          payload TEXT, updatedAt TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY(eventId, userId))''');
        await db.execute(
          'CREATE INDEX agenda_events_user_date ON agenda_events(userId, eventAt)',
        );
        await db.execute(
          'CREATE INDEX pending_ops_user ON pending_operations(userId, updatedAt)',
        );
      },
    );
    return _database!;
  }

  Future<List<AgendaEvent>> events(String userId) async {
    final rows = await (await database).query(
      'agenda_events',
      where: 'userId = ? AND deletedAt IS NULL',
      whereArgs: [userId],
      orderBy: 'eventAt ASC',
    );
    return rows.map(AgendaEvent.fromLocalMap).toList();
  }

  Future<List<AgendaEvent>> eventsForDay(String userId, DateTime day) async {
    final all = await events(userId);
    return all.where((event) => event.occursOn(day)).toList();
  }

  Future<AgendaEvent?> event(String userId, String id) async {
    final rows = await (await database).query(
      'agenda_events',
      where: 'userId = ? AND id = ? AND deletedAt IS NULL',
      whereArgs: [userId, id],
      limit: 1,
    );
    return rows.isEmpty ? null : AgendaEvent.fromLocalMap(rows.first);
  }

  Future<int> pendingCount(String userId) async =>
      Sqflite.firstIntValue(
        await (await database).rawQuery(
          'SELECT COUNT(*) FROM pending_operations WHERE userId = ?',
          [userId],
        ),
      ) ??
      0;

  Future<List<PendingOperation>> pending(String userId) async {
    final rows = await (await database).query(
      'pending_operations',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'updatedAt ASC',
    );
    return rows
        .map(
          (row) => PendingOperation(
            eventId: row['eventId']! as String,
            userId: row['userId']! as String,
            kind: row['kind']! as String,
            payload: row['payload'] == null
                ? null
                : Map<String, Object?>.from(
                    jsonDecode(row['payload']! as String) as Map,
                  ),
            updatedAt: row['updatedAt']! as String,
            attempts: row['attempts']! as int,
          ),
        )
        .toList();
  }

  Future<void> save(AgendaEvent event, {required bool isNew}) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'agenda_events',
        event.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final prior = await txn.query(
        'pending_operations',
        where: 'eventId = ? AND userId = ?',
        whereArgs: [event.id, event.userId],
        limit: 1,
      );
      final kind = prior.isNotEmpty && prior.first['kind'] == 'create'
          ? 'create'
          : (isNew ? 'create' : 'update');
      await _enqueue(txn, event, kind);
    });
  }

  Future<void> deleteEvent(AgendaEvent event) async {
    final db = await database;
    await db.transaction((txn) async {
      final deleted = event.copyWith(
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
        isSynced: false,
      );
      await txn.update(
        'agenda_events',
        deleted.toLocalMap(),
        where: 'id = ? AND userId = ?',
        whereArgs: [event.id, event.userId],
      );
      await txn.insert('pending_operations', {
        'eventId': event.id,
        'userId': event.userId,
        'kind': 'delete',
        'payload': null,
        'updatedAt': deleted.updatedAt.toUtc().toIso8601String(),
        'attempts': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> applyRemote(AgendaEvent event) async {
    final db = await database;
    await db.transaction((txn) async {
      final pending = await txn.query(
        'pending_operations',
        where: 'eventId = ? AND userId = ?',
        whereArgs: [event.id, event.userId],
        limit: 1,
      );
      if (pending.isEmpty) {
        await txn.insert(
          'agenda_events',
          event.toLocalMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<bool> markSynced(PendingOperation operation) async {
    final db = await database;
    return db.transaction((txn) async {
      final current = await txn.query(
        'pending_operations',
        where: 'eventId = ? AND userId = ?',
        whereArgs: [operation.eventId, operation.userId],
        limit: 1,
      );
      if (current.isEmpty || !_matchesOperation(current.first, operation)) {
        return false;
      }
      if (operation.kind == 'delete') {
        await txn.delete(
          'agenda_events',
          where: 'id = ? AND userId = ?',
          whereArgs: [operation.eventId, operation.userId],
        );
      } else {
        await txn.update(
          'agenda_events',
          {'isSynced': 1, 'deletedAt': null},
          where: 'id = ? AND userId = ?',
          whereArgs: [operation.eventId, operation.userId],
        );
      }
      await txn.delete(
        'pending_operations',
        where: 'eventId = ? AND userId = ?',
        whereArgs: [operation.eventId, operation.userId],
      );
      return true;
    });
  }

  Future<bool> markAttempt(PendingOperation operation) async {
    final changed = await (await database).rawUpdate(
      'UPDATE pending_operations SET attempts = attempts + 1 WHERE eventId = ? AND userId = ? AND kind = ? AND updatedAt = ? AND payload IS ?',
      [
        operation.eventId,
        operation.userId,
        operation.kind,
        operation.updatedAt,
        operation.payload == null ? null : _encode(operation.payload!),
      ],
    );
    return changed > 0;
  }

  bool _matchesOperation(
    Map<String, Object?> current,
    PendingOperation operation,
  ) {
    final expectedPayload = operation.payload == null
        ? null
        : _encode(operation.payload!);
    return current['kind'] == operation.kind &&
        current['updatedAt'] == operation.updatedAt &&
        current['payload'] == expectedPayload;
  }

  Future<void> _enqueue(Transaction txn, AgendaEvent event, String kind) =>
      txn.insert('pending_operations', {
        'eventId': event.id,
        'userId': event.userId,
        'kind': kind,
        'payload': kind == 'delete' ? null : _encode(event.toLocalMap()),
        'updatedAt': event.updatedAt.toUtc().toIso8601String(),
        'attempts': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

  String _encode(Map<String, Object?> value) => jsonEncode(value);

  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }
}
