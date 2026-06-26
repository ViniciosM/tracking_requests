import 'package:flutter/material.dart';
import 'package:tracking_requests/core/design_system/utils/enum_visuals.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import '../app_radius.dart';
import '../app_typography.dart';

class SyncBadge extends StatelessWidget {
  final SyncStatusEnum status;
  const SyncBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatusEnum.synced) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.foreground),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTypography.caption.copyWith(color: status.foreground),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: status.foreground),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: AppTypography.label.copyWith(
              fontSize: 12,
              color: status.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
