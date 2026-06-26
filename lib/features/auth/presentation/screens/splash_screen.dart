import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/injection.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = getIt<BrandConfig>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withAlpha(102),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(brand.logoIcon, color: scheme.onPrimary, size: 36),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(brand.appName, style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
