// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/deepseek/ai_chat_page.dart';
import 'package:neonote/main.dart' show themeBox;
import 'package:neonote/momotalk/mohome.dart';
import 'package:neonote/services/gesture_settings.dart';
import 'package:neonote/settings.dart' show GestureMenuGroup;
import 'package:neonote/store/note_store.dart';
import 'package:neonote/workbench.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: ThemeData(useMaterial3: true, splashFactory: InkRipple.splashFactory),
  locale: const Locale('zh'),
  supportedLocales: const [Locale('zh')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: child,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.openBox(themeBox, bytes: Uint8List(0));
  });

  setUp(() async {
    await Hive.box(themeBox).clear();
    NoteStore.revision.value = 0;
  });

  test('gesture settings persist selected actions', () async {
    expect(GestureSettings.rightAction, GestureAction.archive);
    expect(GestureSettings.leftAction, GestureAction.delete);
    await GestureSettings.setRightAction(GestureAction.pin);
    await GestureSettings.setLeftAction(GestureAction.mark);
    expect(GestureSettings.rightAction, GestureAction.pin);
    expect(GestureSettings.leftAction, GestureAction.mark);
  });

  test('note and chat state helpers filter and persist safely', () async {
    final note = await NoteStore.addComponent(NoteComponentType.text);
    note.text = 'hello';
    note.tagIds = ['tag-1'];
    await NoteStore.saveComponent(note, bump: true);

    await NoteStore.setPinned(note.id, true);
    await NoteStore.setMarked(note.id, true);
    await NoteStore.setArchived(note.id, true);

    expect(NoteStore.activeComponents(), isEmpty);
    expect(NoteStore.archivedComponents().single.pinned, isTrue);
    expect(NoteStore.archivedComponents().single.marked, isTrue);
    expect(NoteStore.archivedComponents().single.tagIds, ['tag-1']);

    await NoteStore.setArchived(note.id, false);
    expect(NoteStore.activeComponents().single.id, note.id);

    final chat = await NoteStore.addChat(
      groupId: NoteStore.defaultGroupId(),
      name: 'Smoke test chat',
    );
    await NoteStore.setChatPinned(chat.id, true);
    await NoteStore.setChatMarked(chat.id, true);
    await NoteStore.setChatArchived(chat.id, true);

    expect(NoteStore.activeChats(), isEmpty);
    expect(NoteStore.archivedChats().single.pinned, isTrue);
    expect(NoteStore.archivedChats().single.marked, isTrue);
  });

  testWidgets('gesture settings use dropdowns for both swipe directions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const Scaffold(body: Center(child: GestureMenuGroup()))),
    );
    await tester.pumpAndSettle();

    expect(find.text('右滑动作'), findsOneWidget);
    expect(find.text('左滑动作'), findsOneWidget);
    expect(find.byType(DropdownButton<GestureAction>), findsNWidgets(2));
  });

  testWidgets('blank newly created component is deleted on exit', (
    tester,
  ) async {
    final note = await NoteStore.addComponent(NoteComponentType.text);
    await tester.pumpWidget(_wrap(WorkbenchPage(component: note, isNew: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(NoteStore.components(), isEmpty);
    expect(find.text('空白便签已自动删除'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'discard dialog only has discard and save and deletes component',
    (tester) async {
      await Hive.box(themeBox).put('autoSave', false);
      final note = await NoteStore.addComponent(NoteComponentType.text);
      note.text = 'existing content';
      await NoteStore.saveComponent(note, bump: true);

      await tester.pumpWidget(
        _wrap(WorkbenchPage(component: note, isNew: true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('保存'), findsOneWidget);
      expect(find.text('舍弃'), findsOneWidget);
      expect(find.text('取消'), findsNothing);

      await tester.tap(find.text('舍弃'));
      await tester.pumpAndSettle();
      expect(NoteStore.components(), isEmpty);
    },
  );

  testWidgets(
    'chat input exposes emoji, gallery, student and screenshot actions',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MoChatDetailPage(
            chatId: 'smoke-chat',
            title: '小鸟游星野',
            avatarUrl: '',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('表情'), findsOneWidget);
      expect(find.byTooltip('图片'), findsOneWidget);
      expect(find.byTooltip('学生'), findsOneWidget);
      expect(find.byTooltip('截图'), findsOneWidget);
    },
  );
  testWidgets('auto-save enabled exits a non-empty new note without a dialog', (
    tester,
  ) async {
    await Hive.box(themeBox).put('autoSave', true);
    final note = await NoteStore.addComponent(NoteComponentType.text);
    note.text = 'saved silently';
    await NoteStore.saveComponent(note, bump: true);

    await tester.pumpWidget(_wrap(WorkbenchPage(component: note, isNew: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('保存'), findsNothing);
    expect(find.text('舍弃'), findsNothing);
    expect(NoteStore.components().single.text, 'saved silently');
  });

  testWidgets(
    'AI composer exposes camera, gallery, voice, model, reasoning and modes',
    (tester) async {
      await tester.pumpWidget(_wrap(const AiChatPage()));
      await tester.pumpAndSettle();

      expect(find.byTooltip('拍照'), findsOneWidget);
      expect(find.byTooltip('相册'), findsOneWidget);
      expect(find.byTooltip('语音'), findsOneWidget);
      expect(find.byIcon(Icons.memory), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      expect(find.text('标准模式'), findsOneWidget);
    },
  );

  testWidgets('long pressing a chat message opens the rounded action menu', (
    tester,
  ) async {
    final chat = await NoteStore.addChat(
      groupId: NoteStore.defaultGroupId(),
      name: '小鸟游星野',
      studentId: 76,
    );
    await NoteStore.addMessage(
      chatId: chat.id,
      text: 'hello message',
      isTeacher: false,
    );

    await tester.pumpWidget(
      _wrap(
        MoChatDetailPage(
          chatId: chat.id,
          title: chat.name,
          avatarUrl: chat.avatarUrl,
          studentId: chat.studentId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('hello message'));
    await tester.pumpAndSettle();

    expect(find.text('换行'), findsOneWidget);
    expect(find.text('更改'), findsOneWidget);
    expect(find.text('转换'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);
  });
}
