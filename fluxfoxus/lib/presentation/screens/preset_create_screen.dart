import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/navigation/navigation.dart';
import '../../core/theme/theme.dart';
import '../../features/presets/domain/preset.dart';
import '../../features/presets/domain/preset_app_restriction.dart';
import '../../features/presets/domain/youtube_mode.dart';
import '../../features/presets/presentation/presets_provider.dart';
import '../../features/presets/presentation/widgets/emoji_picker_sheet.dart';

/// PresetCreateScreen implements the full preset creation flow matching ui_preset.md.
class PresetCreateScreen extends ConsumerStatefulWidget {
  const PresetCreateScreen({super.key});

  @override
  ConsumerState<PresetCreateScreen> createState() => _PresetCreateScreenState();
}

class _PresetCreateScreenState extends ConsumerState<PresetCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  static const _uuid = Uuid();

  String _selectedEmoji = '⏳';
  int _breakCount = 1;
  int _breakDuration = 5;
  YouTubeMode _youtubeMode = YouTubeMode.studyMode;

  // Category expansion states
  final Map<String, bool> _categoryExpanded = {
    'Distracting': true,
    'Productive': false,
    'Semi-Productive': false,
    'Others': false,
  };

  // App restrictions map: packageName -> isBlocked
  late final Map<String, _MockAppItem> _apps;

  @override
  void initState() {
    super.initState();
    _apps = {
      // Distracting (default blocked = true)
      'com.instagram.android': const _MockAppItem('Instagram', 'Distracting', Icons.camera_alt_outlined, true),
      'com.zhiliaoapp.musically': const _MockAppItem('TikTok', 'Distracting', Icons.music_note_outlined, true),
      'com.twitter.android': const _MockAppItem('Twitter / X', 'Distracting', Icons.chat_bubble_outline, true),
      // Productive (default blocked = false)
      'com.notion.android': const _MockAppItem('Notion', 'Productive', Icons.edit_note_outlined, false),
      'com.Slack': const _MockAppItem('Slack', 'Productive', Icons.work_outline, false),
      // Semi-Productive (default blocked = false)
      'com.google.android.gm': const _MockAppItem('Gmail', 'Semi-Productive', Icons.mail_outline, false),
      'com.google.android.apps.docs': const _MockAppItem('Google Docs', 'Semi-Productive', Icons.description_outlined, false),
      // Others (default blocked = false)
      'com.android.calculator2': const _MockAppItem('Calculator', 'Others', Icons.calculate_outlined, false),
      'com.android.settings': const _MockAppItem('Settings', 'Others', Icons.settings_outlined, false),
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  int _getBlockedCount(String category) {
    return _apps.values.where((app) => app.category == category && app.isBlocked).length;
  }

  Future<void> _pickEmoji() async {
    final picked = await EmojiPickerSheet.show(context);
    if (picked != null) {
      setState(() {
        _selectedEmoji = picked;
      });
    }
  }

  Future<void> _savePreset() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a preset name', style: AppTypography.body(color: ThemeTokens.textPrimary)),
          backgroundColor: ThemeTokens.surface,
        ),
      );
      return;
    }

    final presetId = _uuid.v4();
    final now = DateTime.now();

    final preset = Preset(
      id: presetId,
      name: name,
      emoji: _selectedEmoji,
      breakCount: _breakCount,
      breakDurationMinutes: _breakDuration,
      youtubeMode: _youtubeMode,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      createdAt: now,
      updatedAt: now,
    );

    final restrictions = _apps.entries.map((entry) {
      return PresetAppRestriction(
        presetId: presetId,
        packageName: entry.key,
        isBlocked: entry.value.isBlocked,
      );
    }).toList();

    await ref.read(presetsListProvider.notifier).createPreset(
          preset,
          restrictions: restrictions,
        );

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('New Preset', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: InkWell(
              key: const Key('close_preset_button'),
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.close, size: 18, color: ThemeTokens.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s),

                    // 1. PRESET NAME
                    Text('PRESET NAME', style: AppTypography.label()),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        color: ThemeTokens.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: ThemeTokens.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            key: const Key('preset_emoji_button'),
                            onTap: _pickEmoji,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: ThemeTokens.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.card),
                              ),
                              alignment: Alignment.center,
                              child: Text(_selectedEmoji, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name', style: AppTypography.caption()),
                                TextField(
                                  key: const Key('preset_name_input'),
                                  controller: _nameController,
                                  style: AppTypography.heading3(),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                    border: InputBorder.none,
                                    hintText: 'Enter preset name',
                                    hintStyle: AppTypography.body(color: ThemeTokens.textMuted.withValues(alpha: 0.5)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.l),

                    // 2. BREAK CONFIGURATION
                    Text('BREAK CONFIGURATION', style: AppTypography.label()),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        // Card 1: Breaks count
                        Expanded(
                          child: _buildStepperCard(
                            title: 'NUMBER OF BREAKS',
                            valueText: '$_breakCount',
                            unitText: 'breaks',
                            canDecrement: _breakCount > 0,
                            canIncrement: _breakCount < 6,
                            decKey: const Key('break_count_dec_button'),
                            incKey: const Key('break_count_inc_button'),
                            valueKey: const Key('break_count_value'),
                            onDecrement: () => setState(() => _breakCount--),
                            onIncrement: () => setState(() => _breakCount++),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        // Card 2: Duration each
                        Expanded(
                          child: _buildStepperCard(
                            title: 'DURATION EACH',
                            valueText: '$_breakDuration',
                            unitText: 'mins',
                            canDecrement: _breakDuration > 1,
                            canIncrement: _breakDuration < 15,
                            decKey: const Key('break_duration_dec_button'),
                            incKey: const Key('break_duration_inc_button'),
                            valueKey: const Key('break_duration_value'),
                            onDecrement: () => setState(() => _breakDuration--),
                            onIncrement: () => setState(() => _breakDuration++),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.l),

                    // 3. YOUTUBE SPECIAL HANDLING
                    Text('YOUTUBE CONFIGURATION', style: AppTypography.label()),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: ThemeTokens.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: ThemeTokens.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildYouTubeRadioOption(
                            mode: YouTubeMode.studyMode,
                            title: 'Study Mode (Whitelisted)',
                            subtitle: 'Allows educational videos only',
                            trailing: TextButton(
                              key: const Key('configure_channels_button'),
                              onPressed: () => context.push(AppRoutes.presetChannelsPath('new')),
                              child: Text('Configure →', style: AppTypography.caption(color: ThemeTokens.primary)),
                            ),
                          ),
                          const Divider(color: ThemeTokens.border, height: 16),
                          _buildYouTubeRadioOption(
                            mode: YouTubeMode.block,
                            title: 'Block completely',
                            subtitle: 'Blocks YouTube app and web domains',
                          ),
                          const Divider(color: ThemeTokens.border, height: 16),
                          _buildYouTubeRadioOption(
                            mode: YouTubeMode.allow,
                            title: 'Allow completely',
                            subtitle: 'No restrictions on YouTube',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.l),

                    // 4. APP RESTRICTIONS
                    Text('APP RESTRICTIONS', style: AppTypography.label()),
                    const SizedBox(height: AppSpacing.xs),
                    _buildCategorySection('Distracting', ThemeTokens.categoryDistracting),
                    const SizedBox(height: AppSpacing.s),
                    _buildCategorySection('Productive', ThemeTokens.categoryProductive),
                    const SizedBox(height: AppSpacing.s),
                    _buildCategorySection('Semi-Productive', ThemeTokens.categorySemiProductive),
                    const SizedBox(height: AppSpacing.s),
                    _buildCategorySection('Others', ThemeTokens.categoryOthers),

                    const SizedBox(height: AppSpacing.l),

                    // 5. DESCRIPTION
                    Text('DESCRIPTION', style: AppTypography.label()),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: ThemeTokens.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: ThemeTokens.border, width: 1),
                      ),
                      child: TextField(
                        key: const Key('preset_description_input'),
                        controller: _descController,
                        maxLines: 3,
                        style: AppTypography.body(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'What do you plan on focusing? Add notes...',
                          hintStyle: AppTypography.body(color: ThemeTokens.textMuted.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Save Button Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: ThemeTokens.background,
                border: Border(top: BorderSide(color: ThemeTokens.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  key: const Key('save_preset_button'),
                  onPressed: _savePreset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Preset',
                    style: AppTypography.heading2(color: ThemeTokens.background),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperCard({
    required String title,
    required String valueText,
    required String unitText,
    required bool canDecrement,
    required bool canIncrement,
    required Key decKey,
    required Key incKey,
    required Key valueKey,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.micro()),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: decKey,
                icon: const Icon(Icons.remove, size: 18),
                color: canDecrement ? ThemeTokens.primary : ThemeTokens.border,
                onPressed: canDecrement ? onDecrement : null,
              ),
              Column(
                children: [
                  Text(valueText, key: valueKey, style: AppTypography.heading2()),
                  Text(unitText, style: AppTypography.micro()),
                ],
              ),
              IconButton(
                key: incKey,
                icon: const Icon(Icons.add, size: 18),
                color: canIncrement ? ThemeTokens.primary : ThemeTokens.border,
                onPressed: canIncrement ? onIncrement : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeRadioOption({
    required YouTubeMode mode,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final isSelected = _youtubeMode == mode;
    return InkWell(
      key: Key('youtube_mode_${mode.value}'),
      onTap: () => setState(() => _youtubeMode = mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ThemeTokens.primary : ThemeTokens.border,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: ThemeTokens.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body(weight: FontWeight.w600)),
                  Text(subtitle, style: AppTypography.caption()),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, Color dotColor) {
    final isExpanded = _categoryExpanded[category] ?? false;
    final blockedCount = _getBlockedCount(category);
    final categoryApps = _apps.entries.where((e) => e.value.category == category).toList();

    return Container(
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            key: Key('category_header_$category'),
            onTap: () {
              setState(() {
                _categoryExpanded[category] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(category, style: AppTypography.body(weight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '$blockedCount blocked',
                    key: Key('blocked_count_$category'),
                    style: AppTypography.caption(),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: ThemeTokens.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: ThemeTokens.border, height: 1),
            ...categoryApps.map((entry) {
              final app = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ThemeTokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Icon(app.icon, color: ThemeTokens.textMuted, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(app.name, style: AppTypography.body()),
                    ),
                    Switch(
                      key: Key('app_switch_${entry.key}'),
                      value: app.isBlocked,
                      activeThumbColor: ThemeTokens.primary,
                      activeTrackColor: ThemeTokens.primary.withValues(alpha: 0.3),
                      inactiveThumbColor: ThemeTokens.textMuted,
                      inactiveTrackColor: ThemeTokens.surfaceElevated,
                      onChanged: (val) {
                        setState(() {
                          _apps[entry.key] = app.copyWith(isBlocked: val);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MockAppItem {
  final String name;
  final String category;
  final IconData icon;
  final bool isBlocked;

  const _MockAppItem(this.name, this.category, this.icon, this.isBlocked);

  _MockAppItem copyWith({bool? isBlocked}) {
    return _MockAppItem(name, category, icon, isBlocked ?? this.isBlocked);
  }
}
