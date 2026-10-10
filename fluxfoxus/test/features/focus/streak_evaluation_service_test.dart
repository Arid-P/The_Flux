import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/focus/data/focus_session_repository.dart';
import 'package:fluxfoxus/features/focus/data/streak_repository.dart';
import 'package:fluxfoxus/features/focus/domain/focus_session.dart';
import 'package:fluxfoxus/features/focus/domain/session_status.dart';
import 'package:fluxfoxus/features/focus/domain/timer_mode.dart';
import 'package:fluxfoxus/features/focus/services/streak_background_worker.dart';
import 'package:fluxfoxus/features/focus/services/streak_evaluation_service.dart';

void main() {
  late FakeStreakRepository streakRepo;
  late FakeFocusSessionRepository sessionRepo;
  late StreakEvaluationService service;

  setUp(() {
    streakRepo = FakeStreakRepository(initialStreak: 5, longestStreak: 10, minimumSessionsPerDay: 1);
    sessionRepo = FakeFocusSessionRepository();
    service = StreakEvaluationService(
      streakRepository: streakRepo,
      sessionRepository: sessionRepo,
    );
  });

  FocusSession createSession({
    required String id,
    required SessionStatus status,
    required DateTime date,
  }) {
    return FocusSession(
      id: id,
      presetName: 'Deep Work',
      presetEmoji: '⚡',
      timerMode: TimerMode.countdown,
      status: status,
      elapsed: const Duration(minutes: 60),
      targetDuration: const Duration(minutes: 60),
      breaksTotal: 1,
      breaksTaken: 0,
      breakDuration: const Duration(minutes: 5),
      startedAt: date,
      completedAt: date.add(const Duration(minutes: 60)),
    );
  }

  group('StreakEvaluationService Tests (TRD Section 5.3.1)', () {
    test('Increments streak when today completed sessions meet minimum', () async {
      final today = DateTime(2026, 3, 25, 18, 0);

      // Add 1 completed session for today
      sessionRepo.finished.add(createSession(
        id: 's1',
        status: SessionStatus.completed,
        date: today,
      ));

      final result = await service.evaluateDailyStreak(date: today);

      expect(result.status, StreakEvaluationStatus.incremented);
      expect(result.currentStreak, 6);
      expect(await streakRepo.getCurrentStreak(), 6);
      expect((await streakRepo.getRecord()).lastStreakDate, today);
    });

    test('Preserves streak on neutral days when minimumSessionsPerDay is 0', () async {
      final today = DateTime(2026, 3, 25, 18, 0);
      await streakRepo.setMinimumSessionsPerDay(0);

      final result = await service.evaluateDailyStreak(date: today);

      expect(result.status, StreakEvaluationStatus.neutralDay);
      expect(result.currentStreak, 5);
      expect(await streakRepo.getCurrentStreak(), 5);
    });

    test('Scales required sessions when scheduled sessions are fewer than minimum', () async {
      final today = DateTime(2026, 3, 25, 10, 0);
      await streakRepo.setMinimumSessionsPerDay(3);

      // Only 1 session scheduled for today
      sessionRepo.scheduled.add(createSession(
        id: 'scheduled_1',
        status: SessionStatus.completed,
        date: today,
      ));

      // 1 session completed
      sessionRepo.finished.add(createSession(
        id: 'comp_1',
        status: SessionStatus.completed,
        date: today,
      ));

      final result = await service.evaluateDailyStreak(date: today);

      // Required was scaled from 3 to 1 scheduled session
      expect(result.requiredSessions, 1);
      expect(result.status, StreakEvaluationStatus.incremented);
      expect(result.currentStreak, 6);
    });

    test('Does not increment twice on same calendar date', () async {
      final today = DateTime(2026, 3, 25, 20, 0);
      sessionRepo.finished.add(createSession(
        id: 's1',
        status: SessionStatus.completed,
        date: today,
      ));

      // First evaluation increments
      final res1 = await service.evaluateDailyStreak(date: today);
      expect(res1.status, StreakEvaluationStatus.incremented);

      // Second evaluation on same day detects already evaluated
      final res2 = await service.evaluateDailyStreak(date: today);
      expect(res2.status, StreakEvaluationStatus.alreadyEvaluated);
      expect(await streakRepo.getCurrentStreak(), 6);
    });

    test('Silent non-increment when criteria not met without breaking streak', () async {
      final today = DateTime(2026, 3, 25, 20, 0);
      await streakRepo.setMinimumSessionsPerDay(2);

      // Only 1 session completed (required is 2)
      sessionRepo.finished.add(createSession(
        id: 's1',
        status: SessionStatus.completed,
        date: today,
      ));

      final result = await service.evaluateDailyStreak(date: today);

      expect(result.status, StreakEvaluationStatus.notMet);
      expect(result.completedSessions, 1);
      expect(result.requiredSessions, 2);
      // TRD 5.3.1: Streak is NOT broken unless user actively stopped session
      expect(await streakRepo.getCurrentStreak(), 5);
    });
  });

  group('StreakBackgroundWorker Tests', () {
    test('executeStreakEvaluation succeeds with service override', () async {
      final success = await StreakBackgroundWorker.executeStreakEvaluation(
        serviceOverride: service,
      );
      expect(success, isTrue);
    });
  });
}
