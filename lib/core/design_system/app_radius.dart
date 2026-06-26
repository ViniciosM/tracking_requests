import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double button = 12;
  static const double input = 12;
  static const double card = 16;
  static const double sheet = 20;
  static const double pill = 999;

  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius sheetTopRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );
}
