import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../domain/preset.dart';
import '../domain/preset_app_restriction.dart';
import '../domain/youtube_mode.dart';

/// PresetsRepository manages CRUD operations for presets and their app restrictions.
class PresetsRepository {
  final AppDatabase appDatabase;
  final HiveStorageService? hiveStorage;
  static const _uuid = Uuid();

  PresetsRepository({
    required this.appDatabase,
    this.hiveStorage,
  });

  Future<Database> get _db => appDatabase.database;

  /// Retrieves all presets ordered by created_at DESC.
  Future<List<Preset>> getAllPresets() async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.presets,
      orderBy: '${DatabaseTables.colPresetCreatedAt} DESC',
    );

    if (rows.isEmpty) {
      // Seed default presets on first access
      await seedDefaultPresets();
      final seededRows = await db.query(
        DatabaseTables.presets,
        orderBy: '${DatabaseTables.colPresetCreatedAt} DESC',
      );
      return seededRows.map(Preset.fromMap).toList();
    }

    return rows.map(Preset.fromMap).toList();
  }

  /// Retrieves a specific preset by ID.
  Future<Preset?> getPresetById(String id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.presets,
      where: '${DatabaseTables.colPresetId} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Preset.fromMap(rows.first);
  }

  /// Inserts a new preset and optional app restrictions into SQLite.
  Future<void> savePreset(
    Preset preset, {
    List<PresetAppRestriction>? restrictions,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        DatabaseTables.presets,
        preset.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (restrictions != null && restrictions.isNotEmpty) {
        final batch = txn.batch();
        for (final r in restrictions) {
          batch.insert(
            DatabaseTables.presetAppRestrictions,
            r.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }
    });

    await setLastUsedPreset(preset.id);
  }

  /// Updates an existing preset and updates its restrictions.
  Future<void> updatePreset(
    Preset preset, {
    List<PresetAppRestriction>? restrictions,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        DatabaseTables.presets,
        preset.toMap(),
        where: '${DatabaseTables.colPresetId} = ?',
        whereArgs: [preset.id],
      );

      if (restrictions != null) {
        // Delete existing restrictions for preset
        await txn.delete(
          DatabaseTables.presetAppRestrictions,
          where: '${DatabaseTables.colRestrictionPresetId} = ?',
          whereArgs: [preset.id],
        );

        // Insert new restrictions
        final batch = txn.batch();
        for (final r in restrictions) {
          batch.insert(
            DatabaseTables.presetAppRestrictions,
            r.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }
    });
  }

  /// Deletes a preset by ID (foreign keys automatically cascade delete restrictions).
  Future<void> deletePreset(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseTables.presets,
      where: '${DatabaseTables.colPresetId} = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all app restrictions for a preset.
  Future<List<PresetAppRestriction>> getRestrictions(String presetId) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseTables.presetAppRestrictions,
      where: '${DatabaseTables.colRestrictionPresetId} = ?',
      whereArgs: [presetId],
    );
    return rows.map(PresetAppRestriction.fromMap).toList();
  }

  /// Retrieves the last-used preset, defaulting to the first available preset.
  Future<Preset?> getLastUsedPreset() async {
    final lastId = hiveStorage?.lastUsedPresetId;
    if (lastId != null) {
      final preset = await getPresetById(lastId);
      if (preset != null) return preset;
    }

    final all = await getAllPresets();
    return all.isNotEmpty ? all.first : null;
  }

  /// Updates the last-used preset ID in Hive.
  Future<void> setLastUsedPreset(String presetId) async {
    await hiveStorage?.setLastUsedPresetId(presetId);
  }

  /// Seeds default presets on fresh installation.
  Future<void> seedDefaultPresets() async {
    final now = DateTime.now();
    final defaultPresets = [
      Preset(
        id: _uuid.v4(),
        name: 'Deep Work',
        emoji: '🎯',
        breakCount: 1,
        breakDurationMinutes: 5,
        youtubeMode: YouTubeMode.studyMode,
        description: 'Intense focus blocks with short recovery breaks.',
        createdAt: now,
        updatedAt: now,
      ),
      Preset(
        id: _uuid.v4(),
        name: 'Study Session',
        emoji: '📚',
        breakCount: 2,
        breakDurationMinutes: 10,
        youtubeMode: YouTubeMode.studyMode,
        description: 'Educational study with whitelisted channels allowed.',
        createdAt: now.add(const Duration(seconds: 1)),
        updatedAt: now.add(const Duration(seconds: 1)),
      ),
      Preset(
        id: _uuid.v4(),
        name: 'Quick Sprint',
        emoji: '⚡',
        breakCount: 0,
        breakDurationMinutes: 5,
        youtubeMode: YouTubeMode.block,
        description: 'Rapid sprint with all distractions blocked completely.',
        createdAt: now.add(const Duration(seconds: 2)),
        updatedAt: now.add(const Duration(seconds: 2)),
      ),
    ];

    final db = await _db;
    final batch = db.batch();
    for (final p in defaultPresets) {
      batch.insert(
        DatabaseTables.presets,
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    if (defaultPresets.isNotEmpty) {
      await setLastUsedPreset(defaultPresets.first.id);
    }
  }
}
