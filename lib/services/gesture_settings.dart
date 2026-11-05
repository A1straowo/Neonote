import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show themeBox;

enum GestureAction { pin, archive, mark, delete }

extension GestureActionLabel on GestureAction {
  String label(AppLocalizations l10n) => switch (this) {
    GestureAction.pin => l10n.gesture_pin,
    GestureAction.archive => l10n.gesture_archive,
    GestureAction.mark => l10n.gesture_mark,
    GestureAction.delete => l10n.delete,
  };
}

class GestureSettings {
  GestureSettings._();

  static const String rightActionKey = 'gesture_right_action';
  static const String leftActionKey = 'gesture_left_action';

  static GestureAction _read(String key, GestureAction fallback) {
    final raw = Hive.box(themeBox).get(key);
    if (raw == null) return fallback;

    for (final action in GestureAction.values) {
      if (action.name == raw.toString()) return action;
    }
    return fallback;
  }

  static GestureAction get rightAction =>
      _read(rightActionKey, GestureAction.archive);

  static GestureAction get leftAction =>
      _read(leftActionKey, GestureAction.delete);

  static Future<void> setRightAction(GestureAction action) {
    return Hive.box(themeBox).put(rightActionKey, action.name);
  }

  static Future<void> setLeftAction(GestureAction action) {
    return Hive.box(themeBox).put(leftActionKey, action.name);
  }
}
