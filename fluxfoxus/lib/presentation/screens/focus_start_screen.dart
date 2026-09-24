import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// FocusStartScreen provides preset selection and entry into an active focus session.
class FocusStartScreen extends StatelessWidget {
  const FocusStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Focus', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.m),
              Text(
                'Choose a Focus Preset',
                style: AppTypography.heading2(),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Select a session mode to block distracting apps and maintain your streak.',
                style: AppTypography.bodySmall(color: ThemeTokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.l),
              // Preset Item Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ThemeTokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🎯', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deep Work', style: AppTypography.body(weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('25m focus · 1 break (5m)', style: AppTypography.caption(color: ThemeTokens.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: ThemeTokens.primary, size: 32),
                      onPressed: () => context.push(AppRoutes.focusSession),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('focus_start_session_button'),
                  onPressed: () => context.push(AppRoutes.focusSession),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Start Deep Work', style: AppTypography.button(color: ThemeTokens.background)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
