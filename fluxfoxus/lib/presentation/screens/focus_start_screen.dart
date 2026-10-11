import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../features/presets/domain/preset.dart';
import '../../features/presets/presentation/presets_provider.dart';

/// FocusStartScreen provides preset selection and entry into an active focus session.
/// Loads dynamic presets from SQLite via PresetsListProvider.
class FocusStartScreen extends ConsumerStatefulWidget {
  const FocusStartScreen({super.key});

  @override
  ConsumerState<FocusStartScreen> createState() => _FocusStartScreenState();
}

class _FocusStartScreenState extends ConsumerState<FocusStartScreen> {
  String? _selectedPresetId;

  void _startSessionWithPreset(Preset preset) {
    // Record as last used preset in repository
    ref.read(presetsRepositoryProvider).setLastUsedPreset(preset.id);

    context.push(
      AppRoutes.focusSession,
      extra: {
        'presetId': preset.id,
        'presetName': preset.name,
        'presetEmoji': preset.emoji,
        'breaksTotal': preset.breakCount,
        'breakDuration': Duration(minutes: preset.breakDurationMinutes),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetsListProvider);
    final presets = presetsAsync.value ?? [];

    final selectedPreset = presets.isEmpty
        ? null
        : (_selectedPresetId != null
            ? presets.firstWhere(
                (p) => p.id == _selectedPresetId,
                orElse: () => presets.first,
              )
            : presets.first);

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Focus', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: TextButton.icon(
              key: const Key('focus_new_preset_button'),
              onPressed: () => context.push(AppRoutes.presetCreate),
              icon: const Icon(Icons.add, size: 18, color: ThemeTokens.primary),
              label: Text(
                'New Preset',
                style: AppTypography.caption(color: ThemeTokens.primary, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
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

              // Presets List or Loading / Empty State
              Expanded(
                child: presetsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: ThemeTokens.primary),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Failed to load presets: $err',
                      style: AppTypography.body(color: ThemeTokens.accent),
                    ),
                  ),
                  data: (presetsList) {
                    if (presetsList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⏳', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              'No presets found',
                              style: AppTypography.heading2(),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Create a preset to configure blocked apps and breaks.',
                              style: AppTypography.caption(color: ThemeTokens.textMuted),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            ElevatedButton(
                              onPressed: () => context.push(AppRoutes.presetCreate),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeTokens.primary,
                                foregroundColor: ThemeTokens.background,
                              ),
                              child: const Text('+ Create Preset'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: presetsList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
                      itemBuilder: (context, index) {
                        final p = presetsList[index];
                        final isSelected = p.id == (selectedPreset?.id ?? presetsList.first.id);

                        return InkWell(
                          key: Key('preset_item_${p.id}'),
                          onTap: () {
                            setState(() {
                              _selectedPresetId = p.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: ThemeTokens.surface,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                              border: Border.all(
                                color: isSelected ? ThemeTokens.primary : ThemeTokens.border,
                                width: isSelected ? 2 : 1,
                              ),
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
                                  child: Text(p.emoji, style: const TextStyle(fontSize: 22)),
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
                                              p.name,
                                              style: AppTypography.body(weight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.check_circle,
                                              color: ThemeTokens.primary,
                                              size: 16,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${p.breakCount} ${p.breakCount == 1 ? "break" : "breaks"} (${p.breakDurationMinutes}m) · ${p.youtubeMode.label}',
                                        style: AppTypography.caption(color: ThemeTokens.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: ThemeTokens.textMuted, size: 20),
                                  tooltip: 'Edit Preset',
                                  onPressed: () => context.push(AppRoutes.presetEditPath(p.id)),
                                ),
                                IconButton(
                                  key: Key('start_preset_icon_${p.id}'),
                                  icon: const Icon(Icons.play_circle_fill, color: ThemeTokens.primary, size: 32),
                                  tooltip: 'Start Session',
                                  onPressed: () => _startSessionWithPreset(p),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // Bottom Primary Start Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('focus_start_session_button'),
                  onPressed: selectedPreset != null ? () => _startSessionWithPreset(selectedPreset) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedPreset != null ? 'Start ${selectedPreset.name}' : 'Start Session',
                    style: AppTypography.button(color: ThemeTokens.background),
                  ),
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
