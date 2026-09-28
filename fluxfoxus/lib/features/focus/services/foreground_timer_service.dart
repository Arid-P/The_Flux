import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraction for managing the ongoing background foreground service.
abstract class ForegroundTimerService {
  Future<void> init();
  Future<bool> startService({required String title, required String text});
  Future<void> updateService({required String title, required String text});
  Future<bool> stopService();
  Future<bool> get isRunning;
}

/// Default production implementation using flutter_foreground_task.
class DefaultForegroundTimerService implements ForegroundTimerService {
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'focus_session_timer',
          channelName: 'Focus Session Active',
          channelDescription: 'Persistent notification during active focus session',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000),
          autoRunOnBoot: false,
          autoRunOnMyPackageReplaced: false,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('ForegroundTimerService.init error: $e');
    }
  }

  @override
  Future<bool> startService({required String title, required String text}) async {
    await init();
    try {
      final running = await FlutterForegroundTask.isRunningService;
      if (running) {
        await updateService(title: title, text: text);
        return true;
      }

      final result = await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: title,
        notificationText: text,
      );
      return result is ServiceRequestSuccess;
    } catch (e) {
      debugPrint('ForegroundTimerService.startService error: $e');
      return false;
    }
  }

  @override
  Future<void> updateService({required String title, required String text}) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } catch (e) {
      debugPrint('ForegroundTimerService.updateService error: $e');
    }
  }

  @override
  Future<bool> stopService() async {
    try {
      final result = await FlutterForegroundTask.stopService();
      return result is ServiceRequestSuccess;
    } catch (e) {
      debugPrint('ForegroundTimerService.stopService error: $e');
      return false;
    }
  }

  @override
  Future<bool> get isRunning async {
    try {
      return await FlutterForegroundTask.isRunningService;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for ForegroundTimerService.
final foregroundTimerServiceProvider = Provider<ForegroundTimerService>((ref) {
  return DefaultForegroundTimerService();
});
