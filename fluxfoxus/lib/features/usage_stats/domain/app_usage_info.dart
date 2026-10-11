import 'app_category.dart';

/// Represents foreground usage statistics for an Android package.
class AppUsageInfo {
  final String packageName;
  final String appName;
  final Duration foregroundTime;
  final DateTime lastTimeUsed;
  final bool isSystemApp;
  final AppCategory category;

  const AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.foregroundTime,
    required this.lastTimeUsed,
    required this.isSystemApp,
    required this.category,
  });

  AppUsageInfo copyWith({
    String? packageName,
    String? appName,
    Duration? foregroundTime,
    DateTime? lastTimeUsed,
    bool? isSystemApp,
    AppCategory? category,
  }) {
    return AppUsageInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      foregroundTime: foregroundTime ?? this.foregroundTime,
      lastTimeUsed: lastTimeUsed ?? this.lastTimeUsed,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'foregroundTimeMs': foregroundTime.inMilliseconds,
      'lastTimeUsed': lastTimeUsed.millisecondsSinceEpoch,
      'isSystemApp': isSystemApp,
      'category': category.toStorageString(),
    };
  }

  factory AppUsageInfo.fromMap(Map<dynamic, dynamic> map, {AppCategory? categoryOverride}) {
    final rawCategory = map['category'] as String?;
    final resolvedCategory = categoryOverride ?? AppCategory.fromString(rawCategory);

    return AppUsageInfo(
      packageName: map['packageName'] as String? ?? 'unknown',
      appName: map['appName'] as String? ?? (map['packageName'] as String? ?? 'Unknown'),
      foregroundTime: Duration(milliseconds: (map['foregroundTimeMs'] as num? ?? 0).toInt()),
      lastTimeUsed: DateTime.fromMillisecondsSinceEpoch(
        (map['lastTimeUsed'] as num? ?? 0).toInt(),
      ),
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      category: resolvedCategory,
    );
  }

  String get formattedDuration {
    final totalSeconds = foregroundTime.inSeconds;
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }
}
