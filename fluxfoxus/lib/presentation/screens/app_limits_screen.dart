import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// AppLimitsScreen renders the Blocks tab per ui_app_limits.md.
class AppLimitsScreen extends StatelessWidget {
  const AppLimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Blocks', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeTokens.surface,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                border: Border.all(color: ThemeTokens.border, width: 1),
              ),
              child: Text(
                'Help',
                style: AppTypography.caption(color: ThemeTokens.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('App Limits', style: AppTypography.heading2()),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18, color: ThemeTokens.accent),
                    label: Text(
                      'Add App',
                      style: AppTypography.button(color: ThemeTokens.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // Category Group: Distracting
              _buildCategoryHeader('Distracting', '3 apps'),
              const SizedBox(height: AppSpacing.s),
              _buildAppCard(
                appName: 'Instagram',
                icon: Icons.camera_alt_outlined,
                spentText: '42m spent / 30m limit',
                isBlocking: true,
              ),
              const SizedBox(height: AppSpacing.s),
              _buildAppCard(
                appName: 'YouTube',
                icon: Icons.play_circle_outline,
                spentText: '15m spent / 45m limit',
                isBlocking: false,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String category, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(category, style: AppTypography.caption(color: ThemeTokens.textMuted, weight: FontWeight.w600)),
        Text(count, style: AppTypography.micro(color: ThemeTokens.textMuted)),
      ],
    );
  }

  Widget _buildAppCard({
    required String appName,
    required IconData icon,
    required String spentText,
    required bool isBlocking,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeTokens.surfaceElevated,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
            ),
            child: Icon(icon, color: ThemeTokens.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName, style: AppTypography.body(weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(spentText, style: AppTypography.caption(color: ThemeTokens.textMuted)),
              ],
            ),
          ),
          if (isBlocking)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeTokens.surfaceElevated,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                border: Border.all(color: ThemeTokens.border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: ThemeTokens.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Blocking', style: AppTypography.micro(color: ThemeTokens.accent)),
                ],
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: ThemeTokens.textMuted, size: 20),
        ],
      ),
    );
  }
}
