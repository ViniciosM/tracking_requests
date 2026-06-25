import 'package:drift/drift.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';

import '../database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<List<SyncQueueEntry>> getPending() =>
      (select(syncQueue)
            ..where((t) => t.status.equalsValue(SyncStatusEnum.pending))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Stream<int> watchPendingCount() {
    final count = syncQueue.id.count();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equalsValue(SyncStatusEnum.pending));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<void> markSynced(int id) =>
      (update(syncQueue)..where((t) => t.id.equals(id))).write(
        const SyncQueueCompanion(status: Value(SyncStatusEnum.synced)),
      );

  Future<void> incrementRetry(
    int id, {
    required int retryCount,
    String? error,
  }) {
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncStatusEnum.pending),
        retryCount: Value(retryCount),
        lastError: Value(error),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markFailed(int id, String error, int retryCount) =>
      (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(
          status: const Value(SyncStatusEnum.failed),
          lastError: Value(error),
          retryCount: Value(retryCount),
          lastAttemptAt: Value(DateTime.now()),
        ),
      );

  Future<void> deleteById(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();
}
