import 'package:flutter/material.dart';
import 'package:neonote/momotalk/student.dart';
import 'package:neonote/store/note_store.dart';

class PickedStudent {
  const PickedStudent({
    required this.name,
    required this.avatarUrl,
    this.studentId = 0,
    this.familyName = '',
    this.givenName = '',
  });

  final String name;
  final String familyName;
  final String givenName;
  final String avatarUrl;
  final int studentId;
}

Future<PickedStudent?> pickStudent(BuildContext context) async {
  final result = await Navigator.push<Object>(
    context,
    MaterialPageRoute<Object>(builder: (_) => const StudentPickerPage()),
  );
  if (result is CustomStudent) {
    return PickedStudent(
      name: result.name,
      familyName: result.familyName,
      givenName: result.givenName,
      avatarUrl: result.avatarUrl,
    );
  }
  if (result is BuiltInStudent) {
    return PickedStudent(
      name: result.name,
      familyName: result.familyName,
      givenName: result.givenName,
      avatarUrl: result.avatarUrl,
      studentId: result.id,
    );
  }
  return null;
}

Future<void> createChatWithStudent(
  BuildContext context,
  PickedStudent student,
) async {
  if (student.name.isEmpty) return;
  await NoteStore.ensureGroups();
  var groupId = NoteStore.defaultGroupId();
  if (!NoteStore.groups().any((group) => group.id == groupId)) {
    groupId = (await NoteStore.addGroup('')).id;
  }
  await NoteStore.addChat(
    groupId: groupId,
    name: student.name,
    familyName: student.familyName,
    givenName: student.givenName,
    avatarUrl: student.avatarUrl,
    studentId: student.studentId,
  );
  await NoteStore.setGroupExpanded(groupId, true);
}
