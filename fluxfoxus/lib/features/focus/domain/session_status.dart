/// Status values for an active focus session per TRD Section 8.
enum SessionStatus {
  idle,
  running,
  paused,
  onBreak,
  completed,
  abandoned;

  bool get isActive => this == running || this == onBreak;
  bool get isPaused => this == paused;
  bool get isEnded => this == completed || this == abandoned;

  static SessionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'running':
        return SessionStatus.running;
      case 'paused':
        return SessionStatus.paused;
      case 'onbreak':
      case 'on_break':
      case 'break':
        return SessionStatus.onBreak;
      case 'completed':
        return SessionStatus.completed;
      case 'abandoned':
      case 'cancelled':
        return SessionStatus.abandoned;
      case 'idle':
      default:
        return SessionStatus.idle;
    }
  }
}
