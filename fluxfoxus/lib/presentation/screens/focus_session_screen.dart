import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// FocusSessionScreen renders the full-screen takeover active focus session.
/// Bottom navigation bar is hidden per ui_navigation.md Section 1.6 & 3.4.
class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = AppBreakpoints.isLandscape(context);
                final bool useHorizontalClock = isLandscape || constraints.maxHeight < 500;

                return AdaptiveScrollBody(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.s),
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: ThemeTokens.primary,
                                borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                              ),
                              child: Text(
                                'Deep Work',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption(
                                  color: ThemeTokens.background,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Flexible(
                            child: Text(
                              '10:00 AM – 10:25 AM',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(color: ThemeTokens.textMuted),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Mechanical Flip Clock Display (adaptive layout: horizontal in landscape/short, vertical in portrait)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: useHorizontalClock
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFlipClockCard('24', 'MINUTES', isCompact: constraints.maxHeight < 360),
                                  const SizedBox(width: 16),
                                  _buildFlipClockCard('59', 'SECONDS', isCompact: constraints.maxHeight < 360),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildFlipClockCard('24', 'MINUTES'),
                                  const SizedBox(height: 12),
                                  _buildFlipClockCard('59', 'SECONDS'),
                                ],
                              ),
                      ),

                      const Spacer(),

                      // Bottom Controls Row
                      Row(
                        children: [
                          // Stop Focusing Button
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                key: const Key('stop_focusing_button'),
                                onPressed: () => context.go(AppRoutes.home),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeTokens.surface,
                                  foregroundColor: ThemeTokens.textPrimary,
                                  side: const BorderSide(color: ThemeTokens.border, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                                  ),
                                  elevation: 0,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Stop Focusing',
                                    style: AppTypography.button(color: ThemeTokens.textPrimary),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.s),

                          // Break Button
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: ThemeTokens.accent, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Break (1)',
                                    style: AppTypography.button(color: ThemeTokens.accent),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.s),

                          // Pause / Play Circle
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isPaused = !_isPaused;
                              });
                            },
                            borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: ThemeTokens.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                color: ThemeTokens.background,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.m),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlipClockCard(String digits, String unit, {bool isCompact = false}) {
    final double cardWidth = isCompact ? 140 : 180;
    final double cardHeight = isCompact ? 84 : 110;
    final double fontSize = isCompact ? 42 : 56;
    final double seamTop = isCompact ? 41 : 54;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
        border: Border.all(color: ThemeTokens.border, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Horizontal Split Seam
          Positioned(
            left: 0,
            right: 0,
            top: seamTop,
            child: Container(
              height: 1.5,
              color: ThemeTokens.border,
            ),
          ),
          // Digits
          Text(
            digits,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: ThemeTokens.textPrimary,
              letterSpacing: 2,
            ),
          ),
          // Unit label
          Positioned(
            bottom: isCompact ? 3 : 6,
            child: Text(
              unit,
              style: AppTypography.micro(color: ThemeTokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
