import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// PlannerScreen renders the calendar day strip and session schedule per ui_planner.md.
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Planner', style: AppTypography.heading1()),
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
              // Day Strip
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDayItem('M', '23', isSelected: false),
                    _buildDayItem('T', '24', isSelected: true),
                    _buildDayItem('W', '25', isSelected: false),
                    _buildDayItem('T', '26', isSelected: false),
                    _buildDayItem('F', '27', isSelected: false),
                    _buildDayItem('S', '28', isSelected: false),
                    _buildDayItem('S', '29', isSelected: false),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              Text('Today\'s Schedule', style: AppTypography.heading2()),
              const SizedBox(height: AppSpacing.m),

              // Sample Session Card
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
                    const Text('🎯', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deep Work', style: AppTypography.body(weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('09:00 AM – 09:50 AM · FF Source', style: AppTypography.caption(color: ThemeTokens.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: ThemeTokens.textMuted, size: 20),
                      onPressed: () => context.push(AppRoutes.presetEditPath('preset-100')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          key: const Key('add_preset_button'),
          onPressed: () => context.push(AppRoutes.presetCreate),
          backgroundColor: ThemeTokens.primary,
          foregroundColor: ThemeTokens.background,
          icon: const Icon(Icons.add),
          label: Text('New Preset', style: AppTypography.button(color: ThemeTokens.background)),
        ),
      ),
    );
  }

  Widget _buildDayItem(String day, String date, {required bool isSelected}) {
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? ThemeTokens.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: AppTypography.micro(
              color: isSelected ? ThemeTokens.background : ThemeTokens.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: AppTypography.caption(
              color: isSelected ? ThemeTokens.background : ThemeTokens.textPrimary,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
