import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persistent on-disk cache for student avatars that have actually been shown.
///
/// The Kivo student list is already cached in Hive, but avatar images were
/// previously fetched by [Image.network] and could disappear when the widget or
/// image cache was rebuilt. This service stores the previewed bytes under the
/// app support directory so opening the student picker again is instant.
class StudentAvatarCache {
  StudentAvatarCache({
    Future<Directory> Function()? directoryProvider,
    http.Client? client,
  }) : _directoryProvider = directoryProvider ?? _defaultDirectory,
       _client = client ?? http.Client();

  static final StudentAvatarCache instance = StudentAvatarCache();

  final Future<Directory> Function() _directoryProvider;
  final http.Client _client;
  final Map<String, Future<File?>> _inFlight = <String, Future<File?>>{};

  static Future<Directory> _defaultDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'student_avatars'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _normalize(String raw) {
    final value = raw.trim();
    if (value.startsWith('//')) return 'https:$value';
    return value;
  }

  String _cacheName(String url) {
    // FNV-1a is stable across runs, unlike String.hashCode.
    var hash = 0x811c9dc5;
    for (var i = 0; i < url.length; i++) {
      hash ^= url.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return '${hash.toRadixString(16)}_${url.length}.img';
  }

  Future<File?> resolve(String rawUrl) async {
    final url = _normalize(rawUrl);
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return null;
    }

    final Directory directory;
    try {
      directory = await _directoryProvider();
    } catch (_) {
      return null;
    }
    final file = File(p.join(directory.path, _cacheName(url)));
    if (await file.exists()) {
      final length = await file.length();
      if (length > 0) return file;
      await file.delete();
    }

    final pending = _inFlight[url];
    if (pending != null) return pending;

    final future = _download(url, file);
    _inFlight[url] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(url);
    }
  }

  Future<File?> _download(String url, File target) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: const <String, String>{
              'User-Agent': 'Neonote/1.0 (Flutter)',
              'Accept': 'image/*',
            },
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final bytes = response.bodyBytes;
      if (bytes.isEmpty) return null;

      final temp = File('${target.path}.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      if (await target.exists()) await target.delete();
      await temp.rename(target.path);
      unawaited(_prune(target.parent));
      return target;
    } catch (_) {
      return null;
    }
  }

  /// Keeps the cache bounded when users browse many student portraits.
  Future<void> _prune(Directory directory) async {
    try {
      final files = await directory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      if (files.length <= 500) return;
      files.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );
      for (final file in files.take(files.length - 500)) {
        try {
          await file.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }
}
