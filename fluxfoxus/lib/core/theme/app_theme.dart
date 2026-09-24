import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_tokens.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// AppTheme builds the locked dark-only ThemeData for FluxFoxus
/// adhering strictly to `ui_design_system.md` and `ff_design_override.md`.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ThemeTokens.background,
      canvasColor: ThemeTokens.surface,
      primaryColor: ThemeTokens.primary,

      colorScheme: const ColorScheme.dark(
        primary: ThemeTokens.primary,
        onPrimary: ThemeTokens.background,
        secondary: ThemeTokens.accent,
        onSecondary: ThemeTokens.background,
        surface: ThemeTokens.surface,
        onSurface: ThemeTokens.textPrimary,
        error: ThemeTokens.danger,
        onError: ThemeTokens.textPrimary,
        outline: ThemeTokens.border,
      ),

      // Flat 2D card surfaces with 1px border and 0 elevation
      cardTheme: const CardThemeData(
        color: ThemeTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: ThemeTokens.border, width: 1.0),
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: ThemeTokens.background,
        ),
        titleTextStyle: AppTypography.heading1(),
      ),

      // Full-pill primary buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primary,
          foregroundColor: ThemeTokens.background,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: GoogleFonts.inter(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outline secondary buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeTokens.textPrimary,
          side: const BorderSide(color: ThemeTokens.accent, width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          textStyle: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ThemeTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.modalTopRadius,
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: ThemeTokens.border,
        thickness: 1.0,
        space: 1.0,
      ),

      // Text Theme with Inter font family
      textTheme: TextTheme(
        displayLarge: AppTypography.display(fontSize: 48),
        displayMedium: AppTypography.display(fontSize: 36),
        displaySmall: AppTypography.display(fontSize: 28),
        headlineLarge: AppTypography.heading1(),
        headlineMedium: AppTypography.heading2(),
        headlineSmall: AppTypography.heading3(),
        bodyLarge: AppTypography.body(),
        bodyMedium: AppTypography.caption(),
        labelSmall: AppTypography.micro(),
      ),
    );
  }
}
