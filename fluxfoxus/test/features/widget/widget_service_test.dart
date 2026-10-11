import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/usage_stats/domain/app_category.dart';
import 'package:fluxfoxus/features/widget/widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FFWidgetService & DonutRingPainter Unit Tests', () {
    test('formatMinutes formats 0, minutes, hours, and mixed hours/minutes', () {
      expect(FFWidgetService.formatMinutes(0), '0m');
      expect(FFWidgetService.formatMinutes(45), '45m');
      expect(FFWidgetService.formatMinutes(60), '1h');
      expect(FFWidgetService.formatMinutes(189), '3h 9m');
    });

    test('DonutRingPainter paints empty state without throwing', () {
      const painter = DonutRingPainter(
        productiveRatio: 0,
        semiProductiveRatio: 0,
        distractingRatio: 0,
        othersRatio: 0,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(100, 100));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('DonutRingPainter paints 4 segments with borders without throwing', () {
      const painter = DonutRingPainter(
        productiveRatio: 40,
        semiProductiveRatio: 20,
        distractingRatio: 30,
        othersRatio: 10,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(100, 100));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('FFWidgetService updateFromCategoryBreakdown completes without throwing', () async {
      final service = FFWidgetService();
      await service.updateFromCategoryBreakdown(
        minutesByCategory: {
          AppCategory.productive: 120,
          AppCategory.semiProductive: 45,
          AppCategory.distracting: 30,
          AppCategory.others: 15,
        },
        isLiveFocusActive: true,
      );
    });
  });
}
