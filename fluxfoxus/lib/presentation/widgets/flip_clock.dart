import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Mechanical FlipClock widget displaying stacked flip cards for time intervals.
/// Implements mechanical split seam in ThemeTokens.primary (#CA9C68),
/// side hinge notches, top/bottom gradient shading, and monospace typography
/// matching active_focus_session.html & ff_design_override.md.
class FlipClock extends StatelessWidget {
  final Duration duration;
  final bool isBreakMode;
  final bool showHours;

  const FlipClock({
    super.key,
    required this.duration,
    this.isBreakMode = false,
    this.showHours = true,
  });

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    // If showing hours, top card is hours, bottom is minutes.
    // Otherwise, top card is minutes, bottom is seconds.
    final topValue = showHours ? hours : minutes;
    final topLabel = showHours ? 'HOURS' : 'MINUTES';
    final bottomValue = showHours ? minutes : seconds;
    final bottomLabel = showHours ? 'MINUTES' : 'SECONDS';

    final digitColor =
        isBreakMode ? ThemeTokens.accent : ThemeTokens.textPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Card
          _MechanicalFlipCard(
            value: topValue,
            subLabel: topLabel,
            digitColor: digitColor,
          ),
          const SizedBox(height: AppSpacing.m),
          // Bottom Card
          _MechanicalFlipCard(
            value: bottomValue,
            subLabel: bottomLabel,
            digitColor: digitColor,
          ),
        ],
      ),
    );
  }
}

/// A single mechanical flip card with split seam and hinge notches.
class _MechanicalFlipCard extends StatelessWidget {
  final int value;
  final String subLabel;
  final Color digitColor;

  const _MechanicalFlipCard({
    required this.value,
    required this.subLabel,
    required this.digitColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = value.toString().padLeft(2, '0');

    return Container(
      width: 280,
      height: 160,
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top Half Shading
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 80,
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
                    Colors.black.withValues(alpha: 0.20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Half Shading
          Positioned(
            top: 80,
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
                    Colors.black.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),

          // Large Monospace Digit
          Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 76,
              fontWeight: FontWeight.bold,
              color: digitColor,
              letterSpacing: 2,
            ),
          ),

          // Mechanical Split Seam Line
          Positioned(
            left: 0,
            right: 0,
            top: 79,
            child: Container(
              height: 2,
              color: ThemeTokens.primary,
            ),
          ),

          // Left Hinge Notch
          Positioned(
            left: -1,
            top: 73,
            child: Container(
              width: 7,
              height: 14,
              decoration: BoxDecoration(
                color: ThemeTokens.background,
                border: Border.all(color: ThemeTokens.border, width: 1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
          ),

          // Right Hinge Notch
          Positioned(
            right: -1,
            top: 73,
            child: Container(
              width: 7,
              height: 14,
              decoration: BoxDecoration(
                color: ThemeTokens.background,
                border: Border.all(color: ThemeTokens.border, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
          ),

          // Sub-Label in Bottom Right (e.g. HOURS / MINUTES)
          Positioned(
            bottom: 10,
            right: 14,
            child: Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: ThemeTokens.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
