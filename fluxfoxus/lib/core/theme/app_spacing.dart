import 'package:flutter/material.dart';

/// Spacing constants for FluxFoxus.
/// Built on a rigid 4px base grid per `ui_design_system.md`.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;

  /// Standard horizontal screen padding (20px)
  static const double screenHorizontal = 20.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: screenHorizontal);

  /// Standard card internal padding (16px)
  static const double cardInternal = 16.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(cardInternal);

  /// Height of the floating bottom navigation bar (72px)
  static const double bottomNavHeight = 72.0;
}
