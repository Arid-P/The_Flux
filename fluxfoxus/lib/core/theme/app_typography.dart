import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_tokens.dart';

/// Typography system for FluxFoxus.
/// Strictly implements the scale and font rules defined in `ui_design_system.md`.
class AppTypography {
  AppTypography._();

  /// 48px - 72px, bold, tabular numbers. Used for mechanical flip clock and hero digits.
  static TextStyle display({Color color = ThemeTokens.textPrimary, double fontSize = 48.0}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// 22px, semi-bold. Screen titles, major section headers.
  static TextStyle heading1({Color color = ThemeTokens.textPrimary}) {
    return GoogleFonts.inter(
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: color,
    );
  }

  /// 18px, semi-bold. Card titles, bottom sheet titles.
  static TextStyle heading2({Color color = ThemeTokens.textPrimary}) {
    return GoogleFonts.inter(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color,
    );
  }

  /// 16px, semi-bold. App names, session titles, dialog actions.
  static TextStyle heading3({Color color = ThemeTokens.textPrimary}) {
    return GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: color,
    );
  }

  /// 15px, medium. Body text, descriptions, list rows.
  static TextStyle body({Color color = ThemeTokens.textPrimary}) {
    return GoogleFonts.inter(
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      color: color,
    );
  }

  /// 13px, semi-bold, 0.8px tracking. Section headers, uppercase labels.
  static TextStyle label({Color color = ThemeTokens.textMuted}) {
    return GoogleFonts.inter(
      fontSize: 13.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color,
    );
  }

  /// 12px, medium. Sub-labels, timestamps, status badges.
  static TextStyle caption({Color color = ThemeTokens.textMuted}) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
      color: color,
    );
  }

  /// 11px, medium. Pill labels, micro counters, unit badges.
  static TextStyle micro({Color color = ThemeTokens.textMuted}) {
    return GoogleFonts.inter(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: color,
    );
  }
}
