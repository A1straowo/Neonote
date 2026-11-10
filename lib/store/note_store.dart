// ignore_for_file: unnecessary_import

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/store/mutation_queue.dart';

const String neonoteBoxName = 'HiveThemeBox';

class NoteKeys {
  static const String tags = 'note_tags';
  static const String components = 'note_components';
  static const String groups = 'mo_groups';
  static const String groupsInitialized = 'mo_groups_initialized';
  static const String chats = 'mo_chats';
  static const String aiConversations = 'ai_conversations';

  static String messages(String chatId) => 'mo_messages_$chatId';
}

String _asString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  final text = value.toString();
  return text;
}

Map<String, String> _asStringMap(Object? value) {
  if (value is! Map) return const <String, String>{};
  return <String, String>{
    for (final entry in value.entries)
      if (entry.value?.toString().trim().isNotEmpty ?? false)
        entry.key.toString(): entry.value.toString().trim(),
  };
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool _asBool(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == 'true';
  return fallback;
}

// PERF: Hive returns the same in-memory value until a key is rewritten.
// Cache both the source identity and the normalized map list. The identity
// check also keeps the cache correct when tests or migrations clear the box
// directly instead of going through NoteStore.
final Map<String, Object?> _perfMapListSource = <String, Object?>{};
final Map<String, List<Map<String, dynamic>>> _perfMapListCache =
    <String, List<Map<String, dynamic>>>{};
final Map<String, Object?> _perfModelListSource = <String, Object?>{};
final Map<String, Object?> _perfModelListCache = <String, Object?>{};

void _invalidateMapListCache(String key) {
  _perfMapListSource.remove(key);
  _perfMapListCache.remove(key);
  _perfModelListSource.remove(key);
  _perfModelListCache.remove(key);
}

List<Map<String, dynamic>> _readMapListRaw(String key) {
  try {
    if (!Hive.isBoxOpen(neonoteBoxName)) return const <Map<String, dynamic>>[];
    final raw = Hive.box(neonoteBoxName).get(key);
    if (raw is! List) return const <Map<String, dynamic>>[];
    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        result.add(<String, dynamic>{
          for (final entry in item.entries) entry.key.toString(): entry.value,
        });
      }
    }
    return result;
  } catch (_) {
    return const <Map<String, dynamic>>[];
  }
}

List<Map<String, dynamic>> _readMapList(String key) {
  try {
    if (!Hive.isBoxOpen(neonoteBoxName)) {
      _invalidateMapListCache(key);
      return const <Map<String, dynamic>>[];
    }
    final raw = Hive.box(neonoteBoxName).get(key);
    if (_perfMapListSource.containsKey(key) &&
        identical(_perfMapListSource[key], raw)) {
      return _perfMapListCache[key] ?? const <Map<String, dynamic>>[];
    }
    final loaded = _readMapListRaw(key);
    _perfMapListSource[key] = raw;
    _perfMapListCache[key] = loaded;
    _perfModelListSource.remove(key);
    _perfModelListCache.remove(key);
    return loaded;
  } catch (_) {
    return const <Map<String, dynamic>>[];
  }
}

/// Parses a collection once per underlying Hive value instead of rebuilding
/// every model on every widget/build notification.
List<T> _readModelList<T>(
  String key,
  T Function(Map<String, dynamic>) fromMap,
) {
  try {
    if (!Hive.isBoxOpen(neonoteBoxName)) {
      _invalidateMapListCache(key);
      return <T>[];
    }
    final raw = Hive.box(neonoteBoxName).get(key);
    if (_perfModelListSource.containsKey(key) &&
        identical(_perfModelListSource[key], raw)) {
      final cached = _perfModelListCache[key];
      if (cached is List<T>) return cached;
    }
    final loaded = _readMapList(key).map(fromMap).toList();
    _perfModelListSource[key] = raw;
    _perfModelListCache[key] = loaded;
    return loaded;
  } catch (_) {
    return <T>[];
  }
}

Future<void> _write(String key, Object? value) async {
  // Invalidate before the await so a failing write cannot leave stale data.
  _invalidateMapListCache(key);
  try {
    if (!Hive.isBoxOpen(neonoteBoxName)) {
      throw StateError('Hive box $neonoteBoxName is not open');
    }
    await Hive.box(neonoteBoxName).put(key, value);
    NoteStore.lastWriteError.value = null;
  } catch (error, stack) {
    NoteStore.lastWriteError.value = error;
    debugPrint('NoteStore write failed for "$key": $error\n$stack');
    rethrow;
  } finally {
    _invalidateMapListCache(key);
  }
}

enum NoteComponentType { text, checklist, drawing, image, audio }

NoteComponentType noteComponentTypeFrom(Object? value) {
  final name = _asString(value);
  for (final type in NoteComponentType.values) {
    if (type.name == name) return type;
  }
  return NoteComponentType.text;
}

