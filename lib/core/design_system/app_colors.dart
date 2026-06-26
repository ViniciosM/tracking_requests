import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Neutrals
  static const Color background = Color(0xFFF6F5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EFF3);
  static const Color border = Color(0xFFE7E5ED);
  static const Color textPrimary = Color(0xFF1C1B2E);
  static const Color textSecondary = Color(0xFF6B6880);
  static const Color textTertiary = Color(0xFF9B98AD);
  static const Color disabled = Color(0xFFC7C4D4);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class AppStatusColors {
  AppStatusColors._();

  static const Color openBg = Color(0xFFDBEAFE);
  static const Color openFg = Color(0xFF1E40AF);
  static const Color inProgressBg = Color(0xFFF1E6FB);
  static const Color inProgressFg = Color(0xFF6D28B5);
  static const Color resolvedBg = Color(0xFFD1FAE5);
  static const Color resolvedFg = Color(0xFF065F46);
  static const Color cancelledBg = Color(0xFFECEAF1);
  static const Color cancelledFg = Color(0xFF5B5870);
}

class AppSyncColors {
  AppSyncColors._();

  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color pendingFg = Color(0xFF92400E);
  static const Color failedBg = Color(0xFFFEE2E2);
  static const Color failedFg = Color(0xFF991B1B);
  static const Color synced = Color(0xFF10B981);
}

class AppPriorityColors {
  AppPriorityColors._();

  static const Color low = Color(0xFF9B98AD);
  static const Color medium = Color(0xFFF59E0B);
  static const Color high = Color(0xFFEF4444);
}
