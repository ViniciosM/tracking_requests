import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(46),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: Color(0xFF92400E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você está offline — alterações serão sincronizadas',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
