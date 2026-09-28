/// Timer modes supported by the Focus Session per TRD Section 8.
enum TimerMode {
  /// Counts DOWN from a target duration (e.g. 90 minutes).
  countdown,

  /// Counts UP indefinitely from 0.
  stopwatch,

  /// No target duration — runs until user stops.
  openEnded;

  String get label {
    switch (this) {
      case TimerMode.countdown:
        return 'Countdown';
      case TimerMode.stopwatch:
        return 'Stopwatch';
      case TimerMode.openEnded:
        return 'Open Ended';
    }
  }

  static TimerMode fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'stopwatch':
        return TimerMode.stopwatch;
      case 'openended':
      case 'open_ended':
        return TimerMode.openEnded;
      case 'countdown':
      default:
        return TimerMode.countdown;
    }
  }
}
