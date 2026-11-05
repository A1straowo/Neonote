import 'package:flutter/material.dart';

/// Icon button with a mandatory tooltip.
///
/// Icon-only actions in the note cards, drawer and archive pages currently have
/// no tooltip label. TalkBack announces them as unlabeled buttons and sighted
/// users must guess what a swipe or icon does. Making `tooltip` required at the
/// call site prevents new icon-only controls from regressing.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.onPressed,
    this.isSelected,
    this.color,
    this.iconSize = 22,
    this.visualDensity = VisualDensity.standard,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool? isSelected;
  final Color? color;
  final double iconSize;
  final VisualDensity visualDensity;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: isSelected,
      color: color,
      iconSize: iconSize,
      visualDensity: visualDensity,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      icon: icon,
    );
  }
}
