import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/theme.dart';
import '../domain/confirmation_sentences.dart';
import '../domain/study_channel.dart';
import 'youtube_study_providers.dart';

/// Modal bottom sheet enforcing the confirmation sentence typing ritual
/// prior to whitelisting any YouTube channel per Step 15 & 16.
class AddChannelConfirmationSheet extends ConsumerStatefulWidget {
  const AddChannelConfirmationSheet({super.key});

  static Future<StudyChannel?> show(BuildContext context) {
    return showModalBottomSheet<StudyChannel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddChannelConfirmationSheet(),
    );
  }

  @override
  ConsumerState<AddChannelConfirmationSheet> createState() =>
      _AddChannelConfirmationSheetState();
}

class _AddChannelConfirmationSheetState
    extends ConsumerState<AddChannelConfirmationSheet> {
  static const _uuid = Uuid();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _sentenceController = TextEditingController();

  String _requiredSentence = ConfirmationSentences.shortPool.first;

  @override
  void initState() {
    super.initState();
    _loadSentence();
    _sentenceController.addListener(() => setState(() {}));
    _nameController.addListener(() => setState(() {}));
  }

  Future<void> _loadSentence() async {
    try {
      final service = ref.read(youtubeStudyServiceProvider);
      final sentence = await service.getNextConfirmationSentence();
      if (mounted) {
        setState(() {
          _requiredSentence = sentence;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _sentenceController.dispose();
    super.dispose();
  }

  bool get _isSentenceMatching =>
      _sentenceController.text.trim() == _requiredSentence.trim();

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && _isSentenceMatching;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: AppSpacing.l + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.school_rounded, color: ThemeTokens.primary, size: 24),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    'Add Educational Channel',
                    style: AppTypography.heading2(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: ThemeTokens.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'To protect focus, adding YouTube channels requires typing the confirmation sentence below to ensure deliberate intention.',
              style: AppTypography.caption(color: ThemeTokens.textMuted),
            ),
            const SizedBox(height: AppSpacing.m),

            TextField(
              key: const Key('channel_name_input'),
              controller: _nameController,
              style: AppTypography.body(),
              decoration: InputDecoration(
                labelText: 'Channel Name',
                hintText: 'e.g. 3Blue1Brown, MIT OCW',
                filled: true,
                fillColor: ThemeTokens.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                  borderSide: const BorderSide(color: ThemeTokens.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),

            TextField(
              key: const Key('channel_url_input'),
              controller: _urlController,
              style: AppTypography.body(),
              decoration: InputDecoration(
                labelText: 'Handle / URL (Optional)',
                hintText: 'e.g. @3blue1brown',
                filled: true,
                fillColor: ThemeTokens.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                  borderSide: const BorderSide(color: ThemeTokens.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            Text('TYPE TO CONFIRM INTENTION', style: AppTypography.label()),
            const SizedBox(height: AppSpacing.xs),

            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                  color: ThemeTokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                  border: Border.all(
                    color: _isSentenceMatching
                        ? ThemeTokens.success
                        : ThemeTokens.border,
                    width: 1,
                  ),
                ),
                child: SelectableText(
                  _requiredSentence,
                  key: const Key('confirmation_sentence_target'),
                  style: AppTypography.body(
                    color: ThemeTokens.primary,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.s),

            TextField(
              key: const Key('confirmation_sentence_input'),
              controller: _sentenceController,
              maxLines: 2,
              style: AppTypography.body(),
              decoration: InputDecoration(
                hintText: 'Type the exact sentence above...',
                filled: true,
                fillColor: ThemeTokens.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMd),
                  borderSide: BorderSide(
                    color: _isSentenceMatching ? ThemeTokens.success : ThemeTokens.border,
                  ),
                ),
                suffixIcon: _isSentenceMatching
                    ? const Icon(Icons.check_circle, color: ThemeTokens.success)
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            ElevatedButton(
              key: const Key('confirm_add_channel_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeTokens.primary,
                foregroundColor: ThemeTokens.background,
                disabledBackgroundColor: ThemeTokens.surfaceElevated,
                disabledForegroundColor: ThemeTokens.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                ),
              ),
              onPressed: _canSubmit
                  ? () async {
                      final newChannel = StudyChannel(
                        id: _uuid.v4(),
                        channelName: _nameController.text.trim(),
                        channelUrl: _urlController.text.trim().isNotEmpty
                            ? _urlController.text.trim()
                            : null,
                        addedAt: DateTime.now(),
                      );
                      await ref
                          .read(whitelistedChannelsProvider.notifier)
                          .addChannel(newChannel);
                      if (context.mounted) {
                        Navigator.pop(context, newChannel);
                      }
                    }
                  : null,
              child: Text(
                _isSentenceMatching ? 'Confirm & Add Channel' : 'Type Sentence Exactly to Enable',
                style: AppTypography.button(
                  color: _canSubmit ? ThemeTokens.background : ThemeTokens.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
