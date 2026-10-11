import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_tables.dart';
import '../../core/theme/theme.dart';
import '../../features/presets/presentation/presets_provider.dart';

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

  Future<void> _addLimit(String appName, String packageName, String category, int limitMinutes) async {
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
          DatabaseTables.colLimitExtraSessionDuration: 300,
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

  Future<void> _toggleLimit(String packageName, bool currentActive) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      await db.update(
        DatabaseTables.appLimits,
        {DatabaseTables.colLimitIsActive: currentActive ? 0 : 1},
        where: '${DatabaseTables.colLimitPackageName} = ?',
        whereArgs: [packageName],
      );
      await _loadLimits();
    } catch (_) {}
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final pkgCtrl = TextEditingController();
    final minsCtrl = TextEditingController(text: '30');
    String selectedCategory = 'Distracting';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ThemeTokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: const BorderSide(color: ThemeTokens.border, width: 1),
          ),
          title: Text('Add App Limit', style: AppTypography.heading2()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: AppTypography.body(),
                decoration: InputDecoration(
                  labelText: 'App Name',
                  hintText: 'e.g. Instagram',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
                onChanged: (val) {
                  if (pkgCtrl.text.isEmpty || pkgCtrl.text.startsWith('com.')) {
                    pkgCtrl.text = 'com.${val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';
                  }
                },
              ),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: minsCtrl,
                keyboardType: TextInputType.number,
                style: AppTypography.body(),
                decoration: InputDecoration(
                  labelText: 'Daily Limit (Minutes)',
                  hintText: 'e.g. 30',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
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
                final name = nameCtrl.text.trim();
                final pkg = pkgCtrl.text.trim();
                final mins = int.tryParse(minsCtrl.text.trim()) ?? 30;
                if (name.isNotEmpty) {
                  _addLimit(name, pkg.isNotEmpty ? pkg : 'com.${name.toLowerCase()}', selectedCategory, mins);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
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

                          final limitMins = dailySec ~/ 60;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s),
                            child: _buildAppCard(
                              appName: name,
                              packageName: pkg,
                              icon: Icons.apps_outlined,
                              spentText: '$limitMins mins daily limit',
                              isActive: isActive,
                              onToggle: () => _toggleLimit(pkg, isActive),
                              onDelete: () => _deleteLimit(pkg),
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
    required VoidCallback onToggle,
    required VoidCallback onDelete,
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
          Switch(
            value: isActive,
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
    );
  }
}