class ChecklistItem {
  ChecklistItem({String? id, this.text = '', this.done = false})
    : id = id ?? NoteStore.newId();

  final String id;
  String text;
  bool done;

  Map<String, dynamic> toMap() => {'id': id, 'text': text, 'done': done};

  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
    id: _asString(map['id']).isEmpty ? null : _asString(map['id']),
    text: _asString(map['text']),
    done: _asBool(map['done']),
  );
}

enum NoteTextBlockKind { paragraph, checklist, divider, image, audio, drawing }

/// A single editable sentence/line in a text note.
///
/// Formatting is stored per block so the secondary text toolbar only changes
/// the sentence that currently owns the caret.
class NoteTextBlock {
  NoteTextBlock({
    String? id,
    this.kind = NoteTextBlockKind.paragraph,
    this.text = '',
    this.done = false,
    this.mediaPath = '',
    List<DrawingStroke>? strokes,
    this.fontSize = 0,
    this.color = 0,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.alignment = 'left',
  }) : id = id ?? NoteStore.newId(),
       drawingStrokes = strokes ?? <DrawingStroke>[];

  final String id;
  NoteTextBlockKind kind;
  String text;
  bool done;
  String mediaPath;
  List<DrawingStroke> drawingStrokes;
  double fontSize;
  int color;
  bool bold;
  bool italic;
  bool underline;
  bool strikethrough;
  String alignment;

  String get plainText => switch (kind) {
    NoteTextBlockKind.paragraph => text,
    NoteTextBlockKind.checklist => '${done ? '☑' : '☐'} $text',
    NoteTextBlockKind.divider => '────────',
    NoteTextBlockKind.image => '[图片]',
    NoteTextBlockKind.audio => '[语音]',
    NoteTextBlockKind.drawing => '[绘图]',
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind.name,
    'text': text,
    'done': done,
    'media_path': mediaPath,
    'drawing_strokes': [for (final stroke in drawingStrokes) stroke.toMap()],
    'font_size': fontSize,
    'color': color,
    'bold': bold,
    'italic': italic,
    'underline': underline,
    'strikethrough': strikethrough,
    'alignment': alignment,
  };

  factory NoteTextBlock.fromMap(Map<String, dynamic> map) {
    final kindName = _asString(map['kind'], NoteTextBlockKind.paragraph.name);
    final kind = NoteTextBlockKind.values.firstWhere(
      (value) => value.name == kindName,
      orElse: () => NoteTextBlockKind.paragraph,
    );
    final alignment = _asString(map['alignment'], 'left');
    final rawStrokes = map['drawing_strokes'];
    return NoteTextBlock(
      id: _asString(map['id']).isEmpty ? null : _asString(map['id']),
      kind: kind,
      text: _asString(map['text']),
      done: _asBool(map['done']),
      mediaPath: _asString(map['media_path']),
      strokes: rawStrokes is List
          ? rawStrokes
                .whereType<Map>()
                .map(
                  (item) => DrawingStroke.fromMap(<String, dynamic>{
                    for (final entry in item.entries)
                      entry.key.toString(): entry.value,
                  }),
                )
                .toList()
          : <DrawingStroke>[],
      fontSize: _asDouble(map['font_size']),
      color: _asInt(map['color']),
      bold: _asBool(map['bold']),
      italic: _asBool(map['italic']),
      underline: _asBool(map['underline']),
      strikethrough: _asBool(map['strikethrough']),
      alignment: const {'left', 'center', 'right'}.contains(alignment)
          ? alignment
          : 'left',
    );
  }
}

class DrawingStroke {
  DrawingStroke({required this.points, required this.color, this.width = 4});

  List<Offset> points;
  int color;
  double width;

  Map<String, dynamic> toMap() => {
    'c': color,
    'w': width,
    'p': [
      for (final point in points) ...[point.dx, point.dy],
    ],
  };

  factory DrawingStroke.fromMap(Map<String, dynamic> map) {
    final points = <Offset>[];
    final raw = map['p'];
    if (raw is List) {
      for (var i = 0; i + 1 < raw.length; i += 2) {
        points.add(Offset(_asDouble(raw[i]), _asDouble(raw[i + 1])));
      }
    }
    return DrawingStroke(
      points: points,
      color: _asInt(map['c'], 0xFF4C5B70),
      width: _asDouble(map['w'], 4),
    );
  }
}

