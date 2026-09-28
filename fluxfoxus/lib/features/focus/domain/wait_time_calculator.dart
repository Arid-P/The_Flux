/// Wait time calculator for the Stop Focusing discipline friction modal.
///
/// Implements TRD Section 5.3.3.
/// Calculates a required wait time between 15 and 25 seconds based on
/// current streak days and distracting app usage ratio.
/// Note: Productive app time is strictly excluded from usage calculations.
class WaitTimeCalculator {
  const WaitTimeCalculator._();

  /// Calculates the required wait time in seconds (clamped between 15 and 25).
  static int calculateWaitSeconds({
    required int streakDays,
    required Duration todayDistractingUsage,
    required Duration avgDistractingUsage,
  }) {
    final weights = getWeights(streakDays);

    final usageRatio = avgDistractingUsage.inSeconds == 0
        ? 1.0
        : todayDistractingUsage.inSeconds / avgDistractingUsage.inSeconds;

    final streakScore = weights.streak * 25;
    final usageScore = weights.usage * 25 * usageRatio.clamp(0.0, 1.0);

    return (streakScore + usageScore).clamp(15.0, 25.0).round();
  }

  /// Returns the weight distribution between streak length and distracting usage.
  ///
  /// | Streak Length | Streak Weight | Usage Weight |
  /// | < 10 days     | 55%           | 45%          |
  /// | 10–20 days    | 45%           | 55%          |
  /// | 21–29 days    | 40%           | 60%          |
  /// | 30–44 days    | 25%           | 75%          |
  /// | 45–59 days    | 15%           | 85%          |
  /// | 60–89 days    | 10%           | 90%          |
  /// | ≥ 100 days    | 0%            | 100%         |
  static ({double streak, double usage}) getWeights(int days) {
    if (days < 10) return (streak: 0.55, usage: 0.45);
    if (days < 21) return (streak: 0.45, usage: 0.55);
    if (days < 30) return (streak: 0.40, usage: 0.60);
    if (days < 45) return (streak: 0.25, usage: 0.75);
    if (days < 60) return (streak: 0.15, usage: 0.85);
    if (days < 100) return (streak: 0.10, usage: 0.90);
    return (streak: 0.00, usage: 1.00);
  }
}
