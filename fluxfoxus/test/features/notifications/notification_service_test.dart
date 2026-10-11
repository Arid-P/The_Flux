import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/notifications/notifications.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Unit Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
    });

    test('Channel IDs match TRD Section 5.7.1 requirements', () {
      expect(NotificationService.channelFocusSession, 'focus_session');
      expect(NotificationService.channelSessionComplete, 'session_complete');
      expect(NotificationService.channelWeeklyReport, 'weekly_report');
      expect(NotificationService.channelAppLimit, 'app_limit');
    });

    test('initialize executes without unhandled exception', () async {
      await service.initialize();
    });

    test('showSessionHeadsUp executes without unhandled exception', () async {
      await service.showSessionHeadsUp(
        id: 101,
        sessionName: 'Deep Work',
        scheduledStart: DateTime.now().add(const Duration(minutes: 15)),
      );
    });

    test('showSessionComplete executes without unhandled exception', () async {
      await service.showSessionComplete(
        id: 102,
        sessionName: 'Coding Sprint',
        focusMinutes: 45,
      );
    });

    test('showBreakEnd executes without unhandled exception', () async {
      await service.showBreakEnd(
        id: 103,
        sessionName: 'Study Block',
      );
    });

    test('showWeeklyReport executes without unhandled exception', () async {
      await service.showWeeklyReport(
        id: 104,
        totalMinutes: 1250,
        streakDays: 6,
      );
    });

    test('cancel and cancelAll execute without unhandled exception', () async {
      await service.cancel(101);
      await service.cancelAll();
    });
  });
}
