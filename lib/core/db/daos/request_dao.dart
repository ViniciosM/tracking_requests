import 'package:drift/drift.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';

import '../database.dart';
import '../tables/requests_table.dart';

part 'request_dao.g.dart';

@DriftAccessor(tables: [Requests])
class RequestDao extends DatabaseAccessor<AppDatabase> with _$RequestDaoMixin {
  RequestDao(super.db);

  Stream<List<RequestRow>> watchRequests({
    RequestStatusEnum? status,
    int limit = 20,
  }) {
    final query = select(requests)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    if (status != null) {
      query.where((t) => t.status.equalsValue(status));
    }
    return query.watch();
  }

  Future<RequestRow?> getByLocalId(String localId) => (select(
    requests,
  )..where((t) => t.localId.equals(localId))).getSingleOrNull();

  Future<RequestRow?> getByRemoteId(String remoteId) => (select(
    requests,
  )..where((t) => t.remoteId.equals(remoteId))).getSingleOrNull();

  Future<void> upsert(RequestsCompanion entry) =>
      into(requests).insertOnConflictUpdate(entry);

  Future<void> upsertAll(List<RequestsCompanion> entries) =>
      batch((b) => b.insertAllOnConflictUpdate(requests, entries));

  Future<void> deleteByLocalId(String localId) =>
      (delete(requests)..where((t) => t.localId.equals(localId))).go();
}
