import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../features/youtube_study/presentation/add_channel_confirmation_sheet.dart';
import '../../features/youtube_study/presentation/youtube_study_providers.dart';

/// ChannelWhitelistScreen displays and manages whitelisted YouTube study channels
/// persisted in SQLite table `study_channels` per ui_preset.md and TRD Section 4.6.
class ChannelWhitelistScreen extends ConsumerStatefulWidget {
  final String presetId;

  const ChannelWhitelistScreen({
    super.key,
    required this.presetId,
  });

  @override
  ConsumerState<ChannelWhitelistScreen> createState() => _ChannelWhitelistScreenState();
}

class _ChannelWhitelistScreenState extends ConsumerState<ChannelWhitelistScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddChannelSheet() async {
    await AddChannelConfirmationSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(whitelistedChannelsProvider);
    final isStudyActive = ref.watch(youtubeStudyActiveProvider);

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
        actions: [
          Row(
            children: [
              Text(
                isStudyActive ? 'Active' : 'Off',
                style: AppTypography.caption(
                  color: isStudyActive ? ThemeTokens.primary : ThemeTokens.textMuted,
                  weight: FontWeight.w600,
                ),
              ),
              Switch(
                key: const Key('study_mode_appbar_switch'),
                value: isStudyActive,
                activeThumbColor: ThemeTokens.primary,
                activeTrackColor: ThemeTokens.primary.withValues(alpha: 0.3),
                inactiveThumbColor: ThemeTokens.textMuted,
                inactiveTrackColor: ThemeTokens.surfaceElevated,
                onChanged: (_) =>
                    ref.read(youtubeStudyActiveProvider.notifier).toggle(),
              ),
              const SizedBox(width: AppSpacing.s),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
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

                // Search Bar
                TextField(
                  key: const Key('channel_search_bar'),
                  controller: _searchController,
                  style: AppTypography.body(),
                  decoration: InputDecoration(
                    hintText: 'Search channels by name or handle...',
                    prefixIcon: const Icon(Icons.search, color: ThemeTokens.textMuted),
                    filled: true,
                    fillColor: ThemeTokens.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                      borderSide: const BorderSide(color: ThemeTokens.border),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: ThemeTokens.textMuted),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                Expanded(
                  child: channelsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: ThemeTokens.primary),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error loading channels: $err', style: AppTypography.body()),
                    ),
                    data: (channels) {
                      final filtered = channels.where((ch) {
                        if (_searchQuery.isEmpty) return true;
                        final nameMatches = ch.channelName.toLowerCase().contains(_searchQuery);
                        final urlMatches = (ch.channelUrl ?? '').toLowerCase().contains(_searchQuery);
                        return nameMatches || urlMatches;
                      }).toList();

                      if (channels.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.video_library_outlined, size: 48, color: ThemeTokens.textMuted),
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                'No Channels Whitelisted',
                                style: AppTypography.heading2(color: ThemeTokens.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'In Study Mode, all YouTube videos are blocked unless the channel is added to this whitelist.',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption(color: ThemeTokens.textMuted),
                              ),
                              const SizedBox(height: AppSpacing.m),
                              ElevatedButton.icon(
                                key: const Key('add_first_channel_button'),
                                onPressed: _openAddChannelSheet,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add First Channel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeTokens.primary,
                                  foregroundColor: ThemeTokens.background,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No channels matching "$_searchQuery"',
                            style: AppTypography.body(color: ThemeTokens.textMuted),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
                        itemBuilder: (ctx, idx) {
                          final ch = filtered[idx];

                          return Container(
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
                                      Text(ch.channelName, style: AppTypography.body(weight: FontWeight.w600)),
                                      Text(
                                        ch.channelUrl ?? 'Whitelisted Channel',
                                        style: AppTypography.micro(color: ThemeTokens.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: ThemeTokens.textMuted, size: 20),
                                  tooltip: 'Remove from whitelist',
                                  onPressed: () => ref
                                      .read(whitelistedChannelsProvider.notifier)
                                      .removeChannel(ch.id),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    key: const Key('add_channel_button'),
                    onPressed: _openAddChannelSheet,
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
      ),
    );
  }
}
