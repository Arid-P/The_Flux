import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// EmojiPickerSheet displays the emoji grid bottom sheet matching ui_preset.md Section 9.
class EmojiPickerSheet extends StatelessWidget {
  static const List<String> defaultEmojis = [
    '⏳', '🎯', '📚', '💻', '🧠', '⚡', '🔥', '🚀',
    '☕', '📝', '🎨', '🔬', '📖', '🧘', '🏋️', '💡',
    '⏱️', '🛠️', '🎓', '💼', '🎧', '📊', '🍎', '🌟',
  ];

  const EmojiPickerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: ThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modalTop)),
      ),
      builder: (ctx) => const EmojiPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeTokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Icon', style: AppTypography.heading2()),
                IconButton(
                  icon: const Icon(Icons.close, color: ThemeTokens.textMuted, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: defaultEmojis.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final emoji = defaultEmojis[index];
                return InkWell(
                  key: Key('emoji_picker_item_$emoji'),
                  onTap: () => Navigator.pop(context, emoji),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeTokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
