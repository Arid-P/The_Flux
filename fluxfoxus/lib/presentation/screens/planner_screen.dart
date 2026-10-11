import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../features/focus/focus.dart';
import '../../features/presets/presentation/presets_provider.dart';

/// Provider fetching focus sessions for a given date from SQLite.
final plannerSessionsForDateProvider =
    FutureProvider.family.autoDispose<List<Map<String, dynamic>>, DateTime>((ref, date) async {
  final repo = ref.watch(focusSessionRepositoryProvider);
  final completed = await repo.getCompletedForDate(date);
  final scheduled = await repo.getScheduledForDate(date);
  return [...completed, ...scheduled];
});

/// PlannerScreen renders the calendar day strip, streaks, daily focus stats,
/// and scheduled/completed session cards per ui_mockups/planner.html and ui_planner.md.
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  late int _selectedDayIndex;
  late DateTime _weekMonday;

  static const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDayIndex = now.weekday - 1; // 0 for Monday, 6 for Sunday
    _weekMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  }

  DateTime _getDateForIndex(int index) {
    return _weekMonday.add(Duration(days: index));
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0m';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String _formatTime(int millisecondsSinceEpoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(currentStreakProvider);
    final streakDays = streakAsync.value ?? 0;
    final presetsAsync = ref.watch(presetsListProvider);
    final presets = presetsAsync.value ?? [];

    final selectedDate = _getDateForIndex(_selectedDayIndex);
    final sessionsAsync = ref.watch(plannerSessionsForDateProvider(selectedDate));
    final sessionsList = sessionsAsync.value ?? [];

    int totalFocusSeconds = 0;
    for (final s in sessionsList) {
      totalFocusSeconds += (s['actual_focus_seconds'] as int? ?? 0);
    }

    final monthTitle = '${_monthNames[selectedDate.month - 1]} ${selectedDate.year}';

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
                            monthTitle,
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
                          onTap: () {
                            final now = DateTime.now();
                            setState(() {
                              _selectedDayIndex = now.weekday - 1;
                              _weekMonday = DateTime(now.year, now.month, now.day)
                                  .subtract(Duration(days: now.weekday - 1));
                            });
                          },
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
                          streakDays > 0 ? 'Current streak: $streakDays days' : 'Start your streak today!',
                          style: AppTypography.caption(
                            color: ThemeTokens.primary,
                            weight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        streakDays > 0 ? 'Keep pushing!' : 'Zero interruptions',
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
                      '${_dayNames[_selectedDayIndex]}, ${selectedDate.day} ${_monthNames[selectedDate.month - 1]}',
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
                      final dayDate = _getDateForIndex(idx);

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
                                  '${dayDate.day}',
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

                // 4. Daily Stats Row (Focus vs Sessions)
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
                              _formatDuration(totalFocusSeconds),
                              style: AppTypography.heading1(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sessionsList.length} ${sessionsList.length == 1 ? "session" : "sessions"} logged',
                              style: AppTypography.micro(color: ThemeTokens.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    // Presets Configured Card
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
                                Text('PRESETS', style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700)),
                                const Text('⚡', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${presets.length}',
                              style: AppTypography.heading1(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active templates',
                              style: AppTypography.micro(color: ThemeTokens.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.m),

                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s,
                    runSpacing: 4,
                    children: [
                    Text(
                      'SESSIONS FOR DAY',
                      style: AppTypography.micro(
                        color: ThemeTokens.textMuted,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          key: const Key('schedule_session_button'),
                          onPressed: () => _showScheduleSessionDialog(selectedDate, presets),
                          icon: const Icon(Icons.alarm_add, size: 16, color: ThemeTokens.primary),
                          label: Text(
                            'Schedule Block',
                            style: AppTypography.micro(color: ThemeTokens.primary, weight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${sessionsList.length} items',
                          style: AppTypography.micro(color: ThemeTokens.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                const SizedBox(height: AppSpacing.s),

                // Session Cards or Empty State
                if (sessionsList.isEmpty)
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
                          'Assign a specific focus block (e.g. 3:00 PM – 5:00 PM) to structure your day.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(color: ThemeTokens.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: [
                            ElevatedButton.icon(
                              key: const Key('empty_schedule_block_button'),
                              onPressed: () => _showScheduleSessionDialog(selectedDate, presets),
                              icon: const Icon(Icons.alarm_add, size: 16),
                              label: const Text('Schedule Block'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeTokens.primary,
                                foregroundColor: ThemeTokens.background,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            OutlinedButton(
                              onPressed: () => context.push(AppRoutes.presetCreate),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: ThemeTokens.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                              ),
                              child: Text(
                                '+ Create Preset',
                                style: AppTypography.caption(color: ThemeTokens.textMuted, weight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  ...sessionsList.map((s) => _buildRealSessionCard(s, presets)),

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

  Widget _buildRealSessionCard(Map<String, dynamic> sessionMap, List<dynamic> presets) {
    final name = (sessionMap['session_name'] as String?) ?? 'Focus Session';
    final presetId = sessionMap['preset_id'] as String?;
    final actualSeconds = (sessionMap['actual_focus_seconds'] as int?) ?? 0;
    final source = ((sessionMap['source'] as String?) ?? 'FF').toUpperCase();
    final startMs = sessionMap['scheduled_start'] as int? ?? sessionMap['actual_start'] as int?;
    final endMs = sessionMap['scheduled_end'] as int? ?? sessionMap['actual_end'] as int?;

    String timeString;
    if (startMs != null && endMs != null) {
      timeString = '${_formatTime(startMs)} – ${_formatTime(endMs)}';
    } else if (startMs != null) {
      timeString = _formatTime(startMs);
    } else {
      timeString = 'Scheduled';
    }

    final plannedSeconds = sessionMap['planned_duration_seconds'] as int? ?? 0;
    final durationString = _formatDuration(actualSeconds > 0 ? actualSeconds : plannedSeconds);

    // Find emoji from preset if available
    String emoji = '🎯';
    if (presetId != null && presets.isNotEmpty) {
      final matching = presets.where((p) => p.id == presetId);
      if (matching.isNotEmpty) {
        emoji = matching.first.emoji;
      }
    }

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
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
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
                        name,
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
                        source,
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
                  '$timeString · $durationString',
                  style: AppTypography.caption(color: ThemeTokens.textMuted),
                ),
              ],
            ),
          ),
          if (presetId != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: ThemeTokens.textMuted, size: 20),
              onPressed: () => context.push(AppRoutes.presetEditPath(presetId)),
            ),
        ],
      ),
    );
  }

  Future<void> _showScheduleSessionDialog(DateTime selectedDate, List<dynamic> presets) async {
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please create at least one preset first.', style: AppTypography.caption()),
          backgroundColor: ThemeTokens.surface,
          action: SnackBarAction(
            label: 'Create',
            textColor: ThemeTokens.primary,
            onPressed: () => context.push(AppRoutes.presetCreate),
          ),
        ),
      );
      return;
    }

    dynamic selectedPreset = presets.first;
    TimeOfDay startTime = const TimeOfDay(hour: 15, minute: 0); // 3:00 PM
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);   // 5:00 PM

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modalTop)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final startDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              startTime.hour,
              startTime.minute,
            );
            DateTime endDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              endTime.hour,
              endTime.minute,
            );
            if (endDateTime.isBefore(startDateTime)) {
              endDateTime = endDateTime.add(const Duration(days: 1));
            }
            final durationMins = endDateTime.difference(startDateTime).inMinutes;

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.l,
                right: AppSpacing.l,
                top: AppSpacing.l,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Schedule Focus Block', style: AppTypography.heading2()),
                      IconButton(
                        icon: const Icon(Icons.close, color: ThemeTokens.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Assign a temporal time block for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}:',
                    style: AppTypography.caption(color: ThemeTokens.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Preset Picker
                  Text('SELECT PRESET', style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: ThemeTokens.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: ThemeTokens.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: selectedPreset,
                        isExpanded: true,
                        dropdownColor: ThemeTokens.surface,
                        items: presets.map((p) {
                          return DropdownMenuItem<dynamic>(
                            value: p,
                            child: Row(
                              children: [
                                Text(p.emoji as String? ?? '🎯', style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(p.name as String, style: AppTypography.body(color: ThemeTokens.textPrimary)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedPreset = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Time Pickers Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('START TIME', style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: ctx,
                                  initialTime: startTime,
                                );
                                if (picked != null) {
                                  setModalState(() => startTime = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: ThemeTokens.background,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(color: ThemeTokens.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(startTime.format(ctx), style: AppTypography.body(weight: FontWeight.w700)),
                                    const Icon(Icons.access_time, size: 16, color: ThemeTokens.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('END TIME', style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: ctx,
                                  initialTime: endTime,
                                );
                                if (picked != null) {
                                  setModalState(() => endTime = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: ThemeTokens.background,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(color: ThemeTokens.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(endTime.format(ctx), style: AppTypography.body(weight: FontWeight.w700)),
                                    const Icon(Icons.access_time, size: 16, color: ThemeTokens.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Duration summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: ThemeTokens.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: ThemeTokens.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timelapse, size: 16, color: ThemeTokens.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Total Planned Duration: ${_formatDuration(durationMins * 60)}',
                          style: AppTypography.caption(color: ThemeTokens.textPrimary, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      key: const Key('confirm_schedule_session_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeTokens.primary,
                        foregroundColor: ThemeTokens.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                      ),
                      onPressed: () async {
                        final formattedStart = startTime.format(ctx);
                        final formattedEnd = endTime.format(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        final presetName = selectedPreset.name as String;

                        final repo = ref.read(focusSessionRepositoryProvider);
                        final uuid = const Uuid().v4();
                        await repo.createScheduledSession(
                          id: uuid,
                          presetId: selectedPreset.id as String,
                          name: presetName,
                          scheduledStart: startDateTime,
                          scheduledEnd: endDateTime,
                          source: 'ff',
                        );
                        ref.invalidate(plannerSessionsForDateProvider(selectedDate));
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Scheduled "$presetName" for $formattedStart – $formattedEnd'),
                              backgroundColor: ThemeTokens.surface,
                            ),
                          );
                        }
                      },
                      child: Text('Confirm & Schedule Block', style: AppTypography.button(color: ThemeTokens.background)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
