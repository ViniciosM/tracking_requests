import 'package:dartz/dartz.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/description_suggestion_entity.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/request_local_datasource.dart';
import '../datasources/request_remote_datasource.dart';
import '../datasources/sync_queue_local_datasource.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remote;
  final RequestLocalDataSource local;
  final SyncQueueLocalDataSource syncQueue;
  final AiRemoteDataSource ai;
  final ConnectivityService connectivity;
  final Uuid uuid;

  RequestRepositoryImpl({
    required this.remote,
    required this.local,
    required this.syncQueue,
    required this.ai,
    required this.connectivity,
    required this.uuid,
  });

  @override
  Stream<List<RequestEntity>> watchRequests({
    RequestStatusEnum? status,
    int limit = 20,
  }) {
    return local.watchRequests(status: status, limit: limit);
  }

  @override
  Future<Either<Failure, Unit>> refreshRequests({
    RequestStatusEnum? status,
    int page = 1,
  }) async {
    if (!await connectivity.isOnline) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remote.fetchRequests(
        status: status,
        page: page,
        limit: AppConstants.pageSize,
      );
      await local.upsertFromRemote(result.items);
      return const Right(unit);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RequestEntity>> getRequestById(String localId) async {
    try {
      final request = await local.getByLocalId(localId);
      if (request == null) {
        return const Left(CacheFailure('Solicitação não encontrada.'));
      }
      return Right(request);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RequestEntity>> createRequest({
    required String title,
    required String description,
    required RequestCategoryEnum category,
    required RequestPriorityEnum priority,
  }) async {
    try {
      final now = DateTime.now();
      final request = RequestEntity(
        localId: uuid.v4(),
        title: title,
        description: description,
        category: category,
        status: RequestStatusEnum.open,
        priority: priority,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatusEnum.pending,
      );
      await local.upsert(request);
      await syncQueue.enqueueCreate(request);
      return Right(request);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RequestEntity>> updateStatus({
    required String localId,
    required RequestStatusEnum status,
  }) async {
    try {
      final current = await local.getByLocalId(localId);
      if (current == null) {
        return const Left(CacheFailure('Solicitação não encontrada.'));
      }
      final updated = current.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatusEnum.pending,
      );
      await local.upsert(updated);
      await syncQueue.enqueueUpdateStatus(updated);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DescriptionSuggestionEntity>> suggestDescription(
    String title,
  ) async {
    if (!await connectivity.isOnline) {
      return const Left(
        NetworkFailure('A sugestão por IA precisa de internet.'),
      );
    }
    try {
      final suggestion = await ai.suggestDescription(title);
      return Right(suggestion);
    } on NetworkException {
      return const Left(
        NetworkFailure('A sugestão por IA precisa de internet.'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
