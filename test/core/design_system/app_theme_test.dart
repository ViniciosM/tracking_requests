import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracking_requests/core/design_system/app_theme.dart';
import 'package:tracking_requests/core/design_system/brand_config.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('Brand A maps its tokens into the theme', () {
    final theme = AppTheme.fromBrand(const BrandA());

    expect(theme.colorScheme.primary, const Color(0xFF8D47D6));
    expect(theme.colorScheme.secondary, const Color(0xFF10B981));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F5F8));
    expect(theme.colorScheme.error, const Color(0xFFEF4444));
  });

  test('Brand B re-themes primary and secondary (whitelabel)', () {
    final a = AppTheme.fromBrand(const BrandA());
    final b = AppTheme.fromBrand(const BrandB());

    expect(b.colorScheme.primary, const Color(0xFF0EA5A4));
    expect(b.colorScheme.secondary, const Color(0xFFF97316));
    expect(a.colorScheme.primary, isNot(b.colorScheme.primary));

    expect(a.scaffoldBackgroundColor, b.scaffoldBackgroundColor);
  });

  test('uses a Montserrat-based text theme', () {
    final theme = AppTheme.fromBrand(const BrandA());

    expect(theme.textTheme.titleLarge, isNotNull);
    expect(theme.textTheme.titleLarge!.fontFamily, contains('Montserrat'));
  });
}
