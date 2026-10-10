import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/focus_session_repository.dart';
import '../data/streak_repository.dart';

/// Status of the daily streak evaluation.
enum StreakEvaluationStatus {
  /// Daily session criteria was met; current streak incremented by 1.
  incremented,

  /// Day has minimumSessionsPerDay = 0; streak preserved without increment.
  neutralDay,

  /// Streak was already incremented for the given date.
  alreadyEvaluated,

  /// Daily session criteria not met; silent non-increment per TRD 5.3.1.
  notMet,
}

/// Detailed result of evaluating a daily streak.
class StreakEvaluationResult {
  final StreakEvaluationStatus status;
  final int currentStreak;
  final int longestStreak;
  final int completedSessions;
  final int requiredSessions;
  final String message;

  const StreakEvaluationResult({
    required this.status,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedSessions,
    required this.requiredSessions,
    required this.message,
  });

  bool get isSuccess => status == StreakEvaluationStatus.incremented;
  bool get isNeutral => status == StreakEvaluationStatus.neutralDay;

  @override
  String toString() =>
      'StreakEvaluationResult(status: $status, streak: $currentStreak, completed: $completedSessions/$requiredSessions, message: $message)';
}

/// Service that evaluates daily focus session completion against streak goals.
///
/// Implements TRD Section 5.3.1.
class StreakEvaluationService {
  final StreakRepository streakRepository;
  final FocusSessionRepository sessionRepository;

  StreakEvaluationService({
    required this.streakRepository,
    required this.sessionRepository,
  });

  /// Evaluates whether the streak should be incremented for [date] (defaults to today).
  Future<StreakEvaluationResult> evaluateDailyStreak({DateTime? date}) async {
    final evalDate = date ?? DateTime.now();
    final record = await streakRepository.getRecord();
    final minimum = record.minimumSessionsPerDay;

    // 1. Streak neutral day: minimum == 0
    if (record.isNeutralDay) {
      return StreakEvaluationResult(
        status: StreakEvaluationStatus.neutralDay,
        currentStreak: record.currentStreak,
        longestStreak: record.longestStreak,
        completedSessions: 0,
        requiredSessions: 0,
        message: 'Streak neutral day (minimumSessionsPerDay is 0). Streak preserved.',
      );
    }

    // 2. Check if already incremented for this date
    if (record.lastStreakDate != null) {
      final last = record.lastStreakDate!;
      if (last.year == evalDate.year &&
          last.month == evalDate.month &&
          last.day == evalDate.day) {
        return StreakEvaluationResult(
          status: StreakEvaluationStatus.alreadyEvaluated,
          currentStreak: record.currentStreak,
          longestStreak: record.longestStreak,
          completedSessions: 0,
          requiredSessions: minimum,
          message: 'Streak already evaluated and updated for this date.',
        );
      }
    }

    // 3. Query sessions completed and scheduled for date
    final completedSessions =
        await sessionRepository.getCompletedForDate(evalDate);
    final scheduledSessions =
        await sessionRepository.getScheduledForDate(evalDate);

    // TRD 5.3.1: required is either scheduled sessions (if fewer than minimum) or minimum
    final required = (scheduledSessions.isNotEmpty && scheduledSessions.length < minimum)
        ? scheduledSessions.length
        : minimum;

    // 4. Evaluate requirement
    if (completedSessions.length >= required && required > 0) {
      await streakRepository.incrementStreak(date: evalDate);
      final updatedRecord = await streakRepository.getRecord();

      return StreakEvaluationResult(
        status: StreakEvaluationStatus.incremented,
        currentStreak: updatedRecord.currentStreak,
        longestStreak: updatedRecord.longestStreak,
        completedSessions: completedSessions.length,
        requiredSessions: required,
        message: 'Goal met! Streak incremented to ${updatedRecord.currentStreak} days.',
      );
    } else {
      // TRD §5.3.1: "streak not broken unless user actively stopped — silent non-increment"
      return StreakEvaluationResult(
        status: StreakEvaluationStatus.notMet,
        currentStreak: record.currentStreak,
        longestStreak: record.longestStreak,
        completedSessions: completedSessions.length,
        requiredSessions: required,
        message:
            'Sessions completed (${completedSessions.length}/$required) below required. Streak retained without increment.',
      );
    }
  }
}

/// Provider for StreakEvaluationService.
final streakEvaluationServiceProvider = Provider<StreakEvaluationService>((ref) {
  final streakRepo = ref.watch(streakRepositoryProvider);
  final sessionRepo = ref.watch(focusSessionRepositoryProvider);

  return StreakEvaluationService(
    streakRepository: streakRepo,
    sessionRepository: sessionRepo,
  );
});
