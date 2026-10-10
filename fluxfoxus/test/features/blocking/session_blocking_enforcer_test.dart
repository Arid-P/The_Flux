import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/storage/hive_storage_service.dart';
import 'package:fluxfoxus/features/blocking/presentation/blocking_providers.dart';
import 'package:fluxfoxus/features/blocking/services/app_detection_service.dart';
import 'package:fluxfoxus/features/blocking/services/session_blocking_enforcer.dart';
import 'package:fluxfoxus/features/focus/focus.dart';
import 'package:fluxfoxus/features/presets/data/presets_repository.dart';
import 'package:fluxfoxus/features/presets/domain/preset_app_restriction.dart';
import 'package:fluxfoxus/features/presets/presentation/presets_provider.dart';

class _FakePresetsRepository extends PresetsRepository {
  final Map<String, List<PresetAppRestriction>> fakeRestrictions = {};

  _FakePresetsRepository() : super(appDatabase: AppDatabase());

  @override
  Future<List<PresetAppRestriction>> getRestrictions(String presetId) async {
    return fakeRestrictions[presetId] ?? [];
  }
}

class _FakeForegroundService implements ForegroundTimerService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> startService({required String title, required String text}) async => true;
  @override
  Future<void> updateService({required String title, required String text}) async {}
  @override
  Future<bool> stopService() async => true;
  @override
  Future<bool> get isRunning async => true;
}

class _FakeFocusSessionRepository extends FocusSessionRepository {
  FocusSession? active;
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionBlockingEnforcer Direct Unit Tests', () {
    late FakeAppDetectionService fakeDetection;
    late _FakePresetsRepository fakePresets;
    late SessionBlockingEnforcer enforcer;

    setUp(() {
      fakeDetection = FakeAppDetectionService();
      fakePresets = _FakePresetsRepository();
      enforcer = SessionBlockingEnforcer(
        appDetectionService: fakeDetection,
        presetsRepository: fakePresets,
      );
    });

    tearDown(() {
      enforcer.dispose();
      fakeDetection.dispose();
    });

    test('Does not redirect when session is inactive even if distracting app opened', () async {
      await enforcer.syncSessionState(isSessionActive: false);

      final wasBlocked = await enforcer.handleForegroundApp('com.instagram.android');

      expect(wasBlocked, isFalse);
      expect(fakeDetection.redirectCount, equals(0));
    });

    test('Redirects to app when distracting package opened during active session', () async {
      await enforcer.syncSessionState(isSessionActive: true);

      final wasBlocked = await enforcer.handleForegroundApp('com.instagram.android');

      expect(wasBlocked, isTrue);
      expect(fakeDetection.redirectCount, equals(1));
      expect(fakeDetection.redirectCalls.first, equals('com.instagram.android'));
    });

    test('Does not redirect when productive app opened during active session', () async {
      await enforcer.syncSessionState(isSessionActive: true);

      final wasBlocked = await enforcer.handleForegroundApp('com.google.android.calculator');

      expect(wasBlocked, isFalse);
      expect(fakeDetection.redirectCount, equals(0));
    });

    test('Respects preset specific app restrictions', () async {
      fakePresets.fakeRestrictions['preset-study'] = const [
        PresetAppRestriction(
          presetId: 'preset-study',
          packageName: 'com.custom.game',
          isBlocked: true,
        ),
        PresetAppRestriction(
          presetId: 'preset-study',
          packageName: 'com.instagram.android',
          isBlocked: false,
        ),
      ];

      await enforcer.syncSessionState(
        isSessionActive: true,
        presetId: 'preset-study',
      );

      // Blocked in preset -> redirect
      final gameBlocked = await enforcer.handleForegroundApp('com.custom.game');
      expect(gameBlocked, isTrue);
      expect(fakeDetection.redirectCount, equals(1));

      // Whitelisted in preset -> no redirect
      final instaBlocked = await enforcer.handleForegroundApp('com.instagram.android');
      expect(instaBlocked, isFalse);
      expect(fakeDetection.redirectCount, equals(1));
    });

    test('Listening stream triggers redirection automatically', () async {
      final blockedEvents = <String>[];
      await enforcer.syncSessionState(isSessionActive: true);
      enforcer.startListening(onRedirect: blockedEvents.add);

      fakeDetection.emitForegroundApp('com.google.android.youtube');
      await pumpEventQueue();

      expect(fakeDetection.redirectCount, equals(1));
      expect(blockedEvents, equals(['com.google.android.youtube']));

      enforcer.stopListening();
    });
  });

  group('SessionBlockingEnforcer Riverpod Integration Tests', () {
    test('Automatically synchronizes with FocusSessionNotifier state changes', () async {
      final fakeDetection = FakeAppDetectionService();
      final fakePresets = _FakePresetsRepository();
      final fakeSessionRepo = _FakeFocusSessionRepository();
      final fakeForeground = _FakeForegroundService();

      final container = ProviderContainer(
        overrides: [
          appDetectionServiceProvider.overrideWithValue(fakeDetection),
          presetsRepositoryProvider.overrideWithValue(fakePresets),
          focusSessionRepositoryProvider.overrideWithValue(fakeSessionRepo),
          foregroundTimerServiceProvider.overrideWithValue(fakeForeground),
        ],
      );

      addTearDown(container.dispose);

      // Read enforcer to activate listener
      final enforcer = container.read(sessionBlockingEnforcerProvider);
      expect(enforcer.isSessionActive, isFalse);

      // Start focus session
      final sessionNotifier = container.read(focusSessionProvider.notifier);
      await sessionNotifier.startSession(
        targetDuration: const Duration(minutes: 25),
      );
      await pumpEventQueue();

      expect(enforcer.isSessionActive, isTrue);
      expect(fakeDetection.isSessionActive, isTrue);

      // Emitting distracting package should redirect
      fakeDetection.emitForegroundApp('com.twitter.android');
      await pumpEventQueue();

      expect(fakeDetection.redirectCount, equals(1));
      expect(fakeDetection.redirectCalls.last, equals('com.twitter.android'));
    });
  });
}
