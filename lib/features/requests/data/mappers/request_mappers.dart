import 'package:drift/drift.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

import '../../../../core/db/database.dart';

extension RequestRowMapper on RequestRow {
  RequestEntity toEntity() => RequestEntity(
    localId: localId,
    remoteId: remoteId,
    title: title,
    description: description,
    category: category,
    status: status,
    priority: priority,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: syncStatus,
  );
}

extension RequestEntityMapper on RequestEntity {
  RequestsCompanion toCompanion() => RequestsCompanion(
    localId: Value(localId),
    remoteId: Value(remoteId),
    title: Value(title),
    description: Value(description),
    category: Value(category),
    status: Value(status),
    priority: Value(priority),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    syncStatus: Value(syncStatus),
  );
}
