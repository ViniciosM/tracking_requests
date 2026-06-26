import 'package:flutter/material.dart';

import '../app_typography.dart';
import '../app_colors.dart';

class SyncStatusIndicator extends StatelessWidget {
  final int pendingCount;
  const SyncStatusIndicator({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (pendingCount == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 6),
          Text(
            'Tudo sincronizado',
            style: AppTypography.caption.copyWith(color: AppColors.success),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withBlue(10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Sincronizando… $pendingCount '
            '${pendingCount == 1 ? "pendente" : "pendentes"}',
            style: AppTypography.label.copyWith(fontSize: 13, color: primary),
          ),
        ],
      ),
    );
  }
}
