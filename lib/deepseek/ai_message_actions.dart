import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/accessible_icon_button.dart';

/// Action row shown below assistant messages.
///
/// Today the only action available on a DeepSeek reply is "Insert into notes".
/// There is no copy action, no regenerate action and no visible state while the
/// clipboard operation runs. This widget supplies those affordances using
/// visible labels where possible, which also improves discoverability.
class AiMessageActions extends StatelessWidget {
  const AiMessageActions({
    super.key,
    required this.content,
    this.onInsert,
    this.onRegenerate,
    this.onShare,
    this.insertLabel = 'Insert into notes',
    this.regenerateLabel = 'Regenerate',
    this.shareLabel = 'Share',
    this.copyTooltip = 'Copy reply',
    this.copiedMessage = 'Reply copied',
    this.copyFailedMessage = 'Could not copy reply',
  });

  final String content;
  final VoidCallback? onInsert;
  final VoidCallback? onRegenerate;
  final VoidCallback? onShare;
  final String insertLabel;
  final String regenerateLabel;
  final String shareLabel;
  final String copyTooltip;
  final String copiedMessage;
  final String copyFailedMessage;

  Future<void> _copy(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: content));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(copiedMessage)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(copyFailedMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AccessibleIconButton(
          tooltip: copyTooltip,
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => _copy(context),
        ),
        if (onInsert != null)
          TextButton.icon(
            onPressed: onInsert,
            icon: const Icon(Icons.note_add_outlined, size: 18),
            label: Text(insertLabel),
          ),
        if (onRegenerate != null)
          TextButton.icon(
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(regenerateLabel),
          ),
        if (onShare != null)
          AccessibleIconButton(
            tooltip: shareLabel,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: onShare,
          ),
      ],
    );
  }
}
