import 'dart:async';

import 'package:uuid/uuid.dart';

import '../database/local_database.dart';
import '../models/agenda_event_model.dart';
import '../services/firestore_service.dart';
import '../services/image_store.dart';
import '../services/sync_service.dart';

class AgendaSnapshot {
  const AgendaSnapshot(
    this.events,
    this.pendingCount,
    this.hasFailures,
    this.isSyncing,
  );
  final List<AgendaEvent> events;
  final int pendingCount;
  final bool hasFailures;
  final bool isSyncing;
}

class AgendaRepository {
  AgendaRepository({
    LocalDatabase? local,
    FirestoreService? remote,
    SyncService? sync,
  }) : _local = local ?? LocalDatabase.instance,
       _remote = remote ?? FirestoreService(),
       sync = sync ?? SyncService();

  final LocalDatabase _local;
  final FirestoreService _remote;
  final SyncService sync;
  final ImageStore imageStore = ImageStore();
  final StreamController<AgendaSnapshot> _changes =
      StreamController.broadcast();
  StreamSubscription<List<AgendaEvent>>? _remoteSub;
  String? _uid;

  Stream<AgendaSnapshot> get changes => _changes.stream;

  Future<void> connect(String uid) async {
    if (_uid == uid) return;
    await disconnect();
    _uid = uid;
    await refresh();
    _remoteSub = _remote
        .watch(uid)
        .listen(
          (records) async {
            for (final record in records) {
              await _local.applyRemote(record);
            }
            if (_uid == uid) await refresh();
          },
          onError: (_) async {
            // The local agenda remains usable; pending work stays in SQLite.
            if (_uid == uid) await refresh();
          },
        );
    sync.start(uid, onChanged: () => refresh());
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null || _changes.isClosed) return;
    final values = await Future.wait([_local.events(uid), _local.pending(uid)]);
    final events = values[0] as List<AgendaEvent>;
    final operations = values[1] as List<PendingOperation>;
    _changes.add(
      AgendaSnapshot(
        events,
        operations.length,
        operations.any((operation) => operation.attempts > 0),
        sync.isSyncing,
      ),
    );
  }

  Future<void> save({
    required String title,
    required String description,
    required DateTime eventAt,
    required String? imagePath,
    required double? latitude,
    required double? longitude,
    AgendaEvent? existing,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Entre na sua conta para usar a agenda.');
    final now = DateTime.now();
    final event = AgendaEvent(
      id: existing?.id ?? const Uuid().v4(),
      userId: uid,
      title: title.trim(),
      description: description.trim(),
      eventAt: eventAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
      isSynced: false,
    );
    await _local.save(event, isNew: existing == null);
    if (existing?.imagePath != null && existing!.imagePath != imagePath) {
      await imageStore.deleteIfUnused(existing.imagePath);
    }
    await refresh();
    await sync.syncNow(uid);
    await refresh();
  }

  Future<void> delete(AgendaEvent event) async {
    await _local.deleteEvent(event);
    await imageStore.deleteIfUnused(event.imagePath);
    await refresh();
    await sync.syncNow(event.userId);
    await refresh();
  }

  Future<SyncResult> synchronize() async {
    final uid = _uid;
    if (uid == null) return const SyncResult(synced: 0, failed: 0);
    final result = await sync.syncNow(uid);
    await refresh();
    return result;
  }

  Future<void> disconnect() async {
    await sync.stop();
    await _remoteSub?.cancel();
    _remoteSub = null;
    _uid = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _changes.close();
  }
}
