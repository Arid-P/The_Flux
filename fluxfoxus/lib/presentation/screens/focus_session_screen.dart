import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../features/focus/focus.dart';
import '../widgets/stop_focusing_modal.dart';

/// FocusSessionScreen renders the full-screen takeover active focus session.
/// Integrates with FocusSessionNotifier, mechanical FlipClock,
/// break state handling, and bottom navigation takeover per TRD Section 8 & ui_navigation.md.
class FocusSessionScreen extends ConsumerStatefulWidget {
  final String? presetId;
  final String? presetName;
  final String? presetEmoji;
  final TimerMode timerMode;
  final Duration? targetDuration;
  final int breaksTotal;
  final Duration breakDuration;
  final int? countdownSecondsOverride;

  const FocusSessionScreen({
    super.key,
    this.presetId,
    this.presetName,
    this.presetEmoji,
    this.timerMode = TimerMode.countdown,
    this.targetDuration = const Duration(minutes: 90),
    this.breaksTotal = 2,
    this.breakDuration = const Duration(minutes: 5),
    this.countdownSecondsOverride,
  });


  @override
  ConsumerState<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends ConsumerState<FocusSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSessionStarted();
    });
  }

  void _ensureSessionStarted() {
    final current = ref.read(focusSessionProvider);
    if (current == null || !current.status.isActive) {
      ref.read(focusSessionProvider.notifier).startSession(
            presetId: widget.presetId,
            presetName: widget.presetName ?? 'Deep Work',
            presetEmoji: widget.presetEmoji ?? '⚡',
            timerMode: widget.timerMode,
            targetDuration: widget.targetDuration,
            breaksTotal: widget.breaksTotal,
            breakDuration: widget.breakDuration,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusSessionProvider) ??
        FocusSession(
          id: 'initial',
          presetId: widget.presetId,
          presetName: widget.presetName ?? 'Deep Work',
          presetEmoji: widget.presetEmoji ?? '⚡',
          timerMode: widget.timerMode,
          status: SessionStatus.running,
          elapsed: Duration.zero,
          targetDuration: widget.targetDuration,
          breaksTotal: widget.breaksTotal,
          breaksTaken: 0,
          breakDuration: widget.breakDuration,
          startedAt: DateTime.now(),
        );

    final isBreak = session.status == SessionStatus.onBreak;
    final isPaused = session.status == SessionStatus.paused;

    // Display duration: remaining for countdown, elapsed for stopwatch/openEnded, breakRemaining for break
    final Duration displayDuration;
    if (isBreak) {
      displayDuration = session.breakRemaining;
    } else if (session.timerMode == TimerMode.countdown &&
        session.targetDuration != null) {
      displayDuration = session.remaining;
    } else {
      displayDuration = session.elapsed;
    }

    final bool showHours = displayDuration.inHours > 0;
    final int topValue =
        showHours ? displayDuration.inHours : displayDuration.inMinutes.remainder(60);
    final String topLabel = showHours ? 'HOURS' : 'MINUTES';
    final int bottomValue = showHours
        ? displayDuration.inMinutes.remainder(60)
        : displayDuration.inSeconds.remainder(60);
    final String bottomLabel = showHours ? 'MINUTES' : 'SECONDS';

    final Color digitColor =
        isBreak ? ThemeTokens.accent : ThemeTokens.textPrimary;

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = AppBreakpoints.isLandscape(context);
                final bool useHorizontalClock =
                    isLandscape || constraints.maxHeight < 500;

                return AdaptiveScrollBody(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.s),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeTokens.primary,
                                borderRadius:
                                    BorderRadius.circular(ThemeTokens.radiusPill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    session.presetEmoji,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      session.presetName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption(
                                        color: ThemeTokens.background,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Flexible(
                            child: isBreak
                                ? Text(
                                    'BREAK',
                                    style: AppTypography.heading3(
                                      color: ThemeTokens.accent,
                                      weight: FontWeight.w800,
                                    ),
                                  )
                                : Text(
                                    '${session.timerMode.label.toUpperCase()} MODE',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.micro(
                                      color: ThemeTokens.textMuted,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Mechanical Split-Line Flip Clock
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: useHorizontalClock
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildMechanicalCard(
                                    topValue,
                                    topLabel,
                                    digitColor: digitColor,
                                    isBreak: isBreak,
                                    isCompact: constraints.maxHeight < 360,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildMechanicalCard(
                                    bottomValue,
                                    bottomLabel,
                                    digitColor: digitColor,
                                    isBreak: isBreak,
                                    isCompact: constraints.maxHeight < 360,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMechanicalCard(
                                    topValue,
                                    topLabel,
                                    digitColor: digitColor,
                                    isBreak: isBreak,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildMechanicalCard(
                                    bottomValue,
                                    bottomLabel,
                                    digitColor: digitColor,
                                    isBreak: isBreak,
                                  ),
                                ],
                              ),
                      ),

                      // Timer Mode Status Pill Sub-Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isBreak
                                  ? ThemeTokens.accent
                                  : (isPaused
                                      ? ThemeTokens.textMuted
                                      : ThemeTokens.primary),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBreak
                                ? 'BREAK WINDOW ACTIVE'
                                : (isPaused
                                    ? 'SESSION PAUSED'
                                    : '${session.timerMode.label.toUpperCase()} ACTIVE'),
                            style: AppTypography.micro(
                              color: ThemeTokens.textMuted,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom Controls Row
                      Row(
                        children: [
                          // 1. Stop Focusing Button
                          Expanded(
                            flex: isBreak ? 4 : 5,
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                key: const Key('stop_focusing_button'),
                                onPressed: () async {
                                  final wasRunning =
                                      session.status == SessionStatus.running;
                                  if (wasRunning) {
                                    ref
                                        .read(focusSessionProvider.notifier)
                                        .pauseSession();
                                  }

                                  final streak = await ref
                                      .read(streakRepositoryProvider)
                                      .getCurrentStreak();
                                  if (!context.mounted) return;

                                  final confirmed =
                                      await StopFocusingModal.show(
                                    context,
                                    streakDays: streak > 0 ? streak : 1,
                                    countdownOverride:
                                        widget.countdownSecondsOverride,
                                  );

                                  if (!context.mounted) return;

                                  if (confirmed == true) {
                                    try {
                                      await ref
                                          .read(streakRepositoryProvider)
                                          .resetStreak();
                                    } catch (_) {}
                                    try {
                                      await ref
                                          .read(focusSessionProvider.notifier)
                                          .stopSession();
                                    } catch (_) {}
                                    if (context.mounted) {
                                      context.go(AppRoutes.home);
                                    }
                                  } else if (wasRunning) {
                                    try {
                                      await ref
                                          .read(focusSessionProvider.notifier)
                                          .resumeSession();
                                    } catch (_) {}
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isBreak
                                      ? ThemeTokens.surface
                                      : ThemeTokens.primary,
                                  foregroundColor: isBreak
                                      ? ThemeTokens.textPrimary
                                      : ThemeTokens.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        ThemeTokens.radiusPill),
                                    side: isBreak
                                        ? const BorderSide(
                                            color: ThemeTokens.border,
                                            width: 1,
                                          )
                                        : BorderSide.none,
                                  ),
                                  elevation: 0,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Stop Focusing',
                                    style: AppTypography.button(
                                      color: isBreak
                                          ? ThemeTokens.textPrimary
                                          : ThemeTokens.background,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Break / End Break Early Button (absent if 0 breaks configured and not currently on break)
                          if (session.breaksTotal > 0 || isBreak) ...[
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              flex: isBreak ? 5 : 3,
                              child: SizedBox(
                                height: 52,
                                child: isBreak
                                    ? ElevatedButton(
                                        key: const Key('focus_break_button'),
                                        onPressed: () => ref
                                            .read(focusSessionProvider.notifier)
                                            .endBreak(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ThemeTokens.primary,
                                          foregroundColor:
                                              ThemeTokens.background,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    ThemeTokens.radiusPill),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'End Break Early',
                                            style: AppTypography.button(
                                              color: ThemeTokens.background,
                                              weight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Opacity(
                                        opacity: session.canTakeBreak ? 1.0 : 0.4,
                                        child: OutlinedButton(
                                          key: const Key('focus_break_button'),
                                          onPressed: session.canTakeBreak
                                              ? () => ref
                                                  .read(focusSessionProvider
                                                      .notifier)
                                                  .startBreak()
                                              : null,
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: session.canTakeBreak
                                                  ? ThemeTokens.accent
                                                  : ThemeTokens.border,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ThemeTokens.radiusPill),
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Break (${session.breaksTotal - session.breaksTaken})',
                                              style: AppTypography.button(
                                                color: session.canTakeBreak
                                                    ? ThemeTokens.accent
                                                    : ThemeTokens.textMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],

                          // 3. Pause / Play Circle Button (absent during break mode per ui_focus_session.md Section 2.4)
                          if (!isBreak) ...[
                            const SizedBox(width: AppSpacing.s),
                            InkWell(
                              key: const Key('focus_pause_play_button'),
                              onTap: () {
                                if (isPaused) {
                                  ref
                                      .read(focusSessionProvider.notifier)
                                      .resumeSession();
                                } else {
                                  ref
                                      .read(focusSessionProvider.notifier)
                                      .pauseSession();
                                }
                              },
                              borderRadius:
                                  BorderRadius.circular(ThemeTokens.radiusPill),
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: ThemeTokens.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isPaused ? Icons.play_arrow : Icons.pause,
                                  color: ThemeTokens.background,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: AppSpacing.m),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMechanicalCard(
    int value,
    String unit, {
    required Color digitColor,
    bool isCompact = false,
    bool isBreak = false,
  }) {
    final double cardWidth = isCompact ? 140 : 180;
    final double cardHeight = isCompact ? 84 : 110;
    final double fontSize = isCompact ? 42 : 56;
    final double seamTop = isCompact ? 41 : 54;
    final String digits = value.toString().padLeft(2, '0');

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isBreak ? ThemeTokens.accent : ThemeTokens.border,
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top Half Subtle Shading
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: cardHeight / 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  topRight: Radius.circular(AppRadius.card),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Half Subtle Shading
          Positioned(
            top: cardHeight / 2,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.card),
                  bottomRight: Radius.circular(AppRadius.card),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),

          // Mechanical Split Seam Line
          Positioned(
            left: 0,
            right: 0,
            top: seamTop,
            child: Container(
              height: 1.5,
              color: isBreak ? ThemeTokens.accent : ThemeTokens.primary,
            ),
          ),

          // Left Hinge Notch
          Positioned(
            left: -1,
            top: seamTop - 5,
            child: Container(
              width: 5,
              height: 10,
              decoration: BoxDecoration(
                color: ThemeTokens.background,
                border: Border.all(color: ThemeTokens.border, width: 1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),

          // Right Hinge Notch
          Positioned(
            right: -1,
            top: seamTop - 5,
            child: Container(
              width: 5,
              height: 10,
              decoration: BoxDecoration(
                color: ThemeTokens.background,
                border: Border.all(color: ThemeTokens.border, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                ),
              ),
            ),
          ),

          // Digits
          Text(
            digits,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: digitColor,
              letterSpacing: 2,
            ),
          ),

          // Unit label
          Positioned(
            bottom: isCompact ? 3 : 6,
            right: isCompact ? 8 : 12,
            child: Text(
              unit,
              style: AppTypography.micro(
                color: ThemeTokens.textMuted.withValues(alpha: 0.8),
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
