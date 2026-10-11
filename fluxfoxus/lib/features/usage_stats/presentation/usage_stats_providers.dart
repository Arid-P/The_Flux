import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presets/presets.dart';
import '../domain/app_category.dart';
import '../domain/app_usage_info.dart';
import '../services/usage_stats_service.dart';

/// Provider for UsageStatsService.
final usageStatsServiceProvider = Provider<UsageStatsService>((ref) {
  final hive = ref.watch(hiveStorageServiceProvider);
  return MethodChannelUsageStatsService(hiveStorage: hive);
});

/// Provider checking whether PACKAGE_USAGE_STATS is granted.
final usageStatsPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(usageStatsServiceProvider);
  return service.hasPermission();
});

/// Provider for today's per-app usage stats.
final todayUsageStatsProvider = FutureProvider<List<AppUsageInfo>>((ref) async {
  final service = ref.watch(usageStatsServiceProvider);
  return service.getDailyUsageStats();
});

/// Family provider for specific date usage stats.
final dailyUsageStatsFamily = FutureProvider.family<List<AppUsageInfo>, DateTime>((ref, date) async {
  final service = ref.watch(usageStatsServiceProvider);
  return service.getDailyUsageStats(date: date);
});

/// Provider for 7-day rolling window usage stats.
final weeklyUsageStatsProvider = FutureProvider<List<AppUsageInfo>>((ref) async {
  final service = ref.watch(usageStatsServiceProvider);
  return service.getWeeklyUsageStats();
});

/// Provider for category breakdown durations today.
final todayCategoryBreakdownProvider = FutureProvider<Map<AppCategory, Duration>>((ref) async {
  final apps = await ref.watch(todayUsageStatsProvider.future);
  final service = ref.watch(usageStatsServiceProvider);
  return service.getCategoryBreakdown(apps);
});
