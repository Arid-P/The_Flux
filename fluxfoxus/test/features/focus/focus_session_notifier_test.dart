import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/storage/hive_storage_service.dart';
import 'package:fluxfoxus/features/focus/focus.dart';

class _FakeForegroundService implements ForegroundTimerService {
  bool running = false;
  String? lastTitle;
  String? lastText;

  @override
  Future<void> init() async {}

  @override
  Future<bool> startService({required String title, required String text}) async {
    running = true;
    lastTitle = title;
    lastText = text;
    return true;
  }

  @override
  Future<void> updateService({required String title, required String text}) async {
    lastTitle = title;
    lastText = text;
  }

  @override
  Future<bool> stopService() async {
    running = false;
    return true;
  }

  @override
  Future<bool> get isRunning async => running;
}

class _FakeFocusSessionRepository extends FocusSessionRepository {
  FocusSession? active;
  final List<FocusSession> finished = [];

  _FakeFocusSessionRepository()
      : super(
          appDatabase: AppDatabase(),
          hiveStorageService: HiveStorageService(),
        );

  @override
  FocusSession? getActiveSession() => active;

  @override
  Future<void> saveActiveSession(FocusSession session) async {
    active = session;
  }

  @override
  Future<void> clearActiveSession() async {
    active = null;
  }

  @override
  Future<void> recordFinishedSession(FocusSession session) async {
    finished.add(session);
  }
}

void main() {
  late _FakeForegroundService fakeForeground;
  late _FakeFocusSessionRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeForeground = _FakeForegroundService();
    fakeRepo = _FakeFocusSessionRepository();
    container = ProviderContainer(
      overrides: [
        foregroundTimerServiceProvider.overrideWithValue(fakeForeground),
        focusSessionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FocusSessionNotifier State Machine Tests', () {
    test('startSession initializes running session and updates services', () async {
      final notifier = container.read(focusSessionProvider.notifier);

      await notifier.startSession(
        presetId: 'preset_deep',
        presetName: 'Deep Work',
        presetEmoji: '🎯',
        timerMode: TimerMode.countdown,
        targetDuration: const Duration(minutes: 60),
        breaksTotal: 2,
        breakDuration: const Duration(minutes: 5),
      );

      final state = container.read(focusSessionProvider);
      expect(state, isNotNull);
      expect(state!.presetName, 'Deep Work');
      expect(state.presetEmoji, '🎯');
      expect(state.status, SessionStatus.running);
      expect(state.targetDuration, const Duration(minutes: 60));
      expect(state.remaining, const Duration(minutes: 60));
      expect(state.breaksTotal, 2);
      expect(state.breaksTaken, 0);

      expect(fakeRepo.active?.id, state.id);
      expect(fakeForeground.running, true);
    });

    test('pauseSession transitions running session to paused', () async {
      final notifier = container.read(focusSessionProvider.notifier);

      await notifier.startSession(
        presetName: 'Coding Sprint',
        targetDuration: const Duration(minutes: 30),
      );

      await notifier.pauseSession();

      final state = container.read(focusSessionProvider);
      expect(state!.status, SessionStatus.paused);
      expect(state.isPaused, true);
    });

    test('resumeSession transitions paused session back to running', () async {
      final notifier = container.read(focusSessionProvider.notifier);

      await notifier.startSession(presetName: 'Sprint');
      await notifier.pauseSession();
      expect(container.read(focusSessionProvider)!.status, SessionStatus.paused);

      await notifier.resumeSession();
      expect(container.read(focusSessionProvider)!.status, SessionStatus.running);
    });

    test('startBreak increments breaksTaken and sets onBreak status', () async {
      final notifier = container.read(focusSessionProvider.notifier);

      await notifier.startSession(
        presetName: 'Deep Work',
        breaksTotal: 2,
        breakDuration: const Duration(minutes: 5),
      );

      await notifier.startBreak();

      final state = container.read(focusSessionProvider);
      expect(state!.status, SessionStatus.onBreak);
      expect(state.breaksTaken, 1);
      expect(state.canTakeBreak, true);
      expect(fakeForeground.lastTitle, contains('Break Time'));
    });

    test('endBreak resumes session from break mode', () async {
      final notifier = container.read(focusSessionProvider.notifier);

      await notifier.startSession(presetName: 'Deep Work');
      await notifier.startBreak();
      expect(container.read(focusSessionProvider)!.status, SessionStatus.onBreak);

      await notifier.endBreak();
      final state = container.read(focusSessionProvider);
      expect(state!.status, SessionStatus.running);
    });

    test('stopSession marks abandoned, records to database, and clears active', () async {
      final notifier = container.read(focusSessionProvider.notifier);

      await notifier.startSession(presetName: 'Short Sprint');
      await notifier.stopSession();

      final state = container.read(focusSessionProvider);
      expect(state!.status, SessionStatus.abandoned);
      expect(fakeRepo.active, isNull);
      expect(fakeRepo.finished.length, 1);
      expect(fakeRepo.finished.first.status, SessionStatus.abandoned);
      expect(fakeForeground.running, false);
    });
  });
}
