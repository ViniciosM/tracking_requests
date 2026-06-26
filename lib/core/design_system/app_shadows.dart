import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F1C1B2E), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> sheet = [
    BoxShadow(color: Color(0x1F1C1B2E), offset: Offset(0, 8), blurRadius: 24),
  ];
}
