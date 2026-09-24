import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_permission.dart';

/// Abstract service interface for checking and requesting device permissions.
abstract class PermissionService {
  Future<bool> isGranted(AppPermission permission);
  Future<bool> request(AppPermission permission);
  Future<void> openPermissionSettings(AppPermission permission);
  Future<Map<AppPermission, bool>> checkAll();
  Future<bool> hasAllCriticalPermissions();
}

/// Production implementation of PermissionService using permission_handler.
class DefaultPermissionService implements PermissionService {
  final Map<AppPermission, bool> _mockOverrides;

  DefaultPermissionService({Map<AppPermission, bool>? mockOverrides})
      : _mockOverrides = mockOverrides ?? {};

  @override
  Future<bool> isGranted(AppPermission permission) async {
    if (_mockOverrides.containsKey(permission)) {
      return _mockOverrides[permission]!;
    }

    try {
      switch (permission) {
        case AppPermission.notifications:
          final status = await Permission.notification.status;
          return status.isGranted;
        case AppPermission.systemAlertWindow:
          final status = await Permission.systemAlertWindow.status;
          return status.isGranted;
        case AppPermission.usageStats:
        case AppPermission.accessibilityService:
          // Special system settings on Android require intent check via MethodChannel in production
          // Default to false unless granted or overridden
          return false;
      }
    } catch (e) {
      debugPrint('Error checking permission $permission: $e');
      return false;
    }
  }

  @override
  Future<bool> request(AppPermission permission) async {
    if (_mockOverrides.containsKey(permission)) {
      return _mockOverrides[permission]!;
    }

    try {
      switch (permission) {
        case AppPermission.notifications:
          final status = await Permission.notification.request();
          return status.isGranted;
        case AppPermission.systemAlertWindow:
          final status = await Permission.systemAlertWindow.request();
          return status.isGranted;
        case AppPermission.usageStats:
        case AppPermission.accessibilityService:
          await openPermissionSettings(permission);
          return false;
      }
    } catch (e) {
      debugPrint('Error requesting permission $permission: $e');
      return false;
    }
  }

  @override
  Future<void> openPermissionSettings(AppPermission permission) async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings for $permission: $e');
    }
  }

  @override
  Future<Map<AppPermission, bool>> checkAll() async {
    final results = <AppPermission, bool>{};
    for (final perm in AppPermission.values) {
      results[perm] = await isGranted(perm);
    }
    return results;
  }

  @override
  Future<bool> hasAllCriticalPermissions() async {
    final usage = await isGranted(AppPermission.usageStats);
    final accessibility = await isGranted(AppPermission.accessibilityService);
    final overlay = await isGranted(AppPermission.systemAlertWindow);
    return usage && accessibility && overlay;
  }
}

/// Riverpod provider for PermissionService.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return DefaultPermissionService();
});

/// AsyncNotifier tracking permissions status across the app.
class PermissionsNotifier extends AsyncNotifier<Map<AppPermission, bool>> {
  @override
  Future<Map<AppPermission, bool>> build() async {
    final service = ref.watch(permissionServiceProvider);
    return service.checkAll();
  }

  Future<bool> requestPermission(AppPermission permission) async {
    final service = ref.read(permissionServiceProvider);
    final granted = await service.request(permission);
    ref.invalidateSelf();
    return granted;
  }
}

/// Provider for active permissions state.
final permissionsStatusProvider =
    AsyncNotifierProvider<PermissionsNotifier, Map<AppPermission, bool>>(
  PermissionsNotifier.new,
);
