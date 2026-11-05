import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';

class SourceImageView extends StatelessWidget {
  const SourceImageView({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.loading,
    this.error,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? loading;
  final Widget? error;

  /// Decode at display resolution instead of loading a full-size camera image
  /// into the Flutter image cache.
  final int? cacheWidth;
  final int? cacheHeight;

  static bool isRemote(String source) =>
      source.startsWith('http://') ||
      source.startsWith('https://') ||
      source.startsWith('//');

  static String normalized(String source) =>
      source.startsWith('//') ? 'https:$source' : source;

  Widget _defaultError(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.error,
        semanticLabel: l10n?.image_load_failed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return error ?? const SizedBox.shrink();
    if (isRemote(source)) {
      return Image.network(
        normalized(source),
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : (loading ?? const SizedBox.shrink()),
        errorBuilder: (context, error, stackTrace) =>
            this.error ?? _defaultError(context),
      );
    }
    return Image.file(
      File(source),
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: (context, error, stackTrace) =>
          this.error ?? _defaultError(context),
    );
  }
}
