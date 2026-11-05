import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Local export/backup helpers.
///
/// Neonote currently has no export, import or backup path. If the app is
/// uninstalled or its data is cleared, every note, chat and AI conversation is
/// lost. These helpers provide a minimal, dependency-light escape hatch:
/// Markdown for humans and JSON for a future restore flow.
abstract final class NoteExportService {
  static const int backupSchemaVersion = 1;

  static String buildMarkdown(
    Iterable<Map<String, dynamic>> components, {
    String title = 'Neonote export',
    DateTime? exportedAt,
  }) {
    final buffer = StringBuffer()
      ..writeln('# $title')
      ..writeln()
      ..writeln(
        '_Exported ${(exportedAt ?? DateTime.now()).toIso8601String()}_',
      )
      ..writeln();

    for (final component in components) {
      final componentTitle = (component['title']?.toString() ?? '').trim();
      if (componentTitle.isNotEmpty) {
        buffer
          ..writeln('## $componentTitle')
          ..writeln();
      }

      final type = component['type']?.toString() ?? 'text';
      switch (type) {
        case 'checklist':
          final items = component['items'];
          if (items is Iterable) {
            for (final item in items) {
              if (item is Map) {
                final done = item['done'] == true;
                final text = item['text']?.toString() ?? '';
                buffer.writeln('- [${done ? 'x' : ' '}] $text');
              }
            }
          }
          buffer.writeln();
          break;
        case 'drawing':
          final strokes = component['strokes'] ?? component['drawing_strokes'];
          final count = strokes is Iterable ? strokes.length : 0;
          buffer
            ..writeln('> Drawing ($count stroke${count == 1 ? '' : 's'})')
            ..writeln();
          break;
        case 'image':
          final paths = <String>[];
          final blocks = component['text_blocks'];
          if (blocks is Iterable) {
            for (final block in blocks) {
              if (block is Map &&
                  block['kind']?.toString() == 'image' &&
                  (block['media_path']?.toString() ?? '').trim().isNotEmpty) {
                paths.add(block['media_path'].toString());
              }
            }
          }
          if (paths.isEmpty) {
            final url = component['url']?.toString() ?? '';
            if (url.trim().isNotEmpty) paths.add(url);
          }
          if (paths.isEmpty) {
            buffer.writeln('> Image');
          } else {
            for (final path in paths) {
              buffer.writeln('![Image]($path)');
            }
          }
          buffer.writeln();
          break;
        case 'audio':
          final path = component['media_path']?.toString() ?? '';
          buffer
            ..writeln(path.isEmpty ? '> Audio recording' : '> Audio: `$path`')
            ..writeln();
          break;
        default:
          final text = _componentText(component);
          if (text.isNotEmpty) {
            buffer
              ..writeln(text)
              ..writeln();
          }
      }
    }

    return '${buffer.toString().trimRight()}\n';
  }

  static String buildBackupJson({
    required Iterable<Map<String, dynamic>> components,
    Iterable<Map<String, dynamic>> tags = const <Map<String, dynamic>>[],
    Iterable<Map<String, dynamic>> chats = const <Map<String, dynamic>>[],
    Iterable<Map<String, dynamic>> aiConversations =
        const <Map<String, dynamic>>[],
    DateTime? exportedAt,
  }) {
    return const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'schemaVersion': backupSchemaVersion,
      'app': 'Neonote',
      'exportedAt': (exportedAt ?? DateTime.now()).toIso8601String(),
      'components': components.toList(growable: false),
      'tags': tags.toList(growable: false),
      'chats': chats.toList(growable: false),
      'aiConversations': aiConversations.toList(growable: false),
    });
  }

  static Future<void> copyMarkdownToClipboard(
    Iterable<Map<String, dynamic>> components, {
    String title = 'Neonote export',
  }) {
    return Clipboard.setData(
      ClipboardData(text: buildMarkdown(components, title: title)),
    );
  }

  static Future<File> saveMarkdownToFile(
    Iterable<Map<String, dynamic>> components, {
    String title = 'Neonote export',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File('${directory.path}/neonote-$timestamp.md');
    await file.writeAsString(buildMarkdown(components, title: title));
    return file;
  }

  static Future<File> saveBackupToFile({
    required Iterable<Map<String, dynamic>> components,
    Iterable<Map<String, dynamic>> tags = const <Map<String, dynamic>>[],
    Iterable<Map<String, dynamic>> chats = const <Map<String, dynamic>>[],
    Iterable<Map<String, dynamic>> aiConversations =
        const <Map<String, dynamic>>[],
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File('${directory.path}/neonote-backup-$timestamp.json');
    await file.writeAsString(
      buildBackupJson(
        components: components,
        tags: tags,
        chats: chats,
        aiConversations: aiConversations,
      ),
    );
    return file;
  }

  static String _componentText(Map<String, dynamic> component) {
    final parts = <String>[];
    void add(Object? value) {
      if (value is String && value.trim().isNotEmpty) parts.add(value.trim());
    }

    add(component['text']);
    final blocks = component['text_blocks'];
    if (blocks is Iterable) {
      for (final block in blocks) {
        if (block is Map) add(block['text']);
      }
    }
    return parts.join('\n\n');
  }
}
