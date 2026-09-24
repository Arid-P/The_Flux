import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/database/database_tables.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('AppDatabase Tests', () {
    late AppDatabase appDatabase;
    late Database db;

    setUp(() async {
      appDatabase = AppDatabase();
      db = await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('All 6 tables are created correctly', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );
      final tableNames = tables.map((row) => row['name'] as String).toSet();

      expect(
        tableNames,
        containsAll([
          DatabaseTables.presets,
          DatabaseTables.presetAppRestrictions,
          DatabaseTables.focusSessions,
          DatabaseTables.appLimits,
          DatabaseTables.streakRecords,
          DatabaseTables.studyChannels,
        ]),
      );
    });

    test('Foreign key cascade deletes preset_app_restrictions when preset is deleted', () async {
      await db.insert(DatabaseTables.presets, {
        DatabaseTables.colPresetId: 'preset-100',
        DatabaseTables.colPresetName: 'Deep Work',
        DatabaseTables.colPresetEmoji: '🎯',
        DatabaseTables.colPresetBreakCount: 3,
        DatabaseTables.colPresetBreakDuration: 5,
        DatabaseTables.colPresetYoutubeMode: 'study_mode',
        DatabaseTables.colPresetDescription: 'Flow state focus',
        DatabaseTables.colPresetCreatedAt: 1700000000,
        DatabaseTables.colPresetUpdatedAt: 1700000000,
      });

      await db.insert(DatabaseTables.presetAppRestrictions, {
        DatabaseTables.colRestrictionPresetId: 'preset-100',
        DatabaseTables.colRestrictionPackageName: 'com.instagram.android',
        DatabaseTables.colRestrictionIsBlocked: 1,
      });

      await db.insert(DatabaseTables.presetAppRestrictions, {
        DatabaseTables.colRestrictionPresetId: 'preset-100',
        DatabaseTables.colRestrictionPackageName: 'com.tiktok.android',
        DatabaseTables.colRestrictionIsBlocked: 1,
      });

      var restrictions = await db.query(
        DatabaseTables.presetAppRestrictions,
        where: '${DatabaseTables.colRestrictionPresetId} = ?',
        whereArgs: ['preset-100'],
      );
      expect(restrictions.length, 2);

      // Delete parent preset
      await db.delete(
        DatabaseTables.presets,
        where: '${DatabaseTables.colPresetId} = ?',
        whereArgs: ['preset-100'],
      );

      // Verify child restrictions are cascade deleted
      restrictions = await db.query(
        DatabaseTables.presetAppRestrictions,
        where: '${DatabaseTables.colRestrictionPresetId} = ?',
        whereArgs: ['preset-100'],
      );
      expect(restrictions.isEmpty, true);
    });

    test('CRUD operations on focus_sessions table', () async {
      // First insert foreign key preset
      await db.insert(DatabaseTables.presets, {
        DatabaseTables.colPresetId: 'preset-200',
        DatabaseTables.colPresetName: 'Study Mode',
        DatabaseTables.colPresetEmoji: '📚',
        DatabaseTables.colPresetBreakCount: 1,
        DatabaseTables.colPresetBreakDuration: 10,
        DatabaseTables.colPresetYoutubeMode: 'study_mode',
        DatabaseTables.colPresetDescription: null,
        DatabaseTables.colPresetCreatedAt: 1700000000,
        DatabaseTables.colPresetUpdatedAt: 1700000000,
      });

      // Insert focus session
      await db.insert(DatabaseTables.focusSessions, {
        DatabaseTables.colSessionId: 'sess-001',
        DatabaseTables.colSessionPresetId: 'preset-200',
        DatabaseTables.colSessionFdTaskId: 'fd-task-1',
        DatabaseTables.colSessionName: 'Math Revision',
        DatabaseTables.colSessionMode: 'stopwatch',
        DatabaseTables.colSessionScheduledStart: 1700000100,
        DatabaseTables.colSessionScheduledEnd: 1700003700,
        DatabaseTables.colSessionPlannedDuration: 3600,
        DatabaseTables.colSessionActualStart: 1700000100,
        DatabaseTables.colSessionActualEnd: 1700003700,
        DatabaseTables.colSessionActualFocusSeconds: 3300,
        DatabaseTables.colSessionStatus: 'completed',
        DatabaseTables.colSessionBreaksUsed: 1,
        DatabaseTables.colSessionSource: 'ff',
        DatabaseTables.colSessionCreatedAt: 1700000000,
      });

      final rows = await db.query(
        DatabaseTables.focusSessions,
        where: '${DatabaseTables.colSessionId} = ?',
        whereArgs: ['sess-001'],
      );
      expect(rows.length, 1);
      expect(rows.first[DatabaseTables.colSessionName], 'Math Revision');
      expect(rows.first[DatabaseTables.colSessionActualFocusSeconds], 3300);
      expect(rows.first[DatabaseTables.colSessionStatus], 'completed');

      // Update session status
      await db.update(
        DatabaseTables.focusSessions,
        {DatabaseTables.colSessionStatus: 'abandoned'},
        where: '${DatabaseTables.colSessionId} = ?',
        whereArgs: ['sess-001'],
      );

      final updated = await db.query(
        DatabaseTables.focusSessions,
        where: '${DatabaseTables.colSessionId} = ?',
        whereArgs: ['sess-001'],
      );
      expect(updated.first[DatabaseTables.colSessionStatus], 'abandoned');
    });

    test('CRUD operations on app_limits table', () async {
      await db.insert(DatabaseTables.appLimits, {
        DatabaseTables.colLimitPackageName: 'com.twitter.android',
        DatabaseTables.colLimitAppName: 'Twitter / X',
        DatabaseTables.colLimitCategory: 'distracting',
        DatabaseTables.colLimitDailySeconds: 1800,
        DatabaseTables.colLimitExtraSessionCount: 2,
        DatabaseTables.colLimitExtraSessionDuration: 300,
        DatabaseTables.colLimitIsActive: 1,
        DatabaseTables.colLimitPausedUntil: null,
        DatabaseTables.colLimitStreakDays: 5,
        DatabaseTables.colLimitCreatedAt: 1700000000,
      });

      final rows = await db.query(
        DatabaseTables.appLimits,
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: ['com.twitter.android'],
      );
      expect(rows.length, 1);
      expect(rows.first[DatabaseTables.colLimitDailySeconds], 1800);
      expect(rows.first[DatabaseTables.colLimitStreakDays], 5);
      expect(rows.first[DatabaseTables.colLimitIsActive], 1);
    });

    test('Streak records and study channels table operations', () async {
      // Streak records
      final streakId = await db.insert(DatabaseTables.streakRecords, {
        DatabaseTables.colStreakCurrent: 7,
        DatabaseTables.colStreakLongest: 14,
        DatabaseTables.colStreakMinSessionsPerDay: 2,
        DatabaseTables.colStreakLastDate: 1700000000,
        DatabaseTables.colStreakUpdatedAt: 1700000000,
      });
      expect(streakId, greaterThan(0));

      final streaks = await db.query(DatabaseTables.streakRecords);
      expect(streaks.length, 1);
      expect(streaks.first[DatabaseTables.colStreakCurrent], 7);
      expect(streaks.first[DatabaseTables.colStreakLongest], 14);

      // Study channels
      await db.insert(DatabaseTables.studyChannels, {
        DatabaseTables.colChannelId: 'UC_x5XG1OV2P6uZZ5FSM9Ttw',
        DatabaseTables.colChannelName: 'Google Developers',
        DatabaseTables.colChannelUrl: 'https://youtube.com/@googledevelopers',
        DatabaseTables.colChannelAddedAt: 1700000000,
      });

      final channels = await db.query(DatabaseTables.studyChannels);
      expect(channels.length, 1);
      expect(channels.first[DatabaseTables.colChannelName], 'Google Developers');
    });

    test('Required performance indexes are created', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%';",
      );
      final indexNames = indexes.map((row) => row['name'] as String).toSet();

      expect(
        indexNames,
        containsAll([
          'idx_focus_sessions_scheduled',
          'idx_focus_sessions_status',
          'idx_preset_restrictions_preset',
        ]),
      );
    });
  });
}
