// ignore_for_file: non_constant_identifier_names, deprecated_member_use, use_build_context_synchronously

import 'package:neonote/main.dart' show DeviceInfo, themeBox;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/deepseek/deepseek_settings_page.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/widgets/deepseek_icon.dart';
import 'package:neonote/services/app_storage.dart';
import 'package:neonote/services/gesture_settings.dart';
import 'package:neonote/ui/app_layout.dart';
import 'package:neonote/momotalk/mochar.dart';
import 'package:provider/provider.dart';
import 'package:neonote/momotalk/mochat.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:neonote/aistra.dart';

class ScaleProvider extends ChangeNotifier {
  double _scaleFactor = 1.0;

  ScaleProvider() {
    _scaleFactor = Hive.box(themeBox).get('scaleFactor', defaultValue: 1.0);
  }

  double get scaleFactor => _scaleFactor;

  void setScaleFactor(double value) {
    _scaleFactor = value.clamp(0.6, 1.8);
    Hive.box(themeBox).put('scaleFactor', _scaleFactor);
    notifyListeners();
  }
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  LocaleProvider() : _locale = _loadLocale();

  static Locale _loadLocale() {
    String? code = Hive.box(themeBox).get('localeCode');
    if (code != null) return Locale(code);
    return const Locale('en');
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    final box = Hive.box(themeBox);
    box.put('localeCode', locale.languageCode);
    // Student names follow the app language unless the user explicitly
    // overrides the student-name language afterwards.
    box.put('mochar_nameLanguage', locale.languageCode);
    box.put('mochar_nameLanguageSyncedLocale', locale.languageCode);
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeBeforeMomotalkKey = 'darkModeBeforeMomotalk';

  late String _themeMode;
  Color? _customColor;

  ThemeProvider() {
    final box = Hive.box(themeBox);
    final storedMode = box.get('themeMode', defaultValue: 'default');
    final storedPalette = box.get('paletteMode')?.toString();
    if (storedMode == 'system' ||
        storedMode == 'light' ||
        storedMode == 'dark') {
      // Normalize values written by the temporary System/Light/Dark control
      // back to the original palette setting handled by the app.
      _themeMode = storedPalette == 'momotalk' || storedPalette == 'custom'
          ? storedPalette!
          : 'default';
      if (storedMode == 'dark') {
        box.put('darkMode', true);
      } else if (storedMode == 'light') {
        box.put('darkMode', false);
      }
      box.put('themeMode', _themeMode);
    } else {
      _themeMode = storedMode?.toString() ?? 'default';
    }
    if (_themeMode == 'momotalk') {
      // Momotalk is always shown in light mode while it is active.
      box.put('darkMode', false);
    }
    final colorVal = box.get('customColor');
    _customColor = colorVal is int ? Color(colorVal) : null;
  }

  String get themeMode => _themeMode;
  Color? get customColor => _customColor;
  bool get darkMode =>
      Hive.box(themeBox).get('darkMode', defaultValue: false) == true;

  void setDarkMode(bool value) {
    if (_themeMode == 'momotalk') return;
    Hive.box(themeBox).put('darkMode', value);
    notifyListeners();
  }

  void setThemeMode(String mode, {Color? customColor}) {
    final box = Hive.box(themeBox);
    final previousMode = _themeMode;
    if (mode == 'momotalk' && previousMode != 'momotalk') {
      box.put(_darkModeBeforeMomotalkKey, darkMode);
      box.put('darkMode', false);
    } else if (previousMode == 'momotalk' && mode != 'momotalk') {
      final restoredDarkMode =
          box.get(_darkModeBeforeMomotalkKey, defaultValue: false) == true;
      box.put('darkMode', restoredDarkMode);
      box.delete(_darkModeBeforeMomotalkKey);
    }

    _themeMode = mode;
    if (mode == 'custom' && customColor != null) {
      _customColor = customColor;
      box.put('customColor', customColor.value);
    } else {
      _customColor = null;
      box.delete('customColor');
    }
    box.put('themeMode', mode);
    notifyListeners();
  }
}

void languageMenu(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const LanguageMenuGroup();
    },
  );
}

class LanguageMenuGroup extends StatefulWidget {
  const LanguageMenuGroup({super.key});

  @override
  State<LanguageMenuGroup> createState() => _LanguageMenuGroup();
}

