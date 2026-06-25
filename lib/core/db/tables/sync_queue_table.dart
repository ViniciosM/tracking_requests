import 'package:drift/drift.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import '../../enums/sync_operation_type.dart';

@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityLocalId => text()();
  TextColumn get operationType => textEnum<SyncOperationTypeEnum>()();
  TextColumn get payload => text()();
  TextColumn get status => textEnum<SyncStatusEnum>().withDefault(
    Constant(SyncStatusEnum.pending.name),
  )();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
