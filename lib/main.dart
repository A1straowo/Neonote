// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:neonote/deepseek/ai_chat_page.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/note_editor.dart';
import 'package:neonote/search/note_search.dart';
import 'package:neonote/settings.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/ui/adaptive_text_scale.dart';
import 'package:neonote/ui/device_scale.dart';
import 'package:neonote/widgets/accessible_icon_button.dart';
import 'package:neonote/widgets/app_drawer.dart';
import 'package:neonote/widgets/deepseek_icon.dart';
import 'package:provider/provider.dart';

const themeBox = 'HiveThemeBox';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache
    ..maximumSize = 200
    ..maximumSizeBytes = 64 * 1024 * 1024;
  await Hive.initFlutter();
  await Hive.openBox(themeBox);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ScaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class DeviceInfo {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double physicalWidth = 0;
  static double physicalHeight = 0;
  static double dpr = 0;
  static double ratio = 1.0;
  static double statusBarHeight = 0;
  static double BottomHeight = 0;

  static void initialize(BuildContext context, {double UIWidth = 375}) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    physicalWidth = window.physicalSize.width;
    physicalHeight = window.physicalSize.height;
    dpr = window.devicePixelRatio;
    statusBarHeight = mediaQueryData.padding.top;
    // Keep device scaling modest on tablets/foldables. Extra space should be
    // used by adaptive layouts instead of inflating every font and radius.
    final shortestSide = screenWidth < screenHeight
        ? screenWidth
        : screenHeight;
    ratio = resolveDeviceScale(shortestSide);
  }

  static bool get isLandscape => screenWidth > screenHeight;

  static double pt(double size) {
    return size * DeviceInfo.ratio;
  }
}

class _NeonotePageTransitionsBuilder extends PageTransitionsBuilder {
  const _NeonotePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );
    final fade = Tween<double>(begin: 0, end: 1).animate(curved);
    final slide = Tween<Offset>(
      begin: const Offset(0.075, 0.012),
      end: Offset.zero,
    ).animate(curved);
    final scale = Tween<double>(begin: 0.965, end: 1).animate(curved);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(scale: scale, child: child),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ValueListenable<Box<dynamic>?>? _themeListenable;

  ColorScheme buildColorScheme(
    ColorScheme? base,
    bool isDark,
    String mode,
    Color? customColor,
  ) {
    if (mode == 'default') {
      return base ?? (isDark ? ColorScheme.dark() : ColorScheme.light());
    } else if (mode == 'momotalk') {
      return ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF89A1),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).copyWith(primary: const Color(0xFFFF89A1), onPrimary: Colors.white);
    } else {
      final seed = customColor ?? Colors.blue;
      return ColorScheme.fromSeed(
        seedColor: seed,
        brightness: isDark ? Brightness.dark : Brightness.light,
      );
    }
  }

  ThemeData buildTheme(
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
    bool isDarkMode,
    String themeMode,
    Color? customColor,
  ) {
    final light = buildColorScheme(lightScheme, false, themeMode, customColor);
    final dark = buildColorScheme(darkScheme, true, themeMode, customColor);
    return ThemeData(
      fontFamily: 'ResourceHanCN',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _NeonotePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _NeonotePageTransitionsBuilder(),
          TargetPlatform.linux: _NeonotePageTransitionsBuilder(),
          TargetPlatform.windows: _NeonotePageTransitionsBuilder(),
          TargetPlatform.iOS: _NeonotePageTransitionsBuilder(),
          TargetPlatform.macOS: _NeonotePageTransitionsBuilder(),
        },
      ),
      colorScheme: isDarkMode ? dark : light,
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final themeListenable = _themeListenable ??= Hive.box(themeBox)
            .listenable(
              keys: [
                'darkMode',
                'customColor',
                'themeMode',
                'scaleFactor',
                'localeCode',
              ],
            );
        return ValueListenableBuilder(
          valueListenable: themeListenable,
          builder: (context, box, widget) {
            final currentBox = box!;
            final darkMode = currentBox.get('darkMode', defaultValue: false);
            final themeMode = currentBox.get(
              'themeMode',
              defaultValue: 'default',
            );
            final customColorVal = currentBox.get('customColor');
            final customColor = customColorVal != null
                ? Color(customColorVal)
                : null;
            final localeCode = currentBox.get('localeCode', defaultValue: 'en');
            final scaleFactor = currentBox.get(
              'scaleFactor',
              defaultValue: 1.0,
            );

            final theme = buildTheme(
              lightDynamic,
              darkDynamic,
              darkMode,
              themeMode,
              customColor,
            );

            return MaterialApp(
              locale: Locale(localeCode),
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
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: theme,
              themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
              themeAnimationDuration: const Duration(milliseconds: 300),
              themeAnimationCurve: Curves.easeInOutCubic,
              builder: (context, child) {
                DeviceInfo.initialize(context);
                return _KeyboardDismissOnResume(
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: resolveTextScaler(context, scaleFactor),
                    ),
                    child: child!,
                  ),
                );
              },
              home: const MyHomePage(),
            );
          },
        );
      },
    );
  }
}

