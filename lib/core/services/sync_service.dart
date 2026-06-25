import 'dart:async';

import '../db/daos/sync_queue_dao.dart';
import '../db/database.dart';
import 'connectivity_service.dart';

abstract class SyncProcessor {
  Future<void> process(SyncQueueEntry entry);

  Future<void> onFailedPermanently(SyncQueueEntry entry);
}

class SyncService {
  final ConnectivityService connectivity;
  final SyncQueueDao queueDao;
  final SyncProcessor processor;
  final int maxRetries;
  final Duration Function(int attempt) backoff;

  bool _isSyncing = false;
  int _lastPendingCount = 0;
  StreamSubscription<bool>? _connSub;
  StreamSubscription<int>? _queueSub;
  Timer? _retryTimer;

  SyncService({
    required this.connectivity,
    required this.queueDao,
    required this.processor,
    this.maxRetries = 5,
    Duration Function(int attempt)? backoff,
  }) : backoff = backoff ?? _defaultBackoff;

  void start() {
    _connSub = connectivity.onStatusChange.listen((online) {
      if (online) sync();
    });
    _queueSub = queueDao.watchPendingCount().listen((count) {
      if (count > _lastPendingCount) sync();
      _lastPendingCount = count;
    });
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    await _queueSub?.cancel();
    _retryTimer?.cancel();
  }

  Future<void> sync() async {
    if (_isSyncing) return;
    if (!await connectivity.isOnline) return;
    _isSyncing = true;
    try {
      final pending = await queueDao.getPending();
      for (final entry in pending) {
        try {
          await processor.process(entry);
          await queueDao.markSynced(entry.id);
        } catch (e) {
          await _handleFailure(entry, e);
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _handleFailure(SyncQueueEntry entry, Object error) async {
    final attempt = entry.retryCount + 1;
    if (attempt >= maxRetries) {
      await queueDao.markFailed(entry.id, error.toString(), attempt);
      await processor.onFailedPermanently(entry);
    } else {
      await queueDao.incrementRetry(
        entry.id,
        retryCount: attempt,
        error: error.toString(),
      );
      _scheduleRetry(attempt);
    }
  }

  void _scheduleRetry(int attempt) {
    _retryTimer?.cancel();
    _retryTimer = Timer(backoff(attempt), sync);
  }

  static Duration _defaultBackoff(int attempt) {
    final seconds = 1 << (attempt - 1); // 1, 2, 4, 8, ...
    return Duration(seconds: seconds > 60 ? 60 : seconds);
  }
}
