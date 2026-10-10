import '../../../core/database/database_tables.dart';

/// Domain entity representing a user's focus streak record.
///
/// Implements TRD Section 4.5 (`streak_records` table) and Section 5.3 (Streak Engine).
class StreakRecord {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final int minimumSessionsPerDay;
  final DateTime? lastStreakDate;
  final DateTime updatedAt;

  const StreakRecord({
    this.id = 1,
    required this.currentStreak,
    required this.longestStreak,
    this.minimumSessionsPerDay = 1,
    this.lastStreakDate,
    required this.updatedAt,
  });

  /// A day where minimumSessionsPerDay is 0 is considered a streak neutral day.
  /// On neutral days, not completing focus sessions will not break or alter the streak.
  bool get isNeutralDay => minimumSessionsPerDay == 0;

  StreakRecord copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    int? minimumSessionsPerDay,
    DateTime? lastStreakDate,
    DateTime? updatedAt,
  }) {
    return StreakRecord(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      minimumSessionsPerDay:
          minimumSessionsPerDay ?? this.minimumSessionsPerDay,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colStreakId: id,
      DatabaseTables.colStreakCurrent: currentStreak,
      DatabaseTables.colStreakLongest: longestStreak,
      DatabaseTables.colStreakMinSessionsPerDay: minimumSessionsPerDay,
      DatabaseTables.colStreakLastDate:
          lastStreakDate?.millisecondsSinceEpoch,
      DatabaseTables.colStreakUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  factory StreakRecord.fromMap(Map<String, dynamic> map) {
    return StreakRecord(
      id: (map[DatabaseTables.colStreakId] as num?)?.toInt() ?? 1,
      currentStreak:
          (map[DatabaseTables.colStreakCurrent] as num?)?.toInt() ?? 0,
      longestStreak:
          (map[DatabaseTables.colStreakLongest] as num?)?.toInt() ?? 0,
      minimumSessionsPerDay:
          (map[DatabaseTables.colStreakMinSessionsPerDay] as num?)?.toInt() ??
              1,
      lastStreakDate: map[DatabaseTables.colStreakLastDate] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map[DatabaseTables.colStreakLastDate] as num).toInt(),
            )
          : null,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map[DatabaseTables.colStreakUpdatedAt] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Default initial record when no streak history exists.
  factory StreakRecord.initial() {
    final now = DateTime.now();
    return StreakRecord(
      id: 1,
      currentStreak: 0,
      longestStreak: 0,
      minimumSessionsPerDay: 1,
      lastStreakDate: null,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          minimumSessionsPerDay == other.minimumSessionsPerDay &&
          lastStreakDate == other.lastStreakDate;

  @override
  int get hashCode =>
      id.hashCode ^
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      minimumSessionsPerDay.hashCode ^
      lastStreakDate.hashCode;

  @override
  String toString() =>
      'StreakRecord(id: $id, current: $currentStreak, longest: $longestStreak, minSessions: $minimumSessionsPerDay, lastDate: $lastStreakDate)';
}
