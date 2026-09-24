import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';

/// PresetCreateScreen allows creating new focus presets per ui_preset.md.
class PresetCreateScreen extends StatelessWidget {
  const PresetCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text('New Preset', style: AppTypography.heading1()),
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeTokens.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.m),
              // Preset Name Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: ThemeTokens.surface,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLg),
                  border: Border.all(color: ThemeTokens.border, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ThemeTokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: const Text('⏳', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Preset Name (e.g. Deep Work)',
                          hintStyle: AppTypography.body(color: ThemeTokens.textMuted),
                          border: InputBorder.none,
                        ),
                        style: AppTypography.body(color: ThemeTokens.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              // YouTube Mode Card
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
                    Text('YouTube Mode', style: AppTypography.heading2()),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Choose how YouTube is managed during focus sessions.',
                      style: AppTypography.bodySmall(color: ThemeTokens.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Study Mode (Whitelisted Channels)', style: AppTypography.body()),
                      trailing: TextButton(
                        onPressed: () => context.push(AppRoutes.presetChannelsPath('new')),
                        child: Text('Edit Channels', style: AppTypography.caption(color: ThemeTokens.primary)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('save_preset_button'),
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeTokens.primary,
                    foregroundColor: ThemeTokens.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Save Preset', style: AppTypography.button(color: ThemeTokens.background)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
