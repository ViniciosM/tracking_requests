import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.localId,
    super.remoteId,
    required super.title,
    required super.description,
    required super.category,
    required super.status,
    required super.priority,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      localId: '',
      remoteId: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: RequestCategoryEnum.fromApi(json['category'] as String),
      status: RequestStatusEnum.fromApi(json['status'] as String),
      priority: RequestPriorityEnum.fromApi(json['priority'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: SyncStatusEnum.synced,
    );
  }

  factory RequestModel.fromEntity(RequestEntity r) => RequestModel(
    localId: r.localId,
    remoteId: r.remoteId,
    title: r.title,
    description: r.description,
    category: r.category,
    status: r.status,
    priority: r.priority,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    syncStatus: r.syncStatus,
  );

  Map<String, dynamic> toCreateJson() => {
    'title': title,
    'description': description,
    'category': category.apiValue,
    'status': status.apiValue,
    'priority': priority.apiValue,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
