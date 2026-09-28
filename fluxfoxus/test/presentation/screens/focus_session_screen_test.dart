import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/navigation/navigation.dart';
import 'package:fluxfoxus/core/storage/hive_storage_service.dart';
import 'package:fluxfoxus/features/focus/focus.dart';
import 'package:fluxfoxus/presentation/screens/focus_session_screen.dart';

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
  Future<bool> get isRunning async => false;
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

  setUp(() {
    fakeForeground = _FakeForegroundService();
    fakeRepo = _FakeFocusSessionRepository();
  });

  Widget buildTestApp({
    String initialLocation = AppRoutes.focusSession,
    FocusSession? initialSession,
  }) {
    final router = createAppRouter(initialLocation: initialLocation);

    return ProviderScope(
      overrides: [
        foregroundTimerServiceProvider.overrideWithValue(fakeForeground),
        focusSessionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('FocusSessionScreen Widget Tests', () {
    testWidgets('Renders all header, clock, indicator, and control elements', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(FocusSessionScreen), findsOneWidget);
      expect(find.text('Deep Work'), findsOneWidget);
      expect(find.byKey(const Key('stop_focusing_button')), findsOneWidget);
      expect(find.byKey(const Key('focus_break_button')), findsOneWidget);
      expect(find.byKey(const Key('focus_pause_play_button')), findsOneWidget);
      expect(find.text('COUNTDOWN ACTIVE'), findsOneWidget);
    });

    testWidgets('Tapping pause/play circle toggles session pause and resume', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Tap to pause
      await tester.tap(find.byKey(const Key('focus_pause_play_button')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('SESSION PAUSED'), findsOneWidget);

      // Tap to resume
      await tester.tap(find.byKey(const Key('focus_pause_play_button')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.text('COUNTDOWN ACTIVE'), findsOneWidget);
    });

    testWidgets('Tapping Break button transitions to break mode and back', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap Break
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      expect(find.text('BREAK'), findsOneWidget);
      expect(find.text('BREAK WINDOW ACTIVE'), findsOneWidget);
      expect(find.text('End Break'), findsOneWidget);

      // Tap End Break
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      expect(find.text('COUNTDOWN ACTIVE'), findsOneWidget);
    });

    testWidgets('Tapping Stop Focusing stops session and navigates to Home', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(FocusSessionScreen), findsOneWidget);

      // Tap Stop Focusing
      await tester.tap(find.byKey(const Key('stop_focusing_button')));
      await tester.pumpAndSettle();

      // Should navigate to Home
      expect(find.byType(FocusSessionScreen), findsNothing);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    });
  });
}
