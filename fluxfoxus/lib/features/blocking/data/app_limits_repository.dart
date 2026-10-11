import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/app_limit.dart';

/// Repository managing SQLite persistence for App Limits per TRD §5.2.
class AppLimitsRepository {
  final AppDatabase appDatabase;

  AppLimitsRepository({required this.appDatabase});

  Future<Database> get _db => appDatabase.database;

  /// Retrieves all app limits, seeding initial defaults if database is empty.
  Future<List<AppLimit>> getAllLimits() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.appLimits,
      orderBy: '${DatabaseTables.colLimitDailySeconds} ASC',
    );

    if (rows.isEmpty) {
      await _seedDefaultLimits(db);
      final seeded = await db.query(
        DatabaseTables.appLimits,
        orderBy: '${DatabaseTables.colLimitDailySeconds} ASC',
      );
      return seeded.map((r) => AppLimit.fromMap(r)).toList();
    }

    return rows.map((r) => AppLimit.fromMap(r)).toList();
  }

  Future<AppLimit?> getLimit(String packageName) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.appLimits,
      where: '${DatabaseTables.colLimitPackageName} = ?',
      whereArgs: [packageName],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppLimit.fromMap(rows.first);
  }

  Future<void> saveLimit(AppLimit limit) async {
    final db = await _db;
    await db.insert(
      DatabaseTables.appLimits,
      limit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLimit(AppLimit limit) async {
    final db = await _db;
    await db.update(
      DatabaseTables.appLimits,
      limit.toMap(),
      where: '${DatabaseTables.colLimitPackageName} = ?',
      whereArgs: [limit.packageName],
    );
  }

  Future<void> deleteLimit(String packageName) async {
    final db = await _db;
    await db.delete(
      DatabaseTables.appLimits,
      where: '${DatabaseTables.colLimitPackageName} = ?',
      whereArgs: [packageName],
    );
  }

  Future<void> pauseLimit(String packageName, DateTime pausedUntil) async {
    final db = await _db;
    await db.update(
      DatabaseTables.appLimits,
      {
        DatabaseTables.colLimitIsActive: 0,
        DatabaseTables.colLimitPausedUntil: pausedUntil.millisecondsSinceEpoch,
      },
      where: '${DatabaseTables.colLimitPackageName} = ?',
      whereArgs: [packageName],
    );
  }

  Future<void> resumeLimit(String packageName) async {
    final db = await _db;
    await db.update(
      DatabaseTables.appLimits,
      {
        DatabaseTables.colLimitIsActive: 1,
        DatabaseTables.colLimitPausedUntil: null,
      },
      where: '${DatabaseTables.colLimitPackageName} = ?',
      whereArgs: [packageName],
    );
  }

  /// Adds an extra session duration, respecting the 60-minute maximum cap and 6-session max.
  Future<bool> addExtraSession(String packageName, int durationSeconds) async {
    final current = await getLimit(packageName);
    if (current == null) return false;

    // Hard cap 6 sessions and 3600 seconds total
    if (current.extraSessionCount >= 6) return false;
    final totalExtra = (current.extraSessionCount * current.extraSessionDurationSeconds) + durationSeconds;
    if (totalExtra > 3600) return false;

    final updated = current.copyWith(
      extraSessionCount: current.extraSessionCount + 1,
      extraSessionDurationSeconds: durationSeconds,
    );
    await updateLimit(updated);
    return true;
  }

  Future<void> _seedDefaultLimits(Database db) async {
    final now = DateTime.now();
    final defaults = [
      AppLimit(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        category: 'Distracting',
        dailyLimitSeconds: 1800, // 30m
        streakDays: 4,
        createdAt: now,
      ),
      AppLimit(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        category: 'Distracting',
        dailyLimitSeconds: 2700, // 45m
        streakDays: 2,
        createdAt: now,
      ),
      AppLimit(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        category: 'Distracting',
        dailyLimitSeconds: 1200, // 20m
        streakDays: 7,
        createdAt: now,
      ),
      AppLimit(
        packageName: 'com.twitter.android',
        appName: 'X / Twitter',
        category: 'Distracting',
        dailyLimitSeconds: 1800, // 30m
        streakDays: 5,
        createdAt: now,
      ),
    ];

    for (final limit in defaults) {
      await db.insert(
        DatabaseTables.appLimits,
        limit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
