import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Actions available from a single chat message.
enum AiMessageAction { copy, selectText, edit, regenerate, delete }

/// Labels are injectable so the sheet can follow the app's six locales.
@immutable
class AiMessageActionLabels {
  const AiMessageActionLabels({
    this.title = 'Message actions',
    this.copy = 'Copy',
    this.selectText = 'Select text',
    this.edit = 'Edit',
    this.regenerate = 'Regenerate this reply',
    this.delete = 'Delete',
    this.close = 'Close',
    this.cancel = 'Cancel',
    this.save = 'Save',
    this.deleteTitle = 'Delete this message?',
    this.deleteBody = 'This message will be removed from the conversation.',
    this.regenerateTitle = 'Regenerate this reply?',
    this.removeFollowingBody =
        'Messages after this reply will be removed because the context changes.',
    this.copyFailed = 'Could not copy message',
    this.editHint = 'Edit message text',
  });

  final String title;
  final String copy;
  final String selectText;
  final String edit;
  final String regenerate;
  final String delete;
  final String close;
  final String cancel;
  final String save;
  final String deleteTitle;
  final String deleteBody;
  final String regenerateTitle;
  final String removeFollowingBody;
  final String copyFailed;
  final String editHint;
}

/// Bottom-sheet action menu for one message.
///
/// This intentionally uses a bottom sheet rather than a side drawer/sidebar.
/// The message list remains single-column and vertical.
Future<AiMessageAction?> showAiMessageActionSheet(
  BuildContext context, {
  required bool isAssistant,
  required bool hasFollowingMessages,
  AiMessageActionLabels labels = const AiMessageActionLabels(),
}) {
  return showModalBottomSheet<AiMessageAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(labels.title, style: theme.textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(labels.copy),
              onTap: () => Navigator.pop(sheetContext, AiMessageAction.copy),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields_rounded),
              title: Text(labels.selectText),
              onTap: () =>
                  Navigator.pop(sheetContext, AiMessageAction.selectText),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(labels.edit),
              onTap: () => Navigator.pop(sheetContext, AiMessageAction.edit),
            ),
            if (isAssistant)
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: Text(labels.regenerate),
                subtitle: hasFollowingMessages
                    ? Text(labels.removeFollowingBody)
                    : null,
                onTap: () =>
                    Navigator.pop(sheetContext, AiMessageAction.regenerate),
              ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                labels.delete,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(sheetContext, AiMessageAction.delete),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> copyAiMessageText(
  BuildContext context,
  String text, {
  String copiedMessage = 'Copied',
  AiMessageActionLabels labels = const AiMessageActionLabels(),
}) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(copiedMessage)));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(labels.copyFailed)));
  }
}

/// Opens a fully selectable copy of one message. This is useful because the
/// Markdown renderer may split a reply into several SelectableText widgets.
Future<void> showSelectableMessageDialog(
  BuildContext context, {
  required String text,
  AiMessageActionLabels labels = const AiMessageActionLabels(),
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(labels.selectText),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: SelectableText(
            text,
            style: Theme.of(dialogContext).textTheme.bodyLarge,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(labels.close),
        ),
      ],
    ),
  );
}

Future<String?> showEditAiMessageDialog(
  BuildContext context, {
  required String initialText,
  AiMessageActionLabels labels = const AiMessageActionLabels(),
}) async {
  final controller = TextEditingController(text: initialText);
  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(labels.edit),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 5,
          maxLines: 14,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(hintText: labels.editHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(labels.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(labels.save),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

Future<bool> confirmDeleteAiMessage(
  BuildContext context, {
  AiMessageActionLabels labels = const AiMessageActionLabels(),
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(labels.deleteTitle),
      content: Text(labels.deleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(labels.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(labels.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> confirmRegenerateAiMessage(
  BuildContext context, {
  required bool hasFollowingMessages,
  AiMessageActionLabels labels = const AiMessageActionLabels(),
}) async {
  if (!hasFollowingMessages) return true;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(labels.regenerateTitle),
      content: Text(labels.removeFollowingBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(labels.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(labels.regenerate),
        ),
      ],
    ),
  );
  return result ?? false;
}
