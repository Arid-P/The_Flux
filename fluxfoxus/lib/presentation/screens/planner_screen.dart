import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../features/focus/focus.dart';
import '../../features/presets/presentation/presets_provider.dart';

/// PlannerScreen renders the calendar day strip, streaks, daily focus vs screen time stats,
/// and scheduled session cards per ui_mockups/planner.html and ui_planner.md.
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  int _selectedDayIndex = 2; // Wednesday (Today) by default

  final List<String> _dayNames = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _dayNumbers = const ['23', '24', '25', '26', '27', '28', '29'];

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(currentStreakProvider);
    final streakDays = streakAsync.value ?? 5;
    final presetsAsync = ref.watch(presetsListProvider);
    final presets = presetsAsync.value ?? [];

    // Schedule items for days
    final sessionsForDay = _getSessionsForDay(_selectedDayIndex, presets);

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s),

                // 1. Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FOCUS SCHEDULE',
                            style: AppTypography.micro(
                              color: ThemeTokens.accent,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'March 2026',
                            style: AppTypography.heading1(color: ThemeTokens.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          key: const Key('planner_today_button'),
                          onTap: () => setState(() => _selectedDayIndex = 2),
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ThemeTokens.surface,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                              border: Border.all(color: ThemeTokens.border, width: 1),
                            ),
                            child: Text(
                              'Today',
                              style: AppTypography.caption(
                                color: ThemeTokens.textPrimary,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        InkWell(
                          key: const Key('planner_help_button'),
                          onTap: _showHelpDialog,
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ThemeTokens.surface,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                              border: Border.all(color: ThemeTokens.border, width: 1),
                            ),
                            child: Text(
                              'Help',
                              style: AppTypography.caption(
                                color: ThemeTokens.textMuted,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.m),

                // 2. Streak Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ThemeTokens.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: ThemeTokens.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: ThemeTokens.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: ThemeTokens.primary.withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🔥', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Current streak: $streakDays days',
                          style: AppTypography.caption(
                            color: ThemeTokens.primary,
                            weight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Keep pushing!',
                        style: AppTypography.micro(color: ThemeTokens.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 3. Calendar Day Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Weekly Focus Timeline',
                        style: AppTypography.micro(color: ThemeTokens.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      'Week 13',
                      style: AppTypography.micro(
                        color: ThemeTokens.accent,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeTokens.surface,
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                    border: Border.all(color: ThemeTokens.border, width: 1),
                  ),
                  child: Row(
                    children: List.generate(7, (idx) {
                      final isSelected = idx == _selectedDayIndex;
                      return Expanded(
                        child: InkWell(
                          key: Key('day_item_$idx'),
                          onTap: () => setState(() => _selectedDayIndex = idx),
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? ThemeTokens.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _dayNames[idx],
                                  style: AppTypography.micro(
                                    color: isSelected ? ThemeTokens.background : ThemeTokens.textMuted,
                                    weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _dayNumbers[idx],
                                  style: AppTypography.caption(
                                    color: isSelected ? ThemeTokens.background : ThemeTokens.textPrimary,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 4. Daily Stats Row (Focus vs Usage)
                Row(
                  children: [
                    // Focus Total Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: ThemeTokens.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: ThemeTokens.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('FOCUS', style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700)),
                                const Text('🎯', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedDayIndex == 6 ? '0m' : '2h 27m',
                              style: AppTypography.heading1(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sessionsForDay.length} sessions logged',
                              style: AppTypography.micro(color: ThemeTokens.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    // Usage Total Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: ThemeTokens.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: ThemeTokens.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('USAGE', style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700)),
                                const Text('📱', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedDayIndex == 6 ? '1h 10m' : '6h 18m',
                              style: AppTypography.heading1(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Screen on time',
                              style: AppTypography.micro(color: ThemeTokens.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.m),

                // 5. Scheduled Sessions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SCHEDULED SESSIONS',
                      style: AppTypography.micro(
                        color: ThemeTokens.textMuted,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${sessionsForDay.length} items',
                      style: AppTypography.micro(color: ThemeTokens.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),

                // Session Cards or Empty State
                if (sessionsForDay.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: ThemeTokens.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: ThemeTokens.border, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'No sessions for this day',
                          style: AppTypography.heading2(color: ThemeTokens.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enjoy your scheduled rest or tap "+ Add Preset" below to plan a focus block.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(color: ThemeTokens.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        OutlinedButton(
                          onPressed: () => context.push(AppRoutes.presetCreate),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: ThemeTokens.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                          ),
                          child: Text(
                            '+ Schedule Session',
                            style: AppTypography.caption(color: ThemeTokens.primary, weight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...sessionsForDay.map((session) => _buildSessionCard(session)),

                const SizedBox(height: 120), // Spacing for floating bottom bar & FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          key: const Key('add_preset_button'),
          onPressed: () => context.push(AppRoutes.presetCreate),
          backgroundColor: ThemeTokens.primary,
          foregroundColor: ThemeTokens.background,
          elevation: 4,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'New Preset',
            style: AppTypography.button(color: ThemeTokens.background, weight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(_PlannerSessionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeTokens.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: ThemeTokens.border, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: AppTypography.body(weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ThemeTokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                        border: Border.all(color: ThemeTokens.border, width: 1),
                      ),
                      child: Text(
                        item.source,
                        style: AppTypography.micro(
                          color: ThemeTokens.primary,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.timeRange} · ${item.duration}',
                  style: AppTypography.caption(color: ThemeTokens.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: ThemeTokens.textMuted, size: 20),
            onPressed: () => context.push(AppRoutes.presetEditPath(item.presetId)),
          ),
        ],
      ),
    );
  }

  List<_PlannerSessionItem> _getSessionsForDay(int dayIndex, List<dynamic> presets) {
    if (dayIndex == 6) {
      return []; // Sunday empty rest day per HTML preview
    }
    return [
      const _PlannerSessionItem(
        presetId: 'preset-100',
        emoji: '🎯',
        name: 'Deep Work',
        timeRange: '09:00 AM – 09:50 AM',
        duration: '50m',
        source: 'FF',
      ),
      const _PlannerSessionItem(
        presetId: 'preset-101',
        emoji: '⚡',
        name: 'Math Olympiad',
        timeRange: '02:00 PM – 03:30 PM',
        duration: '1h 30m',
        source: 'FF',
      ),
      const _PlannerSessionItem(
        presetId: 'preset-102',
        emoji: '📚',
        name: 'Physics Study',
        timeRange: '05:00 PM – 05:45 PM',
        duration: '45m',
        source: 'FD',
      ),
    ];
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: ThemeTokens.border, width: 1),
        ),
        title: Row(
          children: [
            const Text('ℹ️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Planner & Sync Guide', style: AppTypography.heading2()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Calendar Strip: Tap any day to inspect logged and scheduled sessions.', style: AppTypography.caption()),
            const SizedBox(height: 8),
            Text('• Streak Bar: Shows consecutive days meeting your focus goal.', style: AppTypography.caption()),
            const SizedBox(height: 8),
            Text('• FF Source: Native FluxFoxus preset sessions.', style: AppTypography.caption()),
            const SizedBox(height: 8),
            Text('• FD Source: FlowDesk synced external calendar sessions.', style: AppTypography.caption()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it', style: AppTypography.button(color: ThemeTokens.primary)),
          ),
        ],
      ),
    );
  }
}

class _PlannerSessionItem {
  final String presetId;
  final String emoji;
  final String name;
  final String timeRange;
  final String duration;
  final String source;

  const _PlannerSessionItem({
    required this.presetId,
    required this.emoji,
    required this.name,
    required this.timeRange,
    required this.duration,
    required this.source,
  });
}
