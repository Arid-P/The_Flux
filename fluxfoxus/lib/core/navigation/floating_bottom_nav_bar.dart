import 'package:flutter/material.dart';
import '../theme/theme_tokens.dart';
import '../theme/app_typography.dart';
import 'aperture_icon.dart';

/// FloatingBottomNavBar implements the 5-tab floating pill navigation bar
/// adhering strictly to `ui_navigation.md` and the Rustic Medley palette (`ff_design_override.md`).
///
/// Features:
/// - Floating container with 28px border radius, 16px margin, 72px height, 1px border.
/// - 5 tabs: Home (Aperture), Usage (Clock), Focus (Eye), Planner (Calendar), Block (Shield).
/// - Distinct sub-container visual grouping: Home standalone, [Usage + Focus] left pair, [Planner + Block] right pair.
/// - Active accent: Primary Rustic Amber `#CA9C68`.
class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeTokens.surface,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusXl),
            border: Border.all(
              color: ThemeTokens.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Home Standalone Tab
              Expanded(
                flex: 10,
                child: _buildTabItem(
                  index: 0,
                  label: 'Home',
                  iconBuilder: (color) => ApertureIcon(size: 22, color: color),
                ),
              ),

              const SizedBox(width: 4),

              // 2. Left Group: [Usage + Focus]
              Expanded(
                flex: 21,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: ThemeTokens.surfaceElevated.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabItem(
                          index: 1,
                          label: 'Usage',
                          iconBuilder: (color) => Icon(
                            Icons.access_time_outlined,
                            size: 22,
                            color: color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTabItem(
                          index: 2,
                          label: 'Focus',
                          iconBuilder: (color) => Icon(
                            Icons.remove_red_eye_outlined,
                            size: 22,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // 3. Right Group: [Planner + Block]
              Expanded(
                flex: 21,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: ThemeTokens.surfaceElevated.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabItem(
                          index: 3,
                          label: 'Planner',
                          iconBuilder: (color) => Icon(
                            Icons.calendar_today_outlined,
                            size: 22,
                            color: color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTabItem(
                          index: 4,
                          label: 'Block',
                          iconBuilder: (color) => Icon(
                            Icons.shield_outlined,
                            size: 22,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required Widget Function(Color color) iconBuilder,
  }) {
    final bool isActive = currentIndex == index;
    final Color itemColor = isActive ? ThemeTokens.primary : ThemeTokens.textMuted;
    final FontWeight fontWeight = isActive ? FontWeight.w600 : FontWeight.w500;

    return Semantics(
      button: true,
      label: '$label tab',
      selected: isActive,
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBuilder(itemColor),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption(
                color: itemColor,
                weight: fontWeight,
              ).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
