import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/aperture_icon.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// HomeScreen renders the main dashboard matching ui_home.md and Rustic Medley palette.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const ApertureIcon(size: 26, color: ThemeTokens.primary),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        'FluxFoxus',
                        style: AppTypography.heading1(color: ThemeTokens.textPrimary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildHeaderPill(label: 'Focused', value: '4h 12m'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildHeaderPill(label: 'Weekly', value: '28h 40m'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // Momentum Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Momentum', style: AppTypography.heading2()),
                        Text('Last 24h', style: AppTypography.caption(color: ThemeTokens.textMuted)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: ThemeTokens.surfaceElevated.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '24h Bézier Momentum Chart',
                        style: AppTypography.bodySmall(color: ThemeTokens.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // Session Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Session', style: AppTypography.heading2()),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ThemeTokens.surfaceElevated,
                            borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                            border: Border.all(color: ThemeTokens.border, width: 1),
                          ),
                          child: Row(
                            children: [
                              Text('Deep Work', style: AppTypography.caption(color: ThemeTokens.primary)),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, size: 16, color: ThemeTokens.textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        key: const Key('home_start_focusing_button'),
                        onPressed: () => context.push(AppRoutes.focusSession),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeTokens.primary,
                          foregroundColor: ThemeTokens.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Start Focusing',
                          style: AppTypography.button(color: ThemeTokens.background),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Spacing for floating bottom bar
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeaderPill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: AppTypography.micro(color: ThemeTokens.textMuted),
          children: [
            TextSpan(
              text: value,
              style: AppTypography.micro(color: ThemeTokens.accent, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
