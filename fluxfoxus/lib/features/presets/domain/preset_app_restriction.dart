import '../../../core/database/database_tables.dart';

/// PresetAppRestriction represents an individual app blocking rule within a preset.
class PresetAppRestriction {
  final String presetId;
  final String packageName;
  final bool isBlocked;

  const PresetAppRestriction({
    required this.presetId,
    required this.packageName,
    this.isBlocked = true,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colRestrictionPresetId: presetId,
      DatabaseTables.colRestrictionPackageName: packageName,
      DatabaseTables.colRestrictionIsBlocked: isBlocked ? 1 : 0,
    };
  }

  factory PresetAppRestriction.fromMap(Map<String, dynamic> map) {
    return PresetAppRestriction(
      presetId: map[DatabaseTables.colRestrictionPresetId] as String,
      packageName: map[DatabaseTables.colRestrictionPackageName] as String,
      isBlocked: (map[DatabaseTables.colRestrictionIsBlocked] as int) == 1,
    );
  }

  PresetAppRestriction copyWith({
    String? presetId,
    String? packageName,
    bool? isBlocked,
  }) {
    return PresetAppRestriction(
      presetId: presetId ?? this.presetId,
      packageName: packageName ?? this.packageName,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
