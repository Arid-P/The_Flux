import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../focus/data/focus_session_repository.dart';
import '../../focus/domain/focus_session.dart';
import '../../presets/data/presets_repository.dart';
import '../../presets/domain/preset.dart';
import '../domain/focus_block_request.dart';

/// Service coordinating the bidirectional IPC bridge between FluxDo (FD)
/// and FluxFoxus (FF) per GMP_FF_BUILD.md Step 22.
class FdIntegrationService {
  static const MethodChannel _defaultChannel =
      MethodChannel('com.fluxfoxus/fd_integration');
  static const _uuid = Uuid();

  final MethodChannel channel;
  final FocusSessionRepository sessionRepository;
  final PresetsRepository presetsRepository;

  FdIntegrationService({
    MethodChannel? channel,
    required this.sessionRepository,
    required this.presetsRepository,
  }) : channel = channel ?? _defaultChannel;

  /// Registers inbound method call handler to process incoming FocusBlockRequests from FD.
  void setupIntegration() {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'focusBlockRequest':
          if (call.arguments is Map) {
            final request = FocusBlockRequest.fromMap(call.arguments as Map);
            await handleFocusBlockRequest(request);
          }
          break;
      }
    });
  }

  /// Handles incoming focusBlockRequest: CREATE, UPDATE, or DELETE.
  Future<void> handleFocusBlockRequest(FocusBlockRequest request) async {
    try {
      switch (request.action) {
        case FocusBlockAction.create:
          final presets = await presetsRepository.getAllPresets();
          if (presets.isEmpty) {
            // Per spec: if no preset exists on CREATE, skip silently
            return;
          }
          final defaultPreset = presets.first;
          await sessionRepository.createFdSession(
            id: _uuid.v4(),
            presetId: defaultPreset.id,
            fdTaskId: request.fdTaskId,
            name: request.name,
            scheduledStart: request.scheduledStart,
            scheduledEnd: request.scheduledEnd,
            plannedDurationMinutes: request.plannedDurationMinutes,
          );
          break;

        case FocusBlockAction.update:
          await sessionRepository.updateFdSession(
            fdTaskId: request.fdTaskId,
            scheduledStart: request.scheduledStart,
            scheduledEnd: request.scheduledEnd,
            plannedDurationMinutes: request.plannedDurationMinutes,
          );
          break;

        case FocusBlockAction.delete:
          await sessionRepository.deleteFdSession(request.fdTaskId);
          break;
      }
    } catch (_) {
      // Fail silently to guarantee FF never crashes on malformed IPC calls
    }
  }

  /// Outbound: Creates a corresponding "Focus Session" task in FD when started from FF.
  Future<bool> createTaskInFd({
    required FocusSession session,
    required Preset preset,
  }) async {
    try {
      final durationStr = session.targetDuration != null
          ? '${session.targetDuration!.inMinutes}'
          : 'Open-ended';

      await channel.invokeMethod('createTask', {
        'name': 'Focus Session',
        'description':
            'Preset: ${preset.name}\n'
            'Mode: ${session.timerMode.name}\n'
            'Duration: $durationStr min\n'
            'Started: ${session.startedAt.toIso8601String()}',
        'listSection': 'FF',
      });
      return true;
    } catch (_) {
      // Graceful fallback if FD is not installed or MethodChannel unavailable
      return false;
    }
  }

  /// Outbound: Queries available task lists from FD with graceful empty fallback.
  Future<List<dynamic>> getTaskListsFromFd() async {
    try {
      final lists = await channel.invokeMethod<List>('getTaskLists');
      return lists ?? [];
    } catch (_) {
      // Graceful fallback if FD is not installed
      return [];
    }
  }
}
