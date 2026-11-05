// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neonote/main.dart' show DeviceInfo;

class FloatingBallItem {
  const FloatingBallItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class FloatingBallMenu extends StatefulWidget {
  const FloatingBallMenu({
    super.key,
    required this.items,
    this.bottom = 20,
    this.right = 18,
  });

  final List<FloatingBallItem> items;
  final double bottom;
  final double right;

  @override
  State<FloatingBallMenu> createState() => _FloatingBallMenuState();
}

class _FloatingBallMenuState extends State<FloatingBallMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 180),
  );

  late List<Animation<double>> _capsuleAnimations = <Animation<double>>[];

  bool _open = false;

  bool get _isLandscape =>
      MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
  double get _ballSize => DeviceInfo.pt(_isLandscape ? 46 : 56);
  double get _capsuleHeight => DeviceInfo.pt(_isLandscape ? 38 : 50);
  double get _capsuleWidth => DeviceInfo.pt(_isLandscape ? 104 : 186);
  double get _gap => DeviceInfo.pt(_isLandscape ? 6 : 10);

  @override
  void initState() {
    super.initState();
    _buildCapsuleAnimations();
  }

  @override
  void didUpdateWidget(covariant FloatingBallMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _buildCapsuleAnimations();
    }
  }

  void _buildCapsuleAnimations() {
    final total = widget.items.length;
    if (total == 0) {
      _capsuleAnimations = <Animation<double>>[];
      return;
    }
    final stagger = total > 1 ? 0.08 : 0.0;
    _capsuleAnimations = List<Animation<double>>.generate(total, (index) {
      final start = (index * stagger).clamp(0.0, 0.72).toDouble();
      final end = total == 1 ? 1.0 : (start + 0.55).clamp(0.0, 1.0).toDouble();
      return _controller.drive(
        CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    final willOpen = !_open;
    setState(() => _open = willOpen);
    if (willOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _controller.reverse();
  }

  void _run(FloatingBallItem item) {
    _close();
    item.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final capsules = <Widget>[
      for (var index = widget.items.length - 1; index >= 0; index--)
        _buildCapsule(
          item: widget.items[index],
          animation: _capsuleAnimations[index],
          background: scheme.primary,
          foreground: scheme.onPrimary,
        ),
    ];

    return Stack(
      children: [
        Positioned(
          right: widget.right,
          bottom: widget.bottom,
          child: RepaintBoundary(
            child: _isLandscape
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [...capsules.reversed, _buildBall(scheme)],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [...capsules, _buildBall(scheme)],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapsule({
    required FloatingBallItem item,
    required Animation<double> animation,
    required Color background,
    required Color foreground,
  }) {
    return SizeTransition(
      axis: _isLandscape ? Axis.horizontal : Axis.vertical,
      axisAlignment: _isLandscape ? 1.0 : 1.0,
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: _isLandscape
              ? EdgeInsets.only(right: _gap)
              : EdgeInsets.only(bottom: _gap),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(_capsuleHeight / 2),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _run(item),
              child: Container(
                width: _capsuleWidth,
                height: _capsuleHeight,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: DeviceInfo.pt(_isLandscape ? 16 : 21),
                      color: foreground,
                    ),
                    SizedBox(width: DeviceInfo.pt(_isLandscape ? 6 : 10)),
                    Flexible(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(_isLandscape ? 12 : 18),
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBall(ColorScheme scheme) {
    final active = _open;
    final size = active ? _ballSize + DeviceInfo.pt(2) : _ballSize;
    return Semantics(
      button: true,
      label: active ? 'close' : 'menu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: active
                ? Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.35),
                    scheme.primaryContainer,
                  )
                : scheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              active ? Icons.close : Icons.add,
              key: ValueKey<bool>(active),
              size: DeviceInfo.pt(_isLandscape ? 22 : 26),
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
  String initialValue = '',
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      hint: hint,
      confirmLabel: confirmLabel,
      initialValue: initialValue,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    ),
  ).then((value) => value?.trim());
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    required this.initialValue,
    required this.keyboardType,
    this.inputFormatters,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String initialValue;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.title,
        style: const TextStyle(fontFamily: 'ResourceHanCN', fontSize: 18),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: const TextStyle(fontFamily: 'ResourceHanCN'),
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(fontFamily: 'ResourceHanCN'),
          ),
        ),
      ],
    );
  }
}
