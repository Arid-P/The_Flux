import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/app_limits_screen.dart';
import '../../presentation/screens/channel_whitelist_screen.dart';
import '../../presentation/screens/focus_session_screen.dart';
import '../../presentation/screens/focus_start_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/onboarding_screens.dart';
import '../../presentation/screens/planner_screen.dart';
import '../../presentation/screens/preset_create_screen.dart';
import '../../presentation/screens/preset_edit_screen.dart';
import '../../presentation/screens/usage_stats_screen.dart';
import 'app_routes.dart';
import 'scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Provider for GoRouter instance used across the app.
final routerProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});

/// Creates a GoRouter instance implementing TRD Section 6 routes and
/// ui_navigation.md floating pill shell navigation.
GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      // Top-level 5-tab destinations wrapped inside ScaffoldWithNavBar shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Usage
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.usage,
                builder: (context, state) => const UsageStatsScreen(),
              ),
            ],
          ),
          // Tab 2: Focus
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.focus,
                builder: (context, state) => const FocusStartScreen(),
              ),
            ],
          ),
          // Tab 3: Planner
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.planner,
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),
          // Tab 4: Block / Limits
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.blocks,
                builder: (context, state) => const AppLimitsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen takeover: Active Focus Session (Bottom Nav Bar is hidden)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.focusSession,
        builder: (context, state) => const FocusSessionScreen(),
      ),

      // Pushed Screens (Slide in / overlays)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.presetCreate,
        builder: (context, state) => const PresetCreateScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.presetEdit,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PresetEditScreen(presetId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.presetChannels,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChannelWhitelistScreen(presetId: id);
        },
      ),

      // Permissions Onboarding Flows
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.usageStatsPermission,
        builder: (context, state) => const UsageStatsPermissionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.accessibilityPermission,
        builder: (context, state) => const AccessibilityPermissionScreen(),
      ),
    ],
  );
}
