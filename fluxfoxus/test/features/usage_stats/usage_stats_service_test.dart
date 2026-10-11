import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/features/usage_stats/usage_stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppCategory Domain Tests', () {
    test('fromString parses all standard categories case-insensitively', () {
      expect(AppCategory.fromString('Productive'), AppCategory.productive);
      expect(AppCategory.fromString('productive'), AppCategory.productive);
      expect(AppCategory.fromString('Semi-Productive'), AppCategory.semiProductive);
      expect(AppCategory.fromString('semiproductive'), AppCategory.semiProductive);
      expect(AppCategory.fromString('Distracting'), AppCategory.distracting);
      expect(AppCategory.fromString('distracting'), AppCategory.distracting);
      expect(AppCategory.fromString('Others'), AppCategory.others);
      expect(AppCategory.fromString('unknown_category'), AppCategory.others);
      expect(AppCategory.fromString(null), AppCategory.others);
    });

    test('toStorageString returns exact display title', () {
      expect(AppCategory.productive.toStorageString(), 'Productive');
      expect(AppCategory.semiProductive.toStorageString(), 'Semi-Productive');
      expect(AppCategory.distracting.toStorageString(), 'Distracting');
      expect(AppCategory.others.toStorageString(), 'Others');
    });
  });

  group('AppUsageInfo Domain Tests', () {
    test('Serialization and formattedDuration', () {
      final now = DateTime.now();
      final info = AppUsageInfo(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        foregroundTime: const Duration(hours: 1, minutes: 45),
        lastTimeUsed: now,
        isSystemApp: false,
        category: AppCategory.distracting,
      );

      expect(info.formattedDuration, '1h 45m');

      final map = info.toMap();
      expect(map['packageName'], 'com.instagram.android');
      expect(map['appName'], 'Instagram');
      expect(map['foregroundTimeMs'], const Duration(hours: 1, minutes: 45).inMilliseconds);
      expect(map['category'], 'Distracting');

      final reconstructed = AppUsageInfo.fromMap(map);
      expect(reconstructed.packageName, 'com.instagram.android');
      expect(reconstructed.appName, 'Instagram');
      expect(reconstructed.category, AppCategory.distracting);
      expect(reconstructed.foregroundTime, const Duration(hours: 1, minutes: 45));
    });

    test('formattedDuration handles zero, minutes only, and hours only', () {
      final now = DateTime.now();
      final zero = AppUsageInfo(
        packageName: 'a',
        appName: 'a',
        foregroundTime: Duration.zero,
        lastTimeUsed: now,
        isSystemApp: false,
        category: AppCategory.others,
      );
      expect(zero.formattedDuration, '0m');

      final mins = zero.copyWith(foregroundTime: const Duration(minutes: 25));
      expect(mins.formattedDuration, '25m');

      final hours = zero.copyWith(foregroundTime: const Duration(hours: 3));
      expect(hours.formattedDuration, '3h');
    });
  });

  group('DefaultAppCategories Tests', () {
    test('Correctly resolves standard popular apps per PRD Step 12', () {
      expect(
        DefaultAppCategories.resolveCategory('com.instagram.android'),
        AppCategory.distracting,
      );
      expect(
        DefaultAppCategories.resolveCategory('com.google.android.youtube'),
        AppCategory.distracting,
      );
      expect(
        DefaultAppCategories.resolveCategory('notion.id'),
        AppCategory.productive,
      );
      expect(
        DefaultAppCategories.resolveCategory('com.google.android.gm'),
        AppCategory.semiProductive,
      );
      expect(
        DefaultAppCategories.resolveCategory('com.random.unrecognized.app'),
        AppCategory.others,
      );
    });
  });

  group('MethodChannelUsageStatsService Mock Channel Tests', () {
    const channel = MethodChannel('com.fluxfoxus/usage_stats');
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'hasUsageStatsPermission':
            return true;
          case 'openUsageAccessSettings':
            return null;
          case 'getUsageStats':
            return [
              {
                'packageName': 'com.instagram.android',
                'appName': 'Instagram',
                'foregroundTimeMs': 3600000, // 60 mins
                'lastTimeUsed': 1700000000000,
                'isSystemApp': false,
              },
              {
                'packageName': 'notion.id',
                'appName': 'Notion',
                'foregroundTimeMs': 1800000, // 30 mins
                'lastTimeUsed': 1700000000000,
                'isSystemApp': false,
              },
            ];
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('hasPermission invokes platform channel and parses boolean', () async {
      final service = MethodChannelUsageStatsService(channel: channel);
      final hasPerm = await service.hasPermission();
      expect(hasPerm, isTrue);
      expect(log.length, 1);
      expect(log.first.method, 'hasUsageStatsPermission');
    });

    test('openUsageAccessSettings invokes platform channel', () async {
      final service = MethodChannelUsageStatsService(channel: channel);
      await service.openUsageAccessSettings();
      expect(log.length, 1);
      expect(log.first.method, 'openUsageAccessSettings');
    });

    test('getUsageStats queries platform channel and resolves categories', () async {
      final service = MethodChannelUsageStatsService(channel: channel);
      final now = DateTime.now();
      final stats = await service.getUsageStats(now.subtract(const Duration(hours: 24)), now);

      expect(stats.length, 2);
      expect(stats[0].packageName, 'com.instagram.android');
      expect(stats[0].category, AppCategory.distracting);
      expect(stats[0].foregroundTime.inMinutes, 60);

      expect(stats[1].packageName, 'notion.id');
      expect(stats[1].category, AppCategory.productive);
      expect(stats[1].foregroundTime.inMinutes, 30);
    });

    test('getCategoryBreakdown calculates cumulative durations per category', () async {
      final service = MethodChannelUsageStatsService(channel: channel);
      final fakeDate = DateTime(2026, 1, 1);
      final apps = [
        AppUsageInfo(
          packageName: 'app1',
          appName: 'App 1',
          foregroundTime: const Duration(minutes: 40),
          lastTimeUsed: fakeDate,
          isSystemApp: false,
          category: AppCategory.distracting,
        ),
        AppUsageInfo(
          packageName: 'app2',
          appName: 'App 2',
          foregroundTime: const Duration(minutes: 20),
          lastTimeUsed: fakeDate,
          isSystemApp: false,
          category: AppCategory.distracting,
        ),
        AppUsageInfo(
          packageName: 'app3',
          appName: 'App 3',
          foregroundTime: const Duration(minutes: 50),
          lastTimeUsed: fakeDate,
          isSystemApp: false,
          category: AppCategory.productive,
        ),
      ];

      final breakdown = service.getCategoryBreakdown(apps);
      expect(breakdown[AppCategory.distracting], const Duration(minutes: 60));
      expect(breakdown[AppCategory.productive], const Duration(minutes: 50));
      expect(breakdown[AppCategory.semiProductive], Duration.zero);
      expect(breakdown[AppCategory.others], Duration.zero);
    });

    test('get7DayRollingAverage calculates daily average duration', () async {
      final service = MethodChannelUsageStatsService(channel: channel);
      // In mock handler, Instagram has 3,600,000 ms (60 min)
      final avg = await service.get7DayRollingAverage('com.instagram.android');
      // 3600000 ms / 7 = ~514,285 ms (~8.5 mins)
      expect(avg.inMinutes, 8);
    });
  });
}
