import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/theme_tokens.dart';

/// Donut ring custom painter for 4 categories per ui_widget.md Section 3.2.
class DonutRingPainter extends CustomPainter {
  final double productiveRatio;
  final double semiProductiveRatio;
  final double distractingRatio;
  final double othersRatio;

  const DonutRingPainter({
    required this.productiveRatio,
    required this.semiProductiveRatio,
    required this.distractingRatio,
    required this.othersRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    const strokeWidth = 12.0;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final total = productiveRatio + semiProductiveRatio + distractingRatio + othersRatio;
    if (total <= 0) {
      // Empty state
      canvas.drawCircle(
        center,
        radius,
        basePaint..color = ThemeTokens.categoryOthers.withValues(alpha: 0.3),
      );
      return;
    }

    final segments = [
      MapEntry(ThemeTokens.categoryProductive, productiveRatio / total),
      MapEntry(ThemeTokens.categorySemiProductive, semiProductiveRatio / total),
      MapEntry(ThemeTokens.categoryDistracting, distractingRatio / total),
      MapEntry(ThemeTokens.categoryOthers, othersRatio / total),
    ];

    double startAngle = -pi / 2; // start clockwise from top
    const gapAngle = 0.04; // 2px visual gap

    for (final seg in segments) {
      final sweepAngle = seg.value * 2 * pi;
      if (sweepAngle > gapAngle) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt
          ..color = seg.key;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gapAngle / 2),
          sweepAngle - gapAngle,
          false,
          paint,
        );

        // For distracting segment: draw 1px subtle border per ui_widget.md Section 3.3
        if (seg.key == ThemeTokens.categoryDistracting) {
          final borderPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = ThemeTokens.textMuted;
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius + (strokeWidth / 2)),
            startAngle + (gapAngle / 2),
            sweepAngle - gapAngle,
            false,
            borderPaint,
          );
        }
      }
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutRingPainter oldDelegate) {
    return oldDelegate.productiveRatio != productiveRatio ||
        oldDelegate.semiProductiveRatio != semiProductiveRatio ||
        oldDelegate.distractingRatio != distractingRatio ||
        oldDelegate.othersRatio != othersRatio;
  }
}
