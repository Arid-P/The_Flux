import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/focus/domain/wait_time_calculator.dart';

void main() {
  group('WaitTimeCalculator (TRD Section 5.3.3)', () {
    test('Weights distribution matches specification across streak brackets', () {
      // < 10 days
      var weights = WaitTimeCalculator.getWeights(5);
      expect(weights.streak, 0.55);
      expect(weights.usage, 0.45);

      // 10–20 days
      weights = WaitTimeCalculator.getWeights(10);
      expect(weights.streak, 0.45);
      expect(weights.usage, 0.55);
      weights = WaitTimeCalculator.getWeights(20);
      expect(weights.streak, 0.45);
      expect(weights.usage, 0.55);

      // 21–29 days
      weights = WaitTimeCalculator.getWeights(25);
      expect(weights.streak, 0.40);
      expect(weights.usage, 0.60);

      // 30–44 days
      weights = WaitTimeCalculator.getWeights(40);
      expect(weights.streak, 0.25);
      expect(weights.usage, 0.75);

      // 45–59 days
      weights = WaitTimeCalculator.getWeights(50);
      expect(weights.streak, 0.15);
      expect(weights.usage, 0.85);

      // 60–89 days
      weights = WaitTimeCalculator.getWeights(75);
      expect(weights.streak, 0.10);
      expect(weights.usage, 0.90);

      // >= 100 days
      weights = WaitTimeCalculator.getWeights(100);
      expect(weights.streak, 0.00);
      expect(weights.usage, 1.00);
      weights = WaitTimeCalculator.getWeights(150);
      expect(weights.streak, 0.00);
      expect(weights.usage, 1.00);
    });

    test('Clamps calculated wait time between 15 and 25 seconds', () {
      // 0 distracting usage on low streak -> should clamp to 15s
      final lowWait = WaitTimeCalculator.calculateWaitSeconds(
        streakDays: 3,
        todayDistractingUsage: Duration.zero,
        avgDistractingUsage: const Duration(hours: 2),
      );
      expect(lowWait, 15);

      // Heavy distracting usage on high streak -> should clamp to 25s
      final highWait = WaitTimeCalculator.calculateWaitSeconds(
        streakDays: 45,
        todayDistractingUsage: const Duration(hours: 4),
        avgDistractingUsage: const Duration(hours: 2),
      );
      expect(highWait, 25);
    });

    test('Handles zero avgDistractingUsage fallback gracefully', () {
      // If user has no recorded average distracting usage yet, ratio defaults to 1.0
      final wait = WaitTimeCalculator.calculateWaitSeconds(
        streakDays: 7,
        todayDistractingUsage: const Duration(minutes: 30),
        avgDistractingUsage: Duration.zero,
      );
      expect(wait, 25);
    });

    test('Produces realistic intermediate wait time values', () {
      final wait = WaitTimeCalculator.calculateWaitSeconds(
        streakDays: 14,
        todayDistractingUsage: const Duration(minutes: 30),
        avgDistractingUsage: const Duration(hours: 1), // ratio = 0.5
      );
      // streak: 0.45 * 25 = 11.25
      // usage: 0.55 * 25 * 0.5 = 6.875
      // sum = 18.125 -> round to 18
      expect(wait, 18);
    });
  });
}
