import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/features/blocking/data/app_limits_repository.dart';
import 'package:fluxfoxus/features/blocking/domain/app_limit.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppLimitsRepository Unit Tests', () {
    late AppDatabase appDatabase;
    late AppLimitsRepository repository;

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      repository = AppLimitsRepository(appDatabase: appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('getAllLimits seeds defaults when empty', () async {
      final limits = await repository.getAllLimits();
      expect(limits.isNotEmpty, true);
      expect(limits.any((l) => l.appName == 'Instagram'), true);
      expect(limits.any((l) => l.appName == 'YouTube'), true);
    });

    test('saveLimit persists a new AppLimit and retrieves it', () async {
      final now = DateTime.now();
      final customLimit = AppLimit(
        packageName: 'com.reddit.frontpage',
        appName: 'Reddit',
        category: 'Distracting',
        dailyLimitSeconds: 2400,
        streakDays: 3,
        createdAt: now,
      );

      await repository.saveLimit(customLimit);
      final retrieved = await repository.getLimit('com.reddit.frontpage');
      expect(retrieved, isNotNull);
      expect(retrieved!.appName, 'Reddit');
      expect(retrieved.dailyLimitSeconds, 2400);
      expect(retrieved.streakDays, 3);
    });

    test('pauseLimit and resumeLimit modify active and pausedUntil status', () async {
      await repository.getAllLimits(); // seeds defaults
      final pausedUntil = DateTime.now().add(const Duration(hours: 2));

      await repository.pauseLimit('com.instagram.android', pausedUntil);
      var limit = await repository.getLimit('com.instagram.android');
      expect(limit!.isActive, false);
      expect(limit.isPaused, true);

      await repository.resumeLimit('com.instagram.android');
      limit = await repository.getLimit('com.instagram.android');
      expect(limit!.isActive, true);
      expect(limit.isPaused, false);
    });

    test('addExtraSession respects 6-session cap and 60-minute limit', () async {
      await repository.getAllLimits();

      // Add 10m (600s) extra session
      final ok1 = await repository.addExtraSession('com.instagram.android', 600);
      expect(ok1, true);

      var limit = await repository.getLimit('com.instagram.android');
      expect(limit!.extraSessionCount, 1);
      expect(limit.extraSessionDurationSeconds, 600);

      // Add 5 more sessions
      for (int i = 0; i < 5; i++) {
        await repository.addExtraSession('com.instagram.android', 300);
      }

      limit = await repository.getLimit('com.instagram.android');
      expect(limit!.extraSessionCount, 6);

      // 7th session should be rejected by the cap
      final ok7 = await repository.addExtraSession('com.instagram.android', 300);
      expect(ok7, false);
    });

    test('deleteLimit removes limit entry from database', () async {
      await repository.getAllLimits();
      expect(await repository.getLimit('com.zhiliaoapp.musically'), isNotNull);

      await repository.deleteLimit('com.zhiliaoapp.musically');
      expect(await repository.getLimit('com.zhiliaoapp.musically'), isNull);
    });
  });
}
