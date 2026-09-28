import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/theme/theme.dart';
import 'package:fluxfoxus/features/focus/data/streak_repository.dart';
import 'package:fluxfoxus/presentation/widgets/stop_focusing_modal.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget buildModalTestApp({
    int streakDays = 5,
    int? countdownOverride = 0,
    VoidCallback? onKeepGoing,
    VoidCallback? onQuit,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: StopFocusingModal(
            streakDays: streakDays,
            countdownOverride: countdownOverride,
            onKeepGoing: onKeepGoing,
            onQuit: onQuit,
          ),
        ),
      ),
    );
  }

  group('StopFocusingModal Widget Tests', () {
    testWidgets('Renders all modal content per ui_focus_session.md Section 3', (tester) async {
      await tester.pumpWidget(buildModalTestApp(streakDays: 14));
      await tester.pumpAndSettle();

      // Alert Icon
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);

      // Primary Heading
      expect(find.text('Finish the goal?'), findsOneWidget);

      // Secondary Text
      expect(
        find.text('You will break your focus streak if you stop now.'),
        findsOneWidget,
      );

      // Streak Section
      expect(find.text('FluxFoxus Streak'), findsOneWidget);
      expect(find.text('14 days'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.text('0 days'), findsOneWidget);

      // Action Buttons
      expect(find.byKey(const Key('modal_keep_going_button')), findsOneWidget);
      expect(find.byKey(const Key('modal_quit_session_button')), findsOneWidget);
    });

    testWidgets('Buttons are locked/disabled during countdown and show timer text', (tester) async {
      await tester.pumpWidget(buildModalTestApp(countdownOverride: 18));
      await tester.pump();

      // Check inline countdown timer in button
      expect(find.text('Quit Session (18s)'), findsOneWidget);

      // Buttons are disabled
      final keepGoingButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('modal_keep_going_button')),
      );
      expect(keepGoingButton.onPressed, isNull);

      final quitButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('modal_quit_session_button')),
      );
      expect(quitButton.onPressed, isNull);
    });

    testWidgets('Countdown ticks down and unlocks buttons at zero', (tester) async {
      await tester.pumpWidget(buildModalTestApp(countdownOverride: 2));
      await tester.pump();

      expect(find.text('Quit Session (2s)'), findsOneWidget);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Quit Session (1s)'), findsOneWidget);

      // Advance 1 second -> reaches 0
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Quit Session'), findsOneWidget);

      // Buttons are now enabled
      final keepGoingButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('modal_keep_going_button')),
      );
      expect(keepGoingButton.onPressed, isNotNull);

      final quitButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('modal_quit_session_button')),
      );
      expect(quitButton.onPressed, isNotNull);
    });

    testWidgets('Tapping Keep Going triggers callback and pops false', (tester) async {
      bool keepGoingCalled = false;
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await StopFocusingModal.show(
                    context,
                    streakDays: 7,
                    countdownOverride: 0,
                    onKeepGoing: () => keepGoingCalled = true,
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.byType(StopFocusingModal), findsOneWidget);

      // Tap Keep Going
      await tester.tap(find.byKey(const Key('modal_keep_going_button')));
      await tester.pumpAndSettle();

      expect(find.byType(StopFocusingModal), findsNothing);
      expect(keepGoingCalled, isTrue);
      expect(result, isFalse);
    });

    testWidgets('Tapping Quit Session triggers callback and pops true', (tester) async {
      bool quitCalled = false;
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await StopFocusingModal.show(
                    context,
                    streakDays: 7,
                    countdownOverride: 0,
                    onQuit: () => quitCalled = true,
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.byType(StopFocusingModal), findsOneWidget);

      // Tap Quit Session
      await tester.tap(find.byKey(const Key('modal_quit_session_button')));
      await tester.pumpAndSettle();

      expect(find.byType(StopFocusingModal), findsNothing);
      expect(quitCalled, isTrue);
      expect(result, isTrue);
    });
  });

  group('StreakRepository Tests', () {
    test('FakeStreakRepository handles get, update, and reset correctly', () async {
      final repo = FakeStreakRepository(initialStreak: 10);
      expect(await repo.getCurrentStreak(), 10);

      await repo.updateStreak(15);
      expect(await repo.getCurrentStreak(), 15);

      await repo.resetStreak();
      expect(await repo.getCurrentStreak(), 0);
    });
  });
}
