import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/database/database_tables.dart';
import 'package:fluxfoxus/features/presets/presets.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PresetsRepository Unit Tests', () {
    late AppDatabase appDatabase;
    late Database db;
    late PresetsRepository repository;

    setUp(() async {
      appDatabase = AppDatabase();
      db = await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      repository = PresetsRepository(appDatabase: appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('getAllPresets seeds default presets on empty database', () async {
      final presets = await repository.getAllPresets();
      expect(presets.length, 3);
      expect(presets.any((p) => p.name == 'Deep Work'), true);
      expect(presets.any((p) => p.name == 'Study Session'), true);
      expect(presets.any((p) => p.name == 'Quick Sprint'), true);
    });

    test('savePreset persists preset and app restrictions in SQLite', () async {
      final now = DateTime.now();
      final preset = Preset(
        id: 'test-preset-1',
        name: 'Coding Flow',
        emoji: '💻',
        breakCount: 2,
        breakDurationMinutes: 8,
        youtubeMode: YouTubeMode.studyMode,
        description: 'Focus on coding tasks',
        createdAt: now,
        updatedAt: now,
      );

      final restrictions = [
        const PresetAppRestriction(
          presetId: 'test-preset-1',
          packageName: 'com.instagram.android',
          isBlocked: true,
        ),
        const PresetAppRestriction(
          presetId: 'test-preset-1',
          packageName: 'com.twitter.android',
          isBlocked: true,
        ),
      ];

      await repository.savePreset(preset, restrictions: restrictions);

      final fetched = await repository.getPresetById('test-preset-1');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Coding Flow');
      expect(fetched.emoji, '💻');
      expect(fetched.breakCount, 2);
      expect(fetched.breakDurationMinutes, 8);
      expect(fetched.youtubeMode, YouTubeMode.studyMode);

      final fetchedRestrictions = await repository.getRestrictions('test-preset-1');
      expect(fetchedRestrictions.length, 2);
      expect(fetchedRestrictions.any((r) => r.packageName == 'com.instagram.android'), true);
    });

    test('updatePreset updates properties and replaces restrictions', () async {
      final now = DateTime.now();
      final initial = Preset(
        id: 'test-preset-2',
        name: 'Initial Name',
        emoji: '⏳',
        breakCount: 1,
        breakDurationMinutes: 5,
        youtubeMode: YouTubeMode.block,
        createdAt: now,
        updatedAt: now,
      );
      await repository.savePreset(initial);

      final updated = initial.copyWith(
        name: 'Updated Name',
        breakCount: 3,
        youtubeMode: YouTubeMode.allow,
      );

      await repository.updatePreset(updated);

      final result = await repository.getPresetById('test-preset-2');
      expect(result!.name, 'Updated Name');
      expect(result.breakCount, 3);
      expect(result.youtubeMode, YouTubeMode.allow);
    });

    test('deletePreset cascades and removes child restrictions', () async {
      final now = DateTime.now();
      final preset = Preset(
        id: 'test-preset-delete',
        name: 'To Delete',
        createdAt: now,
        updatedAt: now,
      );
      final restriction = const PresetAppRestriction(
        presetId: 'test-preset-delete',
        packageName: 'com.tiktok.android',
        isBlocked: true,
      );

      await repository.savePreset(preset, restrictions: [restriction]);

      var restrictions = await repository.getRestrictions('test-preset-delete');
      expect(restrictions.length, 1);

      await repository.deletePreset('test-preset-delete');

      final deleted = await repository.getPresetById('test-preset-delete');
      expect(deleted, isNull);

      final remainingRestrictions = await db.query(
        DatabaseTables.presetAppRestrictions,
        where: '${DatabaseTables.colRestrictionPresetId} = ?',
        whereArgs: ['test-preset-delete'],
      );
      expect(remainingRestrictions.isEmpty, true);
    });

    test('YouTubeMode serialization and deserialization', () {
      expect(YouTubeMode.fromString('block'), YouTubeMode.block);
      expect(YouTubeMode.fromString('allow'), YouTubeMode.allow);
      expect(YouTubeMode.fromString('study_mode'), YouTubeMode.studyMode);
      expect(YouTubeMode.fromString('unknown'), YouTubeMode.studyMode);
    });
  });
}
