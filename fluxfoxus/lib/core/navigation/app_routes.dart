/// Route path and name constants for FluxFoxus.
/// Implements routes defined in TRD Section 6 and Section 7.
class AppRoutes {
  AppRoutes._();

  // Top-level tab routes
  static const String home = '/';
  static const String usage = '/usage';
  static const String focus = '/focus';
  static const String planner = '/planner';
  static const String blocks = '/blocks';

  // Session routes (takeover)
  static const String focusSession = '/focus/session';

  // Planner nested routes
  static const String presetCreate = '/planner/preset/create';
  static const String presetEdit = '/planner/preset/:id/edit';
  static const String presetChannels = '/planner/preset/:id/channels';

  static String presetEditPath(String presetId) => '/planner/preset/$presetId/edit';
  static String presetChannelsPath(String presetId) => '/planner/preset/$presetId/channels';

  // Onboarding & Permissions routes
  static const String usageStatsPermission = '/onboarding/usage_stats_permission';
  static const String accessibilityPermission = '/onboarding/accessibility_permission';
}
