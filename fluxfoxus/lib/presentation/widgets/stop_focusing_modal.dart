import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../features/focus/domain/wait_time_calculator.dart';

/// Friction modal displayed when attempting to stop or abandon an active focus session.
///
/// Implements PRD/TRD Section 5.3.3 and `ui_focus_session.md` Section 3.
/// Features a formula-driven discipline delay (15–25 seconds) during which action
/// buttons remain locked to prevent impulsive quits.
class StopFocusingModal extends StatefulWidget {
  const StopFocusingModal({
    super.key,
    this.streakDays = 1,
    this.todayDistractingUsage = Duration.zero,
    this.avgDistractingUsage = Duration.zero,
    this.countdownOverride,
    this.onKeepGoing,
    this.onQuit,
  });

  /// Current active streak in days.
  final int streakDays;

  /// Today's cumulative distracting app screen time.
  final Duration todayDistractingUsage;

  /// Personal average daily distracting app screen time.
  final Duration avgDistractingUsage;

  /// Testing override for the initial countdown seconds.
  /// If provided, bypasses the formula calculation.
  final int? countdownOverride;

  /// Callback invoked when "Keep Going" is tapped.
  final VoidCallback? onKeepGoing;

  /// Callback invoked when "Quit Session" is confirmed.
  final VoidCallback? onQuit;

  /// Displays the modal dialog over the current screen.
  ///
  /// Returns `true` if the user confirmed "Quit Session", `false` if they tapped
  /// "Keep Going", or `null` if cancelled.
  static Future<bool?> show(
    BuildContext context, {
    int streakDays = 1,
    Duration todayDistractingUsage = Duration.zero,
    Duration avgDistractingUsage = Duration.zero,
    int? countdownOverride,
    VoidCallback? onKeepGoing,
    VoidCallback? onQuit,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: StopFocusingModal(
          streakDays: streakDays,
          todayDistractingUsage: todayDistractingUsage,
          avgDistractingUsage: avgDistractingUsage,
          countdownOverride: countdownOverride,
          onKeepGoing: onKeepGoing,
          onQuit: onQuit,
        ),
      ),
    );
  }

  @override
  State<StopFocusingModal> createState() => _StopFocusingModalState();
}

class _StopFocusingModalState extends State<StopFocusingModal> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownOverride ??
        WaitTimeCalculator.calculateWaitSeconds(
          streakDays: widget.streakDays,
          todayDistractingUsage: widget.todayDistractingUsage,
          avgDistractingUsage: widget.avgDistractingUsage,
        );

    if (_remainingSeconds > 0) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
        } else {
          _remainingSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleKeepGoing() {
    if (_remainingSeconds > 0) return;
    widget.onKeepGoing?.call();
    Navigator.of(context).pop(false);
  }

  void _handleQuit() {
    if (_remainingSeconds > 0) return;
    widget.onQuit?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = _remainingSeconds == 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: ThemeTokens.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: ThemeTokens.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Alert Bell Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ThemeTokens.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: ThemeTokens.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Primary Text
                Text(
                  'Finish the goal?',
                  textAlign: TextAlign.center,
                  style: AppTypography.heading2(
                    color: ThemeTokens.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),

                // Secondary Text
                Text(
                  'You will break your focus streak if you stop now.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    color: ThemeTokens.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Streak Display Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.m,
                    horizontal: AppSpacing.l,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeTokens.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: ThemeTokens.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'FluxFoxus Streak',
                        style: AppTypography.micro(
                          color: ThemeTokens.textMuted,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left: Amber dot + X days
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ThemeTokens.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.streakDays} days',
                            style: AppTypography.body(
                              color: ThemeTokens.textPrimary,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),

                          // Arrow
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: ThemeTokens.primary,
                          ),
                          const SizedBox(width: AppSpacing.m),

                          // Right: Grey dot + 0 days
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ThemeTokens.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '0 days',
                            style: AppTypography.body(
                              color: ThemeTokens.textMuted,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Action Buttons Row (Side by side)
                Row(
                  children: [
                    // Keep Going (Primary)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Opacity(
                          opacity: isUnlocked ? 1.0 : 0.35,
                          child: ElevatedButton(
                            key: const Key('modal_keep_going_button'),
                            onPressed: isUnlocked ? _handleKeepGoing : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeTokens.primary,
                              foregroundColor: ThemeTokens.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ThemeTokens.radiusPill,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Keep Going',
                                style: AppTypography.button(
                                  color: ThemeTokens.background,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),

                    // Quit Session (Secondary)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Opacity(
                          opacity: isUnlocked ? 1.0 : 0.35,
                          child: OutlinedButton(
                            key: const Key('modal_quit_session_button'),
                            onPressed: isUnlocked ? _handleQuit : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isUnlocked
                                    ? ThemeTokens.accent
                                    : ThemeTokens.border,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ThemeTokens.radiusPill,
                                ),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isUnlocked
                                    ? 'Quit Session'
                                    : 'Quit Session (${_remainingSeconds}s)',
                                style: AppTypography.button(
                                  color: isUnlocked
                                      ? ThemeTokens.textPrimary
                                      : ThemeTokens.textMuted,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
