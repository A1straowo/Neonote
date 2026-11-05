import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/store/note_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class StorageSnapshot {
  const StorageSnapshot({required this.storageBytes, required this.cacheBytes});

  final int storageBytes;
  final int cacheBytes;

  static const StorageSnapshot empty = StorageSnapshot(
    storageBytes: 0,
    cacheBytes: 0,
  );
}

class StorageOptimizationResult {
  const StorageOptimizationResult({
    required this.orphanedMediaBytes,
    required this.legacyExportBytes,
    required this.databaseBytes,
    required this.deletedFiles,
  });

  final int orphanedMediaBytes;
  final int legacyExportBytes;
  final int databaseBytes;
  final int deletedFiles;

  int get releasedBytes =>
      orphanedMediaBytes + legacyExportBytes + databaseBytes;
}

class AppStorage {
  AppStorage._();

  static Future<StorageSnapshot> measure() async {
    var storage = 0;
    var cache = 0;

    final databasePath = await _guard(getDatabasesPath);
    final supportDirectory = await _guard(getApplicationSupportDirectory);
    final documentsDirectory = await _guard(getApplicationDocumentsDirectory);

    // Count each storage root only once. The Hive file lives inside one of
    // these directories (usually the documents/support directory), so adding
    // `_hivePath()` separately used to count the same data twice.
    final storageRoots = _uniqueRoots(<String>[
      ?databasePath,
      ?supportDirectory?.path,
      ?documentsDirectory?.path,
    ]);

    for (final path in storageRoots) {
      storage += await _directorySize(path);
    }

    // Defensive fallback: if a future Hive implementation stores its box
    // outside all measured roots, count it explicitly.
    final hivePath = _hivePath();
    if (hivePath != null &&
        !storageRoots.any((root) => _isSameOrNested(hivePath, root))) {
      storage += await _fileSize(hivePath);
    }

    final cacheDirectory = await _guard(getApplicationCacheDirectory);
    final temporaryDirectory = await _guard(getTemporaryDirectory);
    final cacheRoots = _uniqueRoots(<String>[
      ?cacheDirectory?.path,
      ?temporaryDirectory?.path,
    ]);
    for (final path in cacheRoots) {
      cache += await _directorySize(path);
    }

    return StorageSnapshot(storageBytes: storage, cacheBytes: cache);
  }

  static Future<void> clearCache() async {
    final cacheDirectory = await _guard(getApplicationCacheDirectory);
    if (cacheDirectory != null) await _clearDirectory(cacheDirectory.path);
    final temporaryDirectory = await _guard(getTemporaryDirectory);
    if (temporaryDirectory != null &&
        (cacheDirectory == null ||
            !_isSameOrNested(temporaryDirectory.path, cacheDirectory.path))) {
      await _clearDirectory(temporaryDirectory.path);
    }
  }

  /// Deletes media files that are no longer referenced by any note, chat or
  /// AI conversation, removes private copies produced by the retired export
  /// UI, and compacts the Hive database. User-authored notes are never deleted.
  static Future<StorageOptimizationResult> optimize() async {
    final supportDirectory = await _guard(getApplicationSupportDirectory);
    final documentsDirectory = await _guard(getApplicationDocumentsDirectory);

    final references = <String>{};
    _collectReferencesFromBox(references);
    _collectReferencesFromModels(references);

    var orphanedMediaBytes = 0;
    var deletedFiles = 0;
    if (supportDirectory != null) {
      final changed = await _removeOrphanedMedia(
        supportDirectory.path,
        references,
      );
      orphanedMediaBytes += changed.$1;
      deletedFiles += changed.$2;
    }

    var legacyExportBytes = 0;
    if (documentsDirectory != null) {
      final changed = await _removeLegacyExports(documentsDirectory.path);
      legacyExportBytes += changed.$1;
      deletedFiles += changed.$2;
      final changedMedia = await _removeOrphanedMedia(
        documentsDirectory.path,
        references,
      );
      orphanedMediaBytes += changedMedia.$1;
      deletedFiles += changedMedia.$2;
    }

    await _removeOrphanedRecoveryDrafts();

    final before = await _fileSize(_hivePath());
    try {
      if (Hive.isBoxOpen(neonoteBoxName)) {
        final box = Hive.box(neonoteBoxName);
        await box.flush();
        await box.compact();
      }
    } catch (_) {}
    final after = await _fileSize(_hivePath());
    final databaseBytes = before > after ? before - after : 0;

    return StorageOptimizationResult(
      orphanedMediaBytes: orphanedMediaBytes,
      legacyExportBytes: legacyExportBytes,
      databaseBytes: databaseBytes,
      deletedFiles: deletedFiles,
    );
  }

