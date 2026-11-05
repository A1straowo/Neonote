import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../ui/app_layout.dart';
import '../widgets/empty_state.dart';

/// A lightweight, serializable search row.
///
/// The editor currently has tag management but no way to search the content of
/// the note. This model intentionally depends only on `Map<String, dynamic>` and
/// not on the storage layer, so it can be used by the note page, the archive
/// page or a future multi-notebook page.
@immutable
class NoteSearchEntry {
  const NoteSearchEntry({
    required this.id,
    required this.title,
    required this.preview,
    required this.body,
    required this.type,
    required this.tags,
    this.payload,
  });

  final String id;
  final String title;
  final String preview;
  final String body;
  final String type;
  final List<String> tags;
  final Object? payload;

  factory NoteSearchEntry.fromMap(
    Map<String, dynamic> map, {
    Map<String, String> tagNames = const <String, String>{},
  }) {
    final rawBlocks = map['text_blocks'];
    final bodyParts = <String>[];
    _collectStrings(map['text'], bodyParts);
    _collectStrings(map['url'], bodyParts);
    if (rawBlocks is Iterable) {
      for (final block in rawBlocks) {
        if (block is Map) {
          _collectStrings(block['text'], bodyParts);
          final strokes = block['drawing_strokes'];
          if (strokes is Iterable && strokes.isNotEmpty) {
            bodyParts.add('drawing');
          }
        } else {
          _collectStrings(block, bodyParts);
        }
      }
    }
    final items = map['items'];
    if (items is Iterable) {
      for (final item in items) {
        if (item is Map) _collectStrings(item['text'], bodyParts);
      }
    }

    final rawTagIds = map['tag_ids'] ?? map['tags'];
    final tags = <String>[];
    if (rawTagIds is Iterable) {
      for (final rawTag in rawTagIds) {
        final id = rawTag?.toString() ?? '';
        if (id.isEmpty) continue;
        tags.add(tagNames[id] ?? id);
      }
    }

    final title = (map['title']?.toString() ?? '').trim();
    final body = bodyParts
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join('\n');
    final preview = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return NoteSearchEntry(
      id: map['id']?.toString() ?? '',
      title: title.isEmpty ? (tags.isEmpty ? '' : tags.first) : title,
      preview: preview,
      body: body,
      type: map['type']?.toString() ?? '',
      tags: List<String>.unmodifiable(tags),
      payload: map,
    );
  }

  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final needle = query.toLowerCase();
    return title.toLowerCase().contains(needle) ||
        body.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }

  static void _collectStrings(Object? value, List<String> target) {
    if (value == null) return;
    if (value is String) {
      if (value.trim().isNotEmpty) target.add(value);
      return;
    }
    if (value is Iterable) {
      for (final item in value) {
        _collectStrings(item, target);
      }
      return;
    }
    if (value is Map) {
      for (final item in value.values) {
        _collectStrings(item, target);
      }
    }
  }
}

/// Full-screen search with text, tag filters and highlighted matches.
///
/// Wrap this page in a `MaterialPageRoute` and pass entries created from
/// `NoteStore.activeComponents().map((e) => NoteSearchEntry.fromMap(e.toMap()))`.
class NoteSearchPage extends StatefulWidget {
  const NoteSearchPage({
    super.key,
    required this.entries,
    required this.onSelected,
    this.title = 'Search',
    this.hint = 'Search notes, tags and content',
    this.emptyTitle = 'Start typing to search',
    this.emptyMessage = 'Search titles, body text, checklist items and tags.',
    this.noResultsTitle = 'No results',
    this.noResultsMessage = 'Try a shorter keyword or remove a tag filter.',
    this.searchActionLabel = 'Search',
    this.clearTooltip,
    this.untitledLabel,
  });

  final List<NoteSearchEntry> entries;
  final ValueChanged<NoteSearchEntry> onSelected;
  final String title;
  final String hint;
  final String emptyTitle;
  final String emptyMessage;
  final String noResultsTitle;
  final String noResultsMessage;
  final String searchActionLabel;
  final String? clearTooltip;
  final String? untitledLabel;

  @override
  State<NoteSearchPage> createState() => _NoteSearchPageState();
}

class _NoteSearchPageState extends State<NoteSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String? _selectedTag;

  List<String> get _availableTags {
    final tags = <String>{};
    for (final entry in widget.entries) {
      tags.addAll(entry.tags);
    }
    final result = tags.toList()..sort();
    return result;
  }

  List<NoteSearchEntry> get _results {
    final results = widget.entries.where((entry) {
      final tagMatches =
          _selectedTag == null || entry.tags.contains(_selectedTag);
      return tagMatches && entry.matches(_query);
    }).toList();

    results.sort((a, b) {
      final aTitle = a.title.toLowerCase();
      final bTitle = b.title.toLowerCase();
      final q = _query.toLowerCase().trim();
      final aStarts = q.isNotEmpty && aTitle.startsWith(q) ? 0 : 1;
      final bStarts = q.isNotEmpty && bTitle.startsWith(q) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return a.title.compareTo(b.title);
    });
    return results;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final tags = _availableTags;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final showEmptyPrompt = _query.trim().isEmpty && _selectedTag == null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: ContentPane(
          maxWidth: AppBreakpoints.readableContentMax,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: widget.clearTooltip ?? l10n.search_clear,
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                              _focusNode.requestFocus();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              if (tags.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return FilterChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (selected) {
                          setState(() => _selectedTag = selected ? tag : null);
                        },
                      );
                    },
                  ),
                ),
              if (!showEmptyPrompt)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.search_results_count(results.length),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: showEmptyPrompt
                    ? EmptyState(
                        icon: Icons.manage_search_rounded,
                        title: widget.emptyTitle,
                        message: widget.emptyMessage,
                      )
                    : results.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: widget.noResultsTitle,
                        message: widget.noResultsMessage,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return _SearchResultTile(
                            entry: result,
                            query: _query,
                            untitledLabel:
                                widget.untitledLabel ?? l10n.untitled,
                            onTap: () => widget.onSelected(result),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.entry,
    required this.query,
    required this.untitledLabel,
    required this.onTap,
  });

  final NoteSearchEntry entry;
  final String query;
  final String untitledLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = entry.title.isEmpty ? untitledLabel : entry.title;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                child: Icon(_iconForType(entry.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: title,
                      query: query,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (entry.preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _HighlightedText(
                        text: entry.preview,
                        query: query,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                      ),
                    ],
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: entry.tags
                            .take(4)
                            .map((tag) => _TagPill(label: tag))
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'checklist':
        return Icons.checklist_rounded;
      case 'drawing':
        return Icons.brush_rounded;
      case 'image':
        return Icons.image_outlined;
      case 'audio':
        return Icons.graphic_eq_rounded;
      default:
        return Icons.notes_rounded;
    }
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 1,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim();
    if (needle.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lower = text.toLowerCase();
    final lowerNeedle = needle.toLowerCase();
    final spans = <TextSpan>[];
    var cursor = 0;
    while (true) {
      final index = lower.indexOf(lowerNeedle, cursor);
      if (index < 0) {
        if (cursor < text.length) {
          spans.add(TextSpan(text: text.substring(cursor)));
        }
        break;
      }
      if (index > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + needle.length),
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      cursor = index + needle.length;
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
