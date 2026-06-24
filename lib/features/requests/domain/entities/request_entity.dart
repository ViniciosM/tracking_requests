import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';

class RequestEntity extends Equatable {
  final String localId;
  final String? remoteId;
  final String title;
  final String description;
  final RequestCategoryEnum category;
  final RequestStatusEnum status;
  final RequestPriorityEnum priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatusEnum syncStatus;

  const RequestEntity({
    required this.localId,
    this.remoteId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatusEnum.synced,
  });

  bool get isSynced => syncStatus == SyncStatusEnum.synced;
  bool get isPending => syncStatus == SyncStatusEnum.pending;
  bool get hasFailedSync => syncStatus == SyncStatusEnum.failed;

  RequestEntity copyWith({
    String? localId,
    String? remoteId,
    String? title,
    String? description,
    RequestCategoryEnum? category,
    RequestStatusEnum? status,
    RequestPriorityEnum? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatusEnum? syncStatus,
  }) {
    return RequestEntity(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
    localId,
    remoteId,
    title,
    description,
    category,
    status,
    priority,
    createdAt,
    updatedAt,
    syncStatus,
  ];
}
