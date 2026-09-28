import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/focus_session_repository.dart';
import '../domain/focus_session.dart';
import '../domain/session_status.dart';
import '../domain/timer_mode.dart';
import '../services/foreground_timer_service.dart';

/// Riverpod Notifier managing the active FocusSession state machine,
/// drift-free delta timing, foreground service sync, and Hive persistence.
class FocusSessionNotifier extends Notifier<FocusSession?> {
  Timer? _ticker;
  int _persistCounter = 0;
  static const _uuid = Uuid();

  FocusSessionRepository get _repo => ref.read(focusSessionRepositoryProvider);
  ForegroundTimerService get _foreground =>
      ref.read(foregroundTimerServiceProvider);

  @override
  FocusSession? build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });
    // Attempt restoring active session on launch (e.g. after app restart)
    final existing = _repo.getActiveSession();
    if (existing != null && existing.status.isActive) {
      // Re-arm ticker and calculate real elapsed time since kill
      final now = DateTime.now();
      if (existing.status == SessionStatus.running &&
          existing.lastResumedAt != null) {
        final delta = now.difference(existing.lastResumedAt!);
        final updated = existing.copyWith(
          elapsed: existing.elapsed + delta,
          lastResumedAt: now,
        );
        _startTicker();
        return updated;
      } else if (existing.status == SessionStatus.onBreak &&
          existing.lastBreakStartedAt != null) {
        final delta = now.difference(existing.lastBreakStartedAt!);
        final updated = existing.copyWith(
          breakElapsed: existing.breakElapsed + delta,
          lastBreakStartedAt: now,
        );
        _startTicker();
        return updated;
      }
      _startTicker();
      return existing;
    }
    return null;
  }

  /// Starts a new focus session.
  Future<void> startSession({
    String? presetId,
    String presetName = 'Focus Session',
    String presetEmoji = '⚡',
    TimerMode timerMode = TimerMode.countdown,
    Duration? targetDuration = const Duration(minutes: 90),
    int breaksTotal = 2,
    Duration breakDuration = const Duration(minutes: 5),
  }) async {
    final now = DateTime.now();
    final session = FocusSession(
      id: _uuid.v4(),
      presetId: presetId,
      presetName: presetName,
      presetEmoji: presetEmoji,
      timerMode: timerMode,
      status: SessionStatus.running,
      elapsed: Duration.zero,
      targetDuration: timerMode == TimerMode.openEnded ? null : targetDuration,
      breaksTotal: breaksTotal,
      breaksTaken: 0,
      breakDuration: breakDuration,
      breakElapsed: Duration.zero,
      startedAt: now,
      lastResumedAt: now,
    );

    state = session;
    await _repo.saveActiveSession(session);
    await _startForeground(session);
    _startTicker();
  }

  /// Pauses the running focus session.
  Future<void> pauseSession() async {
    final current = state;
    if (current == null || current.status != SessionStatus.running) return;

    final now = DateTime.now();
    final delta = current.lastResumedAt != null
        ? now.difference(current.lastResumedAt!)
        : Duration.zero;

    final updated = current.copyWith(
      status: SessionStatus.paused,
      elapsed: current.elapsed + delta,
      lastResumedAt: null,
    );

    state = updated;
    await _repo.saveActiveSession(updated);
    await _foreground.updateService(
      title: '${updated.presetEmoji} ${updated.presetName} (Paused)',
      text: _formatDurationText(updated),
    );
  }

  /// Resumes a paused session.
  Future<void> resumeSession() async {
    final current = state;
    if (current == null || current.status != SessionStatus.paused) return;

    final now = DateTime.now();
    final updated = current.copyWith(
      status: SessionStatus.running,
      lastResumedAt: now,
    );

    state = updated;
    await _repo.saveActiveSession(updated);
    _startTicker();
    await _updateForeground(updated);
  }

  /// Transitions the session into Break mode.
  Future<void> startBreak() async {
    final current = state;
    if (current == null || !current.status.isActive || !current.canTakeBreak) return;

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final now = DateTime.now();
    Duration updatedElapsed = current.elapsed;
    if (current.status == SessionStatus.running &&
        current.lastResumedAt != null) {
      updatedElapsed += now.difference(current.lastResumedAt!);
    }

    final updated = current.copyWith(
      status: SessionStatus.onBreak,
      elapsed: updatedElapsed,
      breaksTaken: current.breaksTaken + 1,
      breakElapsed: Duration.zero,
      lastResumedAt: null,
      lastBreakStartedAt: now,
    );

    state = updated;
    await _repo.saveActiveSession(updated);
    _startTicker();
    await _foreground.updateService(
      title: '☕ Break Time — ${updated.presetName}',
      text:
          'Remaining: ${_formatMinutesSeconds(updated.breakRemaining)} (${updated.breaksTaken}/${updated.breaksTotal})',
    );
  }

  /// Ends the break early and resumes focus.
  Future<void> endBreak() async {
    final current = state;
    if (current == null || current.status != SessionStatus.onBreak) return;

    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    final now = DateTime.now();
    final updated = current.copyWith(
      status: SessionStatus.running,
      lastResumedAt: now,
      lastBreakStartedAt: null,
    );

    state = updated;
    await _repo.saveActiveSession(updated);
    _startTicker();
    await _updateForeground(updated);
  }

  /// Stops and abandons the focus session early.
  Future<void> stopSession() async {
    final current = state;
    if (current == null) return;

    _ticker?.cancel();
    final now = DateTime.now();
    Duration updatedElapsed = current.elapsed;
    if (current.status == SessionStatus.running &&
        current.lastResumedAt != null) {
      updatedElapsed += now.difference(current.lastResumedAt!);
    }

    final completed = current.copyWith(
      status: SessionStatus.abandoned,
      elapsed: updatedElapsed,
      completedAt: now,
      lastResumedAt: null,
      lastBreakStartedAt: null,
    );

    state = completed;
    await _repo.recordFinishedSession(completed);
    await _repo.clearActiveSession();
    await _foreground.stopService();
  }

  /// Completes the session successfully upon countdown reaching zero.
  Future<void> _completeSession(FocusSession session) async {
    _ticker?.cancel();
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
    final now = DateTime.now();
    final completed = session.copyWith(
      status: SessionStatus.completed,
      elapsed: session.targetDuration ?? session.elapsed,
      completedAt: now,
      lastResumedAt: null,
      lastBreakStartedAt: null,
    );

    state = completed;
    await _repo.recordFinishedSession(completed);
    await _repo.clearActiveSession();
    await _foreground.updateService(
      title: '🎉 Focus Complete!',
      text: 'Great job! Session completed.',
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    await _foreground.stopService();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final current = state;
    if (current == null) return;

    final now = DateTime.now();

    if (current.status == SessionStatus.running) {
      final delta = current.lastResumedAt != null
          ? now.difference(current.lastResumedAt!)
          : const Duration(seconds: 1);

      final newElapsed = current.elapsed + delta;

      // Auto-complete if countdown target is reached
      if (current.timerMode == TimerMode.countdown &&
          current.targetDuration != null &&
          newElapsed >= current.targetDuration!) {
        _completeSession(current);
        return;
      }

      final updated = current.copyWith(
        elapsed: newElapsed,
        lastResumedAt: now,
      );

      state = updated;
      _handlePeriodicBackgroundSync(updated);
    } else if (current.status == SessionStatus.onBreak) {
      final delta = current.lastBreakStartedAt != null
          ? now.difference(current.lastBreakStartedAt!)
          : const Duration(seconds: 1);

      final newBreakElapsed = current.breakElapsed + delta;

      // Auto-end break when break duration is exhausted
      if (newBreakElapsed >= current.breakDuration) {
        endBreak();
        return;
      }

      final updated = current.copyWith(
        breakElapsed: newBreakElapsed,
        lastBreakStartedAt: now,
      );

      state = updated;
      _handlePeriodicBackgroundSync(updated);
    }
  }

  void _handlePeriodicBackgroundSync(FocusSession session) {
    _persistCounter++;
    if (_persistCounter % 5 == 0) {
      _repo.saveActiveSession(session);
      _updateForeground(session);
    }
  }

  Future<void> _startForeground(FocusSession session) async {
    await _foreground.startService(
      title: '${session.presetEmoji} ${session.presetName}',
      text: _formatDurationText(session),
    );
  }

  Future<void> _updateForeground(FocusSession session) async {
    if (session.status == SessionStatus.onBreak) {
      await _foreground.updateService(
        title: '☕ Break Time — ${session.presetName}',
        text:
            'Remaining: ${_formatMinutesSeconds(session.breakRemaining)} (${session.breaksTaken}/${session.breaksTotal})',
      );
    } else {
      await _foreground.updateService(
        title: '${session.presetEmoji} ${session.presetName}',
        text: _formatDurationText(session),
      );
    }
  }

  String _formatDurationText(FocusSession session) {
    if (session.timerMode == TimerMode.countdown &&
        session.targetDuration != null) {
      return 'Remaining: ${_formatMinutesSeconds(session.remaining)}';
    }
    return 'Elapsed: ${_formatMinutesSeconds(session.elapsed)}';
  }

  String _formatMinutesSeconds(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = duration.inHours;
    if (h > 0) {
      return '$h:$m:$s';
    }
    return '$m:$s';
  }
}

/// Provider for active FocusSession.
final focusSessionProvider =
    NotifierProvider<FocusSessionNotifier, FocusSession?>(
  FocusSessionNotifier.new,
);
