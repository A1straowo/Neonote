// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/deepseek/ai_chat_page.dart';
import 'package:neonote/deepseek/deepseek_settings_page.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show MyHomePage, themeBox;
import 'package:neonote/momotalk/mohome.dart';
import 'package:neonote/momotalk/student.dart';
import 'package:neonote/note_editor.dart';
import 'package:neonote/search.dart';
import 'package:neonote/services/gesture_settings.dart';
import 'package:neonote/settings.dart'
    show
        GestureMenuGroup,
        LocaleProvider,
        MySettingPage,
        ScaleProvider,
        StoragePage,
        ThemeProvider;
import 'package:neonote/store/note_store.dart';
import 'package:provider/provider.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('zh')}) => MaterialApp(
  theme: ThemeData(useMaterial3: true, splashFactory: InkRipple.splashFactory),
  locale: locale,
  supportedLocales: const [
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('es'),
    Locale('ru'),
    Locale('en'),
  ],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: child,
);

Future<void> _pump(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  // Persistence is serialized through real asynchronous Hive writes. Give
  // those futures a turn of the real event loop before asserting UI state.
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  });
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.openBox(themeBox, bytes: Uint8List(0));
  });

  setUp(() async {
    await Hive.box(themeBox).clear();
    NoteStore.revision.value = 0;
  });

  testWidgets('note page ball appends components and keeps five capsules', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Scaffold(body: NoteEditorView())));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.add).first);
    await _pump(tester);
    expect(find.text('文本'), findsOneWidget);
    expect(find.text('清单'), findsOneWidget);
    expect(find.text('音频'), findsOneWidget);
    expect(find.text('绘图'), findsOneWidget);
    expect(find.text('图片'), findsOneWidget);
    expect(find.text('新分组'), findsNothing);
    expect(find.text('新对话'), findsNothing);

    await tester.tap(find.text('文本'));
    await _pump(tester);
    expect(NoteStore.components().length, 1);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).last, 'hello neonote');
    await _pump(tester);
    expect(NoteStore.components().first.text, 'hello neonote');

    // Auto-save is enabled by default, so leaving the editor saves silently.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.add).first);
    await _pump(tester);
    await tester.tap(find.text('清单'));
    await _pump(tester);
    expect(NoteStore.components().length, 2);
    expect(NoteStore.components()[1].items.length, 1);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await _pump(tester);
  });

  testWidgets('empty home canvas stays blank', (tester) async {
    await tester.pumpWidget(_wrap(const Scaffold(body: NoteEditorView())));
    await _pump(tester);

    expect(find.text('暂无文本内容'), findsNothing);
    expect(find.text('添加文本组件'), findsNothing);
    expect(find.textContaining('DeepSeek'), findsNothing);
  });

  testWidgets('label page creates, renames and deletes labels', (tester) async {
    await tester.pumpWidget(_wrap(const TagPage()));
    await _pump(tester);
    expect(find.text('创建新标签'), findsOneWidget);

    await tester.tap(find.text('创建新标签'));
    await _pump(tester);
    await tester.enterText(find.byType(TextField), '二创');
    await tester.tap(find.text('添加'));
    await _pump(tester);

    expect(NoteStore.tags().length, 1);
    expect(find.text('二创'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await _pump(tester);
    await tester.enterText(find.byType(TextField), '作品');
    await tester.tap(find.text('确认'));
    await _pump(tester);
    expect(NoteStore.tags().single.name, '作品');
    expect(find.text('作品'), findsOneWidget);

    await tester.longPress(find.text('作品'));
    await _pump(tester);
    await tester.tap(find.text('确认'));
    await _pump(tester);
    expect(NoteStore.tags(), isEmpty);
    expect(find.text('作品'), findsNothing);
  });

  testWidgets('momotalk ball only creates chats and groups', (tester) async {
    await NoteStore.ensureGroups();
    await CustomStudentRepository.upsert(
      const CustomStudent(id: 1, name: '测试学生', createdAt: 1),
    );
    await tester.pumpWidget(_wrap(const MoHomePage()));
    await _pump(tester);

    expect(find.text('生日学生'), findsNothing);
    expect(find.text('默认分组'), findsOneWidget);
    expect(find.text('暂无对话'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).first);
    await _pump(tester);
    expect(find.text('新对话'), findsOneWidget);
    expect(find.text('新分组'), findsOneWidget);
    expect(find.text('文本'), findsNothing);

    await tester.tap(find.text('新对话'));
    await _pump(tester);
    expect(find.text('请选择学生'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('自定义'));
    await _pump(tester);
    await tester.tap(find.byTooltip('测试学生'));
    await _pump(tester);

    expect(NoteStore.chats().length, 1);
    expect(NoteStore.chats().single.name, '测试学生');
    expect(find.text('测试学生'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add).first);
    await _pump(tester);
    await tester.tap(find.text('新分组'));
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'My Group');
    await tester.tap(find.text('添加'));
    await _pump(tester);
    expect(NoteStore.groups().length, 2);
    expect(find.text('My Group'), findsOneWidget);
  });

  testWidgets('momotalk default group can be deleted from its menu', (
    tester,
  ) async {
    await NoteStore.ensureGroups();
    await tester.pumpWidget(_wrap(const MoHomePage()));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.menu).first);
    await _pump(tester);
    await tester.tap(find.text('删除').last);
    await _pump(tester);
    await tester.tap(find.text('确认'));
    await _pump(tester);

    expect(NoteStore.groups(), isEmpty);
    expect(find.text('默认分组'), findsNothing);
  });

  testWidgets('storage page offers optimization without incomplete exports', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const StoragePage()));
    await _pump(tester);

    expect(find.text('优化存储'), findsOneWidget);
    expect(find.textContaining('Markdown'), findsNothing);
    expect(find.textContaining('JSON'), findsNothing);
  });

  testWidgets('general settings list includes Deepseek Harness', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const MySettingPage()));
    await _pump(tester);
    expect(find.text('DeepSeek'), findsOneWidget);
  });

  testWidgets('deepseek settings persist the API key', (tester) async {
    await tester.pumpWidget(_wrap(const DeepseekSettingsPage()));
    await _pump(tester);

    expect(find.text('DeepSeek'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));

    await tester.enterText(find.byType(TextField).first, 'sk-test-key');
    await tester.ensureVisible(find.text('保存'));
    await _pump(tester);
    await tester.tap(find.text('保存'));
    await _pump(tester);

    expect(Hive.box(themeBox).get('deepseek_api_key'), 'sk-test-key');
  });

  testWidgets('ai chat warns when deepseek is not configured', (tester) async {
    await tester.pumpWidget(_wrap(const AiChatPage()));
    await _pump(tester);

    expect(find.text('DeepSeek'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.send));
    await _pump(tester);

    expect(find.text('请先配置 API Key'), findsOneWidget);
  });

  testWidgets('momotalk chat asks deepseek and survives an API error', (
    tester,
  ) async {
    await Hive.box(themeBox).put('deepseek_api_key', 'sk-test-key');
    await Hive.box(themeBox).put('deepseek_enabled', true);
    await NoteStore.ensureGroups();
    final chat = await NoteStore.addChat(
      groupId: NoteStore.defaultGroupId(),
      name: '测试学生',
    );

    await tester.pumpWidget(_wrap(const MoHomePage()));
    await _pump(tester);
    await tester.tap(find.text('测试学生'));
    await _pump(tester);

    await tester.enterText(find.byType(TextField), '你好');
    await tester.tap(find.byIcon(Icons.send));
    await _pump(tester, 8);

    // The teacher message is stored and the failed request only surfaces a
    // snackbar instead of crashing the chat.
    expect(NoteStore.messages(chat.id).length, 1);
    expect(NoteStore.messages(chat.id).single.isTeacher, isTrue);
    expect(find.textContaining('AI 出错'), findsOneWidget);
  });
  testWidgets('note editor toolbar stays above the software keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Scaffold(body: NoteEditorView())));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.add).first);
    await _pump(tester);
    await tester.tap(find.text('文本'));
    await _pump(tester);

    final keyboardHeight = 300 * tester.view.devicePixelRatio;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    await tester.pumpAndSettle();

    final undo = find.byIcon(Icons.undo);
    expect(undo, findsOneWidget);
    expect(tester.getBottomLeft(undo).dy, lessThanOrEqualTo(301));

    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(undo).dy, greaterThan(301));
  });

  testWidgets('image note blank area opens the image source picker', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Scaffold(body: NoteEditorView())));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.add).first);
    await _pump(tester);
    await tester.tap(find.text('图片'));
    await _pump(tester);

    // The newly-created image component opens the picker once automatically.
    // Dismiss it, then verify the empty placeholder itself is actionable.
    await tester.tapAt(const Offset(8, 8));
    await _pump(tester);
    expect(find.text('选择图片'), findsNothing);

    await tester.tap(find.text('添加图片').first);
    await _pump(tester);
    expect(find.text('选择图片'), findsOneWidget);
  });

  testWidgets('gesture menu clips long localized labels without overflow', (
    tester,
  ) async {
    for (final code in ['zh', 'ja', 'ko', 'es', 'ru', 'en']) {
      await tester.pumpWidget(
        _wrap(const GestureMenuGroup(), locale: Locale(code)),
      );
      await _pump(tester);
      expect(tester.takeException(), isNull, reason: 'locale $code');

      final dropdowns = find.byType(DropdownButton<GestureAction>);
      expect(dropdowns, findsNWidgets(2));
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'menu $code');
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('custom greeting is an info dialog, not a chat message', (
    tester,
  ) async {
    await Hive.box(themeBox).put('mochar_custom_greeting', '欢迎回来');
    await NoteStore.ensureGroups();
    final chat = await NoteStore.addChat(
      groupId: NoteStore.defaultGroupId(),
      name: '测试学生',
    );

    await tester.pumpWidget(_wrap(const MoHomePage()));
    await _pump(tester);
    await tester.tap(find.text('测试学生'));
    await _pump(tester);

    expect(find.text('自定义问候语'), findsOneWidget);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(NoteStore.messages(chat.id), isEmpty);
  });

  test('student names follow the selected app language', () {
    final provider = LocaleProvider();
    provider.setLocale(const Locale('ja'));
    expect(Hive.box(themeBox).get('mochar_nameLanguage'), 'ja');
    expect(Hive.box(themeBox).get('mochar_nameLanguageSyncedLocale'), 'ja');

    const student = BuiltInStudent(
      id: 1,
      name: '圣园未花',
      familyName: '圣园',
      givenName: '未花',
      familyNames: <String, String>{'zh': '圣园', 'ja': '聖園'},
      givenNames: <String, String>{'zh': '未花', 'ja': 'ミカ'},
      avatarUrl: '',
    );
    expect(student.displayName, '聖園ミカ');

    provider.setLocale(const Locale('zh'));
    expect(Hive.box(themeBox).get('mochar_nameLanguage'), 'zh');
    expect(Hive.box(themeBox).get('mochar_nameLanguageSyncedLocale'), 'zh');
    expect(student.displayName, '圣园未花');
    provider.dispose();
  });

  testWidgets('drawer "+" creates a label without breaking other tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ScaleProvider()),
        ],
        child: _wrap(const MyHomePage()),
      ),
    );
    await _pump(tester);

    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await _pump(tester);

    expect(find.text('便签'), findsOneWidget);
    expect(find.text('MomoTalk'), findsOneWidget);
    expect(find.text('标签'), findsOneWidget);

    await tester.tap(find.byTooltip('创建新标签'));
    await _pump(tester);
    await tester.enterText(find.byType(TextField), '作品');
    await tester.tap(find.text('添加'));
    await _pump(tester);

    expect(NoteStore.tags().single.name, '作品');
  });
}