class NoteComponent {
  NoteComponent({
    required this.id,
    required this.type,
    this.title = '',
    this.text = '',
    this.url = '',
    this.pinned = false,
    this.archived = false,
    this.marked = false,
    this.textColor = 0,
    this.textSize = 0,
    this.textBold = false,
    this.textBackgroundType = 'none',
    this.textBackgroundColor = 0,
    this.textBackgroundImage = '',
    this.drawingBackgroundStyle = 'grid',
    List<NoteTextBlock>? textBlocks,
    List<ChecklistItem>? items,
    List<DrawingStroke>? strokes,
    List<String>? tagIds,
  }) : textBlocks = textBlocks ?? <NoteTextBlock>[],
       items = items ?? <ChecklistItem>[],
       strokes = strokes ?? <DrawingStroke>[],
       tagIds = tagIds ?? <String>[];

  final String id;
  NoteComponentType type;
  String title;
  String text;
  String url;

  bool pinned;
  bool archived;
  bool marked;
  List<String> tagIds;

  // Text component presentation. Zero/False means "use the current theme".
  int textColor;
  double textSize;
  bool textBold;

  /// Background of the text workbench: none, color, grid_square, grid_dots,
  /// grid_lines or image.
  String textBackgroundType;
  int textBackgroundColor;
  String textBackgroundImage;

  /// Background style for drawing components: grid, dots or none.
  String drawingBackgroundStyle;

  /// Structured lines used by the rich text workbench. [text] remains the
  /// canonical plain-text preview for cards, search and AI insertion.
  List<NoteTextBlock> textBlocks;

  List<ChecklistItem> items;
  List<DrawingStroke> strokes;

  /// All images attached to this component. Image notes store their gallery in
  /// text blocks so older components with only [url] remain readable.
  List<String> get imagePaths {
    final paths = textBlocks
        .where(
          (block) =>
              block.kind == NoteTextBlockKind.image &&
              block.mediaPath.trim().isNotEmpty,
        )
        .map((block) => block.mediaPath)
        .toList(growable: false);
    if (paths.isNotEmpty) return List<String>.unmodifiable(paths);
    return url.trim().isEmpty
        ? const <String>[]
        : List<String>.unmodifiable(<String>[url]);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    'text': text,
    'url': url,
    'pinned': pinned,
    'archived': archived,
    'marked': marked,
    'tag_ids': tagIds,
    'text_color': textColor,
    'text_size': textSize,
    'text_bold': textBold,
    'text_background_type': textBackgroundType,
    'text_background_color': textBackgroundColor,
    'text_background_image': textBackgroundImage,
    'drawing_background_style': drawingBackgroundStyle,
    'text_blocks': [for (final block in textBlocks) block.toMap()],
    'items': [for (final item in items) item.toMap()],
    'strokes': [for (final stroke in strokes) stroke.toMap()],
  };

  factory NoteComponent.fromMap(Map<String, dynamic> map) {
    final rawTextBlocks = map['text_blocks'];
    final rawItems = map['items'];
    final rawStrokes = map['strokes'];
    final rawTagIds = map['tag_ids'];
    return NoteComponent(
      id: _asString(map['id']),
      type: noteComponentTypeFrom(map['type']),
      title: _asString(map['title']),
      text: _asString(map['text']),
      url: _asString(map['url']),
      pinned: _asBool(map['pinned']),
      archived: _asBool(map['archived']),
      marked: _asBool(map['marked']),
      textColor: _asInt(map['text_color']),
      textSize: _asDouble(map['text_size']),
      textBold: _asBool(map['text_bold']),
      textBackgroundType: _asString(map['text_background_type'], 'none'),
      textBackgroundColor: _asInt(map['text_background_color']),
      textBackgroundImage: _asString(map['text_background_image']),
      drawingBackgroundStyle:
          const {
            'grid',
            'dots',
            'none',
          }.contains(_asString(map['drawing_background_style'], 'grid'))
          ? _asString(map['drawing_background_style'], 'grid')
          : 'grid',
      textBlocks: rawTextBlocks is List
          ? rawTextBlocks
                .whereType<Map>()
                .map(
                  (item) => NoteTextBlock.fromMap(<String, dynamic>{
                    for (final entry in item.entries)
                      entry.key.toString(): entry.value,
                  }),
                )
                .toList()
          : <NoteTextBlock>[],
      tagIds: rawTagIds is List
          ? rawTagIds.map((e) => e.toString()).toList()
          : <String>[],
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => ChecklistItem.fromMap(<String, dynamic>{
                    for (final entry in item.entries)
                      entry.key.toString(): entry.value,
                  }),
                )
                .toList()
          : <ChecklistItem>[],
      strokes: rawStrokes is List
          ? rawStrokes
                .whereType<Map>()
                .map(
                  (item) => DrawingStroke.fromMap(<String, dynamic>{
                    for (final entry in item.entries)
                      entry.key.toString(): entry.value,
                  }),
                )
                .toList()
          : <DrawingStroke>[],
    );
  }
}

class NoteTag {
  NoteTag({required this.id, required this.name, required this.createdAt});

