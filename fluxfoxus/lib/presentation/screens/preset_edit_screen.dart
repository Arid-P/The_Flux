import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/navigation.dart';
import '../../core/theme/theme.dart';
import '../../features/presets/domain/preset.dart';
import '../../features/presets/domain/preset_app_restriction.dart';
import '../../features/presets/domain/youtube_mode.dart';
import '../../features/presets/presentation/presets_provider.dart';
import '../../features/presets/presentation/widgets/emoji_picker_sheet.dart';

/// PresetEditScreen provides full editing, restriction management, and persistence
/// for an existing preset by ID per ui_preset.md and TRD Section 4.1.
class PresetEditScreen extends ConsumerStatefulWidget {
  final String presetId;

  const PresetEditScreen({
    super.key,
    required this.presetId,
  });

  @override
  ConsumerState<PresetEditScreen> createState() => _PresetEditScreenState();
}

class _PresetEditScreenState extends ConsumerState<PresetEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedEmoji = '⏳';
  int _breakCount = 1;
  int _breakDuration = 5;
  YouTubeMode _youtubeMode = YouTubeMode.studyMode;
  DateTime _createdAt = DateTime.now();
  bool _isLoading = true;

  // Category expansion states
  final Map<String, bool> _categoryExpanded = {
    'Distracting': true,
    'Productive': false,
    'Semi-Productive': false,
    'Others': false,
  };

  // App restrictions map: packageName -> _AppItem
  late Map<String, _AppItem> _apps;

  @override
  void initState() {
    super.initState();
    _initDefaultApps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPresetData();
    });
  }

  void _initDefaultApps() {
    _apps = {
      // Distracting
      'com.instagram.android': const _AppItem('Instagram', 'Distracting', Icons.camera_alt_outlined, true),
      'com.zhiliaoapp.musically': const _AppItem('TikTok', 'Distracting', Icons.music_note_outlined, true),
      'com.twitter.android': const _AppItem('Twitter / X', 'Distracting', Icons.chat_bubble_outline, true),
      'com.reddit.frontpage': const _AppItem('Reddit', 'Distracting', Icons.forum_outlined, false),
      'com.discord': const _AppItem('Discord', 'Distracting', Icons.headset_mic_outlined, false),
      // Productive
      'com.notion.android': const _AppItem('Notion', 'Productive', Icons.edit_note_outlined, false),
      'com.Slack': const _AppItem('Slack', 'Productive', Icons.work_outline, false),
      'com.google.android.apps.docs': const _AppItem('Google Docs', 'Productive', Icons.description_outlined, false),
      // Semi-Productive
      'com.google.android.gm': const _AppItem('Gmail', 'Semi-Productive', Icons.mail_outline, false),
      'com.google.android.youtube': const _AppItem('YouTube', 'Semi-Productive', Icons.play_circle_outline, false),
      'com.whatsapp': const _AppItem('WhatsApp', 'Semi-Productive', Icons.chat_outlined, false),
      // Others
      'com.android.calculator2': const _AppItem('Calculator', 'Others', Icons.calculate_outlined, false),
      'com.android.settings': const _AppItem('Settings', 'Others', Icons.settings_outlined, false),
      'com.android.chrome': const _AppItem('Chrome', 'Others', Icons.language_outlined, false),
      'com.spotify.music': const _AppItem('Spotify', 'Others', Icons.music_note_outlined, false),
    };
  }

  Future<void> _loadPresetData() async {
    try {
      final repo = ref.read(presetsRepositoryProvider);
      final preset = await repo.getPresetById(widget.presetId);
      final restrictions = await repo.getRestrictions(widget.presetId);

      if (preset != null && mounted) {
        _nameController.text = preset.name;
        _descController.text = preset.description ?? '';
        _selectedEmoji = preset.emoji;
        _breakCount = preset.breakCount;
        _breakDuration = preset.breakDurationMinutes;
        _youtubeMode = preset.youtubeMode;
        _createdAt = preset.createdAt;

        // Apply restrictions from DB
        final restrictionMap = {for (var r in restrictions) r.packageName: r.isBlocked};
        for (final entry in restrictionMap.entries) {
          if (_apps.containsKey(entry.key)) {
            _apps[entry.key] = _apps[entry.key]!.copyWith(isBlocked: entry.value);
          } else {
            // Custom app previously added
            _apps[entry.key] = _AppItem(
              entry.key.split('.').last,
              'Distracting',
              Icons.apps_rounded,
              entry.value,
            );
          }
        }
      }
    } catch (_) {
      // Gracefully maintain defaults if loading fails
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  Future<void> _saveChanges() async {
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

    try {
      final now = DateTime.now();
      final updatedPreset = Preset(
        id: widget.presetId,
        name: name,
        emoji: _selectedEmoji,
        breakCount: _breakCount,
        breakDurationMinutes: _breakDuration,
        youtubeMode: _youtubeMode,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        createdAt: _createdAt,
        updatedAt: now,
      );

      final restrictions = _apps.entries.map((entry) {
        return PresetAppRestriction(
          presetId: widget.presetId,
          packageName: entry.key,
          isBlocked: entry.value.isBlocked,
        );
      }).toList();

      await ref.read(presetsListProvider.notifier).updatePreset(
            updatedPreset,
            restrictions: restrictions,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset "$name" updated!', style: AppTypography.body(color: ThemeTokens.textPrimary)),
            backgroundColor: ThemeTokens.surface,
          ),
        );
        if (context.canPop()) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update preset: $e', style: AppTypography.body(color: ThemeTokens.textPrimary)),
            backgroundColor: ThemeTokens.surface,
          ),
        );
      }
    }
  }

  void _confirmDeletePreset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: ThemeTokens.border, width: 1),
        ),
        title: Text('Delete Preset', style: AppTypography.heading2()),
        content: Text(
          'Are you sure you want to delete this preset? This action cannot be undone.',
          style: AppTypography.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.caption(color: ThemeTokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeTokens.accent,
              foregroundColor: ThemeTokens.background,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(presetsListProvider.notifier).deletePreset(widget.presetId);
              if (mounted && context.canPop()) {
                context.pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ThemeTokens.background,
        body: Center(
          child: CircularProgressIndicator(color: ThemeTokens.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Preset', style: AppTypography.heading1()),
            Text(widget.presetId, style: AppTypography.caption(color: ThemeTokens.textMuted)),
          ],
        ),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeTokens.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            key: const Key('delete_preset_button'),
            icon: const Icon(Icons.delete_outline, color: ThemeTokens.accent),
            tooltip: 'Delete Preset',
            onPressed: _confirmDeletePreset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
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

                      // 3. YOUTUBE CONFIGURATION
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
                                onPressed: () => context.push(AppRoutes.presetChannelsPath(widget.presetId)),
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

              // Sticky Bottom Save Changes Container
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
                    key: const Key('update_preset_button'),
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeTokens.primary,
                      foregroundColor: ThemeTokens.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Changes',
                      style: AppTypography.heading2(color: ThemeTokens.background),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: AppTypography.micro()),
          ),
          const SizedBox(height: AppSpacing.s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: decKey,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(Icons.remove, size: 18),
                  color: canDecrement ? ThemeTokens.primary : ThemeTokens.border,
                  onPressed: canDecrement ? onDecrement : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Text(valueText, key: valueKey, style: AppTypography.heading2()),
                      Text(unitText, style: AppTypography.micro()),
                    ],
                  ),
                ),
                IconButton(
                  key: incKey,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(Icons.add, size: 18),
                  color: canIncrement ? ThemeTokens.primary : ThemeTokens.border,
                  onPressed: canIncrement ? onIncrement : null,
                ),
              ],
            ),
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
                  Expanded(
                    child: Text(
                      category,
                      style: AppTypography.body(weight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            const Divider(color: ThemeTokens.border, height: 1),
            InkWell(
              onTap: () => _showAddCustomAppDialog(category),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.card)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 18, color: ThemeTokens.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '+ Add custom app to $category',
                        style: AppTypography.caption(color: ThemeTokens.primary, weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddCustomAppDialog(String category) {
    final nameCtrl = TextEditingController();
    final pkgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: ThemeTokens.border, width: 1),
        ),
        title: Text('Add App to $category', style: AppTypography.heading2()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppTypography.body(),
              decoration: InputDecoration(
                labelText: 'App Name',
                labelStyle: AppTypography.caption(color: ThemeTokens.textMuted),
                hintText: 'e.g. Chess, Telegram',
                hintStyle: AppTypography.caption(color: ThemeTokens.textMuted.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              onChanged: (val) {
                if (pkgCtrl.text.isEmpty || pkgCtrl.text.startsWith('com.custom.')) {
                  pkgCtrl.text = 'com.custom.${val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';
                }
              },
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: pkgCtrl,
              style: AppTypography.body(),
              decoration: InputDecoration(
                labelText: 'Package Name',
                labelStyle: AppTypography.caption(color: ThemeTokens.textMuted),
                hintText: 'e.g. com.example.app',
                hintStyle: AppTypography.caption(color: ThemeTokens.textMuted.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.caption(color: ThemeTokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeTokens.primary,
              foregroundColor: ThemeTokens.background,
            ),
            onPressed: () {
              final appName = nameCtrl.text.trim();
              final pkg = pkgCtrl.text.trim();
              if (appName.isNotEmpty) {
                final resolvedPkg = pkg.isNotEmpty ? pkg : 'com.custom.${appName.toLowerCase()}';
                setState(() {
                  _apps[resolvedPkg] = _AppItem(
                    appName,
                    category,
                    Icons.apps_rounded,
                    category == 'Distracting' ? true : false,
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AppItem {
  final String name;
  final String category;
  final IconData icon;
  final bool isBlocked;

  const _AppItem(this.name, this.category, this.icon, this.isBlocked);

  _AppItem copyWith({bool? isBlocked}) {
    return _AppItem(name, category, icon, isBlocked ?? this.isBlocked);
  }
}
