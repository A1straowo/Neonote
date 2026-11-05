// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/widgets/floating_ball.dart';

class TagPage extends StatelessWidget {
  const TagPage({super.key});

  Future<void> _createTag(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: l10n.tag_create,
      hint: l10n.input_name_hint,
      confirmLabel: l10n.add,
    );
    if (name == null) return;
    if (name.isEmpty) {
      if (!context.mounted) return;
      _toast(context, l10n.name_required);
      return;
    }
    try {
      await NoteStore.addTag(name);
    } catch (_) {
      if (context.mounted) _toast(context, l10n.save_failed_retrying);
      return;
    }
    if (!context.mounted) return;
    _toast(context, l10n.tag_added(name));
  }

  Future<void> _renameTag(BuildContext context, NoteTag tag) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: l10n.tag_rename,
      hint: l10n.input_name_hint,
      confirmLabel: l10n.confirm,
      initialValue: tag.name,
    );
    if (name == null || name.isEmpty) return;
    try {
      await NoteStore.renameTag(tag.id, name);
    } catch (_) {
      if (context.mounted) _toast(context, l10n.save_failed_retrying);
    }
  }

  Future<void> _deleteTag(BuildContext context, NoteTag tag) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.delete,
          style: const TextStyle(fontFamily: 'ResourceHanCN'),
        ),
        content: Text(
          l10n.tag_delete_confirm(tag.name),
          style: const TextStyle(fontFamily: 'ResourceHanCN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(fontFamily: 'ResourceHanCN'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(fontFamily: 'ResourceHanCN'),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await NoteStore.deleteTag(tag.id);
    } catch (_) {
      if (context.mounted) _toast(context, l10n.save_failed_retrying);
    }
  }

  void _toast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.label,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: DeviceInfo.pt(24),
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        leading: IconButton(
          tooltip: l10n.close,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: NoteStore.tagsRevision,
        builder: (context, _, _) {
          final tags = NoteStore.tags();
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: DeviceInfo.pt(24),
              vertical: DeviceInfo.pt(8),
            ),
            children: [
              _buildCreateRow(context, l10n),
              SizedBox(height: DeviceInfo.pt(20)),
              for (final tag in tags) _buildTagRow(context, l10n, tag),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateRow(BuildContext context, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.onSurface.withValues(alpha: 0.62);
    return InkWell(
      onTap: () => _createTag(context),
      borderRadius: BorderRadius.circular(DeviceInfo.pt(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: DeviceInfo.pt(12)),
        child: Row(
          children: [
            SizedBox(
              width: DeviceInfo.pt(34),
              child: Icon(Icons.add, size: DeviceInfo.pt(28), color: color),
            ),
            SizedBox(width: DeviceInfo.pt(20)),
            Expanded(
              child: Text(
                l10n.tag_create,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontSize: DeviceInfo.pt(19),
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagRow(
    BuildContext context,
    AppLocalizations l10n,
    NoteTag tag,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {},
      onLongPress: () => _deleteTag(context, tag),
      borderRadius: BorderRadius.circular(DeviceInfo.pt(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: DeviceInfo.pt(10)),
        child: Row(
          children: [
            SizedBox(
              width: DeviceInfo.pt(34),
              child: Icon(
                Icons.label_outline,
                size: DeviceInfo.pt(24),
                color: scheme.onSurface,
              ),
            ),
            SizedBox(width: DeviceInfo.pt(20)),
            Expanded(
              child: Text(
                tag.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontSize: DeviceInfo.pt(19),
                  color: scheme.onSurface,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _renameTag(context, tag),
              tooltip: l10n.tag_rename,
              icon: Icon(
                Icons.edit_outlined,
                size: DeviceInfo.pt(20),
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            IconButton(
              onPressed: () => _deleteTag(context, tag),
              tooltip: l10n.delete,
              icon: Icon(
                Icons.delete_outline,
                size: DeviceInfo.pt(20),
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