class _LanguageMenuGroup extends State<LanguageMenuGroup> {
  static const List<(String, String)> _languages = <(String, String)>[
    ('zh', '简体中文'),
    ('ja', '日本語'),
    ('ko', '한국어'),
    ('en', 'English'),
    ('es', 'Español'),
    ('ru', 'Русский'),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: DeviceInfo.pt(350),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: scheme.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(25),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context)!.language,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      color: scheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final language in _languages)
                  RadioListTile<String>(
                    title: Text(
                      language.$2,
                      style: const TextStyle(fontFamily: 'ResourceHanCN'),
                    ),
                    value: language.$1,
                    groupValue: locale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LocaleProvider>().setLocale(Locale(value));
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void generalMenu(BuildContext context) {
  showDialog(context: context, builder: (context) => const GeneralMenuGroup());
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> clearAppCache(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await confirmAction(
    context,
    title: l10n.clear_cache,
    message: l10n.clear_cache_confirm,
    confirmLabel: l10n.confirm,
  );
  if (!confirmed || !context.mounted) return;
  try {
    await AppStorage.clearCache();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.clear_success)));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${l10n.clear_failed}$error')));
  }
}

Future<void> clearAppConfig(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await confirmAction(
    context,
    title: l10n.clear_config,
    message: l10n.clear_config_confirm,
    confirmLabel: l10n.confirm,
  );
  if (!confirmed || !context.mounted) return;
  final box = Hive.box(themeBox);
  await box.put('themeMode', 'default');
  await box.put('darkMode', false);
  await box.delete('darkModeBeforeMomotalk');
  await box.put('scaleFactor', 1.0);
  await box.put('autoSave', false);
  await box.delete('customColor');
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.defaults_restored)));
}

void gestureMenu(BuildContext context) {
  showDialog(context: context, builder: (context) => const GestureMenuGroup());
}

class GeneralMenuGroup extends StatefulWidget {
  const GeneralMenuGroup({super.key});

  @override
  State<GeneralMenuGroup> createState() => _GeneralMenuGroup();
}

class _GeneralMenuGroup extends State<GeneralMenuGroup> {
  bool DarkMode = false;
  bool AutoSave = false;
  bool _themeMenuOpen = false;

