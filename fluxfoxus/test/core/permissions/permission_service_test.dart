import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxfoxus/core/permissions/permissions.dart';

void main() {
  group('AppPermission & PermissionDetails Tests', () {
    test('All 4 permissions have valid details and plain-language explanations', () {
      for (final perm in AppPermission.values) {
        final details = PermissionDetails.get(perm);
        expect(details.title.isNotEmpty, true);
        expect(details.shortName.isNotEmpty, true);
        expect(details.purpose.isNotEmpty, true);
        expect(details.plainLanguageExplanation.isNotEmpty, true);
        expect(details.icon, isNotNull);
      }
    });

    test('Critical permissions are correctly flagged per TRD Section 7', () {
      expect(PermissionDetails.get(AppPermission.usageStats).isCritical, true);
      expect(PermissionDetails.get(AppPermission.accessibilityService).isCritical, true);
      expect(PermissionDetails.get(AppPermission.systemAlertWindow).isCritical, true);
      expect(PermissionDetails.get(AppPermission.notifications).isCritical, false);
    });
  });

  group('DefaultPermissionService Tests', () {
    test('Evaluates isGranted with mock overrides', () async {
      final service = DefaultPermissionService(mockOverrides: {
        AppPermission.notifications: true,
        AppPermission.usageStats: false,
        AppPermission.systemAlertWindow: true,
        AppPermission.accessibilityService: false,
      });

      expect(await service.isGranted(AppPermission.notifications), true);
      expect(await service.isGranted(AppPermission.usageStats), false);
      expect(await service.isGranted(AppPermission.systemAlertWindow), true);
      expect(await service.isGranted(AppPermission.accessibilityService), false);
    });

    test('hasAllCriticalPermissions requires usage, accessibility, and overlay', () async {
      final partialService = DefaultPermissionService(mockOverrides: {
        AppPermission.usageStats: true,
        AppPermission.systemAlertWindow: true,
        AppPermission.accessibilityService: false,
      });
      expect(await partialService.hasAllCriticalPermissions(), false);

      final fullService = DefaultPermissionService(mockOverrides: {
        AppPermission.usageStats: true,
        AppPermission.systemAlertWindow: true,
        AppPermission.accessibilityService: true,
      });
      expect(await fullService.hasAllCriticalPermissions(), true);
    });

    test('checkAll returns a map containing all permissions', () async {
      final service = DefaultPermissionService(mockOverrides: {
        AppPermission.notifications: true,
        AppPermission.usageStats: true,
        AppPermission.systemAlertWindow: true,
        AppPermission.accessibilityService: true,
      });

      final all = await service.checkAll();
      expect(all.length, AppPermission.values.length);
      expect(all[AppPermission.notifications], true);
      expect(all[AppPermission.usageStats], true);
      expect(all[AppPermission.systemAlertWindow], true);
      expect(all[AppPermission.accessibilityService], true);
    });
  });

  group('PermissionsNotifier Tests', () {
    test('Loads initial permission states via permissionsStatusProvider', () async {
      final service = DefaultPermissionService(mockOverrides: {
        AppPermission.notifications: false,
        AppPermission.usageStats: false,
        AppPermission.systemAlertWindow: false,
        AppPermission.accessibilityService: false,
      });

      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(permissionsStatusProvider.future);
      expect(initial[AppPermission.notifications], false);
      expect(initial[AppPermission.usageStats], false);
      expect(initial[AppPermission.systemAlertWindow], false);
      expect(initial[AppPermission.accessibilityService], false);
    });

    test('Requesting permission triggers state update', () async {
      final service = DefaultPermissionService(mockOverrides: {
        AppPermission.notifications: true,
        AppPermission.usageStats: true,
        AppPermission.systemAlertWindow: true,
        AppPermission.accessibilityService: true,
      });

      final container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(permissionsStatusProvider.notifier);
      final granted = await notifier.requestPermission(AppPermission.notifications);
      expect(granted, true);

      final updated = await container.read(permissionsStatusProvider.future);
      expect(updated[AppPermission.notifications], true);
    });
  });
}
