import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/core/db/database.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/data/datasources/request_local_datasource.dart';
import 'package:uuid/uuid.dart';
import '../../../../_fixtures.dart';

void main() {
  late AppDatabase db;
  late RequestLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = RequestLocalDataSourceImpl(
      dao: db.requestDao,
      uuid: const Uuid(),
    );
  });

  tearDown(() => db.close());

  test(
    'upsert then getByLocalId round-trips through the entity mapper',
    () async {
      // Act
      await dataSource.upsert(buildRequest(localId: 'l1'));
      final result = await dataSource.getByLocalId('l1');

      // Assert
      expect(result, isNotNull);
      expect(result!.localId, 'l1');
      expect(result.category, buildRequest().category);
    },
  );

  test('watchRequests maps Drift rows to domain entities', () async {
    // Act
    await dataSource.upsert(buildRequest(localId: 'l1'));
    final emitted = await dataSource.watchRequests().first;

    // Assert
    expect(emitted.single.localId, 'l1');
  });

  test('upsertFromRemote assigns a localId and marks items synced', () async {
    // Arrange
    final remoteItem = buildRequest(
      localId: '',
      remoteId: 'r1',
      syncStatus: SyncStatusEnum.synced,
    );

    // Act
    await dataSource.upsertFromRemote([remoteItem]);
    final all = await dataSource.watchRequests().first;

    // Assert
    expect(all.length, 1);
    expect(all.single.remoteId, 'r1');
    expect(all.single.localId, isNotEmpty);
    expect(all.single.syncStatus, SyncStatusEnum.synced);
  });

  test('upsertFromRemote reconciles by remoteId without duplicating', () async {
    // Arrange
    await dataSource.upsert(
      buildRequest(
        localId: 'existing',
        remoteId: 'r1',
        status: RequestStatusEnum.open,
      ),
    );

    await dataSource.upsertFromRemote([
      buildRequest(
        localId: '',
        remoteId: 'r1',
        status: RequestStatusEnum.resolved,
      ),
    ]);

    // Act
    final all = await dataSource.watchRequests().first;

    // Assert
    expect(all.length, 1); // not duplicated
    expect(all.single.localId, 'existing'); // localId preserved
    expect(all.single.status, RequestStatusEnum.resolved);
  });
}
