import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/streak_record.dart';

/// Abstract repository managing streak persistence and resets.
abstract class StreakRepository {
  /// Fetches the current full [StreakRecord].
  Future<StreakRecord> getRecord();

  /// Fetches the current active streak count in days.
  Future<int> getCurrentStreak();

  /// Resets the current streak to 0 upon abandoning/quitting a session.
  Future<void> resetStreak();

  /// Sets or updates the current streak directly.
  Future<void> updateStreak(int days);

  /// Increments current streak by 1 and updates longest streak if exceeded.
  Future<void> incrementStreak({DateTime? date});

  /// Configures minimum required sessions per day (0 = neutral day).
  Future<void> setMinimumSessionsPerDay(int min);
}

/// SQLite implementation of [StreakRepository] using [AppDatabase].
class SqliteStreakRepository implements StreakRepository {
  SqliteStreakRepository(this._database);

  final AppDatabase _database;

  @override
  Future<StreakRecord> getRecord() async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseTables.streakRecords,
      orderBy: '${DatabaseTables.colStreakId} DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      final initial = StreakRecord.initial();
      await db.insert(
        DatabaseTables.streakRecords,
        initial.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return initial;
    }

    return StreakRecord.fromMap(rows.first);
  }

  @override
  Future<int> getCurrentStreak() async {
    final record = await getRecord();
    return record.currentStreak;
  }

  @override
  Future<void> resetStreak() async {
    final db = await _database.database;
    final now = DateTime.now();

    final existing = await db.query(
      DatabaseTables.streakRecords,
      orderBy: '${DatabaseTables.colStreakId} DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first[DatabaseTables.colStreakId];
      await db.update(
        DatabaseTables.streakRecords,
        {
          DatabaseTables.colStreakCurrent: 0,
          DatabaseTables.colStreakUpdatedAt: now.millisecondsSinceEpoch,
        },
        where: '${DatabaseTables.colStreakId} = ?',
        whereArgs: [id],
      );
    } else {
      await db.insert(
        DatabaseTables.streakRecords,
        StreakRecord.initial().toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> updateStreak(int days) async {
    final db = await _database.database;
    final now = DateTime.now();

    final existing = await db.query(
      DatabaseTables.streakRecords,
      orderBy: '${DatabaseTables.colStreakId} DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first[DatabaseTables.colStreakId];
      final currentLongest =
          (existing.first[DatabaseTables.colStreakLongest] as num?)?.toInt() ??
              0;
      final newLongest = days > currentLongest ? days : currentLongest;

      await db.update(
        DatabaseTables.streakRecords,
        {
          DatabaseTables.colStreakCurrent: days,
          DatabaseTables.colStreakLongest: newLongest,
          DatabaseTables.colStreakUpdatedAt: now.millisecondsSinceEpoch,
        },
        where: '${DatabaseTables.colStreakId} = ?',
        whereArgs: [id],
      );
    } else {
      final record = StreakRecord(
        id: 1,
        currentStreak: days,
        longestStreak: days,
        minimumSessionsPerDay: 1,
        lastStreakDate: null,
        updatedAt: now,
      );
      await db.insert(
        DatabaseTables.streakRecords,
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> incrementStreak({DateTime? date}) async {
    final currentRecord = await getRecord();
    final now = DateTime.now();
    final effectiveDate = date ?? now;
    final newCurrent = currentRecord.currentStreak + 1;
    final newLongest = newCurrent > currentRecord.longestStreak
        ? newCurrent
        : currentRecord.longestStreak;

    final db = await _database.database;
    await db.update(
      DatabaseTables.streakRecords,
      {
        DatabaseTables.colStreakCurrent: newCurrent,
        DatabaseTables.colStreakLongest: newLongest,
        DatabaseTables.colStreakLastDate: effectiveDate.millisecondsSinceEpoch,
        DatabaseTables.colStreakUpdatedAt: now.millisecondsSinceEpoch,
      },
      where: '${DatabaseTables.colStreakId} = ?',
      whereArgs: [currentRecord.id],
    );
  }

  @override
  Future<void> setMinimumSessionsPerDay(int min) async {
    final currentRecord = await getRecord();
    final now = DateTime.now();
    final db = await _database.database;

    await db.update(
      DatabaseTables.streakRecords,
      {
        DatabaseTables.colStreakMinSessionsPerDay: min,
        DatabaseTables.colStreakUpdatedAt: now.millisecondsSinceEpoch,
      },
      where: '${DatabaseTables.colStreakId} = ?',
      whereArgs: [currentRecord.id],
    );
  }
}

/// Fake in-memory implementation of [StreakRepository] for testing.
class FakeStreakRepository implements StreakRepository {
  FakeStreakRepository({
    int initialStreak = 0,
    int longestStreak = 0,
    int minimumSessionsPerDay = 1,
    DateTime? lastStreakDate,
  }) : _record = StreakRecord(
          id: 1,
          currentStreak: initialStreak,
          longestStreak: longestStreak > initialStreak ? longestStreak : initialStreak,
          minimumSessionsPerDay: minimumSessionsPerDay,
          lastStreakDate: lastStreakDate,
          updatedAt: DateTime.now(),
        );

  StreakRecord _record;

  @override
  Future<StreakRecord> getRecord() async => _record;

  @override
  Future<int> getCurrentStreak() async => _record.currentStreak;

  @override
  Future<void> resetStreak() async {
    _record = _record.copyWith(
      currentStreak: 0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateStreak(int days) async {
    final newLongest =
        days > _record.longestStreak ? days : _record.longestStreak;
    _record = _record.copyWith(
      currentStreak: days,
      longestStreak: newLongest,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> incrementStreak({DateTime? date}) async {
    final newCurrent = _record.currentStreak + 1;
    final newLongest =
        newCurrent > _record.longestStreak ? newCurrent : _record.longestStreak;
    _record = _record.copyWith(
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastStreakDate: date ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> setMinimumSessionsPerDay(int min) async {
    _record = _record.copyWith(
      minimumSessionsPerDay: min,
      updatedAt: DateTime.now(),
    );
  }
}

/// Riverpod provider for [StreakRepository].
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return SqliteStreakRepository(AppDatabase());
});

/// Riverpod provider for the current active streak count.
final currentStreakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(streakRepositoryProvider);
  return repo.getCurrentStreak();
});

/// Riverpod provider for the complete [StreakRecord].
final streakRecordProvider = FutureProvider<StreakRecord>((ref) async {
  final repo = ref.watch(streakRepositoryProvider);
  return repo.getRecord();
});
