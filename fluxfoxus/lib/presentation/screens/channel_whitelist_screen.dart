import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

/// ChannelWhitelistScreen displays whitelisted YouTube study channels per ui_preset.md.
class ChannelWhitelistScreen extends StatelessWidget {
  final String presetId;

  const ChannelWhitelistScreen({
    super.key,
    required this.presetId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('YouTube Study Mode', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeTokens.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s),
              Text(
                'Only whitelisted educational channels can be watched during sessions.',
                style: AppTypography.bodySmall(color: ThemeTokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.m),
              // Sample Whitelisted Channel Item
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_library_outlined, color: ThemeTokens.accent),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MIT OpenCourseWare', style: AppTypography.body(weight: FontWeight.w600)),
                          Text('Whitelisted Channel', style: AppTypography.micro(color: ThemeTokens.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: ThemeTokens.textMuted, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: ThemeTokens.primary),
                  label: Text('Add Channel', style: AppTypography.button(color: ThemeTokens.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ThemeTokens.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }
}
