import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluxfoxus/core/navigation/navigation.dart';
import 'package:fluxfoxus/core/permissions/permissions.dart';
import 'package:fluxfoxus/presentation/screens/home_screen.dart';
import 'package:fluxfoxus/presentation/screens/onboarding_screens.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildOnboardingTestApp({
    String initialLocation = AppRoutes.permissionsOnboarding,
    Map<AppPermission, bool>? mockOverrides,
  }) {
    final testService = DefaultPermissionService(
      mockOverrides: mockOverrides ??
          {
            AppPermission.notifications: false,
            AppPermission.usageStats: false,
            AppPermission.systemAlertWindow: false,
            AppPermission.accessibilityService: false,
          },
    );

    final router = createAppRouter(initialLocation: initialLocation);

    return ProviderScope(
      overrides: [
        permissionServiceProvider.overrideWithValue(testService),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('PermissionsOnboardingFlowScreen Tests', () {
    testWidgets('Renders Step 1 (Notifications) with all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildOnboardingTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(PermissionsOnboardingFlowScreen), findsOneWidget);
      expect(find.text('Permissions (1/4)'), findsOneWidget);
      expect(find.byKey(const Key('step_progress_indicator')), findsOneWidget);
      expect(find.text(PermissionDetails.get(AppPermission.notifications).title), findsOneWidget);
      expect(find.text(PermissionDetails.get(AppPermission.notifications).purpose), findsOneWidget);
      expect(find.byKey(const Key('permission_primary_button')), findsOneWidget);
      expect(find.text('Enable Notifications'), findsOneWidget);
    });

    testWidgets('Tapping primary action button advances from Step 1 to Step 2', (WidgetTester tester) async {
      await tester.pumpWidget(buildOnboardingTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Permissions (1/4)'), findsOneWidget);

      await tester.tap(find.byKey(const Key('permission_primary_button')));
      await tester.pumpAndSettle();

      expect(find.text('Permissions (2/4)'), findsOneWidget);
      expect(find.text(PermissionDetails.get(AppPermission.usageStats).title), findsOneWidget);
    });

    testWidgets('Tapping skip button advances through steps without granting', (WidgetTester tester) async {
      await tester.pumpWidget(buildOnboardingTestApp());
      await tester.pumpAndSettle();

      // Step 1 -> Skip to Step 2
      await tester.tap(find.byKey(const Key('permission_secondary_button')));
      await tester.pumpAndSettle();
      expect(find.text('Permissions (2/4)'), findsOneWidget);

      // Step 2 -> Skip to Step 3
      await tester.tap(find.byKey(const Key('permission_secondary_button')));
      await tester.pumpAndSettle();
      expect(find.text('Permissions (3/4)'), findsOneWidget);
      expect(find.text(PermissionDetails.get(AppPermission.systemAlertWindow).title), findsOneWidget);

      // Back button works
      expect(find.byKey(const Key('permission_back_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('permission_back_button')));
      await tester.pumpAndSettle();
      expect(find.text('Permissions (2/4)'), findsOneWidget);
    });

    testWidgets('Tapping Skip All immediately navigates to Home', (WidgetTester tester) async {
      await tester.pumpWidget(buildOnboardingTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('permission_skip_all_button')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Standalone Permission Redirect Screens Tests', () {
    testWidgets('UsageStatsPermissionScreen renders explanation and navigates on grant', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildOnboardingTestApp(initialLocation: AppRoutes.usageStatsPermission),
      );
      await tester.pumpAndSettle();

      expect(find.byType(UsageStatsPermissionScreen), findsOneWidget);
      expect(find.text(PermissionDetails.get(AppPermission.usageStats).title), findsOneWidget);
      expect(find.byKey(const Key('grant_usage_stats_permission_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('grant_usage_stats_permission_button')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AccessibilityPermissionScreen renders explanation and navigates on grant', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildOnboardingTestApp(initialLocation: AppRoutes.accessibilityPermission),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccessibilityPermissionScreen), findsOneWidget);
      expect(find.text(PermissionDetails.get(AppPermission.accessibilityService).title), findsOneWidget);
      expect(find.byKey(const Key('grant_accessibility_permission_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('grant_accessibility_permission_button')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
