import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// UsageStatsPermissionScreen provides plain-language explanation before opening system settings per TRD Section 7.
class UsageStatsPermissionScreen extends StatelessWidget {
  const UsageStatsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: const Icon(Icons.bar_chart, size: 36, color: ThemeTokens.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Usage Stats Access',
                style: AppTypography.heading1(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'FluxFoxus needs permission to view app usage statistics in order to track screen time, evaluate daily limits, and power your focus momentum charts.',
                style: AppTypography.body(color: ThemeTokens.textMuted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('grant_usage_stats_permission_button'),
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Enable Usage Stats', style: AppTypography.button(color: ThemeTokens.background)),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }
}

/// AccessibilityPermissionScreen provides plain-language explanation before opening system settings per TRD Section 7.
class AccessibilityPermissionScreen extends StatelessWidget {
  const AccessibilityPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: const Icon(Icons.accessibility_new, size: 36, color: ThemeTokens.accent),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Accessibility Service',
                style: AppTypography.heading1(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'FluxFoxus uses the Accessibility Service to detect when distracting apps or non-educational YouTube videos are opened, redirecting you back to your focus session.',
                style: AppTypography.body(color: ThemeTokens.textMuted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('grant_accessibility_permission_button'),
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Enable Accessibility', style: AppTypography.button(color: ThemeTokens.background)),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }
}
