import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/database/app_database.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../data/focus_session_repository.dart';
import '../data/streak_repository.dart';
import 'streak_evaluation_service.dart';

/// Background task manager for WorkManager streak evaluation at 11:59 PM.
///
/// Implements TRD Section 1.4 & Section 5.3.1.
class StreakBackgroundWorker {
  const StreakBackgroundWorker._();

  /// Task unique identifier for daily streak evaluation.
  static const String dailyStreakTaskName =
      'com.fluxfoxus.task.evaluate_daily_streak';

  /// Tag for querying or cancelling the task.
  static const String dailyStreakTag = 'fluxfoxus_daily_streak';

  /// Top-level callback dispatcher for Workmanager background execution.
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      if (taskName == dailyStreakTaskName) {
        return await executeStreakEvaluation();
      }
      return Future.value(true);
    });
  }

  /// Hermetic execution routine invoked in background isolates or headless tests.
  static Future<bool> executeStreakEvaluation({
    StreakEvaluationService? serviceOverride,
  }) async {
    try {
      final service = serviceOverride ??
          StreakEvaluationService(
            streakRepository: SqliteStreakRepository(AppDatabase()),
            sessionRepository: FocusSessionRepository(
              appDatabase: AppDatabase(),
              hiveStorageService: HiveStorageService(),
            ),
          );

      final result = await service.evaluateDailyStreak();
      debugPrint('[StreakBackgroundWorker] Evaluation completed: $result');
      return true;
    } catch (e, st) {
      debugPrint('[StreakBackgroundWorker] Evaluation error: $e\n$st');
      return false;
    }
  }

  /// Schedules daily streak evaluation for 11:59 PM (23:59).
  static Future<void> scheduleDailyStreakEvaluation({
    Workmanager? workmanagerOverride,
    DateTime? nowOverride,
  }) async {
    try {
      final wm = workmanagerOverride ?? Workmanager();
      final now = nowOverride ?? DateTime.now();

      // Compute initial delay to 11:59 PM today (or tomorrow if past 11:59 PM)
      var target = DateTime(now.year, now.month, now.day, 23, 59, 0);
      if (now.isAfter(target)) {
        target = target.add(const Duration(days: 1));
      }
      final initialDelay = target.difference(now);

      await wm.registerPeriodicTask(
        dailyStreakTaskName,
        dailyStreakTaskName,
        tag: dailyStreakTag,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelay,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } catch (e) {
      // In non-Android or unit test environments, Workmanager registration fails safely
      debugPrint('[StreakBackgroundWorker] WorkManager registration skipped: $e');
    }
  }

  /// Cancels scheduled daily streak evaluation.
  static Future<void> cancelDailyStreakEvaluation({
    Workmanager? workmanagerOverride,
  }) async {
    try {
      final wm = workmanagerOverride ?? Workmanager();
      await wm.cancelByTag(dailyStreakTag);
    } catch (_) {}
  }
}
