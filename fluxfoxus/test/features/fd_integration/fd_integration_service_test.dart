import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/storage/hive_storage_service.dart';
import 'package:fluxfoxus/features/fd_integration/fd_integration.dart';
import 'package:fluxfoxus/features/focus/data/focus_session_repository.dart';
import 'package:fluxfoxus/features/focus/domain/focus_session.dart';
import 'package:fluxfoxus/features/focus/domain/session_status.dart';
import 'package:fluxfoxus/features/focus/domain/timer_mode.dart';
import 'package:fluxfoxus/features/presets/presets.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('FocusBlockRequest Domain Tests', () {
    test('fromMap parses create, update, and delete actions with timestamps', () {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final createReq = FocusBlockRequest.fromMap({
        'action': 'create',
        'fdTaskId': 'task-123',
        'name': 'Sprint 1',
        'scheduledStart': nowMs,
        'scheduledEnd': nowMs + 1800000,
        'plannedDurationMinutes': 30,
      });

      expect(createReq.action, FocusBlockAction.create);
      expect(createReq.fdTaskId, 'task-123');
      expect(createReq.name, 'Sprint 1');
      expect(createReq.plannedDurationMinutes, 30);
      expect(createReq.scheduledStart?.millisecondsSinceEpoch, nowMs);

      final updateReq = FocusBlockRequest.fromMap({
        'action': 'update',
        'fdTaskId': 'task-123',
        'plannedDurationMinutes': 45,
      });
      expect(updateReq.action, FocusBlockAction.update);

      final deleteReq = FocusBlockRequest.fromMap({
        'action': 'delete',
        'fdTaskId': 'task-123',
      });
      expect(deleteReq.action, FocusBlockAction.delete);
    });
  });

  group('FdIntegrationService SQLite Integration Tests', () {
    late AppDatabase appDatabase;
    late FocusSessionRepository sessionRepo;
    late PresetsRepository presetsRepo;
    late FdIntegrationService service;

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      sessionRepo = FocusSessionRepository(
        appDatabase: appDatabase,
        hiveStorageService: HiveStorageService(),
      );
      presetsRepo = PresetsRepository(appDatabase: appDatabase);
      service = FdIntegrationService(
        sessionRepository: sessionRepo,
        presetsRepository: presetsRepo,
      );
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('handleFocusBlockRequest CREATE creates pending session with source=fd', () async {
      // Seed presets so default preset exists
      await presetsRepo.getAllPresets();

      final now = DateTime.now();
      final request = FocusBlockRequest(
        action: FocusBlockAction.create,
        fdTaskId: 'fd-task-abc',
        name: 'Math Study Block',
        scheduledStart: now,
        scheduledEnd: now.add(const Duration(minutes: 50)),
        plannedDurationMinutes: 50,
      );

      await service.handleFocusBlockRequest(request);

      final created = await sessionRepo.findSessionByFdTaskId('fd-task-abc');
      expect(created, isNotNull);
      expect(created!['session_name'], 'Math Study Block');
      expect(created['source'], 'fd');
      expect(created['status'], 'pending');
      expect(created['planned_duration_seconds'], 50 * 60);
    });

    test('handleFocusBlockRequest UPDATE updates session times', () async {
      await presetsRepo.getAllPresets();

      await service.handleFocusBlockRequest(
        const FocusBlockRequest(
          action: FocusBlockAction.create,
          fdTaskId: 'fd-task-update',
          name: 'Original Session',
          plannedDurationMinutes: 25,
        ),
      );

      await service.handleFocusBlockRequest(
        const FocusBlockRequest(
          action: FocusBlockAction.update,
          fdTaskId: 'fd-task-update',
          plannedDurationMinutes: 40,
        ),
      );

      final updated = await sessionRepo.findSessionByFdTaskId('fd-task-update');
      expect(updated, isNotNull);
      expect(updated!['planned_duration_seconds'], 40 * 60);
    });

    test('handleFocusBlockRequest DELETE deletes session by fdTaskId', () async {
      await presetsRepo.getAllPresets();

      await service.handleFocusBlockRequest(
        const FocusBlockRequest(
          action: FocusBlockAction.create,
          fdTaskId: 'fd-task-delete',
          name: 'To Be Deleted',
        ),
      );

      expect(await sessionRepo.findSessionByFdTaskId('fd-task-delete'), isNotNull);

      await service.handleFocusBlockRequest(
        const FocusBlockRequest(
          action: FocusBlockAction.delete,
          fdTaskId: 'fd-task-delete',
        ),
      );

      expect(await sessionRepo.findSessionByFdTaskId('fd-task-delete'), isNull);
    });

    test('Outbound calls fail gracefully when FD is not connected', () async {
      final now = DateTime.now();
      final testSession = FocusSession(
        id: 'sess-1',
        presetName: 'Deep Work',
        presetEmoji: '🔥',
        timerMode: TimerMode.countdown,
        status: SessionStatus.running,
        elapsed: Duration.zero,
        targetDuration: const Duration(minutes: 45),
        breaksTotal: 2,
        breaksTaken: 0,
        startedAt: now,
        lastResumedAt: now,
      );
      final testPreset = Preset(
        id: 'preset-1',
        name: 'Deep Work',
        emoji: '🔥',
        breakCount: 2,
        breakDurationMinutes: 5,
        youtubeMode: YouTubeMode.studyMode,
        createdAt: now,
        updatedAt: now,
      );

      // Should not throw, should return false gracefully
      final created = await service.createTaskInFd(
        session: testSession,
        preset: testPreset,
      );
      expect(created, false);

      final lists = await service.getTaskListsFromFd();
      expect(lists, isEmpty);
    });
  });
}
