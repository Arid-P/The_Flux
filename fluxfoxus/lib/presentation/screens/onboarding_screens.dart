import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/permissions/permissions.dart';
import '../../core/theme/theme.dart';

/// PermissionsOnboardingFlowScreen presents the 4-step first-launch permissions wizard
/// in exact order per TRD Section 7.1:
/// 1. POST_NOTIFICATIONS
/// 2. PACKAGE_USAGE_STATS
/// 3. SYSTEM_ALERT_WINDOW
/// 4. ACCESSIBILITY_SERVICE
class PermissionsOnboardingFlowScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const PermissionsOnboardingFlowScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  ConsumerState<PermissionsOnboardingFlowScreen> createState() =>
      _PermissionsOnboardingFlowScreenState();
}

class _PermissionsOnboardingFlowScreenState
    extends ConsumerState<PermissionsOnboardingFlowScreen> {
  late int _currentStep;
  final Map<AppPermission, bool> _grantedMap = {};

  final List<AppPermission> _steps = const [
    AppPermission.notifications,
    AppPermission.usageStats,
    AppPermission.systemAlertWindow,
    AppPermission.accessibilityService,
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, _steps.length - 1);
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final service = ref.read(permissionServiceProvider);
    for (final perm in _steps) {
      final granted = await service.isGranted(perm);
      if (mounted) {
        setState(() {
          _grantedMap[perm] = granted;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _handleAction(AppPermission permission) async {
    final service = ref.read(permissionServiceProvider);
    final granted = await service.request(permission);
    if (mounted) {
      setState(() {
        _grantedMap[permission] = granted;
      });
      _nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPermission = _steps[_currentStep];
    final details = PermissionDetails.get(currentPermission);
    final isGranted = _grantedMap[currentPermission] ?? false;
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                key: const Key('permission_back_button'),
                icon: const Icon(Icons.arrow_back, color: ThemeTokens.textPrimary),
                onPressed: _prevStep,
              )
            : null,
        title: Text(
          'Permissions (${_currentStep + 1}/${_steps.length})',
          style: AppTypography.heading2(),
        ),
        actions: [
          TextButton(
            key: const Key('permission_skip_all_button'),
            onPressed: () => context.go(AppRoutes.home),
            child: Text(
              'Skip All',
              style: AppTypography.caption(color: ThemeTokens.textMuted),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.s),
              // Multi-segment progress bar
              Row(
                key: const Key('step_progress_indicator'),
                children: List.generate(_steps.length, (index) {
                  final active = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: active ? ThemeTokens.primary : ThemeTokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 1),

              // Icon Card
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Icon(
                  details.icon,
                  size: 40,
                  color: isGranted ? ThemeTokens.success : ThemeTokens.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // Title
              Text(
                details.title,
                key: const Key('permission_title'),
                textAlign: TextAlign.center,
                style: AppTypography.heading1(),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Purpose Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeTokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Text(
                  details.purpose,
                  style: AppTypography.caption(color: ThemeTokens.accent, weight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              // Plain-Language Explanation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      details.plainLanguageExplanation,
                      key: const Key('permission_explanation'),
                      style: AppTypography.body(color: ThemeTokens.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 16, color: ThemeTokens.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          '100% on-device. No data leaves your phone.',
                          style: AppTypography.micro(color: ThemeTokens.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('permission_primary_button'),
                  onPressed: () => _handleAction(currentPermission),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGranted ? ThemeTokens.success : ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isGranted
                        ? 'Granted · Next'
                        : 'Enable ${details.shortName}',
                    style: AppTypography.button(color: ThemeTokens.background),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s),

              // Secondary Skip Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  key: const Key('permission_secondary_button'),
                  onPressed: _nextStep,
                  child: Text(
                    isLastStep ? 'Finish Setup' : 'Skip for now',
                    style: AppTypography.caption(color: ThemeTokens.textMuted),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}

/// UsageStatsPermissionScreen provides plain-language explanation when Usage Access is missing.
class UsageStatsPermissionScreen extends ConsumerWidget {
  const UsageStatsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PermissionDetails.get(AppPermission.usageStats);

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
                details.title,
                style: AppTypography.heading1(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                details.plainLanguageExplanation,
                style: AppTypography.body(color: ThemeTokens.textMuted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('grant_usage_stats_permission_button'),
                  onPressed: () async {
                    await ref.read(permissionServiceProvider).request(AppPermission.usageStats);
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
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

/// AccessibilityPermissionScreen provides plain-language explanation when Accessibility Service is missing.
class AccessibilityPermissionScreen extends ConsumerWidget {
  const AccessibilityPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = PermissionDetails.get(AppPermission.accessibilityService);

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
                details.title,
                style: AppTypography.heading1(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                details.plainLanguageExplanation,
                style: AppTypography.body(color: ThemeTokens.textMuted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('grant_accessibility_permission_button'),
                  onPressed: () async {
                    await ref.read(permissionServiceProvider).request(AppPermission.accessibilityService);
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
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
