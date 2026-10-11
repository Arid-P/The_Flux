import 'dart:async';
import 'package:flutter/services.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../data/default_app_categories.dart';
import '../domain/app_category.dart';
import '../domain/app_usage_info.dart';

/// Abstract service interface for Android UsageStats integration per PRD Step 12.
abstract class UsageStatsService {
  Future<bool> hasPermission();
  Future<void> openUsageAccessSettings();
  Future<List<AppUsageInfo>> getUsageStats(DateTime startTime, DateTime endTime);
  Future<List<AppUsageInfo>> getDailyUsageStats({DateTime? date});
  Future<List<AppUsageInfo>> getWeeklyUsageStats({DateTime? endDate});
  Future<Duration> get7DayRollingAverage(String packageName);
  Map<AppCategory, Duration> getCategoryBreakdown(List<AppUsageInfo> apps);
}

/// Production implementation using MethodChannel and Hive persistence.
class MethodChannelUsageStatsService implements UsageStatsService {
  static const MethodChannel defaultChannel = MethodChannel('com.fluxfoxus/usage_stats');

  final MethodChannel _channel;
  final HiveStorageService? _hiveStorage;

  MethodChannelUsageStatsService({
    MethodChannel? channel,
    this._hiveStorage,
  }) : _channel = channel ?? defaultChannel;

  @override
  Future<bool> hasPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('hasUsageStatsPermission');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> openUsageAccessSettings() async {
    try {
      await _channel.invokeMethod<void>('openUsageAccessSettings');
    } on PlatformException {
      // Ignored if settings cannot be opened on current device/environment
    }
  }

  @override
  Future<List<AppUsageInfo>> getUsageStats(DateTime startTime, DateTime endTime) async {
    try {
      final rawStats = await _channel.invokeListMethod<dynamic>('getUsageStats', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });

      if (rawStats == null) return [];

      final List<AppUsageInfo> result = [];
      for (final item in rawStats) {
        if (item is Map) {
          final pkg = item['packageName'] as String? ?? '';
          if (pkg.isEmpty) continue;

          // Check Hive user category override, then predefined defaults
          final customCategory = _hiveStorage?.getCategory(pkg);
          final category = customCategory != null
              ? AppCategory.fromString(customCategory)
              : DefaultAppCategories.resolveCategory(pkg);

          final usageInfo = AppUsageInfo.fromMap(item, categoryOverride: category);
          result.add(usageInfo);

          // Save metadata into Hive cache if storage is available
          if (_hiveStorage != null && item['appName'] != null) {
            _hiveStorage.setMetadata(pkg, {
              'appName': item['appName'],
              'isSystemApp': item['isSystemApp'] ?? false,
              'category': category.toStorageString(),
            });
          }
        }
      }

      result.sort((a, b) => b.foregroundTime.compareTo(a.foregroundTime));
      return result;
    } on PlatformException {
      return [];
    }
  }

  @override
  Future<List<AppUsageInfo>> getDailyUsageStats({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final startOfDay = DateTime(target.year, target.month, target.day, 0, 0, 0);
    final endOfDay = DateTime(target.year, target.month, target.day, 23, 59, 59, 999);
    return getUsageStats(startOfDay, endOfDay);
  }

  @override
  Future<List<AppUsageInfo>> getWeeklyUsageStats({DateTime? endDate}) async {
    final target = endDate ?? DateTime.now();
    final startOfPeriod = target.subtract(const Duration(days: 7));
    return getUsageStats(startOfPeriod, target);
  }

  @override
  Future<Duration> get7DayRollingAverage(String packageName) async {
    final now = DateTime.now();
    final weekly = await getWeeklyUsageStats(endDate: now);
    final match = weekly.where((app) => app.packageName == packageName);
    if (match.isEmpty) return Duration.zero;

    final totalMs = match.first.foregroundTime.inMilliseconds;
    return Duration(milliseconds: totalMs ~/ 7);
  }

  @override
  Map<AppCategory, Duration> getCategoryBreakdown(List<AppUsageInfo> apps) {
    final breakdown = <AppCategory, Duration>{
      AppCategory.productive: Duration.zero,
      AppCategory.semiProductive: Duration.zero,
      AppCategory.distracting: Duration.zero,
      AppCategory.others: Duration.zero,
    };

    for (final app in apps) {
      final current = breakdown[app.category] ?? Duration.zero;
      breakdown[app.category] = current + app.foregroundTime;
    }

    return breakdown;
  }
}
