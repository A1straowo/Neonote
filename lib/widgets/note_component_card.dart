import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo;
import 'package:neonote/services/platform_media.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/widgets/accessible_icon_button.dart';
import 'package:neonote/widgets/floating_ball.dart';
import 'package:neonote/widgets/image_source_view.dart';

class NoteComponentCard extends StatelessWidget {
  const NoteComponentCard({
    super.key,
    required this.component,
    required this.onChanged,
    required this.onDelete,
    this.onOpen,
    this.onEditTags,
    this.preview = false,
    this.tagNames,
  });

  final NoteComponent component;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;
  final VoidCallback? onEditTags;

  /// Optional parent-computed id-to-name map. Building this once per list is
  /// much cheaper than reading the tag store from every card build.
  final Map<String, String>? tagNames;

  /// true：首页只读缩略预览；false：编辑器内部可编辑。
  final bool preview;

  @override
  Widget build(BuildContext context) {
    if (preview) {
      return _buildPreviewCard(context);
    }

    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final meta = switch (component.type) {
      NoteComponentType.text => (Icons.text_fields, l10n.component_text),
      NoteComponentType.checklist => (
        Icons.check_box_outlined,
        l10n.component_checklist,
      ),
      NoteComponentType.drawing => (
        Icons.brush_outlined,
        l10n.component_drawing,
      ),
      NoteComponentType.image => (Icons.image_outlined, l10n.component_image),
      NoteComponentType.audio => (Icons.mic_none, l10n.component_audio),
    };

    return Card(
      margin: EdgeInsets.only(bottom: DeviceInfo.pt(12)),
      elevation: 0,
      color: scheme.onSurface.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DeviceInfo.pt(18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          DeviceInfo.pt(14),
          DeviceInfo.pt(6),
          DeviceInfo.pt(6),
          DeviceInfo.pt(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  meta.$1,
                  size: DeviceInfo.pt(16),
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
                SizedBox(width: DeviceInfo.pt(8)),
                Expanded(
                  child: Text(
                    meta.$2,
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: DeviceInfo.pt(13),
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                if (onOpen != null)
                  AccessibleIconButton(
                    onPressed: onOpen,
                    tooltip: l10n.rename,
                    visualDensity: VisualDensity.compact,
                    iconSize: DeviceInfo.pt(17),
                    icon: Icon(
                      Icons.open_in_full,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                AccessibleIconButton(
                  onPressed: onDelete,
                  tooltip: l10n.component_delete,
                  visualDensity: VisualDensity.compact,
                  iconSize: DeviceInfo.pt(18),
                  icon: Icon(
                    Icons.delete_outline,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: DeviceInfo.pt(8)),
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final meta = switch (component.type) {
      NoteComponentType.text => (Icons.text_fields, l10n.component_text),
      NoteComponentType.checklist => (
        Icons.check_box_outlined,
        l10n.component_checklist,
      ),
      NoteComponentType.drawing => (
        Icons.brush_outlined,
        l10n.component_drawing,
      ),
      NoteComponentType.image => (Icons.image_outlined, l10n.component_image),
      NoteComponentType.audio => (Icons.mic_none, l10n.component_audio),
    };

    final resolvedTagNames =
        tagNames ??
        <String, String>{for (final tag in NoteStore.tags()) tag.id: tag.name};
    final title = component.title.trim();
    final summary = _semanticsPreview(l10n);
    final semanticLabel = [
      meta.$2,
      if (title.isNotEmpty) title,
      if (summary.isNotEmpty) summary,
    ].join('，');
    final accent = switch (component.type) {
      NoteComponentType.text => scheme.primary,
      NoteComponentType.checklist => scheme.tertiary,
      NoteComponentType.drawing => const Color(0xFF7B4B94),
      NoteComponentType.image => const Color(0xFFB26A00),
      NoteComponentType.audio => const Color(0xFF1565C0),
    };

    return Card(
      margin: EdgeInsets.only(bottom: DeviceInfo.pt(12)),
      elevation: 0,
      color: scheme.onSurface.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DeviceInfo.pt(18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Semantics(
          container: true,
          label: semanticLabel,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.075),
                  scheme.surface.withValues(alpha: 0.015),
                ],
              ),
              border: Border(
                left: BorderSide(color: accent, width: DeviceInfo.pt(3)),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DeviceInfo.pt(16),
                DeviceInfo.pt(10),
                DeviceInfo.pt(8),
                DeviceInfo.pt(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DeviceInfo.pt(9),
                          vertical: DeviceInfo.pt(4),
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              meta.$1,
                              size: DeviceInfo.pt(14),
                              color: accent,
                            ),
                            SizedBox(width: DeviceInfo.pt(5)),
                            Text(
                              meta.$2,
                              style: TextStyle(
                                fontFamily: 'ResourceHanCN',
                                fontSize: DeviceInfo.pt(12),
                                fontWeight: FontWeight.w500,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (component.pinned)
                        Padding(
                          padding: EdgeInsets.only(right: DeviceInfo.pt(2)),
                          child: Icon(
                            Icons.push_pin,
                            size: DeviceInfo.pt(17),
                            color: scheme.primary,
                          ),
                        ),
                      if (component.marked)
                        Padding(
                          padding: EdgeInsets.only(right: DeviceInfo.pt(2)),
                          child: Icon(
                            Icons.flag,
                            size: DeviceInfo.pt(17),
                            color: Colors.purple,
                          ),
                        ),
                      if (onEditTags != null)
                        AccessibleIconButton(
                          onPressed: onEditTags,
                          tooltip: l10n.label,
                          visualDensity: VisualDensity.compact,
                          iconSize: DeviceInfo.pt(17),
                          icon: Icon(
                            Icons.label_outline,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      AccessibleIconButton(
                        onPressed: onDelete,
                        tooltip: l10n.component_delete,
                        visualDensity: VisualDensity.compact,
                        iconSize: DeviceInfo.pt(17),
                        icon: Icon(
                          Icons.delete_outline,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: DeviceInfo.pt(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (component.title.trim().isNotEmpty)
                          Text(
                            component.title.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'ResourceHanCN',
                              fontSize: DeviceInfo.pt(17),
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: scheme.onSurface,
                            ),
                          ),
                        if (component.title.trim().isNotEmpty)
                          SizedBox(height: DeviceInfo.pt(8)),
                        ExcludeSemantics(child: _buildPreviewContent(context)),
                        if (component.tagIds.isNotEmpty) ...[
                          SizedBox(height: DeviceInfo.pt(8)),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final id in component.tagIds)
                                if (resolvedTagNames[id] != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DeviceInfo.pt(8),
                                      vertical: DeviceInfo.pt(3),
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest
                                          .withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      resolvedTagNames[id]!,
                                      style: TextStyle(
                                        fontFamily: 'ResourceHanCN',
                                        fontSize: DeviceInfo.pt(11),
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticsPreview(AppLocalizations l10n) {
    final raw = switch (component.type) {
      NoteComponentType.text => component.text,
      NoteComponentType.checklist =>
        '${component.items.where((item) => item.done).length}/'
            '${component.items.length}',
      NoteComponentType.drawing => l10n.component_drawing,
      NoteComponentType.image =>
        component.url.isEmpty ? l10n.no_images : l10n.component_image,
      NoteComponentType.audio =>
        component.url.isEmpty ? l10n.no_recording : l10n.component_audio,
    };
    final clean = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length <= 80 ? clean : '${clean.substring(0, 80)}…';
  }

  Widget _buildPreviewContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    switch (component.type) {
      case NoteComponentType.text:
        final text = component.text.trim();
        return Text(
          text.isEmpty
              ? l10n.no_text_content
              : text.replaceAll(RegExp(r'\s+'), ' '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            fontSize: DeviceInfo.pt(14.5),
            height: 1.5,
            color: scheme.onSurface.withValues(alpha: 0.82),
          ),
        );
      case NoteComponentType.checklist:
        if (component.items.isEmpty) {
          return Text(
            l10n.no_checklist_items,
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.55)),
          );
        }
        final done = component.items.where((item) => item.done).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.completed_count(done, component.items.length),
              style: TextStyle(
                fontSize: DeviceInfo.pt(13),
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: DeviceInfo.pt(4)),
            for (final item in component.items.take(3))
              Padding(
                padding: EdgeInsets.only(bottom: DeviceInfo.pt(3)),
                child: Row(
                  children: [
                    Icon(
                      item.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: DeviceInfo.pt(16),
                      color: item.done
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: DeviceInfo.pt(6)),
                    Expanded(
                      child: Text(
                        item.text.trim().isEmpty
                            ? l10n.unnamed_checklist_item
                            : item.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(14),
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: scheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (component.items.length > 3)
              Text(
                l10n.more_items(component.items.length - 3),
                style: TextStyle(
                  fontSize: DeviceInfo.pt(12),
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        );
      case NoteComponentType.drawing:
        if (component.strokes.isEmpty) {
          return _emptyPreview(context, Icons.brush_outlined, l10n.no_drawings);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
          child: Container(
            height: DeviceInfo.pt(112),
            width: double.infinity,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: CustomPaint(
              painter: _DrawingThumbnailPainter(component.strokes),
            ),
          ),
        );
      case NoteComponentType.image:
        final imagePaths = component.imagePaths;
        if (imagePaths.isEmpty) {
          return _emptyPreview(context, Icons.image_outlined, l10n.no_images);
        }
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
              child: SourceImageView(
                source: imagePaths.first,
                height: DeviceInfo.pt(112),
                width: double.infinity,
                fit: BoxFit.cover,
                loading: Container(
                  height: DeviceInfo.pt(112),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                error: _emptyPreview(
                  context,
                  Icons.broken_image_outlined,
                  l10n.image_load_failed,
                ),
              ),
            ),
            if (imagePaths.length > 1)
              Positioned(
                right: DeviceInfo.pt(6),
                bottom: DeviceInfo.pt(6),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DeviceInfo.pt(8),
                    vertical: DeviceInfo.pt(3),
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${imagePaths.length}',
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: DeviceInfo.pt(12),
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        );
      case NoteComponentType.audio:
        return Row(
          children: [
            CircleAvatar(
              radius: DeviceInfo.pt(20),
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
              child: Icon(
                component.url.isEmpty ? Icons.mic_off : Icons.graphic_eq,
                color: scheme.primary,
              ),
            ),
            SizedBox(width: DeviceInfo.pt(10)),
            Expanded(
              child: Text(
                component.url.isEmpty
                    ? l10n.no_recording
                    : l10n.recorded_tap_to_play,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _emptyPreview(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: DeviceInfo.pt(90),
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: scheme.onSurface.withValues(alpha: 0.35)),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: DeviceInfo.pt(13),
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (component.type) {
      case NoteComponentType.text:
        return _TextComponent(component: component, onChanged: onChanged);
      case NoteComponentType.checklist:
        return _ChecklistComponent(component: component, onChanged: onChanged);
      case NoteComponentType.drawing:
        return _DrawingComponent(component: component, onChanged: onChanged);
      case NoteComponentType.image:
        return _ImageComponent(component: component, onChanged: onChanged);
      case NoteComponentType.audio:
        return _AudioComponent(component: component, onChanged: onChanged);
    }
  }
}

class _TextComponent extends StatefulWidget {
  const _TextComponent({required this.component, required this.onChanged});

  final NoteComponent component;
  final VoidCallback onChanged;

  @override
  State<_TextComponent> createState() => _TextComponentState();
}

class _TextComponentState extends State<_TextComponent> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.component.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = widget.component.title.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: DeviceInfo.pt(2)),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: DeviceInfo.pt(15),
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        TextField(
          controller: _controller,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          cursorColor: scheme.primary,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            fontSize: DeviceInfo.pt(17),
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: '...',
            hintStyle: TextStyle(color: scheme.secondary),
          ),
          onChanged: (value) {
            widget.component.text = value;
            widget.onChanged();
          },
        ),
      ],
    );
  }
}

class _ChecklistComponent extends StatefulWidget {
  const _ChecklistComponent({required this.component, required this.onChanged});

  final NoteComponent component;
  final VoidCallback onChanged;

  @override
  State<_ChecklistComponent> createState() => _ChecklistComponentState();
}

class _ChecklistComponentState extends State<_ChecklistComponent> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final items = widget.component.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          _ChecklistRow(
            key: ValueKey<String>(item.id),
            item: item,
            onChanged: () {
              setState(() {});
              widget.onChanged();
            },
            onRemove: () {
              setState(() => items.removeWhere((entry) => entry.id == item.id));
              widget.onChanged();
            },
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() => items.add(ChecklistItem()));
              widget.onChanged();
            },
            icon: Icon(Icons.add, size: DeviceInfo.pt(18)),
            label: Text(
              l10n.checklist_add_item,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: DeviceInfo.pt(14),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatefulWidget {
  const _ChecklistRow({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final ChecklistItem item;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.item.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Checkbox(
          value: widget.item.done,
          visualDensity: VisualDensity.compact,
          onChanged: (value) {
            widget.item.done = value ?? false;
            widget.onChanged();
          },
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            cursorColor: scheme.primary,
            style: TextStyle(
              fontFamily: 'ResourceHanCN',
              fontSize: DeviceInfo.pt(16),
              color: scheme.onSurface,
              decoration: widget.item.done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: '...',
            ),
            onChanged: (value) {
              widget.item.text = value;
              widget.onChanged();
            },
          ),
        ),
        AccessibleIconButton(
          tooltip: l10n.delete,
          onPressed: widget.onRemove,
          visualDensity: VisualDensity.compact,
          iconSize: DeviceInfo.pt(18),
          icon: Icon(
            Icons.remove_circle_outline,
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _ImageComponent extends StatelessWidget {
  const _ImageComponent({required this.component, required this.onChanged});

  final NoteComponent component;
  final VoidCallback onChanged;

  Future<void> _editUrl(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final paths = List<String>.of(component.imagePaths);
    final result = await showTextInputDialog(
      context,
      title: l10n.image_url,
      hint: 'https://',
      confirmLabel: l10n.confirm,
      initialValue: paths.isEmpty ? '' : paths.first,
      keyboardType: TextInputType.url,
    );
    if (result == null) return;
    if (result.trim().isEmpty) {
      if (paths.isNotEmpty) paths.removeAt(0);
    } else if (paths.isEmpty) {
      paths.add(result.trim());
    } else {
      paths[0] = result.trim();
    }
    component
      ..url = paths.isEmpty ? '' : paths.first
      ..textBlocks = [
        for (final path in paths)
          NoteTextBlock(kind: NoteTextBlockKind.image, mediaPath: path),
      ];
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final height = DeviceInfo.pt(180);
    final cacheHeight = (height * MediaQuery.devicePixelRatioOf(context))
        .round();

    final imagePaths = component.imagePaths;
    if (imagePaths.isEmpty) {
      return InkWell(
        onTap: () => _editUrl(context),
        borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: DeviceInfo.pt(36),
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
              SizedBox(height: DeviceInfo.pt(8)),
              Text(
                l10n.image_url,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontSize: DeviceInfo.pt(14),
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: SourceImageView(
              source: imagePaths.first,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              cacheHeight: cacheHeight,
              loading: const Center(child: CircularProgressIndicator()),
              error: Container(
                alignment: Alignment.center,
                color: scheme.onSurface.withValues(alpha: 0.06),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ),
        if (imagePaths.length > 1)
          Positioned(
            left: DeviceInfo.pt(6),
            bottom: DeviceInfo.pt(6),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DeviceInfo.pt(8),
                vertical: DeviceInfo.pt(3),
              ),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${imagePaths.length}',
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontSize: DeviceInfo.pt(12),
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        Positioned(
          right: DeviceInfo.pt(6),
          top: DeviceInfo.pt(6),
          child: Material(
            color: scheme.surface.withValues(alpha: 0.85),
            shape: const CircleBorder(),
            child: AccessibleIconButton(
              tooltip: AppLocalizations.of(context)!.image_url,
              onPressed: () => _editUrl(context),
              visualDensity: VisualDensity.compact,
              iconSize: DeviceInfo.pt(18),
              icon: const Icon(Icons.link),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawingComponent extends StatefulWidget {
  const _DrawingComponent({required this.component, required this.onChanged});

  final NoteComponent component;
  final VoidCallback onChanged;

  @override
  State<_DrawingComponent> createState() => _DrawingComponentState();
}

class _DrawingComponentState extends State<_DrawingComponent> {
  DrawingStroke? _current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final strokes = widget.component.strokes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
          child: Container(
            height: DeviceInfo.pt(200),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.18),
              ),
              borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
            ),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                setState(() {
                  _current = DrawingStroke(
                    points: <Offset>[event.localPosition],
                    color: scheme.onSurface.toARGB32(),
                  );
                });
              },
              onPointerMove: (event) {
                final stroke = _current;
                if (stroke == null) return;
                setState(() {
                  final last = stroke.points.last;
                  final delta = event.localPosition - last;
                  final distance = delta.distance;
                  if (distance == 0) return;
                  final steps = (distance / 2).ceil().clamp(1, 32);
                  for (var i = 1; i <= steps; i++) {
                    stroke.points.add(last + delta * (i / steps));
                  }
                });
              },
              onPointerUp: (_) {
                final stroke = _current;
                if (stroke == null) return;
                setState(() {
                  strokes.add(stroke);
                  _current = null;
                });
                widget.onChanged();
              },
              onPointerCancel: (_) {
                final stroke = _current;
                if (stroke == null) return;
                setState(() {
                  strokes.add(stroke);
                  _current = null;
                });
                widget.onChanged();
              },
              child: CustomPaint(
                painter: _DrawingPainter(
                  strokes: strokes,
                  current: _current,
                  fallbackColor: scheme.onSurface,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: strokes.isEmpty
                ? null
                : () {
                    setState(strokes.clear);
                    widget.onChanged();
                  },
            icon: Icon(
              Icons.cleaning_services_outlined,
              size: DeviceInfo.pt(18),
            ),
            label: Text(
              l10n.clear,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: DeviceInfo.pt(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter({
    required this.strokes,
    required this.current,
    required this.fallbackColor,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? current;
  final Color fallbackColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    final active = current;
    if (active != null) _paintStroke(canvas, active);
  }

  void _paintStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;
    final color = stroke.color == 0 ? fallbackColor : Color(stroke.color);
    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.width / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final points = stroke.points;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
    } else {
      for (var i = 1; i < points.length - 1; i++) {
        final point = points[i];
        final next = points[i + 1];
        final middle = Offset(
          (point.dx + next.dx) / 2,
          (point.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(point.dx, point.dy, middle.dx, middle.dy);
      }
      path.lineTo(points.last.dx, points.last.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

class _AudioComponent extends StatefulWidget {
  const _AudioComponent({required this.component, required this.onChanged});

  final NoteComponent component;
  final VoidCallback onChanged;

  @override
  State<_AudioComponent> createState() => _AudioComponentState();
}

class _AudioComponentState extends State<_AudioComponent> {
  bool _recording = false;
  bool _playing = false;

  @override
  void dispose() {
    PlatformMediaService.stopAudio();
    super.dispose();
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  Future<void> _toggleRecording() async {
    final l10n = AppLocalizations.of(context)!;
    if (_recording) {
      final path = await PlatformMediaService.stopRecording();
      if (!mounted) return;
      setState(() => _recording = false);
      if (path != null && path.isNotEmpty) {
        widget.component.url = path;
        widget.onChanged();
      } else {
        _toast(l10n.record_failed);
      }
      return;
    }
    final started = await PlatformMediaService.startRecording();
    if (!mounted) return;
    if (started) {
      setState(() => _recording = true);
    } else {
      _toast(l10n.mic_permission_denied);
    }
  }

  Future<void> _togglePlayback() async {
    if (_playing) {
      await PlatformMediaService.stopAudio();
      if (!mounted) return;
      setState(() => _playing = false);
      return;
    }
    final started = await PlatformMediaService.playAudio(widget.component.url);
    if (!mounted) return;
    setState(() => _playing = started);
  }

  void _clear() {
    PlatformMediaService.stopAudio();
    widget.component.url = '';
    widget.onChanged();
    setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final supported = PlatformMediaService.isMobile;
    final hasRecording = widget.component.url.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: DeviceInfo.pt(10),
        horizontal: DeviceInfo.pt(8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DeviceInfo.pt(12)),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: _recording ? l10n.clear : l10n.record_audio,
            onPressed: supported ? _toggleRecording : null,
            icon: Icon(
              _recording
                  ? Icons.stop_circle_outlined
                  : Icons.fiber_manual_record,
              color: _recording ? Colors.red : scheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              _recording
                  ? l10n.recording
                  : (hasRecording ? l10n.component_audio : l10n.record_audio),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: DeviceInfo.pt(15),
                color: scheme.onSurface,
              ),
            ),
          ),
          if (!supported)
            Flexible(
              child: Text(
                l10n.audio_unsupported,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontSize: DeviceInfo.pt(12),
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          if (hasRecording && !_recording)
            IconButton(
              tooltip: _playing ? l10n.pause : l10n.play,
              onPressed: _togglePlayback,
              icon: Icon(
                _playing
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: scheme.primary,
              ),
            ),
          if (hasRecording && !_recording)
            IconButton(
              tooltip: l10n.delete,
              onPressed: _clear,
              icon: Icon(
                Icons.delete_outline,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

class _DrawingThumbnailPainter extends CustomPainter {
  _DrawingThumbnailPainter(this.strokes);

  final List<DrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final points = strokes.expand((stroke) => stroke.points).toList();
    if (points.isEmpty) return;

    var minX = points.first.dx;
    var maxX = points.first.dx;
    var minY = points.first.dy;
    var maxY = points.first.dy;

    for (final point in points) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    final sourceWidth = math.max(maxX - minX, 1.0);
    final sourceHeight = math.max(maxY - minY, 1.0);
    final scale =
        math.min(size.width / sourceWidth, size.height / sourceHeight) * 0.9;

    final offsetX = (size.width - sourceWidth * scale) / 2 - minX * scale;
    final offsetY = (size.height - sourceHeight * scale) / 2 - minY * scale;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final path = Path();
      final first = stroke.points.first;
      path.moveTo(first.dx * scale + offsetX, first.dy * scale + offsetY);

      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx * scale + offsetX, point.dy * scale + offsetY);
      }

      final paint = Paint()
        ..color = Color(stroke.color)
        ..strokeWidth = math.max(stroke.width * scale, 1.0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingThumbnailPainter oldDelegate) => true;
}