/// Hides the software keyboard when the app returns from the background.
///
/// The wrapper only manages focus and returns its child unchanged, so it does
/// not introduce layout, spacing, or rebuild side effects for the page tree.
class _KeyboardDismissOnResume extends StatefulWidget {
  const _KeyboardDismissOnResume({required this.child});

  final Widget child;

  @override
  State<_KeyboardDismissOnResume> createState() =>
      _KeyboardDismissOnResumeState();
}

class _KeyboardDismissOnResumeState extends State<_KeyboardDismissOnResume>
    with WidgetsBindingObserver {
  Timer? _resumeDismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _resumeDismissTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _dismissKeyboard() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null) {
      // Detach the Android input connection as well as clearing Flutter focus.
      // Some Android IMEs keep a stale bottom inset when an activity is
      // restored without an explicit clearClient call.
      focus.unfocus(disposition: UnfocusDisposition.scope);
      SystemChannels.textInput.invokeMethod<void>('TextInput.clearClient');
    }
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  void _scheduleDismissAfterResume() {
    _resumeDismissTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dismissKeyboard();
      // The Android window can restore its previous focus after the first
      // frame. Hide again once the resume transition has fully settled.
      _resumeDismissTimer = Timer(
        const Duration(milliseconds: 180),
        _dismissKeyboard,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleDismissAfterResume();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _resumeDismissTimer?.cancel();
      _dismissKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NoteEditorViewState> _noteEditorKey =
      GlobalKey<NoteEditorViewState>();

  void _openAiChat() {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiChatPage(
          title: l10n.ai_assistant,
          welcome: l10n.ai_welcome,
          systemPrompt:
              'You are a flexible Deepseek assistant inside Neonote. Help the '
              'user draft and organize notes, answer questions, and engage in '
              'everyday conversation or requested role-play. Keep Deepseek as '
              'your underlying identity.',
          onInsertReply: (text) async {
            final component = await NoteStore.addComponent(
              NoteComponentType.text,
            );
            component.text = text;
            await NoteStore.saveComponent(component, bump: true);
          },
        ),
      ),
    );
  }

  Future<void> _openSearch() async {
    final l10n = AppLocalizations.of(context)!;
    final tagNames = <String, String>{
      for (final tag in NoteStore.tags()) tag.id: tag.name,
    };
    final entries = NoteStore.activeComponents()
        .map(
          (component) =>
              NoteSearchEntry.fromMap(component.toMap(), tagNames: tagNames),
        )
        .toList(growable: false);

    final selected = await Navigator.of(context).push<NoteSearchEntry>(
      MaterialPageRoute(
        builder: (_) => NoteSearchPage(
          entries: entries,
          title: l10n.search_notes,
          hint: l10n.search_notes_hint,
          emptyTitle: l10n.search_empty_title,
          emptyMessage: l10n.search_empty_message,
          noResultsTitle: l10n.search_no_results_title,
          noResultsMessage: l10n.search_no_results_message,
          clearTooltip: l10n.search_clear,
          untitledLabel: l10n.untitled,
          onSelected: (result) => Navigator.of(context).pop(result),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await _noteEditorKey.currentState?.revealComponent(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = Hive.box(
      themeBox,
    ).get('themeMode', defaultValue: 'default');
    final bool isMomotalk = themeMode == 'momotalk';

    final drawerEdgeDragWidth = DeviceInfo.pt(125);
    final iconSizeSmall = DeviceInfo.pt(20);
    final fontSizeTitle = DeviceInfo.pt(25);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
          _scaffoldKey.currentState?.closeDrawer();
          return;
        }
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return;
        }

        final canExit =
            await _noteEditorKey.currentState?.prepareForExit() ?? true;
        if (!canExit || !mounted) return;

        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return AccessibleIconButton(
                tooltip: l10n.open_menu,
                icon: FaIcon(
                  FontAwesomeIcons.bars,
                  color: isMomotalk
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  size: iconSizeSmall,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          centerTitle: true,
          title: Text(
            'Neonote',
            style: TextStyle(
              fontFamily: 'ResourceHanCN',
              color: isMomotalk
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: fontSizeTitle,
            ),
          ),
          backgroundColor: isMomotalk
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          actions: [
            AccessibleIconButton(
              tooltip: l10n.search_notes,
              icon: Icon(
                Icons.search_rounded,
                color: isMomotalk
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                size: iconSizeSmall,
              ),
              onPressed: _openSearch,
            ),
            AccessibleIconButton(
              tooltip: l10n.ai_chat,
              icon: DeepseekIcon(
                color: isMomotalk
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                size: iconSizeSmall,
              ),
              onPressed: _openAiChat,
            ),
          ],
        ),
        drawerEnableOpenDragGesture: true,
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawer: const AppDrawer(activePage: AppDrawerPage.note),
        body: NoteEditorView(key: _noteEditorKey),
      ),
    );
  }
}
