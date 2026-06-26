import 'package:flutter/material.dart';
import 'package:tracking_requests/core/design_system/utils/enum_visuals.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import '../app_radius.dart';
import '../app_typography.dart';

class StatusChip extends StatelessWidget {
  final RequestStatusEnum status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        status.label,
        style: AppTypography.label.copyWith(
          fontSize: 13,
          color: status.foreground,
        ),
      ),
    );
  }
}
