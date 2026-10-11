import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../presets/presentation/presets_provider.dart';
import '../domain/focus_session.dart';
import '../domain/session_status.dart';

/// Repository managing FocusSession persistence in SQLite and Hive.
class FocusSessionRepository {
  final AppDatabase appDatabase;
  final HiveStorageService hiveStorageService;

  FocusSessionRepository({
    required this.appDatabase,
    required this.hiveStorageService,
  });

  /// Loads the active session from Hive if one exists (survives app kill).
  FocusSession? getActiveSession() {
    try {
      final map = hiveStorageService.getActiveFocusSession();
      if (map != null) {
        return FocusSession.fromMap(map);
      }
    } catch (_) {
      // In case box is not opened or data is corrupted
    }
    return null;
  }

  /// Persists active session state to Hive (called every 5s and on state changes).
  Future<void> saveActiveSession(FocusSession session) async {
    await hiveStorageService.saveActiveFocusSession(session.toMap());
  }

  /// Clears active session state from Hive.
  Future<void> clearActiveSession() async {
    await hiveStorageService.clearActiveFocusSession();
  }

  /// Records completed or abandoned focus session into SQLite.
  Future<void> recordFinishedSession(FocusSession session) async {
    try {
      final db = await appDatabase.database;
      await db.insert(
        DatabaseTables.focusSessions,
        {
          DatabaseTables.colSessionId: session.id,
          DatabaseTables.colSessionPresetId: session.presetId ?? 'custom_preset',
          DatabaseTables.colSessionFdTaskId: null,
          DatabaseTables.colSessionName: session.presetName,
          DatabaseTables.colSessionMode: session.timerMode.name,
          DatabaseTables.colSessionScheduledStart:
              session.startedAt.millisecondsSinceEpoch,
          DatabaseTables.colSessionScheduledEnd: session.targetDuration != null
              ? session.startedAt
                  .add(session.targetDuration!)
                  .millisecondsSinceEpoch
              : null,
          DatabaseTables.colSessionPlannedDuration:
              session.targetDuration?.inSeconds,
          DatabaseTables.colSessionActualStart:
              session.startedAt.millisecondsSinceEpoch,
          DatabaseTables.colSessionActualEnd:
              (session.completedAt ?? DateTime.now()).millisecondsSinceEpoch,
          DatabaseTables.colSessionActualFocusSeconds: session.elapsed.inSeconds,
          DatabaseTables.colSessionStatus: session.status.name,
          DatabaseTables.colSessionBreaksUsed: session.breaksTaken,
          DatabaseTables.colSessionSource: 'ff',
          DatabaseTables.colSessionCreatedAt:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (_) {
      // In tests or uninitialized environments, fail gracefully
    }
  }

  /// Retrieves all recorded sessions from SQLite.
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await appDatabase.database;
    return await db.query(
      DatabaseTables.focusSessions,
      orderBy: '${DatabaseTables.colSessionCreatedAt} DESC',
    );
  }

  /// Retrieves completed focus sessions for the given date.
  Future<List<Map<String, dynamic>>> getCompletedForDate(DateTime date) async {
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;

    final db = await appDatabase.database;
    return await db.query(
      DatabaseTables.focusSessions,
      where:
          '${DatabaseTables.colSessionStatus} = ? AND ((${DatabaseTables.colSessionActualEnd} >= ? AND ${DatabaseTables.colSessionActualEnd} <= ?) OR (${DatabaseTables.colSessionActualStart} >= ? AND ${DatabaseTables.colSessionActualStart} <= ?))',
      whereArgs: ['completed', startOfDay, endOfDay, startOfDay, endOfDay],
      orderBy: '${DatabaseTables.colSessionActualEnd} DESC',
    );
  }

  /// Retrieves scheduled focus sessions for the given date.
  Future<List<Map<String, dynamic>>> getScheduledForDate(DateTime date) async {
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;

    final db = await appDatabase.database;
    return await db.query(
      DatabaseTables.focusSessions,
      where:
          '${DatabaseTables.colSessionScheduledStart} >= ? AND ${DatabaseTables.colSessionScheduledStart} <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: '${DatabaseTables.colSessionScheduledStart} ASC',
    );
  }

  /// Creates a scheduled focus session block (e.g. from PlannerScreen).
  Future<void> createScheduledSession({
    required String id,
    required String presetId,
    required String name,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String source = 'ff',
  }) async {
    final db = await appDatabase.database;
    final durationSeconds = scheduledEnd.difference(scheduledStart).inSeconds;
    await db.insert(
      DatabaseTables.focusSessions,
      {
        DatabaseTables.colSessionId: id,
        DatabaseTables.colSessionPresetId: presetId,
        DatabaseTables.colSessionName: name,
        DatabaseTables.colSessionMode: 'countdown',
        DatabaseTables.colSessionScheduledStart: scheduledStart.millisecondsSinceEpoch,
        DatabaseTables.colSessionScheduledEnd: scheduledEnd.millisecondsSinceEpoch,
        DatabaseTables.colSessionPlannedDuration: durationSeconds > 0 ? durationSeconds : 1500,
        DatabaseTables.colSessionStatus: 'scheduled',
        DatabaseTables.colSessionBreaksUsed: 0,
        DatabaseTables.colSessionSource: source,
        DatabaseTables.colSessionCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Creates a scheduled session originating from FluxDo (source='fd', status='pending').
  Future<void> createFdSession({
    required String id,
    required String presetId,
    required String fdTaskId,
    required String name,
    required DateTime? scheduledStart,
    required DateTime? scheduledEnd,
    required int? plannedDurationMinutes,
  }) async {
    final db = await appDatabase.database;
    await db.insert(
      DatabaseTables.focusSessions,
      {
        DatabaseTables.colSessionId: id,
        DatabaseTables.colSessionPresetId: presetId,
        DatabaseTables.colSessionFdTaskId: fdTaskId,
        DatabaseTables.colSessionName: name,
        DatabaseTables.colSessionMode: 'countdown',
        DatabaseTables.colSessionScheduledStart: scheduledStart?.millisecondsSinceEpoch,
        DatabaseTables.colSessionScheduledEnd: scheduledEnd?.millisecondsSinceEpoch,
        DatabaseTables.colSessionPlannedDuration: (plannedDurationMinutes ?? 25) * 60,
        DatabaseTables.colSessionStatus: 'pending',
        DatabaseTables.colSessionBreaksUsed: 0,
        DatabaseTables.colSessionSource: 'fd',
        DatabaseTables.colSessionCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Updates a scheduled session originating from FluxDo.
  Future<void> updateFdSession({
    required String fdTaskId,
    required DateTime? scheduledStart,
    required DateTime? scheduledEnd,
    required int? plannedDurationMinutes,
  }) async {
    final db = await appDatabase.database;
    await db.update(
      DatabaseTables.focusSessions,
      {
        if (scheduledStart != null)
          DatabaseTables.colSessionScheduledStart: scheduledStart.millisecondsSinceEpoch,
        if (scheduledEnd != null)
          DatabaseTables.colSessionScheduledEnd: scheduledEnd.millisecondsSinceEpoch,
        if (plannedDurationMinutes != null)
          DatabaseTables.colSessionPlannedDuration: plannedDurationMinutes * 60,
      },
      where: '${DatabaseTables.colSessionFdTaskId} = ?',
      whereArgs: [fdTaskId],
    );
  }

  /// Deletes a scheduled session originating from FluxDo by its fdTaskId.
  Future<void> deleteFdSession(String fdTaskId) async {
    final db = await appDatabase.database;
    await db.delete(
      DatabaseTables.focusSessions,
      where: '${DatabaseTables.colSessionFdTaskId} = ?',
      whereArgs: [fdTaskId],
    );
  }

  /// Finds a focus session by its fdTaskId.
  Future<Map<String, dynamic>?> findSessionByFdTaskId(String fdTaskId) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      DatabaseTables.focusSessions,
      where: '${DatabaseTables.colSessionFdTaskId} = ?',
      whereArgs: [fdTaskId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }
}

/// Fake implementation of [FocusSessionRepository] for hermetic testing.
class FakeFocusSessionRepository implements FocusSessionRepository {
  FocusSession? active;
  final List<FocusSession> finished = [];
  final List<FocusSession> scheduled = [];

  @override
  AppDatabase get appDatabase => AppDatabase();

  @override
  HiveStorageService get hiveStorageService => HiveStorageService();

  @override
  FocusSession? getActiveSession() => active;

  @override
  Future<void> saveActiveSession(FocusSession session) async {
    active = session;
  }

  @override
  Future<void> clearActiveSession() async {
    active = null;
  }

  @override
  Future<void> recordFinishedSession(FocusSession session) async {
    finished.add(session);
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory() async => [];

  @override
  Future<List<Map<String, dynamic>>> getCompletedForDate(DateTime date) async {
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;

    return finished
        .where((s) {
          final completedTime =
              (s.completedAt ?? s.startedAt).millisecondsSinceEpoch;
          return s.status == SessionStatus.completed &&
              completedTime >= startOfDay &&
              completedTime <= endOfDay;
        })
        .map((s) => s.toMap())
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getScheduledForDate(DateTime date) async {
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;

    return scheduled
        .where((s) {
          final startTime = s.startedAt.millisecondsSinceEpoch;
          return startTime >= startOfDay && startTime <= endOfDay;
        })
        .map((s) => s.toMap())
        .toList();
  }

  @override
  Future<void> createScheduledSession({
    required String id,
    required String presetId,
    required String name,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String source = 'ff',
  }) async {}

  @override
  Future<void> createFdSession({
    required String id,
    required String presetId,
    required String fdTaskId,
    required String name,
    required DateTime? scheduledStart,
    required DateTime? scheduledEnd,
    required int? plannedDurationMinutes,
  }) async {}

  @override
  Future<void> updateFdSession({
    required String fdTaskId,
    required DateTime? scheduledStart,
    required DateTime? scheduledEnd,
    required int? plannedDurationMinutes,
  }) async {}

  @override
  Future<void> deleteFdSession(String fdTaskId) async {}

  @override
  Future<Map<String, dynamic>?> findSessionByFdTaskId(String fdTaskId) async => null;
}

/// Provider for FocusSessionRepository.
final focusSessionRepositoryProvider = Provider<FocusSessionRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  final hiveStorage = ref.watch(hiveStorageServiceProvider);
  return FocusSessionRepository(
    appDatabase: appDb,
    hiveStorageService: hiveStorage,
  );
});

