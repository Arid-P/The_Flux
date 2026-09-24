import 'package:flutter/material.dart';

/// Corner radius constants for FluxFoxus per `ui_design_system.md`.
class AppRadius {
  AppRadius._();

  static const double card = 8.0;
  static const double flipClockCard = 16.0;
  static const double modalTop = 20.0;
  static const double pill = 28.0;
  static const double smallPill = 6.0;
  static const double badge = 4.0;
  static const double appIcon = 10.0;
  static const double widget = 16.0;

  // Generic scale helpers
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius flipClockRadius = BorderRadius.all(Radius.circular(flipClockCard));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius smallPillRadius = BorderRadius.all(Radius.circular(smallPill));
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(badge));
  static const BorderRadius appIconRadius = BorderRadius.all(Radius.circular(appIcon));
  static const BorderRadius modalTopRadius = BorderRadius.vertical(top: Radius.circular(modalTop));
}
