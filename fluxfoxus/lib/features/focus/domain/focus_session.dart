import 'session_status.dart';
import 'timer_mode.dart';

/// Immutable snapshot of a focus session's state and timing.
class FocusSession {
  final String id;
  final String? presetId;
  final String presetName;
  final String presetEmoji;
  final TimerMode timerMode;
  final SessionStatus status;
  final Duration elapsed;
  final Duration? targetDuration;
  final int breaksTotal;
  final int breaksTaken;
  final Duration breakDuration;
  final Duration breakElapsed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? lastResumedAt;
  final DateTime? lastBreakStartedAt;

  const FocusSession({
    required this.id,
    this.presetId,
    this.presetName = 'Focus Session',
    this.presetEmoji = '⚡',
    required this.timerMode,
    required this.status,
    required this.elapsed,
    this.targetDuration,
    required this.breaksTotal,
    required this.breaksTaken,
    this.breakDuration = const Duration(minutes: 5),
    this.breakElapsed = Duration.zero,
    required this.startedAt,
    this.completedAt,
    this.lastResumedAt,
    this.lastBreakStartedAt,
  });

  /// Remaining focus time for countdown mode.
  Duration get remaining {
    if (targetDuration == null) return Duration.zero;
    final r = targetDuration! - elapsed;
    return r.isNegative ? Duration.zero : r;
  }

  /// Remaining break time if on break.
  Duration get breakRemaining {
    final r = breakDuration - breakElapsed;
    return r.isNegative ? Duration.zero : r;
  }

  /// Progress fraction (0.0 to 1.0) for countdown mode.
  double get progress {
    if (targetDuration == null || targetDuration!.inSeconds == 0) return 0.0;
    final frac = elapsed.inSeconds / targetDuration!.inSeconds;
    return frac.clamp(0.0, 1.0);
  }

  /// True if breaks are configured and available to take.
  bool get canTakeBreak => breaksTaken < breaksTotal;

  /// Status convenience getters.
  bool get isPaused => status.isPaused;
  bool get isActive => status.isActive;
  bool get isEnded => status.isEnded;

  /// Clones the session with updated properties.
  FocusSession copyWith({
    String? id,
    String? presetId,
    String? presetName,
    String? presetEmoji,
    TimerMode? timerMode,
    SessionStatus? status,
    Duration? elapsed,
    Duration? targetDuration,
    int? breaksTotal,
    int? breaksTaken,
    Duration? breakDuration,
    Duration? breakElapsed,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastResumedAt,
    DateTime? lastBreakStartedAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      presetName: presetName ?? this.presetName,
      presetEmoji: presetEmoji ?? this.presetEmoji,
      timerMode: timerMode ?? this.timerMode,
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      targetDuration: targetDuration ?? this.targetDuration,
      breaksTotal: breaksTotal ?? this.breaksTotal,
      breaksTaken: breaksTaken ?? this.breaksTaken,
      breakDuration: breakDuration ?? this.breakDuration,
      breakElapsed: breakElapsed ?? this.breakElapsed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
      lastBreakStartedAt: lastBreakStartedAt ?? this.lastBreakStartedAt,
    );
  }

  /// Map serialization for Hive and SQLite persistence.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'preset_id': presetId,
      'preset_name': presetName,
      'preset_emoji': presetEmoji,
      'mode': timerMode.name,
      'status': status.name,
      'elapsed_seconds': elapsed.inSeconds,
      'target_duration_seconds': targetDuration?.inSeconds,
      'breaks_total': breaksTotal,
      'breaks_taken': breaksTaken,
      'break_duration_seconds': breakDuration.inSeconds,
      'break_elapsed_seconds': breakElapsed.inSeconds,
      'started_at': startedAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'last_resumed_at': lastResumedAt?.millisecondsSinceEpoch,
      'last_break_started_at': lastBreakStartedAt?.millisecondsSinceEpoch,
    };
  }

  /// Deserialization from Map.
  factory FocusSession.fromMap(Map<dynamic, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      presetId: map['preset_id'] as String?,
      presetName: (map['preset_name'] as String?) ?? 'Focus Session',
      presetEmoji: (map['preset_emoji'] as String?) ?? '⚡',
      timerMode: TimerMode.fromString(map['mode'] as String?),
      status: SessionStatus.fromString(map['status'] as String?),
      elapsed: Duration(seconds: (map['elapsed_seconds'] as int?) ?? 0),
      targetDuration: map['target_duration_seconds'] != null
          ? Duration(seconds: map['target_duration_seconds'] as int)
          : null,
      breaksTotal: (map['breaks_total'] as int?) ?? 0,
      breaksTaken: (map['breaks_taken'] as int?) ?? 0,
      breakDuration: Duration(
        seconds: (map['break_duration_seconds'] as int?) ?? 300,
      ),
      breakElapsed: Duration(
        seconds: (map['break_elapsed_seconds'] as int?) ?? 0,
      ),
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        map['started_at'] as int,
      ),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      lastResumedAt: map['last_resumed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_resumed_at'] as int)
          : null,
      lastBreakStartedAt: map['last_break_started_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['last_break_started_at'] as int,
            )
          : null,
    );
  }
}
