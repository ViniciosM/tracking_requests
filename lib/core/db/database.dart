import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tracking_requests/core/db/daos/request_dao.dart';
import 'package:tracking_requests/core/db/daos/sync_queue_dao.dart';
import 'package:tracking_requests/core/db/tables/requests_table.dart';
import 'package:tracking_requests/core/db/tables/sync_queue_table.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_operation_type.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Requests, SyncQueue], daos: [RequestDao, SyncQueueDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'tracking_requests.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
