import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/theme/theme.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Rustic Medley ThemeTokens Tests', () {
    test('Core UI palette matches ff_design_override.md exact hex values', () {
      expect(ThemeTokens.background, const Color(0xFF13191F));
      expect(ThemeTokens.surface, const Color(0xFF2B2F2E));
      expect(ThemeTokens.surfaceElevated, const Color(0xFF232726));
      expect(ThemeTokens.border, const Color(0xFF594C3D));
      expect(ThemeTokens.accent, const Color(0xFF906D4B));
      expect(ThemeTokens.primary, const Color(0xFFCA9C68));
      expect(ThemeTokens.textPrimary, const Color(0xFFF8FAFC));
      expect(ThemeTokens.textMuted, const Color(0xFF94A3B8));
    });

    test('Dark theme builds with zero elevation and correct scheme', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF13191F));
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, const Color(0xFF2B2F2E));
      expect(theme.colorScheme.primary, const Color(0xFFCA9C68));
      expect(theme.colorScheme.secondary, const Color(0xFF906D4B));
    });

    test('Spacing base grid constants are multiples of 4', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.s, 8.0);
      expect(AppSpacing.m, 12.0);
      expect(AppSpacing.l, 16.0);
      expect(AppSpacing.xl, 20.0);
      expect(AppSpacing.screenHorizontal, 20.0);
      expect(AppSpacing.bottomNavHeight, 72.0);
    });

    test('Radius constants match ui_design_system.md specifications', () {
      expect(AppRadius.card, 8.0);
      expect(AppRadius.flipClockCard, 16.0);
      expect(AppRadius.pill, 28.0);
      expect(AppRadius.modalTop, 20.0);
    });
  });
}
