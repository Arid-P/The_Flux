import 'dart:async';
import '../../presets/data/presets_repository.dart';
import '../domain/default_distracting_apps.dart';
import 'app_detection_service.dart';

/// Coordinates foreground application blocking enforcement during active focus sessions
/// per TRD §5.2.1 and §5.2.2.
class SessionBlockingEnforcer {
  final AppDetectionService appDetectionService;
  final PresetsRepository? presetsRepository;

  bool _isSessionActive = false;
  Set<String> _blockedPackages = {};
  StreamSubscription<String>? _subscription;

  SessionBlockingEnforcer({
    required this.appDetectionService,
    this.presetsRepository,
  });

  bool get isSessionActive => _isSessionActive;
  Set<String> get blockedPackages => Set.unmodifiable(_blockedPackages);

  /// Synchronizes active session state and updates native blocking rules.
  Future<void> syncSessionState({
    required bool isSessionActive,
    String? presetId,
    List<String>? customBlockedPackages,
  }) async {
    _isSessionActive = isSessionActive;

    List<String> effectiveList;
    if (customBlockedPackages != null) {
      effectiveList = customBlockedPackages;
    } else if (presetId != null && presetsRepository != null) {
      final restrictions = await presetsRepository!.getRestrictions(presetId);
      final blocked = restrictions.where((r) => r.isBlocked).map((r) => r.packageName).toList();
      effectiveList = blocked.isNotEmpty ? blocked : defaultDistractingPackages;
    } else {
      effectiveList = defaultDistractingPackages;
    }

    _blockedPackages = effectiveList.toSet();

    await appDetectionService.setSessionActive(isSessionActive);
    await appDetectionService.updateBlockedPackages(effectiveList);
  }

  /// Evaluates a foreground package change and triggers redirection if blocked.
  Future<bool> handleForegroundApp(
    String packageName, {
    void Function(String blockedPackage)? onRedirect,
  }) async {
    if (!_isSessionActive) {
      return false;
    }

    if (_blockedPackages.contains(packageName)) {
      await appDetectionService.redirectToApp(packageName);
      onRedirect?.call(packageName);
      return true;
    }

    return false;
  }

  /// Begins listening to the foreground app stream.
  void startListening({void Function(String blockedPackage)? onRedirect}) {
    _subscription?.cancel();
    _subscription = appDetectionService.foregroundAppStream.listen((packageName) {
      handleForegroundApp(packageName, onRedirect: onRedirect);
    });
  }

  /// Stops listening to the foreground app stream.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Releases resources.
  void dispose() {
    stopListening();
  }
}
