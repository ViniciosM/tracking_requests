import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'brand_config.dart';

class AppTheme {
  AppTheme._();

  static ThemeData fromBrand(BrandConfig brand) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: brand.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: brand.primary,
          onPrimary: brand.onPrimary,
          secondary: brand.secondary,
          onSecondary: brand.onSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          outline: AppColors.border,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
      ),
    );
  }
}
