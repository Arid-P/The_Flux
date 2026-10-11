import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_tables.dart';
import '../../core/theme/theme.dart';
import '../../features/presets/presentation/presets_provider.dart';

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
  static const _uuid = Uuid();
  List<Map<String, dynamic>> _channels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      final rows = await db.query(
        DatabaseTables.studyChannels,
        orderBy: '${DatabaseTables.colChannelAddedAt} DESC',
      );
      if (mounted) {
        setState(() {
          _channels = rows;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addChannel(String name, String? url) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      await db.insert(
        DatabaseTables.studyChannels,
        {
          DatabaseTables.colChannelId: _uuid.v4(),
          DatabaseTables.colChannelName: name,
          DatabaseTables.colChannelUrl: url,
          DatabaseTables.colChannelAddedAt: DateTime.now().millisecondsSinceEpoch,
        },
      );
      await _loadChannels();
    } catch (_) {}
  }

  Future<void> _deleteChannel(String id) async {
    try {
      final db = await ref.read(appDatabaseProvider).database;
      await db.delete(
        DatabaseTables.studyChannels,
        where: '${DatabaseTables.colChannelId} = ?',
        whereArgs: [id],
      );
      await _loadChannels();
    } catch (_) {}
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: ThemeTokens.border, width: 1),
        ),
        title: Text('Add Educational Channel', style: AppTypography.heading2()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppTypography.body(),
              decoration: InputDecoration(
                labelText: 'Channel Name',
                hintText: 'e.g. 3Blue1Brown, Khan Academy',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: urlCtrl,
              style: AppTypography.body(),
              decoration: InputDecoration(
                labelText: 'Channel URL / Handle (Optional)',
                hintText: 'e.g. @3blue1brown',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.caption(color: ThemeTokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeTokens.primary,
              foregroundColor: ThemeTokens.background,
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final url = urlCtrl.text.trim();
              if (name.isNotEmpty) {
                _addChannel(name, url.isNotEmpty ? url : null);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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

                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: ThemeTokens.primary),
                    ),
                  )
                else if (_channels.isEmpty)
                  Expanded(
                    child: Center(
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
                            onPressed: _showAddDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add First Channel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeTokens.primary,
                              foregroundColor: ThemeTokens.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _channels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
                      itemBuilder: (ctx, idx) {
                        final ch = _channels[idx];
                        final id = ch[DatabaseTables.colChannelId] as String;
                        final name = ch[DatabaseTables.colChannelName] as String;
                        final url = ch[DatabaseTables.colChannelUrl] as String?;

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
                                    Text(name, style: AppTypography.body(weight: FontWeight.w600)),
                                    Text(
                                      url ?? 'Whitelisted Channel',
                                      style: AppTypography.micro(color: ThemeTokens.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: ThemeTokens.textMuted, size: 20),
                                tooltip: 'Remove from whitelist',
                                onPressed: () => _deleteChannel(id),
                              ),
                            ],
                          ),
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
                    onPressed: _showAddDialog,
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
