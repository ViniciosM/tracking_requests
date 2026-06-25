import 'package:drift/drift.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';

@DataClassName('RequestRow')
class Requests extends Table {
  TextColumn get localId => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => textEnum<RequestCategoryEnum>()();
  TextColumn get status => textEnum<RequestStatusEnum>()();
  TextColumn get priority => textEnum<RequestPriorityEnum>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => textEnum<SyncStatusEnum>().withDefault(
    Constant(SyncStatusEnum.synced.name),
  )();

  @override
  Set<Column> get primaryKey => {localId};
}
