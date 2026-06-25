import 'dart:convert';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/db/database.dart';
import '../../../../core/enums/sync_operation_type.dart';

import '../models/request_model.dart';

abstract class SyncQueueLocalDataSource {
  Future<void> enqueueCreate(RequestEntity request);
  Future<void> enqueueUpdateStatus(RequestEntity request);
}

class SyncQueueLocalDataSourceImpl implements SyncQueueLocalDataSource {
  final SyncQueueDao dao;
  SyncQueueLocalDataSourceImpl(this.dao);

  @override
  Future<void> enqueueCreate(RequestEntity request) async {
    final map = RequestModel.fromEntity(request).toCreateJson();
    map['localId'] = request.localId;
    await dao.enqueue(
      SyncQueueCompanion.insert(
        entityLocalId: request.localId,
        operationType: SyncOperationTypeEnum.create,
        payload: jsonEncode(map),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> enqueueUpdateStatus(RequestEntity request) async {
    final payload = jsonEncode({
      'localId': request.localId,
      'status': request.status.apiValue,
      'updatedAt': request.updatedAt.toIso8601String(),
    });
    await dao.enqueue(
      SyncQueueCompanion.insert(
        entityLocalId: request.localId,
        operationType: SyncOperationTypeEnum.updateStatus,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
  }
}
