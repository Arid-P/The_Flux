import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Reusable smooth Bézier stacked area momentum chart matching ui_home.md and ui_usage_stats.md.
/// Renders 4 stacked category layers:
/// 1. Productive (ThemeTokens.categoryProductive)
/// 2. Semi-Productive (ThemeTokens.categorySemiProductive)
/// 3. Distracting (ThemeTokens.categoryDistracting)
/// 4. Others (ThemeTokens.categoryOthers)
class BezierMomentumChart extends StatelessWidget {
  final double height;
  final bool showLegend;
  final String productiveDuration;
  final String semiProdDuration;
  final String distractingDuration;
  final String othersDuration;

  const BezierMomentumChart({
    super.key,
    this.height = 140,
    this.showLegend = true,
    this.productiveDuration = '2h 15m',
    this.semiProdDuration = '1h 05m',
    this.distractingDuration = '45m',
    this.othersDuration = '20m',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Painted Stacked Bézier Area Chart
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _BezierChartPainter(),
          ),
        ),
        const SizedBox(height: 6),
        // X-Axis Time Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('6am', style: AppTypography.micro(color: ThemeTokens.textMuted)),
              Text('12pm', style: AppTypography.micro(color: ThemeTokens.textMuted)),
              Text('6pm', style: AppTypography.micro(color: ThemeTokens.textMuted)),
              Text('12am', style: AppTypography.micro(color: ThemeTokens.textMuted)),
            ],
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ThemeTokens.border, width: 1)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Col 1: Productive + Distracting
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s),
                      child: Column(
                        children: [
                          _buildLegendRow(
                            label: 'Productive',
                            value: productiveDuration,
                            color: ThemeTokens.categoryProductive,
                          ),
                          const SizedBox(height: 6),
                          const Divider(color: ThemeTokens.border, height: 1),
                          const SizedBox(height: 6),
                          _buildLegendRow(
                            label: 'Distracting',
                            value: distractingDuration,
                            color: ThemeTokens.categoryDistracting,
                            hasBorder: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(color: ThemeTokens.border, width: 1),
                  // Col 2: Semi-Prod + Others
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s),
                      child: Column(
                        children: [
                          _buildLegendRow(
                            label: 'Semi-Prod',
                            value: semiProdDuration,
                            color: ThemeTokens.categorySemiProductive,
                          ),
                          const SizedBox(height: 6),
                          const Divider(color: ThemeTokens.border, height: 1),
                          const SizedBox(height: 6),
                          _buildLegendRow(
                            label: 'Others',
                            value: othersDuration,
                            color: ThemeTokens.categoryOthers,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegendRow({
    required String label,
    required String value,
    required Color color,
    bool hasBorder = false,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: ThemeTokens.textMuted, width: 1) : null,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: AppTypography.micro(color: ThemeTokens.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.micro(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _BezierChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw horizontal dashed reference grid lines
    final gridPaint = Paint()
      ..color = ThemeTokens.border.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double yRatio in [0.25, 0.5, 0.75]) {
      final y = h * yRatio;
      double startX = 0;
      while (startX < w) {
        canvas.drawLine(Offset(startX, y), Offset(startX + 4, y), gridPaint);
        startX += 8;
      }
    }

    // Baseline line
    final axisPaint = Paint()
      ..color = ThemeTokens.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, h), Offset(w, h), axisPaint);

    // Layer 4: Others (Topmost Area)
    final pathOthers = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.35)
      ..cubicTo(w * 0.15, h * 0.30, w * 0.3, h * 0.20, w * 0.5, h * 0.15)
      ..cubicTo(w * 0.7, h * 0.10, w * 0.85, h * 0.18, w, h * 0.12)
      ..lineTo(w, h)
      ..close();

    final gradOthers = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ThemeTokens.categoryOthers.withValues(alpha: 0.45),
        ThemeTokens.categoryOthers.withValues(alpha: 0.05),
      ],
    );
    canvas.drawPath(pathOthers, Paint()..shader = gradOthers.createShader(Rect.fromLTWH(0, 0, w, h)));

    final strokeOthers = Paint()
      ..color = ThemeTokens.categoryOthers
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final lineOthers = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.15, h * 0.30, w * 0.3, h * 0.20, w * 0.5, h * 0.15)
      ..cubicTo(w * 0.7, h * 0.10, w * 0.85, h * 0.18, w, h * 0.12);
    canvas.drawPath(lineOthers, strokeOthers);

    // Layer 3: Distracting Area
    final pathDistracting = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.50)
      ..cubicTo(w * 0.2, h * 0.42, w * 0.35, h * 0.32, w * 0.55, h * 0.28)
      ..cubicTo(w * 0.75, h * 0.22, w * 0.88, h * 0.30, w, h * 0.25)
      ..lineTo(w, h)
      ..close();

    final gradDistracting = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ThemeTokens.categoryDistracting.withValues(alpha: 0.85),
        ThemeTokens.categoryDistracting.withValues(alpha: 0.2),
      ],
    );
    canvas.drawPath(pathDistracting, Paint()..shader = gradDistracting.createShader(Rect.fromLTWH(0, 0, w, h)));

    final strokeDistracting = Paint()
      ..color = const Color(0xFFC27838)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final lineDistracting = Path()
      ..moveTo(0, h * 0.50)
      ..cubicTo(w * 0.2, h * 0.42, w * 0.35, h * 0.32, w * 0.55, h * 0.28)
      ..cubicTo(w * 0.75, h * 0.22, w * 0.88, h * 0.30, w, h * 0.25);
    canvas.drawPath(lineDistracting, strokeDistracting);

    // Layer 2: Semi-Productive Area
    final pathSemi = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.70)
      ..cubicTo(w * 0.2, h * 0.60, w * 0.4, h * 0.45, w * 0.6, h * 0.42)
      ..cubicTo(w * 0.78, h * 0.38, w * 0.9, h * 0.45, w, h * 0.40)
      ..lineTo(w, h)
      ..close();

    final gradSemi = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ThemeTokens.categorySemiProductive.withValues(alpha: 0.8),
        ThemeTokens.categorySemiProductive.withValues(alpha: 0.15),
      ],
    );
    canvas.drawPath(pathSemi, Paint()..shader = gradSemi.createShader(Rect.fromLTWH(0, 0, w, h)));

    final strokeSemi = Paint()
      ..color = ThemeTokens.categorySemiProductive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final lineSemi = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.2, h * 0.60, w * 0.4, h * 0.45, w * 0.6, h * 0.42)
      ..cubicTo(w * 0.78, h * 0.38, w * 0.9, h * 0.45, w, h * 0.40);
    canvas.drawPath(lineSemi, strokeSemi);

    // Layer 1: Productive Area (Bottommost)
    final pathProd = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.85)
      ..cubicTo(w * 0.25, h * 0.80, w * 0.45, h * 0.65, w * 0.65, h * 0.58)
      ..cubicTo(w * 0.8, h * 0.52, w * 0.9, h * 0.60, w, h * 0.55)
      ..lineTo(w, h)
      ..close();

    final gradProd = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ThemeTokens.categoryProductive.withValues(alpha: 0.9),
        ThemeTokens.categoryProductive.withValues(alpha: 0.25),
      ],
    );
    canvas.drawPath(pathProd, Paint()..shader = gradProd.createShader(Rect.fromLTWH(0, 0, w, h)));

    final strokeProd = Paint()
      ..color = const Color(0xFF58A366)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final lineProd = Path()
      ..moveTo(0, h * 0.85)
      ..cubicTo(w * 0.25, h * 0.80, w * 0.45, h * 0.65, w * 0.65, h * 0.58)
      ..cubicTo(w * 0.8, h * 0.52, w * 0.9, h * 0.60, w, h * 0.55);
    canvas.drawPath(lineProd, strokeProd);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
