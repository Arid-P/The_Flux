import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_tables.dart';
import '../../core/theme/theme.dart';
import '../../features/presets/presentation/presets_provider.dart';
import '../../features/usage_stats/usage_stats.dart';

/// AppLimitsScreen renders the Blocks tab and allows managing app limits per ui_app_limits.md.
/// Persists limits in SQLite database table `app_limits`.
class AppLimitsScreen extends ConsumerStatefulWidget {
  const AppLimitsScreen({super.key});

  @override
  ConsumerState<AppLimitsScreen> createState() => _AppLimitsScreenState();
}

class _AppLimitsScreenState extends ConsumerState<AppLimitsScreen> {
  List<Map<String, dynamic>> _limits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLimits();
  }

  Future<void> _loadLimits() async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      final rows = await db.query(
        DatabaseTables.appLimits,
        orderBy: '${DatabaseTables.colLimitCategory} ASC, ${DatabaseTables.colLimitAppName} ASC',
      );
      if (mounted) {
        setState(() {
          _limits = rows;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addLimit(
    String appName,
    String packageName,
    String category,
    int limitMinutes, {
    int extraLimitMinutes = 5,
  }) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      await db.insert(
        DatabaseTables.appLimits,
        {
          DatabaseTables.colLimitPackageName: packageName,
          DatabaseTables.colLimitAppName: appName,
          DatabaseTables.colLimitCategory: category,
          DatabaseTables.colLimitDailySeconds: limitMinutes * 60,
          DatabaseTables.colLimitExtraSessionCount: 0,
          DatabaseTables.colLimitExtraSessionDuration: extraLimitMinutes * 60,
          DatabaseTables.colLimitIsActive: 1,
          DatabaseTables.colLimitPausedUntil: null,
          DatabaseTables.colLimitStreakDays: 0,
          DatabaseTables.colLimitCreatedAt: DateTime.now().millisecondsSinceEpoch,
        },
      );
      await _loadLimits();
    } catch (_) {}
  }

  Future<void> _deleteLimit(String packageName) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      await db.delete(
        DatabaseTables.appLimits,
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: [packageName],
      );
      await _loadLimits();
    } catch (_) {}
  }

  Future<void> _toggleLimit(String packageName, String appName, int streakDays, bool currentActive) async {
    if (currentActive) {
      _showTurnOffBlockSheet(packageName, appName, streakDays);
    } else {
      await _resumeLimit(packageName);
    }
  }

  Future<void> _resumeLimit(String packageName) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      await db.update(
        DatabaseTables.appLimits,
        {
          DatabaseTables.colLimitIsActive: 1,
          DatabaseTables.colLimitPausedUntil: null,
        },
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: [packageName],
      );
      await _loadLimits();
    } catch (_) {}
  }

  Future<void> _pauseLimit(String packageName, Duration duration) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      final pausedUntil = DateTime.now().add(duration);
      await db.update(
        DatabaseTables.appLimits,
        {
          DatabaseTables.colLimitIsActive: 0,
          DatabaseTables.colLimitPausedUntil: pausedUntil.millisecondsSinceEpoch,
        },
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: [packageName],
      );
      await _loadLimits();
    } catch (_) {}
  }

  Future<void> _addExtraSession(String packageName, int minutes) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      final rows = await db.query(
        DatabaseTables.appLimits,
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: [packageName],
        limit: 1,
      );
      if (rows.isEmpty) return;

      final current = rows.first;
      final count = current[DatabaseTables.colLimitExtraSessionCount] as int? ?? 0;
      final duration = current[DatabaseTables.colLimitExtraSessionDuration] as int? ?? 300;
      if (count >= 6) return;
      if ((count * duration) + (minutes * 60) > 3600) return;

      await db.update(
        DatabaseTables.appLimits,
        {
          DatabaseTables.colLimitExtraSessionCount: count + 1,
          DatabaseTables.colLimitExtraSessionDuration: minutes * 60,
        },
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: [packageName],
      );
      await _loadLimits();
    } catch (_) {}
  }

  void _showTurnOffBlockSheet(String packageName, String appName, int streakDays) {
    int countdown = 3;
    Duration selectedDuration = const Duration(hours: 1);
    Timer? timer;

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (countdown > 0) {
              setSheetState(() => countdown--);
            } else {
              t.cancel();
            }
          });

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: ThemeTokens.accent, size: 28),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        'Turn Off Block: $appName',
                        style: AppTypography.heading2(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  streakDays > 0
                      ? 'Turning off this limit will freeze your $streakDays-day streak on $appName! Are you sure?'
                      : 'Are you sure you want to pause this application limit?',
                  style: AppTypography.body(color: ThemeTokens.textMuted),
                ),
                const SizedBox(height: AppSpacing.m),
                Text('PAUSE DURATION', style: AppTypography.label()),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('1 Hour'),
                      selected: selectedDuration == const Duration(hours: 1),
                      onSelected: (_) => setSheetState(() => selectedDuration = const Duration(hours: 1)),
                    ),
                    ChoiceChip(
                      label: const Text('Rest of Today'),
                      selected: selectedDuration == const Duration(hours: 8),
                      onSelected: (_) => setSheetState(() => selectedDuration = const Duration(hours: 8)),
                    ),
                    ChoiceChip(
                      label: const Text('Until Tomorrow'),
                      selected: selectedDuration == const Duration(hours: 24),
                      onSelected: (_) => setSheetState(() => selectedDuration = const Duration(hours: 24)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                ElevatedButton(
                  key: const Key('confirm_pause_limit_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.accent,
                    foregroundColor: ThemeTokens.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: countdown > 0
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _pauseLimit(packageName, selectedDuration);
                        },
                  child: Text(countdown > 0 ? 'Wait (${countdown}s)' : 'Pause Limit'),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() => timer?.cancel());
  }

  void _showAddDialog() {
    final searchCtrl = TextEditingController();
    final minsCtrl = TextEditingController(text: '30');
    int extraLimitMins = 5;
    AppUsageInfo? selectedApp;
    String selectedCategory = 'Distracting';
    String customAppName = '';
    String customPkgName = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final installedAppsAsync = ref.watch(installedAppsProvider);
          final allApps = installedAppsAsync.value ?? const <AppUsageInfo>[];
          final query = searchCtrl.text.trim().toLowerCase();
          final filteredApps = allApps.where((a) {
            if (query.isEmpty) return true;
            return a.appName.toLowerCase().contains(query) ||
                a.packageName.toLowerCase().contains(query);
          }).toList();

          return AlertDialog(
            backgroundColor: ThemeTokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: const BorderSide(color: ThemeTokens.border, width: 1),
            ),
            title: Text('Add App Limit', style: AppTypography.heading2()),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      controller: searchCtrl,
                      style: AppTypography.body(),
                      decoration: InputDecoration(
                        hintText: 'Search installed apps...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: ThemeTokens.textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          customAppName = val;
                          customPkgName = 'com.${val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // App picker list
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: ThemeTokens.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: ThemeTokens.border),
                      ),
                      child: filteredApps.isEmpty
                          ? Center(
                              child: Text(
                                query.isEmpty ? 'Loading installed apps...' : 'No matching apps found',
                                style: AppTypography.caption(color: ThemeTokens.textMuted),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredApps.length,
                              itemBuilder: (context, idx) {
                                final app = filteredApps[idx];
                                final isSelected = selectedApp?.packageName == app.packageName;
                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedApp = app;
                                      customAppName = app.appName;
                                      customPkgName = app.packageName;
                                      selectedCategory = app.category.displayName;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    color: isSelected ? ThemeTokens.primary.withValues(alpha: 0.2) : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.check_circle : Icons.apps,
                                          size: 18,
                                          color: isSelected ? ThemeTokens.primary : ThemeTokens.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                app.appName,
                                                style: AppTypography.caption(
                                                  color: isSelected ? ThemeTokens.primary : ThemeTokens.textPrimary,
                                                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                app.packageName,
                                                style: AppTypography.micro(color: ThemeTokens.textMuted),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Selected App label
                    if (selectedApp != null || customAppName.isNotEmpty) ...[
                      Text(
                        'Target: ${selectedApp?.appName ?? customAppName}',
                        style: AppTypography.caption(color: ThemeTokens.primary, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],

                    // Daily Limit Minutes
                    TextField(
                      controller: minsCtrl,
                      keyboardType: TextInputType.number,
                      style: AppTypography.body(),
                      decoration: InputDecoration(
                        labelText: 'Daily Limit (Minutes)',
                        hintText: 'e.g. 30',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Extra Limit Allowance Selector
                    Text(
                      'EXTRA LIMIT TIME ALLOWANCE',
                      style: AppTypography.micro(color: ThemeTokens.textMuted, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [5, 10, 15].map((mins) {
                        final isSel = extraLimitMins == mins;
                        return ChoiceChip(
                          label: Text('$mins min'),
                          selected: isSel,
                          onSelected: (_) => setDialogState(() => extraLimitMins = mins),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Category Selector
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: ThemeTokens.surfaceElevated,
                      items: const [
                        DropdownMenuItem(value: 'Distracting', child: Text('Distracting')),
                        DropdownMenuItem(value: 'Productive', child: Text('Productive')),
                        DropdownMenuItem(value: 'Semi-Productive', child: Text('Semi-Productive')),
                        DropdownMenuItem(value: 'Others', child: Text('Others')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCategory = val);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
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
                  final name = selectedApp?.appName ?? customAppName.trim();
                  final pkg = selectedApp?.packageName ?? customPkgName.trim();
                  final mins = int.tryParse(minsCtrl.text.trim()) ?? 30;
                  if (name.isNotEmpty) {
                    _addLimit(
                      name,
                      pkg.isNotEmpty ? pkg : 'com.${name.toLowerCase()}',
                      selectedCategory,
                      mins,
                      extraLimitMinutes: extraLimitMins,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save Limit'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group limits by category
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final l in _limits) {
      final cat = (l[DatabaseTables.colLimitCategory] as String?) ?? 'Distracting';
      grouped.putIfAbsent(cat, () => []).add(l);
    }

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Blocks', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'App Limits',
                        style: AppTypography.heading2(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      key: const Key('add_app_limit_button'),
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add, size: 18, color: ThemeTokens.accent),
                      label: Text(
                        'Add App',
                        style: AppTypography.button(color: ThemeTokens.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: CircularProgressIndicator(color: ThemeTokens.primary),
                    ),
                  )
                else if (_limits.isEmpty)
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
                        const Icon(Icons.block, size: 40, color: ThemeTokens.textMuted),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'No App Limits Set',
                          style: AppTypography.heading2(color: ThemeTokens.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enforce discipline by configuring daily usage limits on distracting applications.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(color: ThemeTokens.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        ElevatedButton(
                          onPressed: _showAddDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeTokens.primary,
                            foregroundColor: ThemeTokens.background,
                          ),
                          child: const Text('+ Add App Limit'),
                        ),
                      ],
                    ),
                  )
                else
                  ...grouped.entries.map((group) {
                    final cat = group.key;
                    final apps = group.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryHeader(cat, '${apps.length} ${apps.length == 1 ? "app" : "apps"}'),
                        const SizedBox(height: AppSpacing.s),
                        ...apps.map((app) {
                          final pkg = app[DatabaseTables.colLimitPackageName] as String;
                          final name = app[DatabaseTables.colLimitAppName] as String;
                          final dailySec = app[DatabaseTables.colLimitDailySeconds] as int? ?? 1800;
                          final isActive = (app[DatabaseTables.colLimitIsActive] as int? ?? 1) == 1;
                          final pausedUntilEpoch = app[DatabaseTables.colLimitPausedUntil] as int?;
                          final streakDays = app[DatabaseTables.colLimitStreakDays] as int? ?? 0;
                          final extraCount = app[DatabaseTables.colLimitExtraSessionCount] as int? ?? 0;

                          final limitMins = dailySec ~/ 60;
                          final isPaused = pausedUntilEpoch != null &&
                              DateTime.fromMillisecondsSinceEpoch(pausedUntilEpoch).isAfter(DateTime.now());

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s),
                            child: _buildAppCard(
                              appName: name,
                              packageName: pkg,
                              icon: Icons.apps_outlined,
                              spentText: '$limitMins mins daily limit',
                              isActive: isActive && !isPaused,
                              isPaused: isPaused,
                              pausedUntil: pausedUntilEpoch != null
                                  ? DateTime.fromMillisecondsSinceEpoch(pausedUntilEpoch)
                                  : null,
                              streakDays: streakDays,
                              extraSessionsUsed: extraCount,
                              onToggle: () => _toggleLimit(pkg, name, streakDays, isActive && !isPaused),
                              onDelete: () => _deleteLimit(pkg),
                              onAddExtraTime: (mins) => _addExtraSession(pkg, mins),
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.m),
                      ],
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
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
    required String packageName,
    required IconData icon,
    required String spentText,
    required bool isActive,
    bool isPaused = false,
    DateTime? pausedUntil,
    int streakDays = 0,
    int extraSessionsUsed = 0,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
    required ValueChanged<int> onAddExtraTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
        border: Border.all(
          color: isPaused ? ThemeTokens.warning.withValues(alpha: 0.5) : ThemeTokens.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appName,
                            style: AppTypography.body(weight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (streakDays > 0) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ThemeTokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusSm),
                              border: Border.all(color: ThemeTokens.accent, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department, size: 12, color: ThemeTokens.accent),
                                const SizedBox(width: 2),
                                Text(
                                  '${streakDays}d',
                                  style: AppTypography.micro(color: ThemeTokens.textPrimary, weight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(spentText, style: AppTypography.caption(color: ThemeTokens.textMuted)),
                  ],
                ),
              ),
              Switch(
                value: isActive && !isPaused,
                activeThumbColor: ThemeTokens.primary,
                activeTrackColor: ThemeTokens.primary.withValues(alpha: 0.3),
                inactiveThumbColor: ThemeTokens.textMuted,
                inactiveTrackColor: ThemeTokens.surfaceElevated,
                onChanged: (_) => onToggle(),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: ThemeTokens.textMuted),
                tooltip: 'Remove Limit',
                onPressed: onDelete,
              ),
            ],
          ),
          if (isPaused && pausedUntil != null) ...[
            const SizedBox(height: AppSpacing.s),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeTokens.surfaceElevated,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusSm),
                border: Border.all(color: ThemeTokens.warning.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Paused till ${pausedUntil.hour.toString().padLeft(2, '0')}:${pausedUntil.minute.toString().padLeft(2, '0')}',
                style: AppTypography.caption(color: ThemeTokens.warning),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extra: $extraSessionsUsed/6 used',
                style: AppTypography.micro(color: ThemeTokens.textMuted),
              ),
              Wrap(
                spacing: 6,
                children: [
                  _buildQuickExtraChip('+5m', 5, onAddExtraTime, extraSessionsUsed >= 6),
                  _buildQuickExtraChip('+10m', 10, onAddExtraTime, extraSessionsUsed >= 6),
                  _buildQuickExtraChip('+15m', 15, onAddExtraTime, extraSessionsUsed >= 6),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExtraChip(String label, int mins, ValueChanged<int> onAdd, bool disabled) {
    return InkWell(
      onTap: disabled ? null : () => onAdd(mins),
      borderRadius: BorderRadius.circular(ThemeTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceElevated,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusSm),
          border: Border.all(color: disabled ? ThemeTokens.border : ThemeTokens.secondary, width: 0.8),
        ),
        child: Text(
          label,
          style: AppTypography.micro(
            color: disabled ? ThemeTokens.textMuted : ThemeTokens.textPrimary,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