  @override
  void initState() {
    super.initState();
    DarkMode = Hive.box(themeBox).get('darkMode', defaultValue: false);
    AutoSave = Hive.box(themeBox).get('autoSave', defaultValue: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getThemeName(String mode, BuildContext context) {
    switch (mode) {
      case 'default':
        return AppLocalizations.of(context)!.default_color_scheme;
      case 'momotalk':
        return 'Momotalk';
      case 'custom':
        return AppLocalizations.of(context)!.custom_color;
      default:
        return AppLocalizations.of(context)!.default_color_scheme;
    }
  }

  Widget _buildFittedMenuText(
    String text, {
    TextStyle? style,
    AlignmentGeometry alignment = Alignment.centerLeft,
  }) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style:
              style ??
              TextStyle(
                fontFamily: 'ResourceHanCN',
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildThemeMenuItem(
    BuildContext context, {
    required String value,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (selected)
            Icon(
              Icons.check,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickCustomColor(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();
    Color initialColor = themeProvider.customColor ?? Colors.blue;
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = initialColor;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text(AppLocalizations.of(context)!.custom_color),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    setState(() {
                      tempColor = color;
                    });
                  },
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(tempColor),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
      },
    );
    if (pickedColor != null) {
      themeProvider.setThemeMode('custom', customColor: pickedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;
    final currentThemeName = _getThemeName(currentMode, context);
    final bool isMomotalk = currentMode == 'momotalk';
    final scaleProvider = context.watch<ScaleProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: DeviceInfo.pt(350),
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: FaIcon(
                    FontAwesomeIcons.solidLightbulb,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: _buildFittedMenuText(
                          AppLocalizations.of(context)!.dark_theme,
                        ),
                      ),
                      Switch(
                        value: themeProvider.darkMode,
                        onChanged: isMomotalk
                            ? null
                            : themeProvider.setDarkMode,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: FaIcon(
                    FontAwesomeIcons.solidFloppyDisk,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: _buildFittedMenuText(
                          AppLocalizations.of(context)!.auto_save,
                        ),
                      ),
                      Switch(
                        value: AutoSave,
                        onChanged: (value) {
                          setState(() {
                            AutoSave = value;
                            Hive.box(themeBox).put('autoSave', value);
                          });
                        },
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  initialValue: currentMode,
                  position: PopupMenuPosition.under,
                  offset: const Offset(25, -5),
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 50,
                  popUpAnimationStyle: const AnimationStyle(
                    duration: Duration(milliseconds: 220),
                    reverseDuration: Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                  onOpened: () {
                    if (mounted) {
                      setState(() => _themeMenuOpen = true);
                    }
                  },
                  onCanceled: () {
                    if (mounted) {
                      setState(() => _themeMenuOpen = false);
                    }
                  },
                  onSelected: (value) {
                    if (mounted) {
                      setState(() => _themeMenuOpen = false);
                    }
                    if (value == 'default') {
                      themeProvider.setThemeMode('default');
                    } else if (value == 'momotalk') {
                      themeProvider.setThemeMode('momotalk');
                    } else if (value == 'custom') {
                      _pickCustomColor(context);
                    }
                  },
                  itemBuilder: (context) => [
                    _buildThemeMenuItem(
                      context,
                      value: 'default',
                      label: AppLocalizations.of(context)!.default_color_scheme,
                      selected: currentMode == 'default',
                    ),
                    _buildThemeMenuItem(
                      context,
                      value: 'momotalk',
                      label: 'Momotalk',
                      selected: currentMode == 'momotalk',
                    ),
                    _buildThemeMenuItem(
                      context,
                      value: 'custom',
                      label: AppLocalizations.of(context)!.custom_color,
                      selected: currentMode == 'custom',
                    ),
                  ],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: FaIcon(
                      FontAwesomeIcons.palette,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: _buildFittedMenuText(
                            AppLocalizations.of(context)!.color_scheme,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _buildFittedMenuText(
                            currentThemeName,
                            alignment: Alignment.centerRight,
                            style: TextStyle(
                              fontFamily: 'ResourceHanCN',
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: AnimatedRotation(
                      turns: _themeMenuOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: FaIcon(
                        FontAwesomeIcons.chevronDown,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.size,
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${(scaleProvider.scaleFactor * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: scaleProvider.scaleFactor,
                  min: 0.6,
                  max: 1.8,
                  divisions: 12,
                  onChanged: (value) {
                    scaleProvider.setScaleFactor(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GestureMenuGroup extends StatefulWidget {
  const GestureMenuGroup({super.key});
  @override
  State<GestureMenuGroup> createState() => _GestureMenuGroupState();
}

class _GestureMenuGroupState extends State<GestureMenuGroup> {
  GestureAction _rightAction = GestureAction.archive;
  GestureAction _leftAction = GestureAction.delete;

  @override
  void initState() {
    super.initState();
    _rightAction = GestureSettings.rightAction;
    _leftAction = GestureSettings.leftAction;
  }

  Future<void> _updateRight(GestureAction? value) async {
    if (value == null) return;
    setState(() => _rightAction = value);
    await GestureSettings.setRightAction(value);
  }

  Future<void> _updateLeft(GestureAction? value) async {
    if (value == null) return;
    setState(() => _leftAction = value);
    await GestureSettings.setLeftAction(value);
  }

  Widget _dropdownTile({
    required String title,
    required GestureAction value,
    required ValueChanged<GestureAction?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final controlWidth = (constraints.maxWidth * 0.42)
            .clamp(92.0, 148.0)
            .toDouble();
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: SizedBox(
            height: 35,
            width: controlWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<GestureAction>(
                  value: value,
                  isExpanded: true,
                  isDense: true,
                  borderRadius: BorderRadius.circular(18),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  onChanged: onChanged,
                  selectedItemBuilder: (context) => [
                    for (final action in GestureAction.values)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          action.label(l10n),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'ResourceHanCN',
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                  items: [
                    for (final action in GestureAction.values)
                      DropdownMenuItem<GestureAction>(
                        value: action,
                        child: Text(
                          action.label(l10n),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: DeviceInfo.pt(320),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: scheme.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.gesture,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                _dropdownTile(
                  title: l10n.right_swipe_action,
                  value: _rightAction,
                  onChanged: _updateRight,
                ),
                _dropdownTile(
                  title: l10n.left_swipe_action,
                  value: _leftAction,
                  onChanged: _updateLeft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  StorageSnapshot? _snapshot;
  bool _optimizing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted) setState(() => _snapshot = null);
    final snapshot = await AppStorage.measure();
    if (!mounted) return;
    setState(() => _snapshot = snapshot);
  }

  Future<void> _optimizeStorage() async {
    if (_optimizing) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await confirmAction(
      context,
      title: l10n.optimize_storage,
      message: l10n.optimize_storage_confirm,
      confirmLabel: l10n.confirm,
    );
    if (!confirmed || !mounted) return;

    setState(() => _optimizing = true);
    try {
      final result = await AppStorage.optimize();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.optimize_storage_done(formatBytes(result.releasedBytes)),
            ),
          ),
        );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${l10n.clear_failed}$error')));
    } finally {
      if (mounted) setState(() => _optimizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final snapshot = _snapshot;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.storage,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _refresh,
            icon: Icon(Icons.refresh, color: scheme.onSurface),
          ),
        ],
      ),
      body: ContentPane(
        maxWidth: AppBreakpoints.wideContentMax,
        padding: EdgeInsets.zero,
        child: ListView(
          padding: EdgeInsets.all(DeviceInfo.pt(20)),
          children: [
            _summaryCard(
              context,
              icon: FontAwesomeIcons.database,
              title: l10n.storage_used,
              value: snapshot == null
                  ? l10n.calculating
                  : formatBytes(snapshot.storageBytes),
            ),
            SizedBox(height: DeviceInfo.pt(12)),
            _summaryCard(
              context,
              icon: FontAwesomeIcons.broom,
              title: l10n.cache_used,
              value: snapshot == null
                  ? l10n.calculating
                  : formatBytes(snapshot.cacheBytes),
            ),
            SizedBox(height: DeviceInfo.pt(24)),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: scheme.onSurface.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.cleaning_services_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(
                      l10n.optimize_storage,
                      style: const TextStyle(fontFamily: 'ResourceHanCN'),
                    ),
                    subtitle: Text(l10n.optimize_storage_subtitle),
                    onTap: _optimizing ? null : _optimizeStorage,
                  ),
                ],
              ),
            ),
            SizedBox(height: DeviceInfo.pt(24)),
            Row(
              children: [
                Expanded(
                  child: _CapsuleActionButton(
                    label: l10n.clear_cache,
                    onPressed: () async {
                      await clearAppCache(context);
                      await _refresh();
                    },
                  ),
                ),
                SizedBox(width: DeviceInfo.pt(12)),
                Expanded(
                  child: _CapsuleActionButton(
                    label: l10n.clear_config,
                    onPressed: () => clearAppConfig(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required FaIconData icon,
    required String title,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.onSurface.withOpacity(0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: FaIcon(icon, color: scheme.onSurface),
        title: Text(title, style: const TextStyle(fontFamily: 'ResourceHanCN')),
        trailing: Text(
          value,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            fontWeight: FontWeight.w500,
            color: scheme.onSurface.withOpacity(0.75),
          ),
        ),
      ),
    );
  }
}

class _CapsuleActionButton extends StatelessWidget {
  const _CapsuleActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(fontFamily: 'ResourceHanCN'),
        ),
      ),
    );
  }
}

class MySettingPage extends StatelessWidget {
  const MySettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ContentPane(
        maxWidth: AppBreakpoints.wideContentMax,
        padding: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildSectionHeader(context, AppLocalizations.of(context)!.general),
            _buildGroupCard(context, [
              _buildTile(
                context,
                icon: FontAwesomeIcons.ellipsis,
                title: AppLocalizations.of(context)!.interface,
                onTap: () => generalMenu(context),
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.language,
                title: AppLocalizations.of(context)!.language,
                onTap: () => languageMenu(context),
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.hand,
                title: AppLocalizations.of(context)!.gesture,
                onTap: () => gestureMenu(context),
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.database,
                title: AppLocalizations.of(context)!.storage,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoragePage()),
                ),
              ),
              _buildTile(
                context,
                leading: DeepseekIcon(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                title: AppLocalizations.of(context)!.deepseek_harness,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeepseekSettingsPage(),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionHeader(context, AppLocalizations.of(context)!.motalk),
            _buildGroupCard(context, [
              _buildTile(
                context,
                icon: FontAwesomeIcons.solidUserCircle,
                title: AppLocalizations.of(context)!.character,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoCharacterPage()),
                ),
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.solidMessage,
                title: AppLocalizations.of(context)!.message,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoSettingPage()),
                ),
              ),

              _buildTile(
                context,
                icon: FontAwesomeIcons.circleInfo,
                title: AppLocalizations.of(context)!.about,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'ResourceHanCN',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, List<Widget> tiles) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          int index = entry.key;
          Widget tile = entry.value;
          if (index < tiles.length - 1) {
            return Column(
              children: [
                tile,
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                ),
              ],
            );
          } else {
            return tile;
          }
        }).toList(),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    FaIconData? icon,
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final leadingWidget =
        leading ??
        (icon == null
            ? null
            : FaIcon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ));
    return ListTile(
      leading: leadingWidget,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'ResourceHanCN',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
