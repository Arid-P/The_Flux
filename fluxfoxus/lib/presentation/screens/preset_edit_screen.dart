import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// PresetEditScreen allows modifying an existing preset by ID per ui_preset.md.
class PresetEditScreen extends StatelessWidget {
  final String presetId;

  const PresetEditScreen({
    super.key,
    required this.presetId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('Edit Preset', style: AppTypography.heading1()),
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
              const SizedBox(height: AppSpacing.m),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preset ID', style: AppTypography.caption(color: ThemeTokens.textMuted)),
                    const SizedBox(height: 4),
                    Text(presetId, style: AppTypography.heading2()),
                    const SizedBox(height: AppSpacing.m),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Study Channels', style: AppTypography.body()),
                      trailing: TextButton(
                        onPressed: () => context.push(AppRoutes.presetChannelsPath(presetId)),
                        child: Text('Manage Whitelist', style: AppTypography.caption(color: ThemeTokens.primary)),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('update_preset_button'),
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Save Changes', style: AppTypography.button(color: ThemeTokens.background)),
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
