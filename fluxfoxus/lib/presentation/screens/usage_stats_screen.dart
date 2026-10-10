import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../widgets/bezier_momentum_chart.dart';

enum UsageTab { today, daily, weekly }

/// UsageStatsScreen renders complete usage statistics, timeline charts,
/// and searchable application breakdown per ui_mockups/usage_stats.html and ui_usage_stats.md.
class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  UsageTab _selectedTab = UsageTab.today;
  int _selectedDayIndex = 2; // Wednesday by default
  bool _showWeeklySummary = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_AppUsageData> _allApps = const [
    _AppUsageData('Instagram', 'Distracting', Duration(minutes: 75), Icons.camera_alt_outlined, Color(0xFFC27838)),
    _AppUsageData('YouTube', 'Semi-Productive', Duration(minutes: 50), Icons.play_circle_outline, Color(0xFF906D4B)),
    _AppUsageData('Notion', 'Productive', Duration(minutes: 65), Icons.edit_note_outlined, Color(0xFF4E7D56)),
    _AppUsageData('X / Twitter', 'Distracting', Duration(minutes: 40), Icons.chat_bubble_outline, Color(0xFFC27838)),
    _AppUsageData('Visual Studio Code', 'Productive', Duration(minutes: 90), Icons.code_rounded, Color(0xFF4E7D56)),
    _AppUsageData('System Settings', 'Others', Duration(minutes: 20), Icons.settings_outlined, Color(0xFF64748B)),
    _AppUsageData('WhatsApp', 'Semi-Productive', Duration(minutes: 35), Icons.chat_outlined, Color(0xFF906D4B)),
    _AppUsageData('Chrome', 'Others', Duration(minutes: 30), Icons.language_outlined, Color(0xFF64748B)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _allApps.where((app) {
      if (_searchQuery.isEmpty) return true;
      return app.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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

                // 1. Top Bar: Back, Title, Help
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      key: const Key('usage_back_button'),
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ThemeTokens.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: ThemeTokens.border, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.arrow_back_ios_new, size: 16, color: ThemeTokens.textPrimary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Usage Stats',
                        textAlign: TextAlign.center,
                        style: AppTypography.heading1(color: ThemeTokens.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      key: const Key('usage_help_button'),
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

                const SizedBox(height: AppSpacing.m),

                // 2. Tab Selector: Today | Daily | Weekly
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: ThemeTokens.border, width: 1)),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('Today', UsageTab.today),
                      _buildTabButton('Daily', UsageTab.daily),
                      _buildTabButton('Weekly', UsageTab.weekly),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 3. Weekly Summary Card (Visible on Weekly tab)
                if (_selectedTab == UsageTab.weekly && _showWeeklySummary) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: ThemeTokens.primary.withValues(alpha: 0.1),
                        border: const Border(
                          left: BorderSide(color: ThemeTokens.primary, width: 4),
                          top: BorderSide(color: ThemeTokens.border, width: 1),
                          right: BorderSide(color: ThemeTokens.border, width: 1),
                          bottom: BorderSide(color: ThemeTokens.border, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('📊', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SUNDAY WEEKLY REPORT',
                                    style: AppTypography.micro(
                                      color: ThemeTokens.primary,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => setState(() => _showWeeklySummary = false),
                                child: const Icon(Icons.close, size: 16, color: ThemeTokens.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.caption(color: ThemeTokens.textPrimary),
                              children: const [
                                TextSpan(text: 'You focused '),
                                TextSpan(
                                  text: '2h 15m more',
                                  style: TextStyle(color: ThemeTokens.primary, fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: ' than last week! 🔥'),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMiniStatBox(
                                  label: 'CURRENT STREAK',
                                  value: '🔥 5 days',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: _buildMiniStatBox(
                                  label: 'TOTAL FOCUSED',
                                  value: '22h 45m',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMiniStatBox(
                                  label: 'PEAK DAY',
                                  value: 'Wed (4h 30m)',
                                  valueColor: ThemeTokens.categoryProductive,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: _buildMiniStatBox(
                                  label: 'MIN DAY',
                                  value: 'Sun (1h 10m)',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],

                // 4. Dynamic Chart Section
                Container(
                  width: double.infinity,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DISTRIBUTION',
                                  style: AppTypography.micro(
                                    color: ThemeTokens.textMuted,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedTab == UsageTab.today
                                      ? "Today's Timeline"
                                      : _selectedTab == UsageTab.daily
                                          ? 'Daily Overview'
                                          : 'Weekly Trend',
                                  style: AppTypography.heading2(color: ThemeTokens.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeTokens.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                              border: Border.all(color: ThemeTokens.primary.withValues(alpha: 0.4), width: 1),
                            ),
                            child: Text(
                              _selectedTab == UsageTab.today
                                  ? '6h 00m Total'
                                  : _selectedTab == UsageTab.daily
                                      ? '38h 15m Total'
                                      : '142h Total',
                              style: AppTypography.micro(
                                color: ThemeTokens.primary,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Chart view based on selected tab
                      if (_selectedTab == UsageTab.today) ...[
                        const BezierMomentumChart(
                          height: 160,
                          showLegend: false,
                        ),
                      ] else if (_selectedTab == UsageTab.daily) ...[
                        _buildDailyBarChart(),
                      ] else ...[
                        _buildWeeklyBarChart(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 5. 2x2 Category Legend Grid
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: ThemeTokens.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: ThemeTokens.border, width: 1),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Col 1: Productive + Semi-Productive
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.s),
                            child: Column(
                              children: [
                                _buildLegendItem(
                                  label: 'Productive',
                                  value: _selectedTab == UsageTab.today ? '1h 45m' : '14h 20m',
                                  color: ThemeTokens.categoryProductive,
                                ),
                                const SizedBox(height: 6),
                                const Divider(color: ThemeTokens.border, height: 1),
                                const SizedBox(height: 6),
                                _buildLegendItem(
                                  label: 'Semi-Prod',
                                  value: _selectedTab == UsageTab.today ? '0h 50m' : '8h 35m',
                                  color: ThemeTokens.categorySemiProductive,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(color: ThemeTokens.border, width: 1),
                        // Col 2: Distracting + Others
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.s),
                            child: Column(
                              children: [
                                _buildLegendItem(
                                  label: 'Distracting',
                                  value: _selectedTab == UsageTab.today ? '2h 15m' : '11h 10m',
                                  color: const Color(0xFFC27838),
                                  hasBorder: true,
                                ),
                                const SizedBox(height: 6),
                                const Divider(color: ThemeTokens.border, height: 1),
                                const SizedBox(height: 6),
                                _buildLegendItem(
                                  label: 'Others',
                                  value: _selectedTab == UsageTab.today ? '1h 10m' : '4h 10m',
                                  color: const Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // 6. Applications Used Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'APPLICATIONS USED',
                        style: AppTypography.micro(
                          color: ThemeTokens.textMuted,
                          weight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${filteredApps.length} apps tracked',
                      style: AppTypography.micro(color: ThemeTokens.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),

                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: ThemeTokens.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: ThemeTokens.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.search, size: 18, color: ThemeTokens.textMuted),
                      ),
                      Expanded(
                        child: TextField(
                          key: const Key('usage_apps_search_input'),
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: AppTypography.caption(color: ThemeTokens.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search apps...',
                            hintStyle: AppTypography.caption(color: ThemeTokens.textMuted),
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: ThemeTokens.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s),

                // Applications List
                if (filteredApps.isEmpty)
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
                        const Icon(Icons.search_off, size: 36, color: ThemeTokens.textMuted),
                        const SizedBox(height: AppSpacing.s),
                        Text('No apps found', style: AppTypography.heading2(color: ThemeTokens.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for another name or category',
                          style: AppTypography.caption(color: ThemeTokens.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredApps.map((app) => _buildAppRow(app)),

                const SizedBox(height: 100), // Floating bottom nav bar clearance
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, UsageTab tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: InkWell(
        key: Key('usage_tab_${tab.name}'),
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? ThemeTokens.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: isSelected
                ? AppTypography.caption(color: ThemeTokens.textPrimary, weight: FontWeight.w700)
                : AppTypography.caption(color: ThemeTokens.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatBox({required String label, required String value, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeTokens.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: ThemeTokens.border.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.micro(color: ThemeTokens.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.caption(
              color: valueColor ?? ThemeTokens.textPrimary,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = [0.65, 0.50, 0.85, 0.70, 0.90, 0.40, 0.30];

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (idx) {
              final isSelected = idx == _selectedDayIndex;
              final hRatio = heights[idx];
              return InkWell(
                onTap: () => setState(() => _selectedDayIndex = idx),
                borderRadius: BorderRadius.circular(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 120 * hRatio,
                      decoration: BoxDecoration(
                        color: isSelected ? ThemeTokens.primary : ThemeTokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? ThemeTokens.primary : ThemeTokens.border,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (120 * hRatio) * 0.4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4E7D56),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      days[idx],
                      style: AppTypography.micro(
                        color: isSelected ? ThemeTokens.primary : ThemeTokens.textMuted,
                        weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap any bar to inspect category breakdown for that day',
          style: AppTypography.micro(color: ThemeTokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarChart() {
    final weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
    final heights = [0.45, 0.55, 0.60, 0.75, 0.70, 0.85, 0.95];

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (idx) {
              final isLatest = idx == 6;
              final hRatio = heights[idx];
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 28,
                    height: 120 * hRatio,
                    decoration: BoxDecoration(
                      color: isLatest ? ThemeTokens.primary : ThemeTokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isLatest ? ThemeTokens.primary : ThemeTokens.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (120 * hRatio) * 0.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4E7D56),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weeks[idx],
                    style: AppTypography.micro(
                      color: isLatest ? ThemeTokens.primary : ThemeTokens.textMuted,
                      weight: isLatest ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Displaying the 7 most recent rolling weeks',
          style: AppTypography.micro(color: ThemeTokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required String label,
    required String value,
    required Color color,
    bool hasBorder = false,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: ThemeTokens.textMuted, width: 1) : null,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: AppTypography.micro(color: ThemeTokens.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.micro(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildAppRow(_AppUsageData app) {
    final int minutes = app.duration.inMinutes;
    final double fraction = (minutes / 120).clamp(0.05, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ThemeTokens.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                alignment: Alignment.center,
                child: Icon(app.icon, size: 18, color: app.categoryColor),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.name, style: AppTypography.caption(color: ThemeTokens.textPrimary, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(app.category, style: AppTypography.micro(color: ThemeTokens.textMuted)),
                  ],
                ),
              ),
              Text(
                '${minutes ~/ 60 > 0 ? '${minutes ~/ 60}h ' : ''}${minutes % 60}m',
                style: AppTypography.caption(color: ThemeTokens.textPrimary, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: ThemeTokens.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(app.categoryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
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
            Text('Usage Stats Guide', style: AppTypography.heading2()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Today Tab: Shows the 24-hour Bézier stacked area momentum curve across 4 categories.',
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Daily Tab: Displays a 7-day breakdown (Mon–Sun). Tap any day to inspect details.',
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 8),
            Text(
              '• Weekly Tab: Rolling 7-week view with Sunday summary progress insights.',
              style: AppTypography.caption(),
            ),
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

class _AppUsageData {
  final String name;
  final String category;
  final Duration duration;
  final IconData icon;
  final Color categoryColor;

  const _AppUsageData(this.name, this.category, this.duration, this.icon, this.categoryColor);
}
