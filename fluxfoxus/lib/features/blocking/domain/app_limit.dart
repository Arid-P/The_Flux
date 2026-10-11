import '../../../core/database/database_tables.dart';

/// Domain model representing an App Limit per TRD §5.2 and PRD Step 13.
class AppLimit {
  final String packageName;
  final String appName;
  final String category;
  final int dailyLimitSeconds;
  final int extraSessionCount;
  final int extraSessionDurationSeconds;
  final bool isActive;
  final DateTime? pausedUntil;
  final int streakDays;
  final DateTime createdAt;

  const AppLimit({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.dailyLimitSeconds,
    this.extraSessionCount = 0,
    this.extraSessionDurationSeconds = 300,
    this.isActive = true,
    this.pausedUntil,
    this.streakDays = 0,
    required this.createdAt,
  });

  bool get isPaused => pausedUntil != null && pausedUntil!.isAfter(DateTime.now());

  AppLimit copyWith({
    String? packageName,
    String? appName,
    String? category,
    int? dailyLimitSeconds,
    int? extraSessionCount,
    int? extraSessionDurationSeconds,
    bool? isActive,
    DateTime? pausedUntil,
    bool clearPausedUntil = false,
    int? streakDays,
    DateTime? createdAt,
  }) {
    return AppLimit(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      category: category ?? this.category,
      dailyLimitSeconds: dailyLimitSeconds ?? this.dailyLimitSeconds,
      extraSessionCount: extraSessionCount ?? this.extraSessionCount,
      extraSessionDurationSeconds: extraSessionDurationSeconds ?? this.extraSessionDurationSeconds,
      isActive: isActive ?? this.isActive,
      pausedUntil: clearPausedUntil ? null : (pausedUntil ?? this.pausedUntil),
      streakDays: streakDays ?? this.streakDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colLimitPackageName: packageName,
      DatabaseTables.colLimitAppName: appName,
      DatabaseTables.colLimitCategory: category,
      DatabaseTables.colLimitDailySeconds: dailyLimitSeconds,
      DatabaseTables.colLimitExtraSessionCount: extraSessionCount,
      DatabaseTables.colLimitExtraSessionDuration: extraSessionDurationSeconds,
      DatabaseTables.colLimitIsActive: isActive ? 1 : 0,
      DatabaseTables.colLimitPausedUntil: pausedUntil?.millisecondsSinceEpoch,
      DatabaseTables.colLimitStreakDays: streakDays,
      DatabaseTables.colLimitCreatedAt: createdAt.millisecondsSinceEpoch,
    };
  }

  factory AppLimit.fromMap(Map<String, dynamic> map) {
    final pausedEpoch = map[DatabaseTables.colLimitPausedUntil] as int?;
    return AppLimit(
      packageName: map[DatabaseTables.colLimitPackageName] as String,
      appName: map[DatabaseTables.colLimitAppName] as String,
      category: map[DatabaseTables.colLimitCategory] as String,
      dailyLimitSeconds: (map[DatabaseTables.colLimitDailySeconds] as int?) ?? 1800,
      extraSessionCount: (map[DatabaseTables.colLimitExtraSessionCount] as int?) ?? 0,
      extraSessionDurationSeconds: (map[DatabaseTables.colLimitExtraSessionDuration] as int?) ?? 300,
      isActive: (map[DatabaseTables.colLimitIsActive] as int? ?? 1) == 1,
      pausedUntil: pausedEpoch != null ? DateTime.fromMillisecondsSinceEpoch(pausedEpoch) : null,
      streakDays: (map[DatabaseTables.colLimitStreakDays] as int?) ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[DatabaseTables.colLimitCreatedAt] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
