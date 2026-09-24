import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// UsageStatsScreen renders screen time statistics per ui_usage_stats.md.
class UsageStatsScreen extends StatelessWidget {
  const UsageStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Usage Stats', style: AppTypography.heading1()),
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
              const SizedBox(height: AppSpacing.s),
              // Time Range Tabs
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Row(
                  children: [
                    _buildTabPill('Today', isActive: true),
                    _buildTabPill('Daily', isActive: false),
                    _buildTabPill('Weekly', isActive: false),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              // Area Chart Placeholder
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Bézier Stacked Area Chart',
                  style: AppTypography.body(color: ThemeTokens.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill(String title, {required bool isActive}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isActive ? ThemeTokens.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTypography.caption(
            color: isActive ? ThemeTokens.background : ThemeTokens.textMuted,
            weight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
