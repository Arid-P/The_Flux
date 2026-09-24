import 'package:flutter/material.dart';

/// Enum representing the 4 critical permissions required by FluxFoxus.
/// Ordered per TRD Section 7.1.
enum AppPermission {
  notifications,
  usageStats,
  systemAlertWindow,
  accessibilityService,
}

/// Metadata and descriptive information for permissions.
class PermissionDetails {
  final AppPermission permission;
  final String title;
  final String shortName;
  final String purpose;
  final String plainLanguageExplanation;
  final IconData icon;
  final bool isCritical;

  const PermissionDetails({
    required this.permission,
    required this.title,
    required this.shortName,
    required this.purpose,
    required this.plainLanguageExplanation,
    required this.icon,
    this.isCritical = true,
  });

  static const Map<AppPermission, PermissionDetails> all = {
    AppPermission.notifications: PermissionDetails(
      permission: AppPermission.notifications,
      title: 'Stay Informed & On Track',
      shortName: 'Notifications',
      purpose: 'Session alerts and break notifications',
      plainLanguageExplanation:
          'FluxFoxus needs notification permissions to alert you when focus sessions start, warn you 15 minutes before scheduled blocks, and notify you when breaks end.',
      icon: Icons.notifications_active_outlined,
      isCritical: false,
    ),
    AppPermission.usageStats: PermissionDetails(
      permission: AppPermission.usageStats,
      title: 'Screen Time & Momentum Tracking',
      shortName: 'Usage Access',
      purpose: 'Track app usage and calculate 7-day rolling averages',
      plainLanguageExplanation:
          'To generate your 24h Bézier momentum chart and evaluate daily app limits, FluxFoxus reads on-device screen time statistics. Your data never leaves this device.',
      icon: Icons.bar_chart_outlined,
      isCritical: true,
    ),
    AppPermission.systemAlertWindow: PermissionDetails(
      permission: AppPermission.systemAlertWindow,
      title: 'Focus Interventions & Overlays',
      shortName: 'Display Over Other Apps',
      purpose: 'Display distraction intervention windows (2/5/10/20m)',
      plainLanguageExplanation:
          'When an app limit is reached or during active focus sessions, FluxFoxus displays a mindful intervention screen over the distracting app so you can regain control.',
      icon: Icons.layers_outlined,
      isCritical: true,
    ),
    AppPermission.accessibilityService: PermissionDetails(
      permission: AppPermission.accessibilityService,
      title: 'Distraction Blocking & YouTube Study Mode',
      shortName: 'Accessibility Service',
      purpose: 'Detect distracting apps and filter YouTube study channels',
      plainLanguageExplanation:
          'FluxFoxus monitors active window titles strictly to redirect you from blocked apps to your focus session, and to verify whitelisted educational channels in YouTube Study Mode.',
      icon: Icons.accessibility_new_outlined,
      isCritical: true,
    ),
  };

  static PermissionDetails get(AppPermission permission) => all[permission]!;
}
