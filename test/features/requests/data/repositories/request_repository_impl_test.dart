import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/core/error/exceptions.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/services/connectivity_service.dart';
import 'package:tracking_requests/features/requests/data/datasources/ai_remote_datasource.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_local_datasource.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_remote_datasource.dart';
import 'package:tracking_requests/features/requests/data/datasources/sync_queue_local_datasource.dart';
import 'package:tracking_requests/features/requests/data/models/description_suggestion_model.dart';
import 'package:tracking_requests/features/requests/data/repositories/request_repository_impl.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:uuid/uuid.dart';

import '../../../../_fixtures.dart';

class MockRemote extends Mock implements RequestRemoteDataSource {}

class MockLocal extends Mock implements RequestLocalDataSource {}

class MockSyncQueue extends Mock implements SyncQueueLocalDataSource {}

class MockAi extends Mock implements AiRemoteDataSource {}

class MockConnectivity extends Mock implements ConnectivityService {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late RequestRepositoryImpl repository;
  late MockRemote remote;
  late MockLocal local;
  late MockSyncQueue syncQueue;
  late MockAi ai;
  late MockConnectivity connectivity;
  late MockUuid uuid;

  setUpAll(() {
    registerFallbackValue(buildRequest());
    registerFallbackValue(<RequestEntity>[]);
    registerFallbackValue(RequestStatusEnum.open);
  });

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    syncQueue = MockSyncQueue();
    ai = MockAi();
    connectivity = MockConnectivity();
    uuid = MockUuid();
    repository = RequestRepositoryImpl(
      remote: remote,
      local: local,
      syncQueue: syncQueue,
      ai: ai,
      connectivity: connectivity,
      uuid: uuid,
    );
  });

  group('watchRequests', () {
    test('delegates to the local reactive stream', () {
      // Arrange
      final items = [buildRequest()];

      // Act
      when(
        () => local.watchRequests(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value(items));

      // Assert
      expect(repository.watchRequests(), emits(items));
    });
  });

  group('createRequest (optimistic)', () {
    test('persists as pending, enqueues, and returns immediately', () async {
      // Act
      when(() => uuid.v4()).thenReturn('local-new');
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => syncQueue.enqueueCreate(any())).thenAnswer((_) async {});

      final result = await repository.createRequest(
        title: 'Reagendar',
        description: 'Descrição suficientemente longa.',
        category: RequestCategoryEnum.exam,
        priority: RequestPriorityEnum.low,
      );

      // Arrange
      final created = result.getOrElse(() => buildRequest());

      // Assert
      expect(created.localId, 'local-new');
      expect(created.status, RequestStatusEnum.open);
      expect(created.syncStatus, SyncStatusEnum.pending);

      // Act
      final persisted =
          verify(() => local.upsert(captureAny())).captured.single
              as RequestEntity;

      // Assert
      expect(persisted.syncStatus, SyncStatusEnum.pending);
      verify(() => syncQueue.enqueueCreate(any())).called(1);
      verifyNever(() => connectivity.isOnline);
    });
  });

  group('updateStatus (optimistic)', () {
    test('loads current, persists pending, enqueues', () async {
      // Assert
      final current = buildRequest(
        localId: 'l1',
        status: RequestStatusEnum.open,
      );

      // Act
      when(() => local.getByLocalId('l1')).thenAnswer((_) async => current);
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => syncQueue.enqueueUpdateStatus(any())).thenAnswer((_) async {});

      final result = await repository.updateStatus(
        localId: 'l1',
        status: RequestStatusEnum.resolved,
      );

      final updated = result.getOrElse(() => buildRequest());

      // Assert
      expect(updated.status, RequestStatusEnum.resolved);
      expect(updated.syncStatus, SyncStatusEnum.pending);
      verify(() => syncQueue.enqueueUpdateStatus(any())).called(1);
    });

    test('returns CacheFailure and does not enqueue when missing', () async {
      // Act
      when(() => local.getByLocalId(any())).thenAnswer((_) async => null);

      final result = await repository.updateStatus(
        localId: 'missing',
        status: RequestStatusEnum.resolved,
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('left'));
      verifyNever(() => syncQueue.enqueueUpdateStatus(any()));
    });
  });

  group('refreshRequests', () {
    test('returns NetworkFailure and skips the network when offline', () async {
      // Act
      when(() => connectivity.isOnline).thenAnswer((_) async => false);

      final result = await repository.refreshRequests();

      // Assert
      expect(result, const Left(NetworkFailure()));
      verifyNever(
        () => remote.fetchRequests(
          status: any(named: 'status'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('fetches a page and upserts it into the cache when online', () async {
      // Act
      when(() => connectivity.isOnline).thenAnswer((_) async => true);
      when(
        () => remote.fetchRequests(
          status: any(named: 'status'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => PaginatedRequests(items: [buildModel()], totalCount: 1),
      );
      when(() => local.upsertFromRemote(any())).thenAnswer((_) async {});

      final result = await repository.refreshRequests(page: 1);

      // Assert
      expect(result, const Right(unit));
      verify(() => local.upsertFromRemote(any())).called(1);
    });

    test('maps a ServerException to ServerFailure', () async {
      // Act
      when(() => connectivity.isOnline).thenAnswer((_) async => true);
      when(
        () => remote.fetchRequests(
          status: any(named: 'status'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 500));

      final result = await repository.refreshRequests();

      // Assert
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect((f as ServerFailure).statusCode, 500);
      }, (_) => fail('Expected a Left'));
    });
  });

  group('getRequestById', () {
    test('returns the request when found', () async {
      // Assert
      final r = buildRequest(localId: 'l1');

      // Act
      when(() => local.getByLocalId('l1')).thenAnswer((_) async => r);

      final result = await repository.getRequestById('l1');

      // Assert
      expect(result, Right<Failure, RequestEntity>(r));
    });

    test('returns CacheFailure when not found', () async {
      // Act
      when(() => local.getByLocalId(any())).thenAnswer((_) async => null);

      final result = await repository.getRequestById('x');

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  group('suggestDescription', () {
    test('returns NetworkFailure and skips the LLM when offline', () async {
      // Act
      when(() => connectivity.isOnline).thenAnswer((_) async => false);

      final result = await repository.suggestDescription('Reagendar consulta');

      // Assert
      expect(result.isLeft(), isTrue);
      verifyNever(() => ai.suggestDescription(any()));
    });

    test('delegates to the AI data source when online', () async {
      // Arrange
      const suggestion = DescriptionSuggestionModel(
        description: 'Gostaria de reagendar minha consulta.',
      );

      // Act
      when(() => connectivity.isOnline).thenAnswer((_) async => true);
      when(
        () => ai.suggestDescription(any()),
      ).thenAnswer((_) async => suggestion);

      final result = await repository.suggestDescription('Reagendar consulta');

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => ai.suggestDescription('Reagendar consulta')).called(1);
    });
  });
}
