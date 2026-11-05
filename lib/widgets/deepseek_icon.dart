import 'package:flutter/material.dart';

/// The DeepSeek whale mark, tinted so it matches the surrounding icons.
class DeepseekIcon extends StatelessWidget {
  const DeepseekIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        'assets/icon/deepseek.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
