import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _m(
    double size,
    FontWeight weight, {
    double? height,
    double? letterSpacing,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle get display =>
      _m(30, FontWeight.w700, height: 1.15, letterSpacing: -0.6);
  static TextStyle get h1 => _m(24, FontWeight.w600, letterSpacing: -0.24);
  static TextStyle get h2 => _m(20, FontWeight.w600);
  static TextStyle get title => _m(17, FontWeight.w600);
  static TextStyle get bodyLarge => _m(16, FontWeight.w400, height: 1.5);
  static TextStyle get body =>
      _m(14, FontWeight.w400, height: 1.45, color: AppColors.textSecondary);
  static TextStyle get label => _m(14, FontWeight.w600);
  static TextStyle get caption =>
      _m(12, FontWeight.w500, color: AppColors.textTertiary);

  static TextTheme get textTheme => TextTheme(
    displaySmall: display,
    headlineMedium: h1,
    headlineSmall: h2,
    titleLarge: title,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    labelLarge: label,
    bodySmall: caption,
  );
}
