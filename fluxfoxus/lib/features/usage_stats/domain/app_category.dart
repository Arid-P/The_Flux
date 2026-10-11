import 'package:flutter/material.dart';

/// Categories for apps per TRD §4.7 and PRD Step 12.
enum AppCategory {
  productive('Productive', Color(0xFF4E7D56)),
  semiProductive('Semi-Productive', Color(0xFF906D4B)),
  distracting('Distracting', Color(0xFFC27838)),
  others('Others', Color(0xFF64748B));

  final String displayName;
  final Color color;

  const AppCategory(this.displayName, this.color);

  static AppCategory fromString(String? value) {
    if (value == null) return AppCategory.others;
    switch (value.trim().toLowerCase()) {
      case 'productive':
        return AppCategory.productive;
      case 'semi-productive':
      case 'semiproductive':
        return AppCategory.semiProductive;
      case 'distracting':
        return AppCategory.distracting;
      case 'others':
      default:
        return AppCategory.others;
    }
  }

  String toStorageString() => displayName;
}
