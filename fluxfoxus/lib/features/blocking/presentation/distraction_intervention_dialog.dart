import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Distraction Intervention Modal per ui_distracted_intervention.md.
/// Intercepts distracted app launches outside active focus sessions.
class DistractionInterventionDialog extends StatefulWidget {
  final String appName;
  final String packageName;
  final int spentMinutes;
  final int limitMinutes;
  final int streakDays;
  final bool isReappearance;
  final int initialWaitSeconds;
  final VoidCallback? onExitApp;
  final ValueChanged<int>? onSelectMinutes;
  final VoidCallback? onActivateYouTubeStudyMode;

  const DistractionInterventionDialog({
    super.key,
    required this.appName,
    required this.packageName,
    this.spentMinutes = 20,
    this.limitMinutes = 30,
    this.streakDays = 5,
    this.isReappearance = false,
    this.initialWaitSeconds = 0,
    this.onExitApp,
    this.onSelectMinutes,
    this.onActivateYouTubeStudyMode,
  });

  static Future<int?> show(
    BuildContext context, {
    required String appName,
    required String packageName,
    int spentMinutes = 20,
    int limitMinutes = 30,
    int streakDays = 5,
    bool isReappearance = false,
    int initialWaitSeconds = 0,
    VoidCallback? onExitApp,
    VoidCallback? onActivateYouTubeStudyMode,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => DistractionInterventionDialog(
        appName: appName,
        packageName: packageName,
        spentMinutes: spentMinutes,
        limitMinutes: limitMinutes,
        streakDays: streakDays,
        isReappearance: isReappearance,
        initialWaitSeconds: initialWaitSeconds,
        onExitApp: onExitApp,
        onActivateYouTubeStudyMode: onActivateYouTubeStudyMode,
      ),
    );
  }

  @override
  State<DistractionInterventionDialog> createState() => _DistractionInterventionDialogState();
}

class _DistractionInterventionDialogState extends State<DistractionInterventionDialog> {
  int? _selectedMinutes;
  int _waitCountdown = 0;
  Timer? _waitTimer;
  bool _isStudyModeActive = false;

  @override
  void initState() {
    super.initState();
    _waitCountdown = widget.initialWaitSeconds;
    if (_waitCountdown > 0) {
      _startWaitTimer();
    }
  }

  void _startWaitTimer() {
    _waitTimer?.cancel();
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_waitCountdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _waitCountdown = 0);
      } else {
        if (mounted) setState(() => _waitCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  bool get _isYouTube =>
      widget.packageName.contains('youtube') || widget.appName.toLowerCase().contains('youtube');

  @override
  Widget build(BuildContext context) {
    final limitLeftMins = (widget.limitMinutes - widget.spentMinutes).clamp(0, 9999);
    final progress = widget.limitMinutes > 0
        ? (widget.spentMinutes / widget.limitMinutes).clamp(0.0, 1.0)
        : 1.0;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: ThemeTokens.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(color: ThemeTokens.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: App Info + Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ThemeTokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ThemeTokens.border, width: 1),
                        ),
                        child: const Icon(Icons.apps_rounded, size: 18, color: ThemeTokens.primary),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        '${widget.limitMinutes}m limit',
                        style: AppTypography.body(weight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 18, color: ThemeTokens.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.streakDays} days',
                        style: AppTypography.caption(color: ThemeTokens.textPrimary, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // Row 2: Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 8,
                  color: ThemeTokens.background,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ThemeTokens.secondary, ThemeTokens.primary],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Row 3: Time Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.spentMinutes}m / Spent today',
                    style: AppTypography.caption(color: ThemeTokens.textMuted),
                  ),
                  Text(
                    '${limitLeftMins}m / Limit left',
                    style: AppTypography.caption(color: ThemeTokens.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // Row 4: YouTube Study Mode Card (if YouTube)
              if (_isYouTube) ...[
                InkWell(
                  key: const Key('youtube_study_mode_card'),
                  onTap: () {
                    setState(() => _isStudyModeActive = true);
                    widget.onActivateYouTubeStudyMode?.call();
                  },
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: ThemeTokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                      border: Border.all(
                        color: _isStudyModeActive ? ThemeTokens.primary : ThemeTokens.secondary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_fill, size: 22, color: ThemeTokens.accent),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            _isStudyModeActive
                                ? 'Study Mode: ACTIVE (Whitelisted Only)'
                                : 'Watch only Study channels on YouTube',
                            style: AppTypography.body(weight: FontWeight.w600),
                          ),
                        ),
                        if (_isStudyModeActive)
                          const Icon(Icons.check_circle, size: 18, color: ThemeTokens.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              // Row 5 & 6: 2x2 Time Option Grid (hidden if Study Mode activated)
              if (!_isStudyModeActive) ...[
                Text(
                  _waitCountdown > 0
                      ? 'Wait ${_waitCountdown}s to select time'
                      : 'How long do you want to use?',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    color: _waitCountdown > 0 ? ThemeTokens.textMuted : ThemeTokens.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),

                Row(
                  children: [
                    Expanded(child: _buildTimeOptionChip(2)),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(child: _buildTimeOptionChip(5)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Expanded(child: _buildTimeOptionChip(10)),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(child: _buildTimeOptionChip(20)),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
              ],

              // Row 7: Exit Button
              ElevatedButton(
                key: const Key('exit_app_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeTokens.primary,
                  foregroundColor: ThemeTokens.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  widget.onExitApp?.call();
                  Navigator.pop(context);
                },
                child: Text(
                  'Exit ${widget.appName}',
                  style: AppTypography.button(color: ThemeTokens.background),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOptionChip(int minutes) {
    final isSelected = _selectedMinutes == minutes;
    final isDisabled = _waitCountdown > 0;

    return OutlinedButton(
      key: Key('option_${minutes}m_button'),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? ThemeTokens.primary : Colors.transparent,
        foregroundColor: isSelected ? ThemeTokens.background : ThemeTokens.textPrimary,
        side: BorderSide(
          color: isSelected ? ThemeTokens.primary : ThemeTokens.border,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: isDisabled
          ? null
          : () {
              setState(() => _selectedMinutes = minutes);
              widget.onSelectMinutes?.call(minutes);
              Navigator.pop(context, minutes);
            },
      child: Text(
        '$minutes mins',
        style: AppTypography.body(
          color: isDisabled
              ? ThemeTokens.textMuted
              : (isSelected ? ThemeTokens.background : ThemeTokens.textPrimary),
          weight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
