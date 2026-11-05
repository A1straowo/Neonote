// ignore_for_file: non_constant_identifier_names, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart';

class CapsuleStyle1 extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final List<String> options;
  const CapsuleStyle1({
    super.key,
    this.initialIndex = 0,
    required this.onChanged,
    this.options = const ['普通消息', '老师消息'],
  });
  @override
  State<CapsuleStyle1> createState() => _CapsuleStyle1State();
}

class _CapsuleStyle1State extends State<CapsuleStyle1> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.options.length, (index) {
            final isSelected = _selectedIndex == index;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: index == 0 ? Radius.circular(30) : Radius.zero,
                    bottomLeft: index == 0 ? Radius.circular(30) : Radius.zero,
                    topRight: index == widget.options.length - 1
                        ? Radius.circular(30)
                        : Radius.zero,
                    bottomRight: index == widget.options.length - 1
                        ? Radius.circular(30)
                        : Radius.zero,
                  ),
                  child: Material(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        widget.onChanged(index);
                      },
                      borderRadius: BorderRadius.only(
                        topLeft: index == 0 ? Radius.circular(30) : Radius.zero,
                        bottomLeft: index == 0
                            ? Radius.circular(30)
                            : Radius.zero,
                        topRight: index == widget.options.length - 1
                            ? Radius.circular(30)
                            : Radius.zero,
                        bottomRight: index == widget.options.length - 1
                            ? Radius.circular(30)
                            : Radius.zero,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Text(
                          widget.options[index],
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final double cornerRadius;
  final bool showTail;
  final bool tailLeft;

  const Bubble({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.cornerRadius,
    this.showTail = false,
    this.tailLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    const double pad = 10.0;

    return CustomPaint(
      painter: _BubblePainter(
        color: color,
        cornerRadius: cornerRadius,
        showTail: showTail,
        tailLeft: tailLeft,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: pad, right: pad, top: 8.0, bottom: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontFamily: 'ResourceHanCN',
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final bool showTail;
  final bool tailLeft;

  _BubblePainter({
    required this.color,
    required this.cornerRadius,
    required this.showTail,
    required this.tailLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    path.addRRect(rrect);

    if (showTail) {
      final tailSize = 10.0;
      final tailPath = Path();
      if (tailLeft) {
        tailPath.moveTo(0, size.height / 2 - tailSize / 2);
        tailPath.lineTo(-tailSize, size.height / 2);
        tailPath.lineTo(0, size.height / 2 + tailSize / 2);
        tailPath.close();
        path.addPath(tailPath, Offset.zero);
      } else {
        tailPath.moveTo(size.width, size.height / 2 - tailSize / 2);
        tailPath.lineTo(size.width + tailSize, size.height / 2);
        tailPath.lineTo(size.width, size.height / 2 + tailSize / 2);
        tailPath.close();
        path.addPath(tailPath, Offset.zero);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.showTail != showTail ||
      oldDelegate.tailLeft != tailLeft;
}

class MoSettingPage extends StatefulWidget {
  const MoSettingPage({super.key});

  @override
  State<MoSettingPage> createState() => _MoSettingPageState();
}

class _MoSettingPageState extends State<MoSettingPage> {
  int _messageType = 0;
  double _cornerRadius = 8.0;
  Color _dialogColor = const Color(0xFF4C5B70);
  Color _textColor = Colors.white;
  int _emojiSize = 130;
  bool _hasChanged = false;

  late int _originalMessageType;
  late double _originalCornerRadius;
  late Color _originalDialogColor;
  late Color _originalTextColor;
  late int _originalEmojiSize;

  late TextEditingController _dialogColorController;
  late TextEditingController _textColorController;
  late TextEditingController _emojiSizeController;

  final Box _box = Hive.box(themeBox);

  String get _dialogColorKey =>
      _messageType == 0 ? 'mo_dialogColorNormal' : 'mo_dialogColorTeacher';
  String get _textColorKey =>
      _messageType == 0 ? 'mo_textColorNormal' : 'mo_textColorTeacher';
  Color get _defaultDialogColor =>
      _messageType == 0 ? const Color(0xFF4C5B70) : const Color(0xFF4A80CB);
  Color get _defaultTextColor => Colors.white;

  AppLocalizations? get Applocalizations => AppLocalizations.of(context);

  void _loadSettings() {
    _messageType = _box.get('mo_messageType', defaultValue: 0);
    _cornerRadius = _box.get('mo_cornerRadius', defaultValue: 8.0);
    if (_cornerRadius < 8.0) {
      _cornerRadius = 8.0;
      _box.put('mo_cornerRadius', 8.0);
    }
    int? dialogVal = _box.get(_dialogColorKey);
    _dialogColor = dialogVal != null ? Color(dialogVal) : _defaultDialogColor;
    int? textVal = _box.get(_textColorKey);
    _textColor = textVal != null ? Color(textVal) : _defaultTextColor;
    _emojiSize = _box.get('mo_emojiSize', defaultValue: 130);
    _dialogColorController.text = _colorToHex(_dialogColor);
    _textColorController.text = _colorToHex(_textColor);
    _emojiSizeController.text = '$_emojiSize';
    _hasChanged = false;

    _originalMessageType = _messageType;
    _originalCornerRadius = _cornerRadius;
    _originalDialogColor = _dialogColor;
    _originalTextColor = _textColor;
    _originalEmojiSize = _emojiSize;
  }

  void _saveSettings() {
    _box.put('mo_messageType', _messageType);
    _box.put('mo_cornerRadius', _cornerRadius);
    _box.put(_dialogColorKey, _dialogColor.value);
    _box.put(_textColorKey, _textColor.value);
    _box.put('mo_emojiSize', _emojiSize);
  }

  void _switchType(int newType) {
    setState(() {
      _messageType = newType;
      int? dialogVal = _box.get(_dialogColorKey);
      _dialogColor = dialogVal != null ? Color(dialogVal) : _defaultDialogColor;
      int? textVal = _box.get(_textColorKey);
      _textColor = textVal != null ? Color(textVal) : _defaultTextColor;
      _dialogColorController.text = _colorToHex(_dialogColor);
      _textColorController.text = _colorToHex(_textColor);
    });
    _saveSettings();
    _hasChanged = false;
  }

  Future<void> _tryPop() async {
    if (!_hasChanged) {
      Navigator.pop(context);
      return;
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(AppLocalizations.of(context)!.confirm),
        content: Text(AppLocalizations.of(context)!.restore_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm == true) {
      setState(() {
        _messageType = _originalMessageType;
        _cornerRadius = _originalCornerRadius;
        _dialogColor = _originalDialogColor;
        _textColor = _originalTextColor;
        _emojiSize = _originalEmojiSize;
        _dialogColorController.text = _colorToHex(_originalDialogColor);
        _textColorController.text = _colorToHex(_originalTextColor);
        _emojiSizeController.text = '$_originalEmojiSize';
        _hasChanged = false;
      });
      _saveSettings();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _dialogColorController = TextEditingController();
    _textColorController = TextEditingController();
    _emojiSizeController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _dialogColorController.dispose();
    _textColorController.dispose();
    _emojiSizeController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  Color? _tryHexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final normalized = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    if (normalized.length != 8) return null;
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  Future<void> _pickColor(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Color fallback,
    required ValueChanged<String> onChanged,
  }) async {
    Color tempColor = _tryHexToColor(controller.text) ?? fallback;
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(label),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                setDialogState(() => tempColor = color);
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempColor),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
      ),
    );
    if (pickedColor == null) return;
    final hex = _colorToHex(pickedColor);
    controller.text = hex;
    controller.selection = TextSelection.collapsed(offset: hex.length);
    onChanged(hex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        if (didPop) return;
        await _tryPop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.message,
            style: TextStyle(
              fontFamily: 'ResourceHanCN',
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: DeviceInfo.pt(20),
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _tryPop(),
          ),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(DeviceInfo.pt(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CapsuleStyle1(
                initialIndex: _messageType,
                onChanged: (index) => _switchType(index),
                options: [l10n.message_student, l10n.message_teacher],
              ),
              SizedBox(height: DeviceInfo.pt(24)),

              _buildMessagePreview(context),
              SizedBox(height: DeviceInfo.pt(24)),

              _buildCapsuleSlider(context),
              SizedBox(height: DeviceInfo.pt(24)),

              _buildColorTextField(
                context,
                label: AppLocalizations.of(context)!.dialog,
                controller: _dialogColorController,
                fallback: _dialogColor,
                onChanged: (value) {
                  final parsed = _tryHexToColor(value);
                  if (parsed == null) return;
                  setState(() => _dialogColor = parsed);
                  _saveSettings();
                  _hasChanged = true;
                },
              ),
              SizedBox(height: DeviceInfo.pt(16)),

              _buildColorTextField(
                context,
                label: AppLocalizations.of(context)!.font,
                controller: _textColorController,
                fallback: _textColor,
                onChanged: (value) {
                  final parsed = _tryHexToColor(value);
                  if (parsed == null) return;
                  setState(() => _textColor = parsed);
                  _saveSettings();
                  _hasChanged = true;
                },
              ),
              SizedBox(height: DeviceInfo.pt(16)),

              _buildEmojiSizeField(context),
              SizedBox(height: DeviceInfo.pt(24)),

              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagePreview(BuildContext context) {
    final bool isTeacher = _messageType == 1;
    final Color bubbleColor = _dialogColor;
    final Color textColor = _textColor;
    final List<String> texts = ['你好', '这是一段消息演示'];

    Widget buildBubble(
      String text, {
      required bool showTail,
      required bool tailLeft,
    }) {
      return Bubble(
        text: text,
        color: bubbleColor,
        textColor: textColor,
        cornerRadius: _cornerRadius,
        showTail: showTail,
        tailLeft: tailLeft,
      );
    }

    if (!isTeacher) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsetsGeometry.only(top: 16),
            width: DeviceInfo.pt(48),
            height: DeviceInfo.pt(48),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage(
                  'https://static.kivo.wiki/images/students/%E5%9C%A3%E5%9B%AD%20%E6%9C%AA%E8%8A%B1/%E6%B3%B3%E8%A3%85/Student_Portrait_CH0294_Collection.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: DeviceInfo.pt(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    '演示',
                    style: TextStyle(
                      fontSize: DeviceInfo.pt(16),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: DeviceInfo.pt(4)),
                buildBubble(texts[0], showTail: true, tailLeft: true),
                SizedBox(height: DeviceInfo.pt(6)),
                buildBubble(texts[1], showTail: false, tailLeft: true),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildBubble(texts[0], showTail: true, tailLeft: false),
                SizedBox(height: DeviceInfo.pt(6)),
                buildBubble(texts[1], showTail: false, tailLeft: false),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCapsuleSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.radius,
              style: TextStyle(
                fontSize: DeviceInfo.pt(16),
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${_cornerRadius.round()}px',
              style: TextStyle(
                fontSize: DeviceInfo.pt(14),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              disabledThumbRadius: 10,
            ),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.2),
            trackShape: const RoundedRectSliderTrackShape(),
            thumbColor: Theme.of(context).colorScheme.primary,
          ),
          child: Slider(
            value: _cornerRadius,
            min: 0,
            max: 30,
            divisions: 30,
            onChanged: (value) {
              setState(() => _cornerRadius = value);
              _saveSettings();
              _hasChanged = true;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Color fallback,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: '#RRGGBB',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F#]')),
            ],
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: DeviceInfo.pt(12)),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _pickColor(
              context,
              label: label,
              controller: controller,
              fallback: fallback,
              onChanged: onChanged,
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: DeviceInfo.pt(40),
              height: DeviceInfo.pt(40),
              decoration: BoxDecoration(
                color: _tryHexToColor(controller.text) ?? fallback,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiSizeField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _emojiSizeController,
            decoration: InputDecoration(
              labelText: '差分表情大小',
              suffixText: 'px',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final int? parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) {
                setState(() => _emojiSize = parsed);
                _saveSettings();
                _hasChanged = true;
              }
            },
          ),
        ),
        SizedBox(width: DeviceInfo.pt(12)),
        Text(
          '${_emojiSize}px',
          style: TextStyle(
            fontSize: DeviceInfo.pt(16),
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _hasChanged = false;
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.settings_saved),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(AppLocalizations.of(context)!.apply),
          ),
        ),
        SizedBox(width: DeviceInfo.pt(12)),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  scrollable: true,
                  title: Text(AppLocalizations.of(context)!.restore_defaults),
                  content: Text(AppLocalizations.of(context)!.restore_confirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppLocalizations.of(context)!.confirm),
                    ),
                  ],
                ),
              );
              if (!mounted) return;
              if (confirm != true) return;
              setState(() {
                _dialogColor = _defaultDialogColor;
                _textColor = _defaultTextColor;
                _cornerRadius = 8.0;
                _emojiSize = 130;
                _dialogColorController.text = _colorToHex(_defaultDialogColor);
                _textColorController.text = _colorToHex(_defaultTextColor);
                _emojiSizeController.text = '130';
              });
              _saveSettings();
              _hasChanged = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.defaults_restored,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            child: Text(AppLocalizations.of(context)!.restore_defaults),
          ),
        ),
      ],
    );
  }
}
