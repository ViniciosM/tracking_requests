import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

RequestEntity req({
  String localId = 'l1',
  RequestStatusEnum status = RequestStatusEnum.open,
  SyncStatusEnum syncStatus = SyncStatusEnum.synced,
}) {
  return RequestEntity(
    localId: localId,
    remoteId: 'r1',
    title: 'Reagendar consulta',
    description: 'Preciso reagendar minha consulta de cardiologia.',
    category: RequestCategoryEnum.appointment,
    status: status,
    priority: RequestPriorityEnum.high,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 6, 1),
    syncStatus: syncStatus,
  );
}