  final String id;
  String name;
  final int createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt,
  };

  factory NoteTag.fromMap(Map<String, dynamic> map) => NoteTag(
    id: _asString(map['id']),
    name: _asString(map['name']),
    createdAt: _asInt(map['created_at']),
  );
}

class MoGroup {
  MoGroup({
    required this.id,
    this.name = '',
    required this.createdAt,
    this.isDefault = false,
    this.expanded = false,
  });

  final String id;
  String name;
  final int createdAt;
  bool isDefault;
  bool expanded;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt,
    'is_default': isDefault,
    'expanded': expanded,
  };

  factory MoGroup.fromMap(Map<String, dynamic> map) => MoGroup(
    id: _asString(map['id']),
    name: _asString(map['name']),
    createdAt: _asInt(map['created_at']),
    isDefault: _asBool(map['is_default']),
    expanded: _asBool(map['expanded']),
  );
}

class MoChat {
  MoChat({
    required this.id,
    required this.groupId,
    required this.name,
    this.avatarUrl = '',
    this.lastMessage = '',
    this.studentId = 0,
    this.familyName = '',
    this.givenName = '',
    this.familyNames = const <String, String>{},
    this.givenNames = const <String, String>{},
    this.fullNames = const <String, String>{},
    this.pinned = false,
    this.archived = false,
    this.marked = false,
    required this.updatedAt,
  });

  final String id;
  String groupId;
  String name;
  String avatarUrl;
  String lastMessage;
  int studentId;
  String familyName;
  String givenName;
  Map<String, String> familyNames;
  Map<String, String> givenNames;
  Map<String, String> fullNames;

  String get displayName => studentDisplayName(
    fullName: name,
    familyName: familyName,
    givenName: givenName,
    familyNames: familyNames,
    givenNames: givenNames,
    fullNames: fullNames,
  );

  bool pinned;
  bool archived;
  bool marked;

  int updatedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'group_id': groupId,
    'name': name,
    'avatar_url': avatarUrl,
    'last_message': lastMessage,
    'student_id': studentId,
    'family_name': familyName,
    'given_name': givenName,
    'family_names': familyNames,
    'given_names': givenNames,
    'full_names': fullNames,
    'pinned': pinned,
    'archived': archived,
    'marked': marked,
    'updated_at': updatedAt,
  };

  factory MoChat.fromMap(Map<String, dynamic> map) => MoChat(
    id: _asString(map['id']),
    groupId: _asString(map['group_id']),
    name: _asString(map['name']),
    avatarUrl: _asString(map['avatar_url']),
    lastMessage: _asString(map['last_message']),
    studentId: _asInt(map['student_id']),
    familyName: _asString(map['family_name']),
    givenName: _asString(map['given_name']),
    familyNames: _asStringMap(map['family_names']),
    givenNames: _asStringMap(map['given_names']),
    fullNames: _asStringMap(map['full_names']),
    pinned: _asBool(map['pinned']),
    archived: _asBool(map['archived']),
    marked: _asBool(map['marked']),
    updatedAt: _asInt(map['updated_at']),
  );
}

class MoMessage {
  MoMessage({
    required this.id,
    required this.text,
    required this.isTeacher,
    required this.createdAt,
    this.imageUrl = '',
    this.kind = 'text',
  });

  final String id;
  String text;
  bool isTeacher;
  final int createdAt;
  String imageUrl;
  String kind;

  bool get hasImage => imageUrl.trim().isNotEmpty;
  bool get isStudentExpression => kind == 'student_expression';

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'is_teacher': isTeacher,
    'created_at': createdAt,
    'image_url': imageUrl,
    'kind': kind,
  };

  factory MoMessage.fromMap(Map<String, dynamic> map) => MoMessage(
    id: _asString(map['id']),
    text: _asString(map['text']),
    isTeacher: _asBool(map['is_teacher']),
    createdAt: _asInt(map['created_at']),
    imageUrl: _asString(map['image_url']),
    kind: _asString(map['kind'], 'text'),
  );
}

class AiConversationMessage {
  AiConversationMessage({
    required this.role,
    required this.content,
    List<String>? imagePaths,
    List<String>? audioPaths,
  }) : imagePaths = imagePaths ?? <String>[],
       audioPaths = audioPaths ?? <String>[];

  String role;
  String content;
  List<String> imagePaths;
  List<String> audioPaths;

  Map<String, dynamic> toMap() => {
    'role': role,
    'content': content,
    'image_paths': imagePaths,
    'audio_paths': audioPaths,
  };

  factory AiConversationMessage.fromMap(Map<String, dynamic> map) {
    List<String> strings(Object? value) => value is List
        ? value.map((item) => item.toString()).toList()
        : <String>[];
    return AiConversationMessage(
      role: _asString(map['role'], 'user'),
      content: _asString(map['content']),
      imagePaths: strings(map['image_paths']),
      audioPaths: strings(map['audio_paths']),
    );
  }
}

