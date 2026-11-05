// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart';
import 'package:neonote/momotalk/student_actions.dart';
import 'package:neonote/services/platform_media.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/widgets/floating_ball.dart';
import 'package:neonote/widgets/image_source_view.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }
}

class MoCharacterPage extends StatefulWidget {
  const MoCharacterPage({super.key});

  @override
  State<MoCharacterPage> createState() => _MoCharacterPageState();
}

class _MoCharacterPageState extends State<MoCharacterPage> {
  bool _showSurname = true;
  bool _reverseName = false;
  String _nameLanguage = 'zh';
  String _remark = '';
  String _teacherAvatar = '';
  String _greeting = '';
  late Box _box;

  static const String _remarkKey = 'mochar_remark';
  static const String _teacherAvatarKey = 'mochar_teacher_avatar';
  static const String _greetingKey = 'mochar_custom_greeting';

  static const List<String> _nameLanguageCodes = [
    'zh',
    'ja',
    'en',
    'ko',
    'es',
    'ru',
  ];

  @override
  void initState() {
    super.initState();
    _box = Hive.box('HiveThemeBox');
    _loadSettings();
  }

  static bool _readBool(Object? value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  static String _readString(Object? value, [String fallback = '']) =>
      value is String ? value : fallback;

  void _loadSettings() {
    _showSurname = _readBool(_box.get('mochar_showSurname'), true);
    _reverseName = _readBool(_box.get('mochar_reverseName'), false);
    final storedLanguage = _readString(_box.get('mochar_nameLanguage'), 'zh');
    _nameLanguage = _normalizeLanguageCode(storedLanguage);
    if (_nameLanguage != storedLanguage) {
      _box.put('mochar_nameLanguage', _nameLanguage);
    }
    _remark = _readString(_box.get(_remarkKey));
    _teacherAvatar = _readString(_box.get(_teacherAvatarKey));
    _greeting = _readString(_box.get(_greetingKey));
  }

  void _saveSettings() {
    _box.put('mochar_showSurname', _showSurname);
    _box.put('mochar_reverseName', _reverseName);
    _box.put('mochar_nameLanguage', _nameLanguage);
    // Student names are rendered from these settings across MomoTalk.
    NoteStore.revision.value = NoteStore.revision.value + 1;
  }

  static String _normalizeLanguageCode(String value) {
    if (_nameLanguageCodes.contains(value)) return value;
    const legacyCodes = {
      '中文': 'zh',
      '日本語': 'ja',
      'English': 'en',
      '한국어': 'ko',
      'Español': 'es',
      'Русский': 'ru',
    };
    return legacyCodes[value] ?? 'zh';
  }

  String _languageName(AppLocalizations l10n, String code) {
    switch (code) {
      case 'zh':
        return l10n.language_chinese;
      case 'ja':
        return l10n.language_japanese;
      case 'en':
        return l10n.language_english;
      case 'ko':
        return l10n.language_korean;
      case 'es':
        return l10n.language_spanish;
      case 'ru':
        return l10n.language_russian;
      default:
        return l10n.language_english;
    }
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  Widget _fittedText(String text, {TextStyle? style}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        // fit: BoxFit.scaleDown,
        // alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          softWrap: true,
          style:
              style ??
              TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      title: _fittedText(title),
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    String subtitle = '',
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      title: _fittedText(title),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
      trailing: const Icon(Icons.arrow_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildTeacherAvatarTile(AppLocalizations l10n) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: _teacherAvatar.isEmpty
          ? null
          : ClipOval(
              child: SizedBox(
                width: 36,
                height: 36,
                child: SourceImageView(source: _teacherAvatar),
              ),
            ),
      title: _fittedText(l10n.teacher_avatar),
      trailing: const Icon(Icons.arrow_right, size: 20),
      onTap: _pickTeacherAvatar,
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n) {
    return ListTile(
      title: _fittedText(l10n.student_name_language),
      trailing: SizedBox(
        height: 40,
        child: PopupMenuButton<String>(
          initialValue: _nameLanguage,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Theme.of(context).colorScheme.surfaceContainer,
          onSelected: (value) {
            setState(() => _nameLanguage = value);
            _saveSettings();
          },
          itemBuilder: (context) {
            final itemL10n = AppLocalizations.of(context)!;
            return _nameLanguageCodes.map((code) {
              final selected = _nameLanguage == code;
              return PopupMenuItem<String>(
                value: code,
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
                    Text(_languageName(itemL10n, code)),
                  ],
                ),
              );
            }).toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _languageName(l10n, _nameLanguage),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
      onTap: null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Future<void> _editRemark() async {
    final l10n = AppLocalizations.of(context)!;
    final value = await showTextInputDialog(
      context,
      title: l10n.edit_remark,
      hint: l10n.remark_hint,
      confirmLabel: l10n.save,
      initialValue: _remark,
    );
    if (value == null || !mounted) return;
    setState(() => _remark = value);
    await _box.put(_remarkKey, value);
  }

  Future<void> _pickTeacherAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    if (!PlatformMediaService.isMobile) {
      _toast(l10n.image_pick_failed);
      return;
    }
    final path = await PlatformMediaService.pickImageFromGallery();
    if (!mounted || path == null) return;
    setState(() => _teacherAvatar = path);
    await _box.put(_teacherAvatarKey, path);
  }

  Future<void> _editGreeting() async {
    final l10n = AppLocalizations.of(context)!;
    final value = await showTextInputDialog(
      context,
      title: l10n.edit_greeting,
      hint: l10n.greeting_hint,
      confirmLabel: l10n.save,
      initialValue: _greeting,
    );
    if (value == null || !mounted) return;
    setState(() => _greeting = value);
    await _box.put(_greetingKey, value);
  }

  Future<void> _pickStudent() async {
    final l10n = AppLocalizations.of(context)!;
    final student = await pickStudent(context);
    if (student == null || !mounted) return;
    await createChatWithStudent(context, student);
    if (!mounted) return;
    _toast(l10n.chat_added(student.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.character,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: colorScheme.onSurface,
            fontSize: DeviceInfo.pt(20),
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            SettingsCard(
              children: [
                _buildSwitchTile(
                  title: l10n.show_student_surname,
                  value: _showSurname,
                  onChanged: (value) {
                    setState(() => _showSurname = value);
                    _saveSettings();
                  },
                ),
                const SettingsDivider(),
                _buildSwitchTile(
                  title: l10n.reverse_name,
                  value: _reverseName,
                  onChanged: _showSurname
                      ? (value) {
                          setState(() => _reverseName = value);
                          _saveSettings();
                        }
                      : null,
                ),
                const SettingsDivider(),
                _buildLanguageTile(l10n),
              ],
            ),
            SettingsCard(
              children: [
                _buildNavigationTile(
                  title: l10n.remark,
                  subtitle: _remark,
                  onTap: _editRemark,
                ),
                const SettingsDivider(),
                _buildTeacherAvatarTile(l10n),
                const SettingsDivider(),
                _buildNavigationTile(
                  title: l10n.custom_student,
                  onTap: _pickStudent,
                ),
                const SettingsDivider(),
                _buildNavigationTile(
                  title: l10n.custom_greeting,
                  subtitle: _greeting,
                  onTap: _editGreeting,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
