import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neonote/services/student_avatar_cache.dart';

/// Shows a student portrait from the persistent cache. The first time an avatar
/// is visible it is downloaded and stored; later opens read the local file.
class CachedStudentAvatar extends StatefulWidget {
  const CachedStudentAvatar({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
    this.cacheWidth = 256,
  });

  final String source;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;
  final int cacheWidth;

  @override
  State<CachedStudentAvatar> createState() => _CachedStudentAvatarState();
}

class _CachedStudentAvatarState extends State<CachedStudentAvatar> {
  File? _file;
  bool _loading = true;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CachedStudentAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _file = null;
      _loading = true;
      _load();
    }
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    final file = await StudentAvatarCache.instance.resolve(widget.source);
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _file = file;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    if (file != null) {
      return Image.file(
        file,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        errorBuilder: (context, error, stackTrace) =>
            widget.error ?? const SizedBox.shrink(),
      );
    }
    if (_loading) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return widget.error ?? const SizedBox.shrink();
  }
}
