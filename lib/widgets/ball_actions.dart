// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo;
import 'package:neonote/momotalk/student_actions.dart';
import 'package:neonote/workbench.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/widgets/floating_ball.dart';

List<FloatingBallItem> buildNoteBallItems(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return <FloatingBallItem>[
    FloatingBallItem(
      icon: Icons.text_fields,
      label: l10n.component_text,
      onTap: () => _addComponent(context, NoteComponentType.text),
    ),
    FloatingBallItem(
      icon: Icons.check_box_outlined,
      label: l10n.component_checklist,
      onTap: () => _addComponent(context, NoteComponentType.checklist),
    ),
    FloatingBallItem(
      icon: Icons.mic_none,
      label: l10n.component_audio,
      onTap: () => _addComponent(context, NoteComponentType.audio),
    ),
    FloatingBallItem(
      icon: Icons.brush_outlined,
      label: l10n.component_drawing,
      onTap: () => _addComponent(context, NoteComponentType.drawing),
    ),
    FloatingBallItem(
      icon: Icons.image_outlined,
      label: l10n.component_image,
      onTap: () => _addComponent(context, NoteComponentType.image),
    ),
  ];
}

List<FloatingBallItem> buildMomotalkBallItems(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return <FloatingBallItem>[
    FloatingBallItem(
      icon: Icons.create_new_folder_outlined,
      label: l10n.new_group,
      onTap: () => _createGroup(context),
    ),
    FloatingBallItem(
      icon: Icons.add_comment_outlined,
      label: l10n.new_chat,
      onTap: () => _createChat(context),
    ),
  ];
}

void _toast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          DeviceInfo.pt(16),
          DeviceInfo.pt(16),
          DeviceInfo.pt(16),
          DeviceInfo.pt(100),
        ),
      ),
    );
}

Future<void> _addComponent(BuildContext context, NoteComponentType type) async {
  final l10n = AppLocalizations.of(context)!;
  final label = switch (type) {
    NoteComponentType.text => l10n.component_text,
    NoteComponentType.checklist => l10n.component_checklist,
    NoteComponentType.audio => l10n.component_audio,
    NoteComponentType.drawing => l10n.component_drawing,
    NoteComponentType.image => l10n.component_image,
  };
  try {
    final component = await NoteStore.addComponent(type);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkbenchPage(component: component, isNew: true),
      ),
    );
    if (!context.mounted) return;
    final stillExists = NoteStore.components().any(
      (item) => item.id == component.id,
    );
    if (stillExists) {
      _toast(context, l10n.component_added(label));
    }
  } catch (error) {
    debugPrint('addComponent failed: $error');
  }
}

Future<void> _createGroup(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final name = await showTextInputDialog(
    context,
    title: l10n.group_create,
    hint: l10n.input_name_hint,
    confirmLabel: l10n.add,
  );
  if (name == null) return;
  if (name.isEmpty) {
    if (!context.mounted) return;
    _toast(context, l10n.name_required);
    return;
  }
  await NoteStore.addGroup(name);
  if (!context.mounted) return;
  _toast(context, l10n.group_added(name));
}

Future<void> _createChat(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final student = await pickStudent(context);
  if (student == null) return;
  await createChatWithStudent(context, student);
  if (!context.mounted) return;
  _toast(context, l10n.chat_added(student.name));
}