class AiConversation {
  AiConversation({
    String? id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<AiConversationMessage>? messages,
  }) : id = id ?? NoteStore.newId(),
       messages = messages ?? <AiConversationMessage>[];

  final String id;
  String title;
  final int createdAt;
  int updatedAt;
  List<AiConversationMessage> messages;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'messages': [for (final message in messages) message.toMap()],
  };

  factory AiConversation.fromMap(Map<String, dynamic> map) {
    final rawMessages = map['messages'];
    return AiConversation(
      id: _asString(map['id']).isEmpty ? null : _asString(map['id']),
      title: _asString(map['title'], '新对话'),
      createdAt: _asInt(map['created_at']),
      updatedAt: _asInt(map['updated_at']),
      messages: rawMessages is List
          ? rawMessages
                .whereType<Map>()
                .map(
                  (item) => AiConversationMessage.fromMap(<String, dynamic>{
                    for (final entry in item.entries)
                      entry.key.toString(): entry.value,
                  }),
                )
                .toList()
          : <AiConversationMessage>[],
    );
  }
}

class NoteStore {
  NoteStore._();

  static final MutationQueue _mutationQueue = MutationQueue();
  static final ValueNotifier<Object?> lastWriteError = ValueNotifier<Object?>(
    null,
  );
  static final Object _mutationZoneKey = Object();

  /// Serializes read-modify-write operations. Reentrant calls from inside a
  /// queued mutation execute directly instead of deadlocking on the queue.
  static Future<T> _mutate<T>(Future<T> Function() action) {
    if (Zone.current[_mutationZoneKey] == true) {
      return Future<T>.sync(action);
    }
    return _mutationQueue.run(
      () => runZoned(
        action,
        zoneValues: <Object, Object>{_mutationZoneKey: true},
      ),
    );
  }

  /// Aggregate revision retained for compatibility and consumers that need
  /// to observe every store domain.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static final ValueNotifier<int> notesRevision = ValueNotifier<int>(0);
  static final ValueNotifier<int> tagsRevision = ValueNotifier<int>(0);
  static final ValueNotifier<int> chatsRevision = ValueNotifier<int>(0);
  static final ValueNotifier<int> aiRevision = ValueNotifier<int>(0);

  static Timer? _perfBumpTimer;
  static final Set<ValueNotifier<int>> _pendingBumps = <ValueNotifier<int>>{};

  // PERF HOTFIX: coalesce a burst of store writes into at most one
  // notification per domain per frame. Pages no longer rebuild for writes to
  // unrelated collections.
  static void _bump([ValueNotifier<int>? domain]) {
    _pendingBumps.add(revision);
    if (domain != null) _pendingBumps.add(domain);
    _perfBumpTimer?.cancel();
    _perfBumpTimer = Timer(const Duration(milliseconds: 16), () {
      _perfBumpTimer = null;
      final pending = List<ValueNotifier<int>>.of(_pendingBumps);
      _pendingBumps.clear();
      for (final notifier in pending) {
        notifier.value = notifier.value + 1;
      }
    });
  }

  static String newId() {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final salt = math.Random().nextInt(1 << 22);
    return '${stamp}_$salt';
  }

