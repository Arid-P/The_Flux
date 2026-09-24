import 'package:flutter/material.dart';

/// Centralized token definitions for FluxFoxus (FF).
/// Strictly implements the **Rustic Medley** palette override
/// defined in `ff_design_override.md`.
class ThemeTokens {
  ThemeTokens._();

  // ---------------------------------------------------------------------------
  // Core UI Palette (Rustic Medley)
  // ---------------------------------------------------------------------------
  /// #13191F — River Styx. Main app background.
  static const Color background = Color(0xFF13191F);

  /// #2B2F2E — Carbon Fibre. Cards, sheets, modals, surfaces.
  static const Color surface = Color(0xFF2B2F2E);

  /// #232726 — Elevated Carbon. Subtle elevation surface / distracting category.
  static const Color surfaceElevated = Color(0xFF232726);

  /// #594C3D — Afternoon Tea. Card borders, dividers, subtle outlines.
  static const Color border = Color(0xFF594C3D);

  /// #906D4B — Tanned Wood. Secondary UI elements, break timer display, sub-labels.
  static const Color accent = Color(0xFF906D4B);

  /// #CA9C68 — Amber Autumn. Primary actions, start/stop buttons, active states,
  /// and the mechanical split seam line of the flip-clock.
  static const Color primary = Color(0xFFCA9C68);

  /// #F8FAFC — Ghost White. High-contrast primary text and active numerals.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// #94A3B8 — Muted Slate Grey. Labels, subtitles, secondary captions, disabled state.
  static const Color textMuted = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Semantic Colors
  // ---------------------------------------------------------------------------
  /// #EF4444 — Destructive actions, streak reset warning.
  static const Color danger = Color(0xFFEF4444);

  /// #CA9C68 — Streak display, active focus caution states.
  static const Color warning = Color(0xFFCA9C68);

  /// #4E7D56 — Completed sessions, positive focus status.
  static const Color success = Color(0xFF4E7D56);

  // ---------------------------------------------------------------------------
  // Category Palette (Rustic Medley Aligned)
  // ---------------------------------------------------------------------------
  /// Productive category (Olive / Forest Muted Green)
  static const Color categoryProductive = Color(0xFF4E7D56);

  /// Semi-Productive category (Tanned Wood)
  static const Color categorySemiProductive = Color(0xFF906D4B);

  /// Distracting category (Dark Carbon Slate)
  static const Color categoryDistracting = Color(0xFF232726);

  /// Others category (Neutral Slate Grey)
  static const Color categoryOthers = Color(0xFF94A3B8);
}
