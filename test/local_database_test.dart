import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hogwarts_explorer/database/local_database.dart';
import 'package:hogwarts_explorer/models/agenda_event_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final db = LocalDatabase.instance;
  final event = AgendaEvent(
    id: 'local-first-${DateTime.now().microsecondsSinceEpoch}',
    userId: 'test-user-${DateTime.now().microsecondsSinceEpoch}',
    title: 'Teste offline',
    description: 'Criar, editar e excluir',
    eventAt: DateTime(2026, 12, 1, 10),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    latitude: -23.5,
    longitude: -46.6,
  );

  test('SQLite CRUD and offline create/edit/delete coalescing', () async {
    await db.save(event, isNew: true);
    expect((await db.events(event.userId)).single.title, 'Teste offline');
    expect((await db.pending(event.userId)).single.kind, 'create');

    final edited = event.copyWith(
      title: 'Evento atualizado',
      updatedAt: DateTime.now(),
    );
    await db.save(edited, isNew: false);
    final pendingEdit = (await db.pending(event.userId)).single;
    expect(pendingEdit.kind, 'create');
    expect(pendingEdit.payload?['title'], 'Evento atualizado');

    final createInFlight = pendingEdit;
    await db.deleteEvent(edited);
    expect(await db.events(event.userId), isEmpty);
    final deletion = (await db.pending(event.userId)).single;
    expect(deletion.kind, 'delete');
    // A stale create acknowledgement must not remove a newer delete operation.
    expect(await db.markSynced(createInFlight), isFalse);
    expect(await db.markAttempt(createInFlight), isFalse);
    expect((await db.pending(event.userId)).single.kind, 'delete');
    expect(await db.markSynced(deletion), isTrue);
    expect(await db.pending(event.userId), isEmpty);
  });

  test(
    'offline deletion remains as a tombstone until remote confirmation',
    () async {
      final remoteEvent = AgendaEvent(
        id: '${event.id}-remote',
        userId: event.userId,
        title: 'Evento já sincronizado',
        description: event.description,
        eventAt: event.eventAt,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        isSynced: true,
      );
      await db.applyRemote(remoteEvent);
      expect((await db.events(remoteEvent.userId)).single.id, remoteEvent.id);
      await db.deleteEvent(remoteEvent);
      expect(await db.events(remoteEvent.userId), isEmpty);
      final pending = (await db.pending(remoteEvent.userId)).single;
      expect(pending.kind, 'delete');
      expect(pending.eventId, remoteEvent.id);
      await db.markSynced(pending);
      expect(await db.pending(remoteEvent.userId), isEmpty);
    },
  );

  test('records stay isolated by user id', () async {
    expect(await db.events('different-user-${event.userId}'), isEmpty);
  });

  tearDownAll(() async => db.dispose());
}
