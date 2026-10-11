import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import 'youtube_study_providers.dart';

/// Floating Edge Grabber widget per ui_distracted_intervention.md Section 3.5 & GMP_FF_BUILD Step 15.
/// Mounted on the right edge, vertically centered (~32x80dp pill), expands on tap
/// to reveal YouTube Study Mode toggle and status panel.
class YouTubeStudyEdgeGrabber extends ConsumerStatefulWidget {
  final VoidCallback? onOpenWhitelist;

  const YouTubeStudyEdgeGrabber({
    super.key,
    this.onOpenWhitelist,
  });

  @override
  ConsumerState<YouTubeStudyEdgeGrabber> createState() =>
      _YouTubeStudyEdgeGrabberState();
}

class _YouTubeStudyEdgeGrabberState extends ConsumerState<YouTubeStudyEdgeGrabber> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isStudyActive = ref.watch(youtubeStudyActiveProvider);

    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          color: ThemeTokens.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          border: Border.all(
            color: isStudyActive ? ThemeTokens.primary : ThemeTokens.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(-2, 2),
            ),
          ],
        ),
        child: _isExpanded
            ? _buildExpandedPanel(isStudyActive)
            : _buildCollapsedPill(isStudyActive),
      ),
    );
  }

  Widget _buildCollapsedPill(bool isStudyActive) {
    return InkWell(
      key: const Key('youtube_grabber_pill'),
      onTap: () => setState(() => _isExpanded = true),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        width: 32,
        height: 80,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined, // aperture icon metaphor
              size: 16,
              color: isStudyActive ? ThemeTokens.primary : ThemeTokens.accent,
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isStudyActive ? ThemeTokens.primary : ThemeTokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPanel(bool isStudyActive) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 18, color: ThemeTokens.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'YouTube Study',
                        style: AppTypography.body(weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: ThemeTokens.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _isExpanded = false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isStudyActive ? 'Enforcing Whitelist' : 'Study Mode Off',
                  style: AppTypography.caption(
                    color: isStudyActive ? ThemeTokens.primary : ThemeTokens.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(
                key: const Key('youtube_study_mode_switch'),
                value: isStudyActive,
                activeThumbColor: ThemeTokens.primary,
                activeTrackColor: ThemeTokens.primary.withValues(alpha: 0.3),
                inactiveThumbColor: ThemeTokens.textMuted,
                inactiveTrackColor: ThemeTokens.surfaceElevated,
                onChanged: (_) =>
                    ref.read(youtubeStudyActiveProvider.notifier).toggle(),
              ),
            ],
          ),
          if (widget.onOpenWhitelist != null) ...[
            const Divider(color: ThemeTokens.border, height: 16),
            InkWell(
              key: const Key('manage_whitelist_button'),
              onTap: () {
                setState(() => _isExpanded = false);
                widget.onOpenWhitelist?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Whitelist',
                      style: AppTypography.caption(
                        color: ThemeTokens.textPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: ThemeTokens.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
