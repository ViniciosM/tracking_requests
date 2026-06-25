import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/db/database.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/core/error/exceptions.dart';
import 'package:tracking_requests/core/services/connectivity_service.dart';
import 'package:tracking_requests/core/services/sync_service.dart';
import 'package:tracking_requests/features/auth/data/sync/request_sync_processor.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_local_datasource.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_remote_datasource.dart';
import 'package:tracking_requests/features/requests/data/datasources/sync_queue_local_datasource.dart';
import 'package:tracking_requests/features/requests/data/models/request_model.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:uuid/uuid.dart';

class MockRemote extends Mock implements RequestRemoteDataSource {}

class MockConnectivity extends Mock implements ConnectivityService {}

// Arrange
RequestEntity newRequest({
  String localId = 'l1',
  String? remoteId,
  RequestStatusEnum status = RequestStatusEnum.open,
}) {
  return RequestEntity(
    localId: localId,
    remoteId: remoteId,
    title: 'Reagendar consulta',
    description: 'Preciso reagendar minha consulta.',
    category: RequestCategoryEnum.appointment,
    status: status,
    priority: RequestPriorityEnum.high,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 6, 1),
    syncStatus: SyncStatusEnum.pending,
  );
}

// Arrange
RequestModel remoteModel(String id) => RequestModel(
  localId: '',
  remoteId: id,
  title: 'Reagendar consulta',
  description: 'Preciso reagendar minha consulta.',
  category: RequestCategoryEnum.appointment,
  status: RequestStatusEnum.open,
  priority: RequestPriorityEnum.high,
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
  syncStatus: SyncStatusEnum.synced,
);

void main() {
  late AppDatabase db;
  late RequestLocalDataSourceImpl local;
  late SyncQueueLocalDataSourceImpl queue;
  late MockRemote remote;
  late MockConnectivity connectivity;
  late SyncService service;

  setUpAll(() {
    registerFallbackValue(remoteModel('x'));
    registerFallbackValue(RequestStatusEnum.open);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = RequestLocalDataSourceImpl(dao: db.requestDao, uuid: const Uuid());
    queue = SyncQueueLocalDataSourceImpl(db.syncQueueDao);
    remote = MockRemote();
    connectivity = MockConnectivity();
    when(() => connectivity.isOnline).thenAnswer((_) async => true);
    service = SyncService(
      connectivity: connectivity,
      queueDao: db.syncQueueDao,
      processor: RequestSyncProcessor(
        requestDao: db.requestDao,
        remote: remote,
      ),
      maxRetries: 3,
      backoff: (_) => const Duration(hours: 1),
    );
  });

  tearDown(() async {
    await service.dispose();
    await db.close();
  });

  test('create offline then sync: row gets remoteId, queue drains', () async {
    final req = newRequest(remoteId: null);
    await local.upsert(req);
    await queue.enqueueCreate(req);
    when(
      () => remote.createRequest(any()),
    ).thenAnswer((_) async => remoteModel('r99'));

    await service.sync();

    final row = await db.requestDao.getByLocalId('l1');

    // Assert
    expect(row!.remoteId, 'r99');
    expect(row.syncStatus, SyncStatusEnum.synced);
    expect(await db.syncQueueDao.getPending(), isEmpty);
  });

  test(
    'create-before-update: FIFO ordering + remoteId reconciliation',
    () async {
      // Arrange
      final req = newRequest(remoteId: null);

      // Act
      await local.upsert(req);
      await queue.enqueueCreate(req);

      // Arrange
      final updated = req.copyWith(
        status: RequestStatusEnum.resolved,
        syncStatus: SyncStatusEnum.pending,
      );

      // Act
      await local.upsert(updated);
      await queue.enqueueUpdateStatus(updated);

      when(
        () => remote.createRequest(any()),
      ).thenAnswer((_) async => remoteModel('r99'));
      when(
        () => remote.updateStatus(
          remoteId: any(named: 'remoteId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => remoteModel('r99'));

      await service.sync();

      verifyInOrder([
        () => remote.createRequest(any()),
        () => remote.updateStatus(
          remoteId: 'r99',
          status: RequestStatusEnum.resolved,
        ),
      ]);
      final row = await db.requestDao.getByLocalId('l1');

      // Assert
      expect(row!.syncStatus, SyncStatusEnum.synced);
      expect(await db.syncQueueDao.getPending(), isEmpty);
    },
  );

  test(
    'failure keeps the item pending with an incremented retry count',
    () async {
      // Arrange
      final req = newRequest(remoteId: null);

      // Act
      await local.upsert(req);
      await queue.enqueueCreate(req);
      when(
        () => remote.createRequest(any()),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 500));

      await service.sync();

      final pending = await db.syncQueueDao.getPending();

      // Assert
      expect(pending.length, 1);
      expect(pending.single.retryCount, 1);
      expect(pending.single.status, SyncStatusEnum.pending);

      // Act
      final row = await db.requestDao.getByLocalId('l1');

      // Assert
      expect(
        row!.syncStatus,
        SyncStatusEnum.pending,
      ); // unchanged, still pending
    },
  );
}
