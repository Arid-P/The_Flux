import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/theme/theme.dart';
import 'package:fluxfoxus/presentation/widgets/flip_clock.dart';

void main() {
  Widget buildTestWidget({
    required Duration duration,
    bool isBreakMode = false,
    bool showHours = true,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: ThemeTokens.background,
        body: Center(
          child: FlipClock(
            duration: duration,
            isBreakMode: isBreakMode,
            showHours: showHours,
          ),
        ),
      ),
    );
  }

  group('FlipClock Widget Tests', () {
    testWidgets('Renders hours and minutes when showHours is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          duration: const Duration(hours: 1, minutes: 45, seconds: 30),
          showHours: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('01'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('HOURS'), findsOneWidget);
      expect(find.text('MINUTES'), findsOneWidget);
    });

    testWidgets('Renders minutes and seconds when showHours is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          duration: const Duration(minutes: 24, seconds: 59),
          showHours: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('24'), findsOneWidget);
      expect(find.text('59'), findsOneWidget);
      expect(find.text('MINUTES'), findsOneWidget);
      expect(find.text('SECONDS'), findsOneWidget);
    });

    testWidgets('Applies correct digit color in break mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          duration: const Duration(minutes: 5, seconds: 0),
          isBreakMode: true,
          showHours: false,
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('05'));
      expect(textWidget.style?.color, ThemeTokens.accent);
    });
  });
}
