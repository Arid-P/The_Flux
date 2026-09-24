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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeTokens.primary,
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    child: Text(
                      'Deep Work',
                      style: AppTypography.caption(
                        color: ThemeTokens.background,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '10:00 AM – 10:25 AM',
                    style: AppTypography.caption(color: ThemeTokens.textMuted),
                  ),
                ],
              ),

              const Spacer(),

              // Mechanical Flip Clock Display
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFlipClockCard('24', 'MINUTES'),
                  const SizedBox(height: 12),
                  _buildFlipClockCard('59', 'SECONDS'),
                ],
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
                        child: Text(
                          'Stop Focusing',
                          style: AppTypography.button(color: ThemeTokens.textPrimary),
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
                        child: Text(
                          'Break (1)',
                          style: AppTypography.button(color: ThemeTokens.accent),
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
        ),
      ),
    );
  }

  Widget _buildFlipClockCard(String digits, String unit) {
    return Container(
      width: 180,
      height: 110,
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
            top: 54,
            child: Container(
              height: 1.5,
              color: ThemeTokens.border,
            ),
          ),
          // Digits
          Text(
            digits,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w700,
              color: ThemeTokens.textPrimary,
              letterSpacing: 2,
            ),
          ),
          // Unit label
          Positioned(
            bottom: 6,
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
