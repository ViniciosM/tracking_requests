import 'package:flutter/material.dart';

abstract class BrandConfig {
  String get appName;
  String get apiBaseUrl;

  Color get primary;
  Color get primaryDark;
  Color get onPrimary;
  Color get secondary;
  Color get secondaryDark;
  Color get onSecondary;

  IconData get logoIcon;
}

/// Brand A — Vitia Saúde (purple + emerald).
class BrandA implements BrandConfig {
  const BrandA();

  @override
  String get appName => 'Vitia Saúde';
  @override
  String get apiBaseUrl => 'http://10.0.2.2:3000';

  @override
  Color get primary => const Color(0xFF8D47D6);
  @override
  Color get primaryDark => const Color(0xFF6D28B5);
  @override
  Color get onPrimary => const Color(0xFFFFFFFF);
  @override
  Color get secondary => const Color(0xFF10B981);
  @override
  Color get secondaryDark => const Color(0xFF059669);
  @override
  Color get onSecondary => const Color(0xFFFFFFFF);

  @override
  IconData get logoIcon => Icons.monitor_heart_outlined;
}

/// Brand B — Onda Saúde (teal + coral).
class BrandB implements BrandConfig {
  const BrandB();

  @override
  String get appName => 'Onda Saúde';
  @override
  String get apiBaseUrl => 'http://10.0.2.2:3000';

  @override
  Color get primary => const Color(0xFF0EA5A4);
  @override
  Color get primaryDark => const Color(0xFF0C8784);
  @override
  Color get onPrimary => const Color(0xFFFFFFFF);
  @override
  Color get secondary => const Color(0xFFF97316);
  @override
  Color get secondaryDark => const Color(0xFFEA580C);
  @override
  Color get onSecondary => const Color(0xFFFFFFFF);

  @override
  IconData get logoIcon => Icons.waves_outlined;
}
