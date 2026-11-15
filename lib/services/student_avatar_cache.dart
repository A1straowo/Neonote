import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
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

  static const int _cacheVersion = 2;
  static const int _avatarDimension = 256;
  static const int _jpegQuality = 82;
  static const int _maxCacheEntries = 200;
  static const int _maxCacheBytes = 24 * 1024 * 1024;

  final Future<Directory> Function() _directoryProvider;
  final http.Client _client;
  final Map<String, Future<File?>> _inFlight = <String, Future<File?>>{};
  bool _initialPruneDone = false;

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
    return '${hash.toRadixString(16)}_${url.length}_v$_cacheVersion.jpg';
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
    if (!_initialPruneDone) {
      _initialPruneDone = true;
      await _prune(directory);
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

      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // Avatars are displayed at a small size. Persisting the original image
      // can waste several megabytes per student, so normalize every cache hit
      // to a compact square JPEG before it reaches the disk.
      final resized = img.copyResizeCropSquare(
        decoded,
        size: _avatarDimension,
        interpolation: img.Interpolation.average,
      );
      final compactBytes = img.encodeJpg(resized, quality: _jpegQuality);
      if (compactBytes.isEmpty) return null;

      final temp = File('${target.path}.tmp');
      await temp.writeAsBytes(compactBytes, flush: true);
      if (await target.exists()) await target.delete();
      await temp.rename(target.path);
      unawaited(_prune(target.parent));
      return target;
    } catch (_) {
      return null;
    }
  }

  /// Keeps both the file count and total disk usage of the avatar cache
  /// bounded. Versioned filenames also let upgrades discard the old full-size
  /// cache entries instead of retaining them indefinitely.
  Future<void> _prune(Directory directory) async {
    try {
      final files = await directory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      final liveFiles = <File>[];
      for (final file in files) {
        final name = p.basename(file.path);
        final isLegacy = name.endsWith('.img');
        final isTemp = name.endsWith('.tmp');
        if (isLegacy || isTemp) {
          try {
            await file.delete();
          } catch (_) {}
          continue;
        }
        if (name.endsWith('_v$_cacheVersion.jpg')) liveFiles.add(file);
      }

      liveFiles.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );
      var totalBytes = 0;
      for (final file in liveFiles) {
        totalBytes += file.statSync().size;
      }
      var excessCount = liveFiles.length - _maxCacheEntries;
      for (final file in liveFiles) {
        if (excessCount <= 0 && totalBytes <= _maxCacheBytes) break;
        try {
          final length = file.statSync().size;
          await file.delete();
          totalBytes -= length;
          excessCount--;
        } catch (_) {}
      }
    } catch (_) {}
  }
}
