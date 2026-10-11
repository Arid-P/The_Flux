import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/blocking/presentation/distraction_intervention_dialog.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('DistractionInterventionDialog Widget Tests', () {
    testWidgets('renders app name, limit, streak, and 2x2 minute buttons', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const DistractionInterventionDialog(
            appName: 'Instagram',
            packageName: 'com.instagram.android',
            spentMinutes: 15,
            limitMinutes: 30,
            streakDays: 4,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('30m limit'), findsOneWidget);
      expect(find.text('4 days'), findsOneWidget);
      expect(find.text('15m / Spent today'), findsOneWidget);
      expect(find.text('15m / Limit left'), findsOneWidget);
      expect(find.text('2 mins'), findsOneWidget);
      expect(find.text('5 mins'), findsOneWidget);
      expect(find.text('10 mins'), findsOneWidget);
      expect(find.text('20 mins'), findsOneWidget);
      expect(find.text('Exit Instagram'), findsOneWidget);
    });

    testWidgets('triggers onSelectMinutes and pops when time option is tapped', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildTestWidget(
          child: DistractionInterventionDialog(
            appName: 'Twitter',
            packageName: 'com.twitter.android',
            onSelectMinutes: (mins) => selected = mins,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('option_5m_button')));
      await tester.pumpAndSettle();

      expect(selected, 5);
    });

    testWidgets('triggers onExitApp when Exit button is tapped', (tester) async {
      bool exitCalled = false;
      await tester.pumpWidget(
        buildTestWidget(
          child: DistractionInterventionDialog(
            appName: 'Reddit',
            packageName: 'com.reddit.frontpage',
            onExitApp: () => exitCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exit_app_button')));
      await tester.pumpAndSettle();

      expect(exitCalled, true);
    });

    testWidgets('shows YouTube study mode card when app is YouTube', (tester) async {
      bool studyModeActivated = false;
      await tester.pumpWidget(
        buildTestWidget(
          child: DistractionInterventionDialog(
            appName: 'YouTube',
            packageName: 'com.google.android.youtube',
            onActivateYouTubeStudyMode: () => studyModeActivated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('youtube_study_mode_card')), findsOneWidget);
      expect(find.text('Watch only Study channels on YouTube'), findsOneWidget);

      await tester.tap(find.byKey(const Key('youtube_study_mode_card')));
      await tester.pumpAndSettle();

      expect(studyModeActivated, true);
      expect(find.text('Study Mode: ACTIVE (Whitelisted Only)'), findsOneWidget);
    });

    testWidgets('disables time option buttons during wait countdown', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const DistractionInterventionDialog(
            appName: 'Instagram',
            packageName: 'com.instagram.android',
            initialWaitSeconds: 5,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Wait 5s to select time'), findsOneWidget);

      // Button should be disabled (OutlinedButton onPressed is null)
      final button = tester.widget<OutlinedButton>(find.byKey(const Key('option_2m_button')));
      expect(button.onPressed, isNull);
    });
  });
}
