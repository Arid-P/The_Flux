import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service managing notification channels and triggers per TRD §5.7.1 & Step 21.
class NotificationService {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  static const String channelFocusSession = 'focus_session';
  static const String channelSessionComplete = 'session_complete';
  static const String channelWeeklyReport = 'weekly_report';
  static const String channelAppLimit = 'app_limit';

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : localNotificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Initializes Android notification channels with exact TRD importance levels.
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await localNotificationsPlugin.initialize(settings: initSettings);

      final androidPlugin = localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            channelFocusSession,
            'Focus Session',
            description: 'Session start heads-up and break alerts',
            importance: Importance.high,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelSessionComplete,
            'Session Complete',
            description: 'Notifications for completed focus sessions',
            importance: Importance.defaultImportance,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelWeeklyReport,
            'Weekly Report',
            description: 'Weekly screen time and productivity summary',
            importance: Importance.defaultImportance,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelAppLimit,
            'App Limit',
            description: 'App limit warnings and persistent service status',
            importance: Importance.low,
          ),
        );
      }
    } catch (_) {
      // Graceful degradation when running on testing environments or without Android host
    }
  }

  /// Sends a 15-minute heads-up notification before a scheduled focus session.
  Future<void> showSessionHeadsUp({
    required int id,
    required String sessionName,
    required DateTime scheduledStart,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelFocusSession,
      'Focus Session',
      channelDescription: 'Session start heads-up and break alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    try {
      await localNotificationsPlugin.show(
        id: id,
        title: 'Upcoming Session: $sessionName',
        body: 'Starts in 15 minutes. Prepare your focus environment.',
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  /// Sends a session completion notification upon timer zero.
  Future<void> showSessionComplete({
    required int id,
    required String sessionName,
    required int focusMinutes,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelSessionComplete,
      'Session Complete',
      channelDescription: 'Notifications for completed focus sessions',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    try {
      await localNotificationsPlugin.show(
        id: id,
        title: 'Session Completed! 🎉',
        body: 'You focused for $focusMinutes minutes on $sessionName.',
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  /// Sends a break end notification with vibration pattern.
  Future<void> showBreakEnd({
    required int id,
    required String sessionName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelFocusSession,
      'Focus Session',
      channelDescription: 'Session start heads-up and break alerts',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    try {
      await localNotificationsPlugin.show(
        id: id,
        title: 'Break Ended 🔔',
        body: 'Time to resume focusing on $sessionName.',
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  /// Sends the Sunday morning weekly productivity summary notification.
  Future<void> showWeeklyReport({
    required int id,
    required int totalMinutes,
    required int streakDays,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelWeeklyReport,
      'Weekly Report',
      channelDescription: 'Weekly screen time and productivity summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    final hours = totalMinutes ~/ 60;
    try {
      await localNotificationsPlugin.show(
        id: id,
        title: 'Your Weekly Focus Digest 📊',
        body: 'You achieved ${hours}h of deep work this week with a $streakDays-day streak!',
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  Future<void> cancel(int id) async {
    try {
      await localNotificationsPlugin.cancel(id: id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await localNotificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
