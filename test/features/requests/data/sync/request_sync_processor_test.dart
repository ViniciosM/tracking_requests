import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/db/daos/request_dao.dart';
import 'package:tracking_requests/core/db/database.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_operation_type.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/core/error/exceptions.dart';
import 'package:tracking_requests/features/auth/data/sync/request_sync_processor.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_remote_datasource.dart';
import 'package:tracking_requests/features/requests/data/models/request_model.dart';

class MockRequestDao extends Mock implements RequestDao {}

class MockRemote extends Mock implements RequestRemoteDataSource {}

// Arrange
RequestRow row({
  String localId = 'l1',
  String? remoteId,
  RequestStatusEnum status = RequestStatusEnum.open,
}) {
  return RequestRow(
    localId: localId,
    remoteId: remoteId,
    title: 'Title',
    description: 'Description',
    category: RequestCategoryEnum.appointment,
    status: status,
    priority: RequestPriorityEnum.high,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 6, 1),
    syncStatus: SyncStatusEnum.pending,
  );
}

// Arrange
SyncQueueEntry queueEntry(SyncOperationTypeEnum op, {String localId = 'l1'}) {
  return SyncQueueEntry(
    id: 1,
    entityLocalId: localId,
    operationType: op,
    payload: '{"localId":"$localId"}',
    status: SyncStatusEnum.pending,
    retryCount: 0,
    createdAt: DateTime(2026, 6, 1),
  );
}

// Arrange
RequestModel modelWithRemoteId(String id) => RequestModel(
  localId: '',
  remoteId: id,
  title: 'Title',
  description: 'Description',
  category: RequestCategoryEnum.appointment,
  status: RequestStatusEnum.open,
  priority: RequestPriorityEnum.high,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
  syncStatus: SyncStatusEnum.synced,
);

void main() {
  late RequestSyncProcessor processor;
  late MockRequestDao dao;
  late MockRemote remote;

  setUpAll(() {
    registerFallbackValue(modelWithRemoteId('x'));
    registerFallbackValue(RequestStatusEnum.open);
  });

  setUp(() {
    dao = MockRequestDao();
    remote = MockRemote();
    processor = RequestSyncProcessor(requestDao: dao, remote: remote);
  });

  test('create: posts and stores the returned remoteId', () async {
    // Act
    when(() => dao.getByLocalId('l1')).thenAnswer((_) async => row());
    when(
      () => remote.createRequest(any()),
    ).thenAnswer((_) async => modelWithRemoteId('r99'));
    when(
      () => dao.markSynced(any(), remoteId: any(named: 'remoteId')),
    ).thenAnswer((_) async {});

    await processor.process(queueEntry(SyncOperationTypeEnum.create));

    // Assert
    verify(() => remote.createRequest(any())).called(1);
    verify(() => dao.markSynced('l1', remoteId: 'r99')).called(1);
  });

  test(
    'updateStatus: patches using the row remoteId and marks synced',
    () async {
      // Act
      when(() => dao.getByLocalId('l1')).thenAnswer(
        (_) async => row(remoteId: 'r1', status: RequestStatusEnum.resolved),
      );
      when(
        () => remote.updateStatus(
          remoteId: any(named: 'remoteId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => modelWithRemoteId('r1'));
      when(() => dao.markSynced(any())).thenAnswer((_) async {});

      await processor.process(queueEntry(SyncOperationTypeEnum.updateStatus));

      // Assert
      verify(
        () => remote.updateStatus(
          remoteId: 'r1',
          status: RequestStatusEnum.resolved,
        ),
      ).called(1);
      verify(() => dao.markSynced('l1')).called(1);
    },
  );

  test('updateStatus without a remoteId throws so it can retry', () async {
    // Act
    when(
      () => dao.getByLocalId('l1'),
    ).thenAnswer((_) async => row(remoteId: null));

    // Assert
    await expectLater(
      processor.process(queueEntry(SyncOperationTypeEnum.updateStatus)),
      throwsA(isA<ServerException>()),
    );
    verifyNever(
      () => remote.updateStatus(
        remoteId: any(named: 'remoteId'),
        status: any(named: 'status'),
      ),
    );
  });

  test('does nothing when the row was removed locally', () async {
    // Act
    when(() => dao.getByLocalId(any())).thenAnswer((_) async => null);

    await processor.process(queueEntry(SyncOperationTypeEnum.create));

    // Assert
    verifyNever(() => remote.createRequest(any()));
  });
}
