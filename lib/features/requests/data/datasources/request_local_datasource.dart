import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/db/daos/request_dao.dart';
import '../../../../core/error/exceptions.dart';

import '../mappers/request_mappers.dart';

abstract class RequestLocalDataSource {
  Stream<List<RequestEntity>> watchRequests({
    RequestStatusEnum? status,
    int limit,
  });
  Future<RequestEntity?> getByLocalId(String localId);
  Future<void> upsert(RequestEntity request);
  Future<void> upsertFromRemote(List<RequestEntity> remoteItems);
}

class RequestLocalDataSourceImpl implements RequestLocalDataSource {
  final RequestDao dao;
  final Uuid uuid;
  RequestLocalDataSourceImpl({required this.dao, required this.uuid});

  @override
  Stream<List<RequestEntity>> watchRequests({
    RequestStatusEnum? status,
    int limit = 20,
  }) {
    return dao
        .watchRequests(status: status, limit: limit)
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Future<RequestEntity?> getByLocalId(String localId) async {
    try {
      final row = await dao.getByLocalId(localId);
      return row?.toEntity();
    } catch (_) {
      throw const CacheException(message: 'Falha ao ler a solicitação.');
    }
  }

  @override
  Future<void> upsert(RequestEntity request) async {
    try {
      await dao.upsert(request.toCompanion());
    } catch (_) {
      throw const CacheException(message: 'Falha ao salvar a solicitação.');
    }
  }

  @override
  Future<void> upsertFromRemote(List<RequestEntity> remoteItems) async {
    try {
      for (final item in remoteItems) {
        final existing = item.remoteId == null
            ? null
            : await dao.getByRemoteId(item.remoteId!);
        final localId = existing?.localId ?? uuid.v4();
        await dao.upsert(
          item
              .copyWith(localId: localId, syncStatus: SyncStatusEnum.synced)
              .toCompanion(),
        );
      }
    } catch (_) {
      throw const CacheException(message: 'Falha ao atualizar o cache.');
    }
  }
}
