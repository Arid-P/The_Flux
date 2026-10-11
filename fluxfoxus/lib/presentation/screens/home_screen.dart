import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/aperture_icon.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../features/focus/focus.dart';
import '../../features/presets/domain/preset.dart';
import '../../features/presets/presentation/presets_provider.dart';
import '../widgets/bezier_momentum_chart.dart';

/// Provider computing today's and weekly actual focus seconds from SQLite.
final todayFocusStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(focusSessionRepositoryProvider);
  final now = DateTime.now();

  final todaySessions = await repo.getCompletedForDate(now);
  int todaySeconds = 0;
  for (final s in todaySessions) {
    todaySeconds += (s['actual_focus_seconds'] as int? ?? 0);
  }

  int weeklySeconds = todaySeconds;
  for (int i = 1; i <= 6; i++) {
    final pastDate = now.subtract(Duration(days: i));
    final pastSessions = await repo.getCompletedForDate(pastDate);
    for (final s in pastSessions) {
      weeklySeconds += (s['actual_focus_seconds'] as int? ?? 0);
    }
  }

  return {
    'todaySeconds': todaySeconds,
    'weeklySeconds': weeklySeconds,
  };
});

/// HomeScreen renders the complete dashboard matching ui_home.md, ui_mockups/home_screen.html,
/// and the Rustic Medley palette with dynamic SQLite data.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedPresetId;

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(focusSessionProvider);
    final presetsAsync = ref.watch(presetsListProvider);
    final statsAsync = ref.watch(todayFocusStatsProvider);

    final List<Preset> presets = presetsAsync.value ?? [];
    final Preset? currentPreset = _resolveCurrentPreset(presets);

    final bool isSessionActive = activeSession != null && activeSession.status.isActive;

    final int activeElapsedSeconds = isSessionActive ? activeSession.elapsed.inSeconds : 0;
    final int todayFocusSeconds = (statsAsync.value?['todaySeconds'] ?? 0) + activeElapsedSeconds;
    final int weeklyFocusSeconds = (statsAsync.value?['weeklySeconds'] ?? 0) + activeElapsedSeconds;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ApertureIcon(size: 26, color: ThemeTokens.primary),
                          const SizedBox(width: AppSpacing.s),
                          Flexible(
                            child: Text(
                              'FluxFoxus',
                              style: AppTypography.heading1(color: ThemeTokens.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderPill(label: 'Focused', value: _formatSeconds(todayFocusSeconds)),
                        const SizedBox(height: 3),
                        _buildHeaderPill(label: 'Weekly', value: _formatSeconds(weeklyFocusSeconds)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.m),

                // 2. Upcoming Session Banner (Togglable/Interactive)
                InkWell(
                  onTap: () => context.go(AppRoutes.planner),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: ThemeTokens.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: const Border(
                        left: BorderSide(color: ThemeTokens.primary, width: 4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⏰', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: AppTypography.caption(color: ThemeTokens.textPrimary),
                                    children: [
                                      TextSpan(
                                        text: currentPreset?.name ?? 'Focus Block',
                                        style: const TextStyle(
                                          color: ThemeTokens.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: isSessionActive
                                            ? ' is currently active'
                                            : ' · Ready to start',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Planner →',
                          style: AppTypography.micro(
                            color: ThemeTokens.textMuted,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 3. Momentum Card
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
                      BezierMomentumChart(
                        height: 120,
                        productiveDuration: _formatSeconds(todayFocusSeconds),
                        semiProdDuration: '0m',
                        distractingDuration: '0m',
                        othersDuration: '0m',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 4. Session Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: const BoxDecoration(
                      color: ThemeTokens.surface,
                      border: Border(
                        left: BorderSide(color: ThemeTokens.primary, width: 4),
                        top: BorderSide(color: ThemeTokens.border, width: 1),
                        right: BorderSide(color: ThemeTokens.border, width: 1),
                        bottom: BorderSide(color: ThemeTokens.border, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preset Selector Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TODAY'S FOCUS",
                                    style: AppTypography.micro(
                                      color: ThemeTokens.textMuted,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatSeconds(todayFocusSeconds),
                                    style: AppTypography.heading1(
                                      color: ThemeTokens.textPrimary,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: InkWell(
                                onTap: () => _showPresetPicker(presets),
                                borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ThemeTokens.background.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                                    border: Border.all(color: ThemeTokens.border, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(currentPreset?.emoji ?? '⚡', style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          currentPreset?.name ?? 'Deep Work',
                                          style: AppTypography.caption(
                                            color: ThemeTokens.textPrimary,
                                            weight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down, size: 16, color: ThemeTokens.textMuted),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const Divider(color: ThemeTokens.border, height: 1),
                        const SizedBox(height: AppSpacing.s),

                        // Detail Rows
                        _buildDetailRow(
                          label: 'Duration',
                          value: (currentPreset?.breakCount ?? 0) > 0
                              ? '${((currentPreset?.breakCount ?? 0) + 1) * 25}m session'
                              : '25m sprint',
                        ),
                        const Divider(color: ThemeTokens.border, height: 1),
                        _buildDetailRow(
                          label: 'Breaks',
                          value: '${currentPreset?.breakCount ?? 0} ${currentPreset?.breakCount == 1 ? "Break" : "Breaks"}',
                        ),
                        const Divider(color: ThemeTokens.border, height: 1),
                        _buildDetailRow(
                          label: 'Break Time (each)',
                          value: '${currentPreset?.breakDurationMinutes ?? 5}m',
                        ),
                        const Divider(color: ThemeTokens.border, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DESCRIPTION',
                                style: AppTypography.micro(
                                  color: ThemeTokens.textMuted,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentPreset?.description ??
                                    'No description notes added for this preset.',
                                style: AppTypography.caption(
                                  color: ThemeTokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.m),

                        // Start / Resume Focusing CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            key: const Key('home_start_focusing_button'),
                            onPressed: () {
                              if (isSessionActive) {
                                context.push(AppRoutes.focusSession);
                              } else {
                                if (currentPreset != null) {
                                  ref.read(presetsRepositoryProvider).setLastUsedPreset(currentPreset.id);
                                }
                                context.push(
                                  AppRoutes.focusSession,
                                  extra: currentPreset != null
                                      ? {
                                          'presetId': currentPreset.id,
                                          'presetName': currentPreset.name,
                                          'presetEmoji': currentPreset.emoji,
                                          'breaksTotal': currentPreset.breakCount,
                                          'breakDuration':
                                              Duration(minutes: currentPreset.breakDurationMinutes),
                                        }
                                      : null,
                                );
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
                            child: Text(
                              isSessionActive ? 'Resume Session' : 'Start Focusing',
                              style: AppTypography.button(
                                color: ThemeTokens.background,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Bottom padding for floating navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Preset? _resolveCurrentPreset(List<Preset> presets) {
    if (presets.isEmpty) return null;
    if (_selectedPresetId != null) {
      final found = presets.where((p) => p.id == _selectedPresetId);
      if (found.isNotEmpty) return found.first;
    }
    return presets.first;
  }

  void _showPresetPicker(List<Preset> presets) {
    if (presets.isEmpty) {
      context.push(AppRoutes.presetCreate);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        side: BorderSide(color: ThemeTokens.border, width: 1),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Focus Preset', style: AppTypography.heading2()),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push(AppRoutes.presetCreate);
                        },
                        child: Text('+ New', style: AppTypography.caption(color: ThemeTokens.primary)),
                      ),
                    ],
                  ),
                ),
                const Divider(color: ThemeTokens.border),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: presets.length,
                    itemBuilder: (c, idx) {
                      final p = presets[idx];
                      final isSelected = p.id == (_selectedPresetId ?? presets.first.id);
                      return ListTile(
                        leading: Text(p.emoji, style: const TextStyle(fontSize: 22)),
                        title: Text(p.name, style: AppTypography.body(weight: FontWeight.w600)),
                        subtitle: Text(
                          '${p.breakCount} ${p.breakCount == 1 ? "break" : "breaks"} · ${p.breakDurationMinutes}m',
                          style: AppTypography.caption(color: ThemeTokens.textMuted),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: ThemeTokens.primary, size: 20)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedPresetId = p.id;
                          });
                          ref.read(presetsRepositoryProvider).setLastUsedPreset(p.id);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption(color: ThemeTokens.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTypography.caption(
                color: ThemeTokens.textPrimary,
                weight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
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