  static void _collectReferencesFromBox(Set<String> references) {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return;
      for (final value in Hive.box(neonoteBoxName).values) {
        _collectPathStrings(value, references);
      }
    } catch (_) {}
  }

  static void _collectReferencesFromModels(Set<String> references) {
    try {
      void add(Object? value) {
        final path = value?.toString().trim() ?? '';
        if (path.isNotEmpty) references.add(_normalizePath(path));
      }

      for (final component in NoteStore.components()) {
        add(component.url);
        add(component.textBackgroundImage);
        for (final block in component.textBlocks) {
          add(block.mediaPath);
        }
      }
      final chats = NoteStore.chats();
      for (final chat in chats) {
        add(chat.avatarUrl);
        for (final message in NoteStore.messages(chat.id)) {
          add(message.imageUrl);
        }
      }
      for (final conversation in NoteStore.aiConversations()) {
        for (final message in conversation.messages) {
          for (final path in message.imagePaths) {
            add(path);
          }
          for (final path in message.audioPaths) {
            add(path);
          }
        }
      }
    } catch (_) {}
  }

  static void _collectPathStrings(Object? value, Set<String> output) {
    if (value is String) {
      final text = value.trim();
      if (text.contains('/') || text.contains('\\')) {
        output.add(_normalizePath(text));
      }
      return;
    }
    if (value is Map) {
      for (final entry in value.values) {
        _collectPathStrings(entry, output);
      }
      return;
    }
    if (value is Iterable) {
      for (final item in value) {
        _collectPathStrings(item, output);
      }
    }
  }

  static Future<(int, int)> _removeOrphanedMedia(
    String root,
    Set<String> references,
  ) async {
    var released = 0;
    var deleted = 0;
    final directory = Directory(root);
    if (!await directory.exists()) return (0, 0);
    final cutoff = DateTime.now().subtract(const Duration(minutes: 5));

    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final normalized = _normalizePath(entity.path);
        if (!_isMediaCandidate(normalized, root)) continue;
        if (references.contains(normalized)) continue;
        try {
          final stat = await entity.stat();
          // Avoid racing a just-picked attachment that has not reached Hive
          // yet. Older unreferenced files are safe to remove.
          if (stat.modified.isAfter(cutoff)) continue;
          final size = stat.size;
          await entity.delete();
          released += size;
          deleted++;
        } catch (_) {}
      }
    } catch (_) {}
    return (released, deleted);
  }

  static bool _isMediaCandidate(String path, String root) {
    final normalizedRoot = _normalizePath(root);
    final lower = path.toLowerCase();
    final extension = p.extension(lower);
    const mediaExtensions = <String>{
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
      '.m4a',
      '.aac',
      '.mp3',
      '.ogg',
      '.wav',
      '.mp4',
    };
    if (!mediaExtensions.contains(extension)) return false;

    final avatarRoot = _normalizePath(p.join(normalizedRoot, 'avatars'));
    final audioRoot = _normalizePath(p.join(normalizedRoot, 'audio'));
    if (_isSameOrNested(path, avatarRoot) || _isSameOrNested(path, audioRoot)) {
      return true;
    }

    // Cropped note backgrounds are written to the documents directory.
    return p.basename(lower).startsWith('note_background_');
  }

  static Future<(int, int)> _removeLegacyExports(String root) async {
    var released = 0;
    var deleted = 0;
    final directory = Directory(root);
    if (!await directory.exists()) return (0, 0);
    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File) continue;
        final name = p.basename(entity.path).toLowerCase();
        final isLegacyExport =
            (name.startsWith('neonote-backup-') && name.endsWith('.json')) ||
            (name.startsWith('neonote-') && name.endsWith('.md'));
        if (!isLegacyExport) continue;
        try {
          final size = await entity.length();
          await entity.delete();
          released += size;
          deleted++;
        } catch (_) {}
      }
    } catch (_) {}
    return (released, deleted);
  }

  static Future<void> _removeOrphanedRecoveryDrafts() async {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return;
      final box = Hive.box(neonoteBoxName);
      final componentIds = NoteStore.components()
          .map((item) => item.id)
          .toSet();
      final keys = box.keys.toList(growable: false);
      for (final key in keys) {
        final text = key.toString();
        if (!text.startsWith('note_recovery_')) continue;
        final id = text.substring('note_recovery_'.length);
        if (!componentIds.contains(id)) await box.delete(key);
      }
    } catch (_) {}
  }

  static String _normalizePath(String value) {
    var normalized = value.replaceAll('\\', '/');
    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  static String? _hivePath() {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return null;
      return Hive.box(neonoteBoxName).path;
    } catch (_) {
      return null;
    }
  }

  static Future<int> _fileSize(String? path) async {
    if (path == null || path.isEmpty) return 0;
    try {
      final file = File(path);
      if (await file.exists()) return await file.length();
    } catch (_) {}
    return 0;
  }

  static Future<int> _directorySize(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) return 0;
      var total = 0;
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> _clearDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) return;
      await for (final entity in directory.list(followLinks: false)) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Removes nested paths so parent directories are counted only once.
  static List<String> _uniqueRoots(Iterable<String> paths) {
    final normalized =
        paths
            .where((path) => path.isNotEmpty)
            .map((path) => path.replaceAll('\\', '/'))
            .toSet()
            .toList()
          ..sort((a, b) => a.length.compareTo(b.length));

    final roots = <String>[];
    for (final path in normalized) {
      final alreadyCovered = roots.any((root) => _isSameOrNested(path, root));
      if (!alreadyCovered) roots.add(path);
    }
    return roots;
  }

  static bool _isSameOrNested(String inner, String outer) {
    final a = inner.replaceAll('\\', '/');
    final b = outer.replaceAll('\\', '/');
    return a == b || a.startsWith('$b/');
  }

  static Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }
}

String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  if (bytes < 1024) return '$bytes B';
  const units = <String>['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var index = 0;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[index]}';
}
