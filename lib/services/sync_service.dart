import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/local_database.dart';
import '../models/agenda_event_model.dart';
import 'firestore_service.dart';

class SyncResult {
  const SyncResult({required this.synced, required this.failed});
  final int synced;
  final int failed;
}

class SyncService {
  SyncService({LocalDatabase? local, FirestoreService? remote})
    : _local = local ?? LocalDatabase.instance,
      _remote = remote ?? FirestoreService();
  final LocalDatabase _local;
  final FirestoreService _remote;
  Future<SyncResult>? _active;
  String? _syncingUid;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  String? _activeUid;
  void Function()? _onChanged;
  bool get isSyncing => _active != null;

  void start(String uid, {required void Function() onChanged}) {
    _activeUid = uid;
    _onChanged = onChanged;
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(syncNow(uid).then((_) => onChanged()));
      }
    });
    unawaited(syncNow(uid).then((_) => onChanged()));
  }

  Future<SyncResult> syncNow(String uid) {
    if (_active != null) {
      if (_syncingUid == uid) return _active!;
      return _active!.then((_) => syncNow(uid));
    }
    final run = _drain(uid);
    late final Future<SyncResult> managed;
    managed = run.whenComplete(() {
      if (identical(_active, managed)) {
        _active = null;
        _syncingUid = null;
      }
      _onChanged?.call();
    });
    _active = managed;
    _syncingUid = uid;
    _onChanged?.call();
    return managed;
  }

  Future<SyncResult> _drain(String uid) async {
    var synced = 0;
    var failed = 0;
    final attempted = <String>{};
    final connectivity = Connectivity();
    while (true) {
      if (_activeUid != uid) break;
      final networks = await connectivity.checkConnectivity();
      if (networks.isEmpty ||
          networks.every((result) => result == ConnectivityResult.none)) {
        break;
      }
      final operations = await _local.pending(uid);
      PendingOperation? next;
      for (final operation in operations) {
        final key = _operationKey(operation);
        if (!attempted.contains(key)) {
          next = operation;
          attempted.add(key);
          break;
        }
      }
      if (next == null) break;
      final operation = next;
      final currentOperations = await _local.pending(uid);
      if (!currentOperations.any(
        (current) => _operationKey(current) == _operationKey(operation),
      )) {
        continue;
      }
      try {
        if (operation.kind == 'delete') {
          await _remote.delete(uid, operation.eventId);
        } else {
          final payload = operation.payload;
          if (payload == null) {
            throw const FormatException('Missing operation data');
          }
          await _remote.put(AgendaEvent.fromLocalMap(payload));
        }
        if (await _local.markSynced(operation)) synced++;
      } on FirebaseException {
        if (await _local.markAttempt(operation)) failed++;
      } on Exception {
        if (await _local.markAttempt(operation)) failed++;
      }
    }
    return SyncResult(synced: synced, failed: failed);
  }

  String _operationKey(PendingOperation operation) =>
      '${operation.eventId}:${operation.kind}:${operation.updatedAt}:${operation.payload}';

  Future<void> stop() async {
    _activeUid = null;
    _onChanged = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}
