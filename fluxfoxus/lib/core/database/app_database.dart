import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_tables.dart';

/// AppDatabase manages the lifecycle of the local SQLite database for FluxFoxus.
class AppDatabase {
  static const String _databaseName = 'fluxfoxus.db';
  static const int _databaseVersion = 1;

  Database? _db;

  /// Returns the active SQLite database instance. Initializes if needed.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  /// Initializes database from given custom path or default platform path.
  Future<Database> initDatabase({String? customPath, DatabaseFactory? factory}) async {
    final String dbPath = customPath ?? join(await getDatabasesPath(), _databaseName);
    final dbFactory = factory ?? databaseFactory;

    return await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onConfigure: (db) async {
          // Enable foreign keys
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Future migrations
        },
      ),
    );
  }

  /// Creates all 6 core tables and performance indexes.
  static Future<void> _createTables(DatabaseExecutor db) async {
    await db.execute(DatabaseTables.createPresetsTable);
    await db.execute(DatabaseTables.createPresetAppRestrictionsTable);
    await db.execute(DatabaseTables.createFocusSessionsTable);
    await db.execute(DatabaseTables.createAppLimitsTable);
    await db.execute(DatabaseTables.createStreakRecordsTable);
    await db.execute(DatabaseTables.createStudyChannelsTable);

    // Performance Indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_sessions_scheduled ON ${DatabaseTables.focusSessions}(${DatabaseTables.colSessionScheduledStart});',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_sessions_status ON ${DatabaseTables.focusSessions}(${DatabaseTables.colSessionStatus});',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_preset_restrictions_preset ON ${DatabaseTables.presetAppRestrictions}(${DatabaseTables.colRestrictionPresetId});',
    );
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
