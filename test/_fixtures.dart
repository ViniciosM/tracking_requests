import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/data/models/request_model.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

RequestEntity buildRequest({
  String localId = 'local-1',
  String? remoteId = 'r1',
  RequestStatusEnum status = RequestStatusEnum.open,
  SyncStatusEnum syncStatus = SyncStatusEnum.synced,
}) {
  return RequestEntity(
    localId: localId,
    remoteId: remoteId,
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

RequestModel buildModel() => RequestModel.fromEntity(buildRequest());

Map<String, dynamic> requestJson({String id = 'r1'}) => {
  'id': id,
  'title': 'Reagendar consulta',
  'description': 'Preciso reagendar minha consulta de cardiologia.',
  'category': 'appointment',
  'status': 'open',
  'priority': 'high',
  'createdAt': '2026-06-01T00:00:00.000',
  'updatedAt': '2026-06-01T00:00:00.000',
};
