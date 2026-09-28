import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';

/// Abstract repository managing streak persistence and resets.
abstract class StreakRepository {
  /// Fetches the current active streak count in days.
  Future<int> getCurrentStreak();

  /// Resets the current streak to 0 upon abandoning/quitting a session.
  Future<void> resetStreak();

  /// Sets or increments the current streak.
  Future<void> updateStreak(int days);
}

/// SQLite implementation of [StreakRepository] using [AppDatabase].
class SqliteStreakRepository implements StreakRepository {
  SqliteStreakRepository(this._database);

  final AppDatabase _database;

  @override
  Future<int> getCurrentStreak() async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseTables.streakRecords,
      columns: [DatabaseTables.colStreakCurrent],
      orderBy: '${DatabaseTables.colStreakId} DESC',
      limit: 1,
    );

    if (rows.isEmpty) return 0;
    return (rows.first[DatabaseTables.colStreakCurrent] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> resetStreak() async {
    final db = await _database.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      DatabaseTables.streakRecords,
      columns: [DatabaseTables.colStreakId],
      orderBy: '${DatabaseTables.colStreakId} DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first[DatabaseTables.colStreakId];
      await db.update(
        DatabaseTables.streakRecords,
        {
          DatabaseTables.colStreakCurrent: 0,
          DatabaseTables.colStreakUpdatedAt: nowMs,
        },
        where: '${DatabaseTables.colStreakId} = ?',
        whereArgs: [id],
      );
    } else {
      await db.insert(
        DatabaseTables.streakRecords,
        {
          DatabaseTables.colStreakCurrent: 0,
          DatabaseTables.colStreakLongest: 0,
          DatabaseTables.colStreakMinSessionsPerDay: 1,
          DatabaseTables.colStreakUpdatedAt: nowMs,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> updateStreak(int days) async {
    final db = await _database.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      DatabaseTables.streakRecords,
      orderBy: '${DatabaseTables.colStreakId} DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first[DatabaseTables.colStreakId];
      final currentLongest =
          (existing.first[DatabaseTables.colStreakLongest] as num?)?.toInt() ?? 0;
      final newLongest = days > currentLongest ? days : currentLongest;

      await db.update(
        DatabaseTables.streakRecords,
        {
          DatabaseTables.colStreakCurrent: days,
          DatabaseTables.colStreakLongest: newLongest,
          DatabaseTables.colStreakUpdatedAt: nowMs,
        },
        where: '${DatabaseTables.colStreakId} = ?',
        whereArgs: [id],
      );
    } else {
      await db.insert(
        DatabaseTables.streakRecords,
        {
          DatabaseTables.colStreakCurrent: days,
          DatabaseTables.colStreakLongest: days,
          DatabaseTables.colStreakMinSessionsPerDay: 1,
          DatabaseTables.colStreakUpdatedAt: nowMs,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}

/// Fake in-memory implementation of [StreakRepository] for testing.
class FakeStreakRepository implements StreakRepository {
  FakeStreakRepository({int initialStreak = 0}) : _streak = initialStreak;

  int _streak;

  @override
  Future<int> getCurrentStreak() async => _streak;

  @override
  Future<void> resetStreak() async {
    _streak = 0;
  }

  @override
  Future<void> updateStreak(int days) async {
    _streak = days;
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
