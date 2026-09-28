import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/focus/focus.dart';

void main() {
  group('TimerMode Domain Tests', () {
    test('TimerMode labels match specifications', () {
      expect(TimerMode.countdown.label, 'Countdown');
      expect(TimerMode.stopwatch.label, 'Stopwatch');
      expect(TimerMode.openEnded.label, 'Open Ended');
    });

    test('TimerMode.fromString resolves correctly', () {
      expect(TimerMode.fromString('countdown'), TimerMode.countdown);
      expect(TimerMode.fromString('stopwatch'), TimerMode.stopwatch);
      expect(TimerMode.fromString('openended'), TimerMode.openEnded);
      expect(TimerMode.fromString('open_ended'), TimerMode.openEnded);
      expect(TimerMode.fromString(null), TimerMode.countdown);
    });
  });

  group('SessionStatus Domain Tests', () {
    test('SessionStatus isActive evaluates correctly', () {
      expect(SessionStatus.running.isActive, true);
      expect(SessionStatus.onBreak.isActive, true);
      expect(SessionStatus.paused.isActive, false);
      expect(SessionStatus.idle.isActive, false);
      expect(SessionStatus.completed.isActive, false);
      expect(SessionStatus.abandoned.isActive, false);
    });

    test('SessionStatus isPaused and isEnded evaluate correctly', () {
      expect(SessionStatus.paused.isPaused, true);
      expect(SessionStatus.running.isPaused, false);
      expect(SessionStatus.completed.isEnded, true);
      expect(SessionStatus.abandoned.isEnded, true);
      expect(SessionStatus.running.isEnded, false);
    });

    test('SessionStatus.fromString resolves case-insensitively', () {
      expect(SessionStatus.fromString('running'), SessionStatus.running);
      expect(SessionStatus.fromString('paused'), SessionStatus.paused);
      expect(SessionStatus.fromString('onBreak'), SessionStatus.onBreak);
      expect(SessionStatus.fromString('on_break'), SessionStatus.onBreak);
      expect(SessionStatus.fromString('completed'), SessionStatus.completed);
      expect(SessionStatus.fromString('abandoned'), SessionStatus.abandoned);
      expect(SessionStatus.fromString(null), SessionStatus.idle);
    });
  });

  group('FocusSession Arithmetic & Serialization Tests', () {
    final testStartedAt = DateTime(2026, 3, 28, 9, 0, 0);

    test('remaining returns zero when elapsed exceeds targetDuration', () {
      final session = FocusSession(
        id: 'test_1',
        timerMode: TimerMode.countdown,
        status: SessionStatus.running,
        elapsed: const Duration(minutes: 95),
        targetDuration: const Duration(minutes: 90),
        breaksTotal: 2,
        breaksTaken: 0,
        startedAt: testStartedAt,
      );
      expect(session.remaining, Duration.zero);
      expect(session.progress, 1.0);
    });

    test('remaining and progress calculate exact mid-session values', () {
      final session = FocusSession(
        id: 'test_2',
        timerMode: TimerMode.countdown,
        status: SessionStatus.running,
        elapsed: const Duration(minutes: 45),
        targetDuration: const Duration(minutes: 90),
        breaksTotal: 2,
        breaksTaken: 0,
        startedAt: testStartedAt,
      );
      expect(session.remaining, const Duration(minutes: 45));
      expect(session.progress, 0.5);
    });

    test('breakRemaining returns difference from breakDuration', () {
      final session = FocusSession(
        id: 'test_3',
        timerMode: TimerMode.countdown,
        status: SessionStatus.onBreak,
        elapsed: const Duration(minutes: 30),
        targetDuration: const Duration(minutes: 90),
        breaksTotal: 2,
        breaksTaken: 1,
        breakDuration: const Duration(minutes: 5),
        breakElapsed: const Duration(minutes: 2),
        startedAt: testStartedAt,
      );
      expect(session.breakRemaining, const Duration(minutes: 3));
      expect(session.canTakeBreak, true);
    });

    test('canTakeBreak returns false when breaksTaken reaches breaksTotal', () {
      final session = FocusSession(
        id: 'test_4',
        timerMode: TimerMode.countdown,
        status: SessionStatus.running,
        elapsed: const Duration(minutes: 60),
        targetDuration: const Duration(minutes: 90),
        breaksTotal: 2,
        breaksTaken: 2,
        startedAt: testStartedAt,
      );
      expect(session.canTakeBreak, false);
    });

    test('copyWith updates specified fields and preserves others', () {
      final session = FocusSession(
        id: 'test_5',
        presetName: 'Deep Work',
        timerMode: TimerMode.countdown,
        status: SessionStatus.running,
        elapsed: const Duration(minutes: 10),
        targetDuration: const Duration(minutes: 90),
        breaksTotal: 2,
        breaksTaken: 0,
        startedAt: testStartedAt,
      );

      final updated = session.copyWith(
        status: SessionStatus.paused,
        elapsed: const Duration(minutes: 25),
      );

      expect(updated.id, 'test_5');
      expect(updated.presetName, 'Deep Work');
      expect(updated.status, SessionStatus.paused);
      expect(updated.elapsed, const Duration(minutes: 25));
      expect(updated.breaksTotal, 2);
    });

    test('toMap and fromMap serialize and deserialize faithfully', () {
      final session = FocusSession(
        id: 'sess_123',
        presetId: 'preset_math',
        presetName: 'Math Olympiad',
        presetEmoji: '📐',
        timerMode: TimerMode.countdown,
        status: SessionStatus.running,
        elapsed: const Duration(minutes: 35),
        targetDuration: const Duration(minutes: 120),
        breaksTotal: 3,
        breaksTaken: 1,
        breakDuration: const Duration(minutes: 7),
        breakElapsed: const Duration(seconds: 45),
        startedAt: testStartedAt,
      );

      final map = session.toMap();
      final revived = FocusSession.fromMap(map);

      expect(revived.id, session.id);
      expect(revived.presetId, session.presetId);
      expect(revived.presetName, session.presetName);
      expect(revived.presetEmoji, session.presetEmoji);
      expect(revived.timerMode, session.timerMode);
      expect(revived.status, session.status);
      expect(revived.elapsed, session.elapsed);
      expect(revived.targetDuration, session.targetDuration);
      expect(revived.breaksTotal, session.breaksTotal);
      expect(revived.breaksTaken, session.breaksTaken);
      expect(revived.breakDuration, session.breakDuration);
      expect(revived.breakElapsed, session.breakElapsed);
      expect(revived.startedAt, session.startedAt);
    });
  });
}
