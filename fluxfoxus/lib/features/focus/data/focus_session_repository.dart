import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../presets/presentation/presets_provider.dart';
import '../domain/focus_session.dart';

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
