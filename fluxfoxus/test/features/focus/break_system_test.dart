import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
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
    int breaksTotal = 2,
    Duration breakDuration = const Duration(minutes: 5),
  }) {
    return ProviderScope(
      overrides: [
        foregroundTimerServiceProvider.overrideWithValue(fakeForeground),
        focusSessionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        home: FocusSessionScreen(
          presetName: 'Deep Work',
          breaksTotal: breaksTotal,
          breakDuration: breakDuration,
        ),
      ),
    );
  }

  group('Phase 1-B Step 7: Break System Tests', () {
    testWidgets('Break button is interactive and displays breaks remaining when breaks > 0', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(breaksTotal: 2));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('focus_break_button')), findsOneWidget);
      expect(find.text('Break (2)'), findsOneWidget);
      expect(find.byKey(const Key('focus_pause_play_button')), findsOneWidget);
    });

    testWidgets('Break button is ABSENT entirely when breaksTotal == 0 per spec Section 1.5', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(breaksTotal: 0));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('focus_break_button')), findsNothing);
      expect(find.byKey(const Key('stop_focusing_button')), findsOneWidget);
      expect(find.byKey(const Key('focus_pause_play_button')), findsOneWidget);
    });

    testWidgets('Entering break mode switches UI to break state and hides pause button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(breaksTotal: 1));
      await tester.pumpAndSettle();

      // Tap Break
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      // Header switches to BREAK in accent color
      expect(find.text('BREAK'), findsOneWidget);
      expect(find.text('BREAK WINDOW ACTIVE'), findsOneWidget);

      // Break button is replaced by prominent End Break Early button
      expect(find.text('End Break Early'), findsOneWidget);

      // Pause button is ABSENT during break per ui_focus_session.md Section 2.4
      expect(find.byKey(const Key('focus_pause_play_button')), findsNothing);

      // Stop Focusing button is still present
      expect(find.byKey(const Key('stop_focusing_button')), findsOneWidget);
    });

    testWidgets('Tapping End Break Early immediately resumes focus session', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(breaksTotal: 2));
      await tester.pumpAndSettle();

      // Start break
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      expect(find.text('End Break Early'), findsOneWidget);

      // End break early
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      // Resumed back to running
      expect(find.text('COUNTDOWN ACTIVE'), findsOneWidget);
      expect(find.byKey(const Key('focus_pause_play_button')), findsOneWidget);
      // Remaining breaks decremented from 2 to 1
      expect(find.text('Break (1)'), findsOneWidget);
    });

    testWidgets('Exhausting all breaks disables the Break button with greyscale opacity', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(breaksTotal: 1));
      await tester.pumpAndSettle();

      expect(find.text('Break (1)'), findsOneWidget);

      // Take the only break available
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      // End break
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      // Now 0 breaks remain: button shows Break (0)
      expect(find.text('Break (0)'), findsOneWidget);

      // Verify opacity widget wraps the button with 0.4 opacity
      final opacityFinder = find.ancestor(
        of: find.text('Break (0)'),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsOneWidget);
      final Opacity opacityWidget = tester.widget(opacityFinder);
      expect(opacityWidget.opacity, equals(0.4));

      // Tapping the exhausted break button does not enter break mode
      await tester.tap(find.byKey(const Key('focus_break_button')));
      await tester.pumpAndSettle();

      expect(find.text('COUNTDOWN ACTIVE'), findsOneWidget);
      expect(find.text('BREAK'), findsNothing);
    });
  });
}
