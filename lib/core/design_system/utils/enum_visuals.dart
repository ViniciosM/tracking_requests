import 'package:flutter/material.dart';
import 'package:tracking_requests/core/design_system/app_colors.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';

extension RequestStatusVisuals on RequestStatusEnum {
  String get label => switch (this) {
    RequestStatusEnum.open => 'Aberta',
    RequestStatusEnum.inProgress => 'Em andamento',
    RequestStatusEnum.resolved => 'Resolvida',
    RequestStatusEnum.cancelled => 'Cancelada',
  };

  Color get background => switch (this) {
    RequestStatusEnum.open => AppStatusColors.openBg,
    RequestStatusEnum.inProgress => AppStatusColors.inProgressBg,
    RequestStatusEnum.resolved => AppStatusColors.resolvedBg,
    RequestStatusEnum.cancelled => AppStatusColors.cancelledBg,
  };

  Color get foreground => switch (this) {
    RequestStatusEnum.open => AppStatusColors.openFg,
    RequestStatusEnum.inProgress => AppStatusColors.inProgressFg,
    RequestStatusEnum.resolved => AppStatusColors.resolvedFg,
    RequestStatusEnum.cancelled => AppStatusColors.cancelledFg,
  };
}

extension SyncStatusVisuals on SyncStatusEnum {
  String get label => switch (this) {
    SyncStatusEnum.synced => 'Sincronizado',
    SyncStatusEnum.pending => 'Pendente',
    SyncStatusEnum.failed => 'Falhou',
  };

  Color get background => switch (this) {
    SyncStatusEnum.pending => AppSyncColors.pendingBg,
    SyncStatusEnum.failed => AppSyncColors.failedBg,
    SyncStatusEnum.synced => AppSyncColors.synced,
  };

  Color get foreground => switch (this) {
    SyncStatusEnum.pending => AppSyncColors.pendingFg,
    SyncStatusEnum.failed => AppSyncColors.failedFg,
    SyncStatusEnum.synced => AppSyncColors.synced,
  };

  IconData get icon => switch (this) {
    SyncStatusEnum.pending => Icons.cloud_upload_outlined,
    SyncStatusEnum.failed => Icons.error_outline,
    SyncStatusEnum.synced => Icons.check_circle_outline,
  };
}

extension RequestPriorityVisuals on RequestPriorityEnum {
  String get label => switch (this) {
    RequestPriorityEnum.low => 'Baixa',
    RequestPriorityEnum.medium => 'Média',
    RequestPriorityEnum.high => 'Alta',
  };

  Color get color => switch (this) {
    RequestPriorityEnum.low => AppPriorityColors.low,
    RequestPriorityEnum.medium => AppPriorityColors.medium,
    RequestPriorityEnum.high => AppPriorityColors.high,
  };
}

extension RequestCategoryVisuals on RequestCategoryEnum {
  String get label => switch (this) {
    RequestCategoryEnum.appointment => 'Consulta',
    RequestCategoryEnum.exam => 'Exame',
    RequestCategoryEnum.medication => 'Medicação',
    RequestCategoryEnum.billing => 'Financeiro',
    RequestCategoryEnum.general => 'Geral',
  };

  IconData get icon => switch (this) {
    RequestCategoryEnum.appointment => Icons.event_outlined,
    RequestCategoryEnum.exam => Icons.monitor_heart_outlined,
    RequestCategoryEnum.medication => Icons.medication_outlined,
    RequestCategoryEnum.billing => Icons.receipt_long_outlined,
    RequestCategoryEnum.general => Icons.help_outline,
  };
}
