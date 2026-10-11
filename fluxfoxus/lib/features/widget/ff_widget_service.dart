import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../usage_stats/domain/app_category.dart';
import 'donut_ring_painter.dart';

/// Service coordinating data sync and rendering for the Android Home Screen Widget
/// per ui_widget.md and GMP_FF_BUILD.md Step 20.
class FFWidgetService {
  static const String androidWidgetName = 'FFWidgetProvider';

  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  /// Pushes updated screen time stats and active session indicator to the home widget.
  Future<void> updateWidgetData({
    required int totalMinutes,
    required int productiveMinutes,
    required int semiProductiveMinutes,
    required int distractingMinutes,
    required int otherMinutes,
    required bool isLiveFocusActive,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'total_time',
        totalMinutes > 0 ? formatMinutes(totalMinutes) : '--:--',
      );
      await HomeWidget.saveWidgetData<String>(
        'prod_time',
        productiveMinutes > 0 ? formatMinutes(productiveMinutes) : '--',
      );
      await HomeWidget.saveWidgetData<String>(
        'semi_time',
        semiProductiveMinutes > 0 ? formatMinutes(semiProductiveMinutes) : '--',
      );
      await HomeWidget.saveWidgetData<String>(
        'dist_time',
        distractingMinutes > 0 ? formatMinutes(distractingMinutes) : '--',
      );
      await HomeWidget.saveWidgetData<String>(
        'other_time',
        otherMinutes > 0 ? formatMinutes(otherMinutes) : '--',
      );
      await HomeWidget.saveWidgetData<bool>(
        'is_live',
        isLiveFocusActive,
      );

      // Render donut ring image to disk for RemoteViews ImageView
      try {
        await HomeWidget.renderFlutterWidget(
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: DonutRingPainter(
                productiveRatio: productiveMinutes.toDouble(),
                semiProductiveRatio: semiProductiveMinutes.toDouble(),
                distractingRatio: distractingMinutes.toDouble(),
                othersRatio: otherMinutes.toDouble(),
              ),
            ),
          ),
          key: 'donut_ring',
          logicalSize: const Size(100, 100),
        );
      } catch (_) {}

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (_) {
      // Gracefully handle platform exceptions in test or unsupported environments
    }
  }

  /// Convenience method converting category usage maps into widget update parameters.
  Future<void> updateFromCategoryBreakdown({
    required Map<AppCategory, int> minutesByCategory,
    bool isLiveFocusActive = false,
  }) async {
    final prod = minutesByCategory[AppCategory.productive] ?? 0;
    final semi = minutesByCategory[AppCategory.semiProductive] ?? 0;
    final dist = minutesByCategory[AppCategory.distracting] ?? 0;
    final other = minutesByCategory[AppCategory.others] ?? 0;
    final total = prod + semi + dist + other;

    await updateWidgetData(
      totalMinutes: total,
      productiveMinutes: prod,
      semiProductiveMinutes: semi,
      distractingMinutes: dist,
      otherMinutes: other,
      isLiveFocusActive: isLiveFocusActive,
    );
  }
}
