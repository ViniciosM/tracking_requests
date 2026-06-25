import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/core/db/daos/request_dao.dart';
import 'package:tracking_requests/core/db/database.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';

import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';

void main() {
  late AppDatabase db;
  late RequestDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.requestDao;
  });

  tearDown(() => db.close());

  RequestsCompanion build(
    String localId, {
    RequestStatusEnum status = RequestStatusEnum.open,
    DateTime? createdAt,
  }) {
    final ts = createdAt ?? DateTime(2026, 1, 1);
    return RequestsCompanion.insert(
      localId: localId,
      title: 'Title $localId',
      description: 'Description $localId',
      category: RequestCategoryEnum.exam,
      status: status,
      priority: RequestPriorityEnum.low,
      createdAt: ts,
      updatedAt: ts,
    );
  }

  test(
    'upserts and reads a row back, defaulting syncStatus to synced',
    () async {
      // Arrange
      await dao.upsert(build('l1'));

      // Act
      final row = await dao.getByLocalId('l1');

      // Assert
      //expect(row, isNotNull);
      expect(row!.title, 'Title l1');
      expect(row.syncStatus, SyncStatusEnum.synced);
    },
  );

  test('watchRequests filters by status', () async {
    // Arrange
    await dao.upsert(build('l1', status: RequestStatusEnum.open));
    await dao.upsert(build('l2', status: RequestStatusEnum.resolved));

    // Act
    final open = await dao.watchRequests(status: RequestStatusEnum.open).first;

    // Assert
    expect(open.map((r) => r.localId), ['l1']);
  });

  test(
    'watchRequests orders by createdAt desc and respects the limit',
    () async {
      // Arrange
      await dao.upsert(build('old', createdAt: DateTime(2026, 1, 1)));
      await dao.upsert(build('new', createdAt: DateTime(2026, 2, 1)));

      // Act
      final rows = await dao.watchRequests(limit: 1).first;

      // Assert
      expect(rows.single.localId, 'new');
    },
  );

  test(
    'upsert on an existing localId updates instead of duplicating',
    () async {
      // Arrange
      await dao.upsert(build('l1', status: RequestStatusEnum.open));
      await dao.upsert(build('l1', status: RequestStatusEnum.resolved));

      // Act
      final all = await dao.watchRequests().first;

      // Assert
      expect(all.length, 1);
      expect(all.single.status, RequestStatusEnum.resolved);
    },
  );
}
