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
    this.familyNames = const <String, String>{},
    this.givenNames = const <String, String>{},
    this.fullNames = const <String, String>{},
  });

  final String name;
  final String familyName;
  final String givenName;
  final String avatarUrl;
  final int studentId;
  final Map<String, String> familyNames;
  final Map<String, String> givenNames;
  final Map<String, String> fullNames;
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
      familyNames: result.familyNames,
      givenNames: result.givenNames,
      fullNames: result.fullNames,
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
    familyNames: student.familyNames,
    givenNames: student.givenNames,
    fullNames: student.fullNames,
    avatarUrl: student.avatarUrl,
    studentId: student.studentId,
  );
  await NoteStore.setGroupExpanded(groupId, true);
}
