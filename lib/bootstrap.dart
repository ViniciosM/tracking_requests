import 'package:flutter/material.dart';

import 'core/design_system/app_colors.dart';
import 'core/design_system/app_spacing.dart';
import 'core/design_system/app_theme.dart';
import 'core/design_system/app_typography.dart';
import 'core/design_system/brand_config.dart';
import 'core/di/injection.dart';

Future<void> bootstrap(BrandConfig brand) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies(brand: brand);
  runApp(TrackingRequestsApp(brand: brand));
}

class TrackingRequestsApp extends StatelessWidget {
  final BrandConfig brand;
  const TrackingRequestsApp({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: brand.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromBrand(brand),
      // todo: substituir auth e routing
    );
  }
}

class ThemePreview extends StatelessWidget {
  final BrandConfig brand;
  const ThemePreview({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
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
              ),
              child: Icon(brand.logoIcon, color: scheme.onPrimary, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(brand.appName, style: AppTypography.h1),
            const SizedBox(height: AppSpacing.xs),
            Text('Design system pronto', style: AppTypography.body),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}
