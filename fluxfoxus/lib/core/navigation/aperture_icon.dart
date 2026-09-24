import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ApertureIcon renders the FluxFoxus signature mechanical camera aperture emblem.
class ApertureIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ApertureIcon({
    super.key,
    this.size = 24.0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AperturePainter(color: color),
    );
  }
}

class _AperturePainter extends CustomPainter {
  final Color color;

  const _AperturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.88;

    // Outer circle ring
    canvas.drawCircle(center, radius, strokePaint);

    // 6 interlocking aperture blades
    final innerRadius = radius * 0.40;
    const int bladeCount = 6;
    for (int i = 0; i < bladeCount; i++) {
      final double angle = (i * 2 * math.pi / bladeCount);
      final double nextAngle = ((i + 1.25) * 2 * math.pi / bladeCount);

      final p1 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + innerRadius * math.cos(nextAngle),
        center.dy + innerRadius * math.sin(nextAngle),
      );

      canvas.drawLine(p1, p2, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_AperturePainter oldDelegate) => oldDelegate.color != color;
}
