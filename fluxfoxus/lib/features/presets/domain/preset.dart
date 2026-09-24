import '../../../core/database/database_tables.dart';
import 'youtube_mode.dart';

/// Preset represents a focus session template per TRD Section 4.1.
class Preset {
  final String id;
  final String name;
  final String emoji;
  final int breakCount;
  final int breakDurationMinutes;
  final YouTubeMode youtubeMode;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Preset({
    required this.id,
    required this.name,
    this.emoji = '⏳',
    this.breakCount = 0,
    this.breakDurationMinutes = 5,
    this.youtubeMode = YouTubeMode.studyMode,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colPresetId: id,
      DatabaseTables.colPresetName: name,
      DatabaseTables.colPresetEmoji: emoji,
      DatabaseTables.colPresetBreakCount: breakCount,
      DatabaseTables.colPresetBreakDuration: breakDurationMinutes,
      DatabaseTables.colPresetYoutubeMode: youtubeMode.value,
      DatabaseTables.colPresetDescription: description,
      DatabaseTables.colPresetCreatedAt: createdAt.millisecondsSinceEpoch ~/ 1000,
      DatabaseTables.colPresetUpdatedAt: updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  factory Preset.fromMap(Map<String, dynamic> map) {
    return Preset(
      id: map[DatabaseTables.colPresetId] as String,
      name: map[DatabaseTables.colPresetName] as String,
      emoji: (map[DatabaseTables.colPresetEmoji] as String?) ?? '⏳',
      breakCount: (map[DatabaseTables.colPresetBreakCount] as int?) ?? 0,
      breakDurationMinutes: (map[DatabaseTables.colPresetBreakDuration] as int?) ?? 5,
      youtubeMode: YouTubeMode.fromString(
        (map[DatabaseTables.colPresetYoutubeMode] as String?) ?? 'study_mode',
      ),
      description: map[DatabaseTables.colPresetDescription] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        ((map[DatabaseTables.colPresetCreatedAt] as int?) ?? 0) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        ((map[DatabaseTables.colPresetUpdatedAt] as int?) ?? 0) * 1000,
      ),
    );
  }

  Preset copyWith({
    String? id,
    String? name,
    String? emoji,
    int? breakCount,
    int? breakDurationMinutes,
    YouTubeMode? youtubeMode,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      breakCount: breakCount ?? this.breakCount,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      youtubeMode: youtubeMode ?? this.youtubeMode,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
