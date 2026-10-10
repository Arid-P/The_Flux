import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/features/focus/data/streak_repository.dart';
import 'package:fluxfoxus/features/focus/domain/streak_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StreakRecord Domain Entity Tests', () {
    test('StreakRecord.initial produces valid baseline', () {
      final initial = StreakRecord.initial();
      expect(initial.id, 1);
      expect(initial.currentStreak, 0);
      expect(initial.longestStreak, 0);
      expect(initial.minimumSessionsPerDay, 1);
      expect(initial.lastStreakDate, isNull);
      expect(initial.isNeutralDay, isFalse);
    });

    test('isNeutralDay is true when minimumSessionsPerDay is 0', () {
      final neutral = StreakRecord(
        id: 1,
        currentStreak: 5,
        longestStreak: 10,
        minimumSessionsPerDay: 0,
        updatedAt: DateTime.now(),
      );
      expect(neutral.isNeutralDay, isTrue);
    });

    test('toMap and fromMap serialization roundtrip', () {
      final date = DateTime(2026, 3, 15, 14, 30);
      final record = StreakRecord(
        id: 1,
        currentStreak: 12,
        longestStreak: 25,
        minimumSessionsPerDay: 2,
        lastStreakDate: date,
        updatedAt: date,
      );

      final map = record.toMap();
      final restored = StreakRecord.fromMap(map);

      expect(restored.id, record.id);
      expect(restored.currentStreak, 12);
      expect(restored.longestStreak, 25);
      expect(restored.minimumSessionsPerDay, 2);
      expect(restored.lastStreakDate, date);
    });

    test('copyWith updates specified fields only', () {
      final record = StreakRecord.initial();
      final updated = record.copyWith(
        currentStreak: 7,
        longestStreak: 14,
      );

      expect(updated.currentStreak, 7);
      expect(updated.longestStreak, 14);
      expect(updated.minimumSessionsPerDay, record.minimumSessionsPerDay);
    });
  });

  group('SqliteStreakRepository Tests', () {
    late AppDatabase appDatabase;
    late SqliteStreakRepository repository;

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      repository = SqliteStreakRepository(appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('getRecord creates initial default record when database is empty', () async {
      final record = await repository.getRecord();
      expect(record.currentStreak, 0);
      expect(record.longestStreak, 0);
      expect(record.minimumSessionsPerDay, 1);

      final current = await repository.getCurrentStreak();
      expect(current, 0);
    });

    test('incrementStreak increments current and longest streak', () async {
      final evalDate = DateTime(2026, 3, 20);
      await repository.incrementStreak(date: evalDate);

      var record = await repository.getRecord();
      expect(record.currentStreak, 1);
      expect(record.longestStreak, 1);
      expect(record.lastStreakDate, evalDate);

      // Second increment
      await repository.incrementStreak(date: evalDate.add(const Duration(days: 1)));
      record = await repository.getRecord();
      expect(record.currentStreak, 2);
      expect(record.longestStreak, 2);
    });

    test('resetStreak resets current streak to 0 but preserves longest streak', () async {
      await repository.updateStreak(10);
      var record = await repository.getRecord();
      expect(record.currentStreak, 10);
      expect(record.longestStreak, 10);

      await repository.resetStreak();
      record = await repository.getRecord();
      expect(record.currentStreak, 0);
      expect(record.longestStreak, 10);
    });

    test('setMinimumSessionsPerDay updates configuration', () async {
      await repository.setMinimumSessionsPerDay(0);
      var record = await repository.getRecord();
      expect(record.minimumSessionsPerDay, 0);
      expect(record.isNeutralDay, isTrue);

      await repository.setMinimumSessionsPerDay(3);
      record = await repository.getRecord();
      expect(record.minimumSessionsPerDay, 3);
      expect(record.isNeutralDay, isFalse);
    });
  });

  group('FakeStreakRepository Tests', () {
    test('FakeStreakRepository adheres to contract in-memory', () async {
      final fake = FakeStreakRepository(initialStreak: 3, longestStreak: 7);
      expect(await fake.getCurrentStreak(), 3);

      var record = await fake.getRecord();
      expect(record.currentStreak, 3);
      expect(record.longestStreak, 7);

      await fake.incrementStreak();
      record = await fake.getRecord();
      expect(record.currentStreak, 4);
      expect(record.longestStreak, 7);

      await fake.resetStreak();
      record = await fake.getRecord();
      expect(record.currentStreak, 0);
      expect(record.longestStreak, 7);

      await fake.setMinimumSessionsPerDay(0);
      record = await fake.getRecord();
      expect(record.isNeutralDay, isTrue);
    });
  });
}