  static int getInt(String key, int fallback) {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return fallback;
      return _asInt(Hive.box(neonoteBoxName).get(key), fallback);
    } catch (_) {
      return fallback;
    }
  }

  static double getDouble(String key, double fallback) {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return fallback;
      return _asDouble(Hive.box(neonoteBoxName).get(key), fallback);
    } catch (_) {
      return fallback;
    }
  }

  static String getString(String key, String fallback) {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return fallback;
      return _asString(Hive.box(neonoteBoxName).get(key), fallback);
    } catch (_) {
      return fallback;
    }
  }

  static List<NoteTag> tags() => _readModelList(NoteKeys.tags, NoteTag.fromMap);

  static Future<void> _saveTags(List<NoteTag> tags) async {
    await _write(NoteKeys.tags, [for (final tag in tags) tag.toMap()]);
    _bump(tagsRevision);
  }

  static Future<NoteTag> addTag(String name) {
    return _mutate(() async {
      final tags = NoteStore.tags();
      final tag = NoteTag(
        id: newId(),
        name: name.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      tags.add(tag);
      await _saveTags(tags);
      return tag;
    });
  }

  static Future<void> renameTag(String id, String name) {
    return _mutate(() async {
      final tags = NoteStore.tags();
      for (final tag in tags) {
        if (tag.id == id) tag.name = name.trim();
      }
      await _saveTags(tags);
    });
  }

  static Future<void> deleteTag(String id) {
    return _mutate(() async {
      final tags = NoteStore.tags()..removeWhere((tag) => tag.id == id);
      await _saveTags(tags);
    });
  }

  static List<NoteComponent> components() =>
      _readModelList(NoteKeys.components, NoteComponent.fromMap);

  static Future<void> saveComponents(
    List<NoteComponent> components, {
    bool bump = false,
  }) {
    return _mutate(() async {
      await _write(NoteKeys.components, [
        for (final component in components) component.toMap(),
      ]);
      if (bump) _bump(notesRevision);
    });
  }

  static Future<NoteComponent> addComponent(NoteComponentType type) async {
    final component = NoteComponent(id: newId(), type: type);
    if (type == NoteComponentType.checklist) {
      component.items.add(ChecklistItem());
    }
    await saveComponent(component, bump: true);
    return component;
  }

  static Future<void> saveComponent(
    NoteComponent component, {
    bool bump = false,
  }) {
    return _mutate(() async {
      final maps = List<Map<String, dynamic>>.of(
        _readMapList(NoteKeys.components),
      );
      final mapIndex = maps.indexWhere((entry) => entry['id'] == component.id);
      final serialized = component.toMap();
      if (mapIndex == -1) {
        maps.add(serialized);
      } else {
        maps[mapIndex] = serialized;
      }
      await _write(NoteKeys.components, maps);
      if (bump) _bump(notesRevision);
    });
  }

  static Future<void> removeComponent(String id) {
    return _mutate(() async {
      final components = NoteStore.components()
        ..removeWhere((component) => component.id == id);
      await saveComponents(components, bump: true);
    });
  }

  static const String defaultGroupKey = 'mo_default_group';

  static bool _groupsInitialized() {
    try {
      if (!Hive.isBoxOpen(neonoteBoxName)) return false;
      return _asBool(Hive.box(neonoteBoxName).get(NoteKeys.groupsInitialized));
    } catch (_) {
      return false;
    }
  }

  static List<MoGroup> _groups({required bool seed}) {
    final groups = _readModelList(NoteKeys.groups, MoGroup.fromMap);
    if (groups.isEmpty && seed && !_groupsInitialized()) {
      return <MoGroup>[
        MoGroup(
          id: defaultGroupKey,
          name: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          isDefault: true,
          expanded: true,
        ),
      ];
    }
    return groups;
  }

  static List<MoGroup> groups() => _groups(seed: true);

  static Future<void> _saveGroups(List<MoGroup> groups) async {
    await _write(NoteKeys.groups, [for (final group in groups) group.toMap()]);
    await _write(NoteKeys.groupsInitialized, true);
    _bump(chatsRevision);
  }

  static Future<void> ensureGroups() {
    return _mutate(() async {
      final stored = _readMapList(NoteKeys.groups);
      if (stored.isEmpty && !_groupsInitialized()) {
        await _saveGroups(_groups(seed: true));
      }
    });
  }

  static Future<MoGroup> addGroup(String name) {
    return _mutate(() async {
      final all = groups();
      final group = MoGroup(
        id: newId(),
        name: name.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        expanded: true,
      );
      all.add(group);
      await _saveGroups(all);
      return group;
    });
  }

  static Future<void> renameGroup(String id, String name) {
    return _mutate(() async {
      final all = groups();
      for (final group in all) {
        if (group.id == id) group.name = name.trim();
      }
      await _saveGroups(all);
    });
  }

  static Future<void> deleteGroup(String id) {
    return _mutate(() async {
      final all = groups()..removeWhere((group) => group.id == id);
      final chats = NoteStore.chats()
        ..removeWhere((chat) => chat.groupId == id);
      await _saveGroups(all);
      await _saveChats(chats, bump: false);
      _bump(chatsRevision);
    });
  }

  static Future<void> setGroupExpanded(String id, bool expanded) {
    return _mutate(() async {
      final all = groups();
      for (final group in all) {
        if (group.id == id) group.expanded = expanded;
      }
      await _saveGroups(all);
    });
  }

  static List<MoChat> chats() => _readModelList(NoteKeys.chats, MoChat.fromMap);

  static Future<void> _saveChats(List<MoChat> chats, {bool bump = true}) async {
    await _write(NoteKeys.chats, [for (final chat in chats) chat.toMap()]);
    if (bump) _bump(chatsRevision);
  }

  static Future<MoChat> addChat({
    required String groupId,
    required String name,
    String avatarUrl = '',
    int studentId = 0,
    String familyName = '',
    String givenName = '',
    Map<String, String> familyNames = const <String, String>{},
    Map<String, String> givenNames = const <String, String>{},
    Map<String, String> fullNames = const <String, String>{},
  }) {
    return _mutate(() async {
      final chats = NoteStore.chats();
      final chat = MoChat(
        id: newId(),
        groupId: groupId,
        name: name.trim(),
        avatarUrl: avatarUrl.trim(),
        studentId: studentId,
        familyName: familyName.trim(),
        givenName: givenName.trim(),
        familyNames: Map<String, String>.from(familyNames),
        givenNames: Map<String, String>.from(givenNames),
        fullNames: Map<String, String>.from(fullNames),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      chats.add(chat);
      await _saveChats(chats);
      return chat;
    });
  }

  static Future<void> deleteChat(String id) {
    return _mutate(() async {
      final chats = NoteStore.chats()..removeWhere((chat) => chat.id == id);
      await _saveChats(chats);
    });
  }

  static Future<void> touchChat(String id, String lastMessage) {
    return _mutate(() async {
      final chats = NoteStore.chats();
      for (final chat in chats) {
        if (chat.id == id) {
          chat.lastMessage = lastMessage;
          chat.updatedAt = DateTime.now().millisecondsSinceEpoch;
        }
      }
      await _saveChats(chats);
    });
  }

  static String defaultGroupId() {
    final all = groups();
    for (final group in all) {
      if (group.isDefault) return group.id;
    }
    return all.isEmpty ? defaultGroupKey : all.first.id;
  }

  static List<MoMessage> messages(String chatId) =>
      _readModelList(NoteKeys.messages(chatId), MoMessage.fromMap);

  static Future<void> addMessage({
    required String chatId,
    required String text,
    required bool isTeacher,
    String imageUrl = '',
    String kind = 'text',
  }) {
    return _mutate(() async {
      final messages = NoteStore.messages(chatId);
      messages.add(
        MoMessage(
          id: newId(),
          text: text,
          isTeacher: isTeacher,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          imageUrl: imageUrl,
          kind: kind,
        ),
      );
      await _write(NoteKeys.messages(chatId), [
        for (final message in messages) message.toMap(),
      ]);
      await touchChat(chatId, text.trim().isEmpty ? '[图片]' : text);
      _bump(chatsRevision);
    });
  }

  static Future<void> updateChatStudent(
    String id, {
    required String name,
    required String avatarUrl,
    required int studentId,
    String familyName = '',
    String givenName = '',
    Map<String, String> familyNames = const <String, String>{},
    Map<String, String> givenNames = const <String, String>{},
    Map<String, String> fullNames = const <String, String>{},
  }) {
    return _mutate(() async {
      final all = chats();
      final index = all.indexWhere((chat) => chat.id == id);
      if (index < 0) return;
      all[index].name = name.trim();
      all[index].avatarUrl = avatarUrl.trim();
      all[index].studentId = studentId;
      all[index].familyName = familyName.trim();
      all[index].givenName = givenName.trim();
      all[index].familyNames = Map<String, String>.from(familyNames);
      all[index].givenNames = Map<String, String>.from(givenNames);
      all[index].fullNames = Map<String, String>.from(fullNames);
      await _saveChats(all);
    });
  }

  static Future<void> replaceMessages(String chatId, List<MoMessage> messages) {
    return _mutate(() async {
      await _write(NoteKeys.messages(chatId), [
        for (final message in messages) message.toMap(),
      ]);
      if (messages.isEmpty) {
        await touchChat(chatId, '');
      } else {
        final last = messages.last;
        await touchChat(
          chatId,
          last.text.trim().isEmpty
              ? (last.imageUrl.trim().isEmpty ? '' : '[图片]')
              : last.text,
        );
      }
      _bump(chatsRevision);
    });
  }

  static Future<void> updateMessage({
    required String chatId,
    required String messageId,
    String? text,
    String? imageUrl,
    String? kind,
  }) {
    return _mutate(() async {
      final messages = NoteStore.messages(chatId);
      final index = messages.indexWhere((message) => message.id == messageId);
      if (index < 0) return;
      if (text != null) messages[index].text = text;
      if (imageUrl != null) messages[index].imageUrl = imageUrl;
      if (kind != null) messages[index].kind = kind;
      await replaceMessages(chatId, messages);
    });
  }

  static Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) {
    return _mutate(() async {
      final messages = NoteStore.messages(chatId)
        ..removeWhere((message) => message.id == messageId);
      await replaceMessages(chatId, messages);
    });
  }

  static List<AiConversation> aiConversations() {
    final conversations = _readModelList(
      NoteKeys.aiConversations,
      AiConversation.fromMap,
    );
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  static Future<void> saveAiConversation(AiConversation conversation) {
    return _mutate(() async {
      final conversations = aiConversations();
      final index = conversations.indexWhere(
        (item) => item.id == conversation.id,
      );
      if (index == -1) {
        conversations.add(conversation);
      } else {
        conversations[index] = conversation;
      }
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      await _write(NoteKeys.aiConversations, [
        for (final item in conversations) item.toMap(),
      ]);
      _bump(aiRevision);
    });
  }

  static Future<void> deleteAiConversation(String id) {
    return _mutate(() async {
      final conversations = aiConversations()
        ..removeWhere((item) => item.id == id);
      await _write(NoteKeys.aiConversations, [
        for (final item in conversations) item.toMap(),
      ]);
      _bump(aiRevision);
    });
  }

  static List<NoteComponent> activeComponents() =>
      components().where((c) => !c.archived).toList();

  static List<NoteComponent> archivedComponents() =>
      components().where((c) => c.archived).toList();

  static Future<void> setPinned(String id, bool pinned) {
    return _mutate(() async {
      final all = components();
      final index = all.indexWhere((c) => c.id == id);
      if (index < 0) return;
      all[index].pinned = pinned;
      await saveComponent(all[index], bump: true);
    });
  }

  static Future<void> setArchived(String id, bool archived) {
    return _mutate(() async {
      final all = components();
      final index = all.indexWhere((c) => c.id == id);
      if (index < 0) return;
      all[index].archived = archived;
      await saveComponent(all[index], bump: true);
    });
  }

  static Future<void> setMarked(String id, bool marked) {
    return _mutate(() async {
      final all = components();
      final index = all.indexWhere((c) => c.id == id);
      if (index < 0) return;
      all[index].marked = marked;
      await saveComponent(all[index], bump: true);
    });
  }

  static Future<void> setTags(String id, List<String> tagIds) {
    return _mutate(() async {
      final all = components();
      final index = all.indexWhere((c) => c.id == id);
      if (index < 0) return;
      all[index].tagIds = List<String>.from(tagIds);
      await saveComponent(all[index], bump: true);
    });
  }

  static List<MoChat> activeChats() =>
      chats().where((chat) => !chat.archived).toList();

  static List<MoChat> archivedChats() =>
      chats().where((chat) => chat.archived).toList();

  static Future<void> setChatPinned(String id, bool pinned) {
    return _mutate(() async {
      final all = chats();
      final index = all.indexWhere((chat) => chat.id == id);
      if (index < 0) return;
      all[index].pinned = pinned;
      await _saveChats(all);
    });
  }

  static Future<void> setChatArchived(String id, bool archived) {
    return _mutate(() async {
      final all = chats();
      final index = all.indexWhere((chat) => chat.id == id);
      if (index < 0) return;
      all[index].archived = archived;
      await _saveChats(all);
    });
  }

  static Future<void> setChatMarked(String id, bool marked) {
    return _mutate(() async {
      final all = chats();
      final index = all.indexWhere((chat) => chat.id == id);
      if (index < 0) return;
      all[index].marked = marked;
      await _saveChats(all);
    });
  }
}

bool _studentNameSetting(String key, bool fallback) {
  try {
    if (!Hive.isBoxOpen(neonoteBoxName)) return fallback;
    return _asBool(Hive.box(neonoteBoxName).get(key), fallback);
  } catch (_) {
    return fallback;
  }
}

/// Formats a student name according to the MomoTalk character settings.
///
/// The API exposes family and given names separately. Custom students and old
/// cached records that only have a full name gracefully fall back to it.
String _studentNameLanguage() {
  try {
    if (!Hive.isBoxOpen(neonoteBoxName)) return 'zh';
    final box = Hive.box(neonoteBoxName);
    final stored = _asString(box.get('mochar_nameLanguage'));
    if (stored.isNotEmpty) return stored;
    final locale = _asString(box.get('localeCode'), 'zh');
    return locale.isEmpty ? 'zh' : locale;
  } catch (_) {
    return 'zh';
  }
}

String _localizedStudentNamePart(String base, Map<String, String>? variants) {
  final language = _studentNameLanguage();
  final localized = variants?[language]?.trim() ?? '';
  return localized.isNotEmpty ? localized : base.trim();
}

String studentDisplayName({
  required String fullName,
  String familyName = '',
  String givenName = '',
  Map<String, String>? familyNames,
  Map<String, String>? givenNames,
  Map<String, String>? fullNames,
}) {
  final full = _localizedStudentNamePart(fullName, fullNames);
  final family = _localizedStudentNamePart(familyName, familyNames);
  final given = _localizedStudentNamePart(givenName, givenNames);
  if (family.isEmpty && given.isEmpty) return full;
  final showSurname = _studentNameSetting('mochar_showSurname', true);
  final reverse = _studentNameSetting('mochar_reverseName', false);
  if (!showSurname) return given.isNotEmpty ? given : full;
  if (reverse) {
    return [given, family].where((part) => part.isNotEmpty).join();
  }
  return [family, given].where((part) => part.isNotEmpty).join();
}
