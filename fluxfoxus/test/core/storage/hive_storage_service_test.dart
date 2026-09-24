import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fluxfoxus/core/storage/hive_storage_service.dart';

void main() {
  late Directory tempDir;
  late HiveStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    storageService = HiveStorageService();
    await storageService.init(subDir: tempDir.path);
  });

  tearDown(() async {
    await storageService.close();
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HiveStorageService - Preferences', () {
    test('Default values are returned when not set', () {
      expect(storageService.minimumSessionsPerDay, 1);
      expect(storageService.sessionStartConfirmAfterHours, 60);
      expect(storageService.lastUsedPresetId, isNull);
    });

    test('Updating preferences persists correctly', () async {
      await storageService.setMinimumSessionsPerDay(3);
      await storageService.setSessionStartConfirmAfterHours(48);
      await storageService.setLastUsedPresetId('preset_flow_state');

      expect(storageService.minimumSessionsPerDay, 3);
      expect(storageService.sessionStartConfirmAfterHours, 48);
      expect(storageService.lastUsedPresetId, 'preset_flow_state');
    });
  });

  group('HiveStorageService - App Categories', () {
    test('Can store and retrieve category overrides', () async {
      await storageService.setCategory('com.instagram.android', 'distracting');
      await storageService.setCategory('com.slack', 'productive');

      expect(storageService.getCategory('com.instagram.android'), 'distracting');
      expect(storageService.getCategory('com.slack'), 'productive');
      expect(storageService.getCategory('com.unknown'), isNull);

      final allCategories = storageService.getAllCategories();
      expect(allCategories, {
        'com.instagram.android': 'distracting',
        'com.slack': 'productive',
      });
    });
  });

  group('HiveStorageService - App Metadata', () {
    test('Can store and retrieve app metadata maps', () async {
      final metadata = {
        'appName': 'Instagram',
        'isSystemApp': false,
        'installTime': 1700000000,
      };

      await storageService.setMetadata('com.instagram.android', metadata);
      final retrieved = storageService.getMetadata('com.instagram.android');

      expect(retrieved, isNotNull);
      expect(retrieved!['appName'], 'Instagram');
      expect(retrieved['isSystemApp'], false);
    });
  });

  group('HiveStorageService - Error Handling', () {
    test('Throws StateError if accessed before initialization', () {
      final uninitService = HiveStorageService();
      expect(() => uninitService.preferencesBox, throwsStateError);
      expect(() => uninitService.categoriesBox, throwsStateError);
      expect(() => uninitService.metadataBox, throwsStateError);
    });
  });
}
