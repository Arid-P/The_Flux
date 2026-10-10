import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../focus/domain/session_status.dart';
import '../../focus/presentation/focus_session_notifier.dart';
import '../../presets/presentation/presets_provider.dart';
import '../services/app_detection_service.dart';
import '../services/session_blocking_enforcer.dart';

/// Provider for AppDetectionService. Overridable with [FakeAppDetectionService] in tests.
final appDetectionServiceProvider = Provider<AppDetectionService>((ref) {
  final service = MethodChannelAppDetectionService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for SessionBlockingEnforcer managing active session app blocking.
final sessionBlockingEnforcerProvider = Provider<SessionBlockingEnforcer>((ref) {
  final appDetection = ref.watch(appDetectionServiceProvider);
  final presetsRepo = ref.watch(presetsRepositoryProvider);

  final enforcer = SessionBlockingEnforcer(
    appDetectionService: appDetection,
    presetsRepository: presetsRepo,
  );

  // Automatically synchronize with focus session state changes
  ref.listen(focusSessionProvider, (previous, next) {
    final isRunning = next?.status == SessionStatus.running;
    enforcer.syncSessionState(
      isSessionActive: isRunning,
      presetId: next?.presetId,
    );
  }, fireImmediately: true);

  enforcer.startListening();

  ref.onDispose(() => enforcer.dispose());
  return enforcer;
});
