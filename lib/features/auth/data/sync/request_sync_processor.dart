import 'dart:convert';

import 'package:tracking_requests/features/requests/data/datasources/request_remote_datasource.dart';
import 'package:tracking_requests/features/requests/data/mappers/request_mappers.dart';
import 'package:tracking_requests/features/requests/data/models/request_model.dart';

import '../../../../core/db/daos/request_dao.dart';
import '../../../../core/db/database.dart';
import '../../../../core/enums/sync_operation_type.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/sync_service.dart';

class RequestSyncProcessor implements SyncProcessor {
  final RequestDao requestDao;
  final RequestRemoteDataSource remote;

  RequestSyncProcessor({required this.requestDao, required this.remote});

  @override
  Future<void> process(SyncQueueEntry entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    final localId = payload['localId'] as String;
    final row = await requestDao.getByLocalId(localId);
    if (row == null) return;

    switch (entry.operationType) {
      case SyncOperationTypeEnum.create:
        final created = await remote.createRequest(
          RequestModel.fromEntity(row.toEntity()),
        );
        await requestDao.markSynced(localId, remoteId: created.remoteId);
      case SyncOperationTypeEnum.updateStatus:
        final remoteId = row.remoteId;
        if (remoteId == null) {
          throw const ServerException(message: 'remoteId ainda indisponível.');
        }
        await remote.updateStatus(remoteId: remoteId, status: row.status);
        await requestDao.markSynced(localId);
    }
  }

  @override
  Future<void> onFailedPermanently(SyncQueueEntry entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    await requestDao.markFailed(payload['localId'] as String);
  }
}
