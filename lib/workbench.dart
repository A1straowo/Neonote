import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo, themeBox;
import 'package:neonote/services/platform_media.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/ui/app_layout.dart';
import 'package:neonote/ui/canvas_grid_painter.dart';
import 'package:neonote/widgets/exit_save_dialog.dart';
import 'package:neonote/widgets/image_source_view.dart';
import 'package:neonote/widgets/note_component_card.dart';
import 'package:path_provider/path_provider.dart';

import 'perf/perf_runtime.dart' as perf;

class _TextBackgroundChoice {
  const _TextBackgroundChoice({
    required this.type,
    this.color = 0,
    this.action = '',
  });

  final String type;
  final int color;
  final String action;
}

class _TextNoteBackground extends StatelessWidget {
  const _TextNoteBackground({
    required this.type,
    required this.color,
    required this.imagePath,
    required this.scheme,
  });

  final String type;
  final int color;
  final String imagePath;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'color':
        return ColoredBox(color: color == 0 ? scheme.surface : Color(color));
      case 'grid_square':
      case 'grid_dots':
      case 'grid_lines':
        final backgroundColor = color == 0 ? scheme.surface : Color(color);
        return RepaintBoundary(
          child: CustomPaint(
            painter: NoteCardGridPainter(
              style: _noteCardGridStyle(type),
              backgroundColor: backgroundColor,
              lineColor: _gridLineColor(backgroundColor),
            ),
            isComplex: true,
            willChange: false,
            size: Size.infinite,
          ),
        );
      case 'image':
        if (imagePath.isEmpty) return const SizedBox.shrink();
        return Stack(
          fit: StackFit.expand,
          children: [
            SourceImageView(
              source: imagePath,
              fit: BoxFit.cover,
              loading: Center(
                child: CircularProgressIndicator(color: scheme.primary),
              ),
              error: ColoredBox(color: scheme.surface),
            ),
            // Keep text readable regardless of the chosen image.
            ColoredBox(color: scheme.surface.withValues(alpha: 0.62)),
          ],
        );
      default:
        return ColoredBox(color: scheme.surface);
    }
  }

  Color _gridLineColor(Color background) {
    return background.computeLuminance() > 0.55
        ? const Color(0x33000000)
        : const Color(0x44FFFFFF);
  }
}

NoteCardGridStyle _noteCardGridStyle(String kind) {
  return switch (kind) {
    'grid_square' => NoteCardGridStyle.square,
    'grid_dots' => NoteCardGridStyle.dots,
    'grid_lines' => NoteCardGridStyle.horizontalLines,
    _ => NoteCardGridStyle.none,
  };
}

class WorkbenchPage extends StatefulWidget {
  const WorkbenchPage({super.key, required this.component, this.isNew = false});

  final NoteComponent component;
  final bool isNew;

  @override
  State<WorkbenchPage> createState() => _WorkbenchPageState();
}

class _WorkbenchPageState extends State<WorkbenchPage>
    with WidgetsBindingObserver {
  Timer? _saveTimer;
  Timer? _maxSaveTimer;
  int _editRevision = 0;
  bool _saving = false;
  bool _saveQueued = false;
  bool _deleted = false;
  bool _dirty = false;
  bool _allowPop = false;
  int _recoveryEpoch = 0;
  DateTime? _lastSaveErrorNotice;

  bool get _autoSaveEnabled =>
      Hive.box(themeBox).get('autoSave', defaultValue: true) == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_checkRecoveryDraft());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_deleted || !_dirty) return;
    if (state != AppLifecycleState.inactive &&
        state != AppLifecycleState.paused &&
        state != AppLifecycleState.detached) {
      return;
    }
    if (_autoSaveEnabled) {
      unawaited(_saveNow());
    } else {
      unawaited(_saveRecoveryDraft());
    }
  }

  String get _recoveryKey => 'note_recovery_${widget.component.id}';

  Future<void> _saveRecoveryDraft() async {
    if (_deleted || !_dirty) return;
    try {
      if (!Hive.isBoxOpen(themeBox)) {
        throw StateError('Hive box is not open');
      }
      await Hive.box(themeBox).put(_recoveryKey, {
        ...widget.component.toMap(),
        'recovery_saved_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (error) {
      _showPersistenceError(error);
    }
  }

  Future<void> _deleteRecoveryDraft() async {
    try {
      if (Hive.isBoxOpen(themeBox)) {
        await Hive.box(themeBox).delete(_recoveryKey);
      }
    } catch (_) {}
  }

  NoteComponent? _readRecoveryDraft() {
    try {
      if (!Hive.isBoxOpen(themeBox)) return null;
      final raw = Hive.box(themeBox).get(_recoveryKey);
      if (raw is! Map) return null;
      return NoteComponent.fromMap(<String, dynamic>{
        for (final entry in raw.entries) entry.key.toString(): entry.value,
      });
    } catch (_) {
      return null;
    }
  }

  void _applyRecoveredDraft(NoteComponent draft) {
    widget.component
      ..title = draft.title
      ..text = draft.text
      ..url = draft.url
      ..pinned = draft.pinned
      ..archived = draft.archived
      ..marked = draft.marked
      ..tagIds = List<String>.from(draft.tagIds)
      ..textColor = draft.textColor
      ..textSize = draft.textSize
      ..textBold = draft.textBold
      ..textBackgroundType = draft.textBackgroundType
      ..textBackgroundColor = draft.textBackgroundColor
      ..textBackgroundImage = draft.textBackgroundImage
      ..drawingBackgroundStyle = draft.drawingBackgroundStyle
      ..textBlocks = List<NoteTextBlock>.from(draft.textBlocks)
      ..items = List<ChecklistItem>.from(draft.items)
      ..strokes = List<DrawingStroke>.from(draft.strokes);
  }

  Future<void> _checkRecoveryDraft() async {
    final draft = _readRecoveryDraft();
    if (draft == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final restore = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n.recovery_draft_found),
        content: Text(l10n.recovery_draft_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.discard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
    await _deleteRecoveryDraft();
    if (!mounted || restore != true) return;
    _applyRecoveredDraft(draft);
    setState(() => _recoveryEpoch++);
    _dirty = true;
    _editRevision++;
  }

  bool get _hasContent {
    final component = widget.component;
    return switch (component.type) {
      NoteComponentType.text =>
        component.title.trim().isNotEmpty || component.text.trim().isNotEmpty,
      NoteComponentType.checklist => component.items.any(
        (item) => item.text.trim().isNotEmpty,
      ),
      NoteComponentType.drawing => component.strokes.isNotEmpty,
      NoteComponentType.image => component.url.trim().isNotEmpty,
      NoteComponentType.audio => component.url.trim().isNotEmpty,
    };
  }

  void _notify(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  void _scheduleSave({bool markEdit = true}) {
    if (markEdit) _editRevision++;
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = null;

    if (!_autoSaveEnabled) return;

    _saveTimer = Timer(const Duration(milliseconds: 300), () async {
      _saveTimer = null;
      await _saveNow();
    });
    // Continuous typing must not starve persistence forever.
    _maxSaveTimer ??= Timer(const Duration(seconds: 2), () {
      _maxSaveTimer = null;
      unawaited(_saveNow());
    });
  }

  void _showPersistenceError(Object? error) {
    if (error != null) debugPrint('Note persistence failed: $error');
    final now = DateTime.now();
    final previous = _lastSaveErrorNotice;
    if (previous != null &&
        now.difference(previous) < const Duration(seconds: 3)) {
      return;
    }
    _lastSaveErrorNotice = now;
    if (mounted) _notify(AppLocalizations.of(context)!.save_failed_retrying);
  }

  Future<void> _saveNow() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    if (_deleted) return;
    if (_saving) {
      _saveQueued = true;
      return;
    }

    _saving = true;
    try {
      do {
        _saveQueued = false;
        final revisionAtStart = _editRevision;
        await NoteStore.saveComponent(widget.component, bump: true);
        if (revisionAtStart == _editRevision) {
          _dirty = false;
          _maxSaveTimer?.cancel();
          _maxSaveTimer = null;
          await _deleteRecoveryDraft();
        } else {
          // Edits landed while the write was in flight. Keep dirty and write
          // the newer state before considering the save complete.
          _saveQueued = true;
          _dirty = true;
        }
      } while (_saveQueued);
    } catch (error) {
      _dirty = true;
      _showPersistenceError(error);
      if (_autoSaveEnabled) _scheduleSave(markEdit: false);
    } finally {
      _saving = false;
    }
  }

  Future<bool> _confirmExit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_deleted) return true;

    // Auto-save on: never ask. Blank components are removed and non-empty
    // components are saved without showing an exit dialog.
    if (_autoSaveEnabled) {
      if (!_hasContent) {
        _deleted = true;
        _saveTimer?.cancel();
        await NoteStore.removeComponent(widget.component.id);
        _notify(l10n.note_blank_deleted);
      } else {
        await _saveNow();
        if (_dirty) return false;
      }
      return true;
    }

    // Auto-save off: a newly created component always asks whether to keep it,
    // even when it is still blank. Discarding deletes the component.
    if (widget.isNew) {
      final decision = await showExitSaveDialog(context);
      if (!mounted) return false;
      if (decision == ExitSaveDecision.save) {
        await _saveNow();
        return !_dirty;
      }

      _deleted = true;
      _saveTimer?.cancel();
      await NoteStore.removeComponent(widget.component.id);
      _notify(l10n.note_discarded);
      return true;
    }

    if (!_dirty) return true;

    final decision = await showExitSaveDialog(context);
    if (!mounted) return false;

    if (decision == ExitSaveDecision.save) {
      await _saveNow();
    }
    // Existing components keep their previously persisted data when the user
    // chooses not to save the in-memory edit.
    return true;
  }

  Future<void> _requestClose() async {
    if (_allowPop) return;

    final shouldPop = await _confirmExit();
    if (!mounted || !shouldPop) return;

    setState(() => _allowPop = true);
    await Future<void>.delayed(Duration.zero);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteComponent() async {
    _deleted = true;
    _saveTimer?.cancel();

    await NoteStore.removeComponent(widget.component.id);
    if (!mounted) return;

    _allowPop = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _maxSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.component.type) {
      NoteComponentType.text => _TextWorkbench(
        component: widget.component,
        onChanged: _scheduleSave,
        onDelete: _deleteComponent,
      ),
      NoteComponentType.drawing => _DrawingWorkbench(
        component: widget.component,
        onChanged: _scheduleSave,
        onDelete: _deleteComponent,
      ),
      NoteComponentType.image => _ImageWorkbench(
        component: widget.component,
        onChanged: _scheduleSave,
        onDelete: _deleteComponent,
      ),
      NoteComponentType.checklist => _CardWorkbench(
        component: widget.component,
        onChanged: _scheduleSave,
        onDelete: _deleteComponent,
      ),
      NoteComponentType.audio => _CardWorkbench(
        component: widget.component,
        onChanged: _scheduleSave,
        onDelete: _deleteComponent,
      ),
    };

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _requestClose();
      },
      child: KeyedSubtree(
        key: ValueKey<String>('workbench-editor-$_recoveryEpoch'),
        child: child,
      ),
    );
  }
}

String _componentTitle(AppLocalizations l10n, NoteComponentType type) {
  return switch (type) {
    NoteComponentType.text => l10n.component_text,
    NoteComponentType.checklist => l10n.component_checklist,
    NoteComponentType.drawing => l10n.component_drawing,
    NoteComponentType.image => l10n.component_image,
    NoteComponentType.audio => l10n.component_audio,
  };
}

class _CardWorkbench extends StatelessWidget {
  const _CardWorkbench({
    required this.component,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteComponent component;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _componentTitle(l10n, component.type),
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: DeviceInfo.pt(20),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DeviceInfo.pt(16)),
          child: NoteComponentCard(
            component: component,
            onChanged: onChanged,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }
}

class _TextWorkbench extends StatefulWidget {
  const _TextWorkbench({
    required this.component,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteComponent component;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  State<_TextWorkbench> createState() => _TextWorkbenchState();
}

enum _TextToolbarPanel { none, insert, format, more }

class _TextNoteSnapshot {
  _TextNoteSnapshot(this.data) : estimatedBytes = _estimateBytes(data);

  final Map<String, dynamic> data;

  /// Approximate retained size of the in-memory snapshot. This is cheaper and
  /// more predictable than repeatedly JSON-encoding the whole document.
  final int estimatedBytes;

  static int _estimateBytes(Map<String, dynamic> data) {
    var bytes = 128;
    bytes += (data['title']?.toString().length ?? 0) * 2;
    bytes += (data['background_image']?.toString().length ?? 0) * 2;
    final blocks = data['blocks'];
    if (blocks is List) {
      for (final block in blocks) {
        bytes += 160;
        if (block is! Map) continue;
        bytes += (block['text']?.toString().length ?? 0) * 2;
        final items = block['items'];
        if (items is List) {
          for (final item in items) {
            bytes += 96;
            if (item is Map) {
              bytes += (item['text']?.toString().length ?? 0) * 2;
            }
          }
        }
        final strokes = block['drawing_strokes'];
        if (strokes is List) {
          for (final stroke in strokes) {
            bytes += 96;
            if (stroke is Map) {
              final points = stroke['p'];
              if (points is List) bytes += points.length * 8;
            }
          }
        }
      }
    }
    return bytes;
  }
}

class _EditableTextBlock {
  _EditableTextBlock({
    required this.id,
    required this.kind,
    String text = '',
    this.done = false,
    this.mediaPath = '',
    List<DrawingStroke>? strokes,
    this.fontSize = 16,
    this.color = 0,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.alignment = TextAlign.left,
  }) : controller = TextEditingController(text: text),
       drawingStrokes = strokes ?? <DrawingStroke>[],
       focusNode = FocusNode();

  final String id;
  NoteTextBlockKind kind;
  bool done;
  String mediaPath;
  List<DrawingStroke> drawingStrokes;
  double fontSize;
  int color;
  bool bold;
  bool italic;
  bool underline;
  bool strikethrough;
  TextAlign alignment;
  final TextEditingController controller;
  final FocusNode focusNode;

  NoteTextBlock toModel() => NoteTextBlock(
    id: id,
    kind: kind,
    text: kind == NoteTextBlockKind.divider ? '' : controller.text,
    done: done,
    mediaPath: mediaPath,
    strokes: drawingStrokes,
    fontSize: fontSize,
    color: color,
    bold: bold,
    italic: italic,
    underline: underline,
    strikethrough: strikethrough,
    alignment: switch (alignment) {
      TextAlign.center => 'center',
      TextAlign.right => 'right',
      _ => 'left',
    },
  );

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

double _distanceToSegment(Offset point, Offset start, Offset end) {
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  if (dx == 0 && dy == 0) return (point - start).distance;
  final t =
      (((point.dx - start.dx) * dx + (point.dy - start.dy) * dy) /
              (dx * dx + dy * dy))
          .clamp(0.0, 1.0);
  final projection = Offset(start.dx + t * dx, start.dy + t * dy);
  return (point - projection).distance;
}

bool _strokeIntersectsEraser(
  DrawingStroke stroke,
  Offset center,
  double radius,
) {
  final points = stroke.points;
  if (points.isEmpty) return false;
  final threshold = radius + stroke.width / 2;
  if (points.length == 1) {
    return (points.first - center).distance <= threshold;
  }
  for (var i = 0; i + 1 < points.length; i++) {
    if (_distanceToSegment(center, points[i], points[i + 1]) <= threshold) {
      return true;
    }
  }
  return false;
}

class _InlineDrawingBlock extends StatefulWidget {
  const _InlineDrawingBlock({
    required this.strokes,
    required this.onChanged,
    required this.onRemove,
    required this.scheme,
    required this.l10n,
  });

  final List<DrawingStroke> strokes;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final ColorScheme scheme;
  final AppLocalizations l10n;

  @override
  State<_InlineDrawingBlock> createState() => _InlineDrawingBlockState();
}

class _InlineDrawingBlockState extends State<_InlineDrawingBlock> {
  static const List<Color> _colors = <Color>[
    Color(0xFF1F1F1F),
    Color(0xFF1565C0),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
  ];

  DrawingStroke? _current;
  final List<Offset> _eraserPoints = <Offset>[];
  bool _eraserChanged = false;
  Color _color = _colors.first;
  bool _eraser = false;

  void _start(Offset position) {
    if (_eraser) {
      _eraserPoints
        ..clear()
        ..add(position);
      _eraserChanged = false;
      if (_eraseAt(position)) setState(() {});
      return;
    }
    setState(() {
      _current = DrawingStroke(
        points: <Offset>[position],
        color: _color.toARGB32(),
        width: 2.5,
      );
    });
  }

  void _move(Offset position) {
    if (_eraser) {
      final last = _eraserPoints.isEmpty ? position : _eraserPoints.last;
      final delta = position - last;
      final distance = delta.distance;
      final steps = perf.adaptiveStepCount(distance);
      var changed = false;
      if (steps == 0) {
        changed = _eraseAt(position);
      } else {
        for (var i = 1; i <= steps; i++) {
          final point = last + delta * (i / steps);
          _eraserPoints.add(point);
          changed = _eraseAt(point) || changed;
        }
      }
      if (changed) setState(() {});
      return;
    }
    final stroke = _current;
    if (stroke == null) return;
    final last = stroke.points.last;
    final delta = position - last;
    final distance = delta.distance;
    if (distance < 1.5) return;
    final steps = perf.adaptiveStepCount(distance);
    setState(() {
      for (var i = 1; i <= steps; i++) {
        stroke.points.add(last + delta * (i / steps));
      }
    });
  }

  void _end() {
    if (_eraser) {
      final changed = _eraserChanged;
      _eraserPoints.clear();
      _eraserChanged = false;
      if (changed) widget.onChanged();
      return;
    }
    final stroke = _current;
    if (stroke == null) return;
    stroke.points = perf.simplifyPolyline(
      stroke.points,
      epsilon: 0.75,
      maxPoints: 512,
    );
    setState(() {
      widget.strokes.add(stroke);
      _current = null;
    });
    widget.onChanged();
  }

  bool _eraseAt(Offset center) {
    final before = widget.strokes.length;
    widget.strokes.removeWhere(
      (stroke) => _strokeIntersectsEraser(stroke, center, 18),
    );
    final changed = widget.strokes.length != before;
    if (changed) _eraserChanged = true;
    return changed;
  }

  void _clear() {
    if (widget.strokes.isEmpty) return;
    setState(widget.strokes.clear);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: DeviceInfo.pt(180),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.12),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RepaintBoundary(
              child: RawGestureDetector(
                gestures: {
                  EagerGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        EagerGestureRecognizer
                      >(() => EagerGestureRecognizer(), (_) {}),
                },
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _start(event.localPosition),
                  onPointerMove: (event) => _move(event.localPosition),
                  onPointerUp: (_) => _end(),
                  onPointerCancel: (_) => _end(),
                  child: CustomPaint(
                    painter: _InlineDrawingPainter(
                      strokes: widget.strokes,
                      current: _current,
                      fallbackColor: scheme.onSurface,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            for (final color in _colors)
              GestureDetector(
                onTap: () => setState(() {
                  _color = color;
                  _eraser = false;
                }),
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(right: 7, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: !_eraser && _color == color ? 3 : 1,
                      color: !_eraser && _color == color
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            IconButton(
              tooltip: widget.l10n.drawing_eraser,
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _eraser = !_eraser),
              style: IconButton.styleFrom(
                backgroundColor: _eraser
                    ? scheme.primaryContainer
                    : Colors.transparent,
              ),
              icon: const Icon(Icons.auto_fix_normal, size: 19),
            ),
            IconButton(
              tooltip: widget.l10n.clear,
              visualDensity: VisualDensity.compact,
              onPressed: _clear,
              icon: const Icon(Icons.delete_sweep_outlined, size: 19),
            ),
            IconButton(
              tooltip: widget.l10n.delete,
              visualDensity: VisualDensity.compact,
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close, size: 19),
            ),
          ],
        ),
      ],
    );
  }
}

class _InlineDrawingPainter extends CustomPainter {
  const _InlineDrawingPainter({
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
        Paint()..color = color,
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
    for (var i = 1; i < points.length - 1; i++) {
      final point = points[i];
      final next = points[i + 1];
      final middle = Offset((point.dx + next.dx) / 2, (point.dy + next.dy) / 2);
      path.quadraticBezierTo(point.dx, point.dy, middle.dx, middle.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InlineDrawingPainter oldDelegate) => true;
}

class _DocumentSelectionDialog extends StatefulWidget {
  const _DocumentSelectionDialog({required this.text});

  final String text;

  @override
  State<_DocumentSelectionDialog> createState() =>
      _DocumentSelectionDialogState();
}

class _DocumentSelectionDialogState extends State<_DocumentSelectionDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  )..selection = TextSelection(baseOffset: 0, extentOffset: widget.text.length);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.sizeOf(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.select_all_document),
      content: SizedBox(
        width: media.width > 600 ? 520 : media.width * 0.82,
        height: media.height > 600 ? 420 : media.height * 0.5,
        child: TextField(
          controller: _controller,
          autofocus: true,
          readOnly: true,
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(fontFamily: 'ResourceHanCN', fontSize: 15),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          onTap: () {
            _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.text.length,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: widget.text));
            if (!context.mounted) return;
            final messenger = ScaffoldMessenger.maybeOf(context);
            Navigator.pop(context);
            messenger?.showSnackBar(
              SnackBar(
                content: Text(l10n.all_text_copied),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: const Icon(Icons.copy),
          label: Text(l10n.copy_all_text),
        ),
      ],
    );
  }
}

class _TextWorkbenchState extends State<_TextWorkbench> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.component.title,
  );
  final List<_EditableTextBlock> _blocks = <_EditableTextBlock>[];
  final ScrollController _textScrollController = ScrollController();
  int _activeBlockIndex = 0;
  _TextToolbarPanel _panel = _TextToolbarPanel.none;
  bool _recordingAudio = false;
  Timer? _perfHistoryDebounce;
  _TextNoteSnapshot? _historyCurrent;
  final List<_TextNoteSnapshot> _undoStack = <_TextNoteSnapshot>[];
  final List<_TextNoteSnapshot> _redoStack = <_TextNoteSnapshot>[];
  int _undoBytes = 0;
  int _redoBytes = 0;
  final ValueNotifier<int> _wordCount = ValueNotifier<int>(0);
  bool _historySuspended = false;

  static const int _maxHistoryBytes = 4 * 1024 * 1024;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
    _refreshWordCount();
    _historyCurrent = _captureSnapshot();
    HardwareKeyboard.instance.addHandler(_handleGlobalBackspace);
    HardwareKeyboard.instance.addHandler(_handleGlobalSelectAll);
  }

  @override
  void dispose() {
    _perfHistoryDebounce?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleGlobalBackspace);
    HardwareKeyboard.instance.removeHandler(_handleGlobalSelectAll);
    if (_recordingAudio) unawaited(PlatformMediaService.stopRecording());
    _titleController.dispose();
    _textScrollController.dispose();
    _wordCount.dispose();
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  void _loadBlocks() {
    final stored = widget.component.textBlocks;
    if (stored.isNotEmpty) {
      for (final model in stored) {
        _blocks.add(
          _EditableTextBlock(
            id: model.id,
            kind: model.kind,
            text: model.text,
            done: model.done,
            mediaPath: model.mediaPath,
            strokes: model.drawingStrokes,
            fontSize: model.fontSize > 0 ? model.fontSize : 16,
            color: model.color,
            bold: model.bold,
            italic: model.italic,
            underline: model.underline,
            strikethrough: model.strikethrough,
            alignment: switch (model.alignment) {
              'center' => TextAlign.center,
              'right' => TextAlign.right,
              _ => TextAlign.left,
            },
          ),
        );
      }
      _coalesceParagraphBlocks();
      return;
    }

    final legacyText = widget.component.text;
    final lines = legacyText.isEmpty ? <String>[''] : legacyText.split('\n');
    for (final line in lines) {
      if (line.trim() == '────────') {
        _blocks.add(
          _EditableTextBlock(
            id: NoteStore.newId(),
            kind: NoteTextBlockKind.divider,
          ),
        );
      } else if (line.startsWith('☐ ') || line.startsWith('☑ ')) {
        _blocks.add(
          _EditableTextBlock(
            id: NoteStore.newId(),
            kind: NoteTextBlockKind.checklist,
            text: line.substring(2),
            done: line.startsWith('☑ '),
            fontSize: widget.component.textSize > 0
                ? widget.component.textSize
                : 16,
            color: widget.component.textColor,
            bold: widget.component.textBold,
          ),
        );
      } else {
        _blocks.add(
          _EditableTextBlock(
            id: NoteStore.newId(),
            kind: NoteTextBlockKind.paragraph,
            text: line,
            fontSize: widget.component.textSize > 0
                ? widget.component.textSize
                : 16,
            color: widget.component.textColor,
            bold: widget.component.textBold,
          ),
        );
      }
    }
    if (_blocks.isEmpty) {
      _blocks.add(
        _EditableTextBlock(
          id: NoteStore.newId(),
          kind: NoteTextBlockKind.paragraph,
        ),
      );
    }
    _coalesceParagraphBlocks();
  }

  bool _sameParagraphStyle(_EditableTextBlock a, _EditableTextBlock b) {
    return a.kind == b.kind &&
        a.kind == NoteTextBlockKind.paragraph &&
        a.fontSize == b.fontSize &&
        a.color == b.color &&
        a.bold == b.bold &&
        a.italic == b.italic &&
        a.underline == b.underline &&
        a.strikethrough == b.strikethrough &&
        a.alignment == b.alignment;
  }

  /// Keeps ordinary multiline text in one editable field when adjacent
  /// paragraph blocks share the same style. This restores native selection,
  /// backspace and IME behaviour instead of exposing one field per line.
  void _coalesceParagraphBlocks() {
    if (_blocks.length < 2) return;
    final merged = <_EditableTextBlock>[];
    for (final block in _blocks) {
      if (merged.isNotEmpty && _sameParagraphStyle(merged.last, block)) {
        final previous = merged.last;
        previous.controller.text =
            '${previous.controller.text}\n${block.controller.text}';
        block.dispose();
      } else {
        merged.add(block);
      }
    }
    _blocks
      ..clear()
      ..addAll(merged);
    if (_activeBlockIndex >= _blocks.length) {
      _activeBlockIndex = _blocks.isEmpty ? 0 : _blocks.length - 1;
    }
  }

  int get _editableTextBlockCount => _blocks
      .where(
        (block) =>
            block.kind == NoteTextBlockKind.paragraph ||
            block.kind == NoteTextBlockKind.checklist,
      )
      .length;

  _EditableTextBlock? get _activeBlock {
    if (_blocks.isEmpty) return null;
    if (_activeBlockIndex < 0) _activeBlockIndex = 0;
    if (_activeBlockIndex >= _blocks.length) {
      _activeBlockIndex = _blocks.length - 1;
    }
    return _blocks[_activeBlockIndex];
  }

  _EditableTextBlock? get _activeTextBlock {
    final block = _activeBlock;
    if (block == null || block.kind == NoteTextBlockKind.divider) return null;
    return block;
  }

  void _showNotice(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  void _refreshWordCount() {
    _wordCount.value = _blocks
        .where((block) => block.kind != NoteTextBlockKind.divider)
        .fold<int>(
          0,
          (sum, block) => sum + block.controller.text.characters.length,
        );
  }

  void _syncComponent() {
    widget.component.text = _blocks
        .map((block) {
          if (block.kind == NoteTextBlockKind.divider) return '────────';
          if (block.kind == NoteTextBlockKind.image) {
            return '[${_l10n.component_image}]';
          }
          if (block.kind == NoteTextBlockKind.audio) {
            return '[${_l10n.component_audio}]';
          }
          if (block.kind == NoteTextBlockKind.drawing) {
            return '[${_l10n.component_drawing}]';
          }
          if (block.kind == NoteTextBlockKind.checklist) {
            return '${block.done ? '☑' : '☐'} ${block.controller.text}';
          }
          return block.controller.text;
        })
        .join('\n');
    widget.component.textBlocks = [
      for (final block in _blocks) block.toModel(),
    ];
    _refreshWordCount();
    widget.onChanged();
    if (!_historySuspended) _scheduleHistoryCommit();
  }

  _TextNoteSnapshot _captureSnapshot() => _TextNoteSnapshot({
    'title': _titleController.text,
    'blocks': [for (final block in _blocks) block.toModel().toMap()],
    'background_type': widget.component.textBackgroundType,
    'background_color': widget.component.textBackgroundColor,
    'background_image': widget.component.textBackgroundImage,
  });

  bool get _canUndo => _undoStack.isNotEmpty || _perfHistoryDebounce != null;
  bool get _canRedo => _redoStack.isNotEmpty;

  void _addUndoSnapshot(_TextNoteSnapshot snapshot) {
    _undoStack.add(snapshot);
    _undoBytes += snapshot.estimatedBytes;
    while (_undoStack.length > 24 ||
        (_undoStack.length > 1 && _undoBytes > _maxHistoryBytes)) {
      _undoBytes -= _undoStack.removeAt(0).estimatedBytes;
    }
  }

  void _addRedoSnapshot(_TextNoteSnapshot snapshot) {
    _redoStack.add(snapshot);
    _redoBytes += snapshot.estimatedBytes;
    while (_redoStack.length > 24 ||
        (_redoStack.length > 1 && _redoBytes > _maxHistoryBytes)) {
      _redoBytes -= _redoStack.removeAt(0).estimatedBytes;
    }
  }

  void _clearRedo() {
    _redoStack.clear();
    _redoBytes = 0;
  }

  // PERF HOTFIX: input events only restart a timer. The full document is
  // captured at most once per 650 ms pause instead of on every keystroke.
  void _scheduleHistoryCommit() {
    _perfHistoryDebounce?.cancel();
    _perfHistoryDebounce = Timer(const Duration(milliseconds: 650), () {
      _perfHistoryDebounce = null;
      _commitHistory();
    });
  }

  void _commitHistory() {
    if (_historySuspended) return;
    final current = _captureSnapshot();
    final previous = _historyCurrent;
    if (previous == null) {
      _historyCurrent = current;
      return;
    }
    _addUndoSnapshot(previous);
    _clearRedo();
    _historyCurrent = current;
    if (mounted) setState(() {});
  }

  void _flushHistory() {
    _perfHistoryDebounce?.cancel();
    _perfHistoryDebounce = null;
    _commitHistory();
  }

  void _undo() {
    _flushHistory();
    if (_undoStack.isEmpty) return;
    final current = _captureSnapshot();
    final target = _undoStack.removeLast();
    _undoBytes -= target.estimatedBytes;
    _addRedoSnapshot(current);
    _restoreSnapshot(target);
  }

  void _redo() {
    _flushHistory();
    if (_redoStack.isEmpty) return;
    final current = _captureSnapshot();
    final target = _redoStack.removeLast();
    _redoBytes -= target.estimatedBytes;
    _addUndoSnapshot(current);
    _restoreSnapshot(target);
  }

  _EditableTextBlock _blockFromModel(NoteTextBlock model) {
    return _EditableTextBlock(
      id: model.id,
      kind: model.kind,
      text: model.text,
      done: model.done,
      mediaPath: model.mediaPath,
      strokes: model.drawingStrokes,
      fontSize: model.fontSize > 0 ? model.fontSize : 16,
      color: model.color,
      bold: model.bold,
      italic: model.italic,
      underline: model.underline,
      strikethrough: model.strikethrough,
      alignment: switch (model.alignment) {
        'center' => TextAlign.center,
        'right' => TextAlign.right,
        _ => TextAlign.left,
      },
    );
  }

  void _restoreSnapshot(_TextNoteSnapshot snapshot) {
    _historySuspended = true;
    final oldBlocks = List<_EditableTextBlock>.of(_blocks);
    final restored = <_EditableTextBlock>[];
    final rawBlocks = snapshot.data['blocks'];
    if (rawBlocks is List) {
      for (final raw in rawBlocks) {
        if (raw is Map) {
          restored.add(
            _blockFromModel(
              NoteTextBlock.fromMap(<String, dynamic>{
                for (final entry in raw.entries)
                  entry.key.toString(): entry.value,
              }),
            ),
          );
        }
      }
    }
    if (restored.isEmpty) {
      restored.add(
        _EditableTextBlock(
          id: NoteStore.newId(),
          kind: NoteTextBlockKind.paragraph,
        ),
      );
    }

    _blocks
      ..clear()
      ..addAll(restored);
    _activeBlockIndex = _activeBlockIndex.clamp(0, _blocks.length - 1);
    _titleController.text = snapshot.data['title']?.toString() ?? '';
    widget.component.textBackgroundType =
        snapshot.data['background_type']?.toString() ?? 'none';
    widget.component.textBackgroundColor =
        (snapshot.data['background_color'] as num?)?.toInt() ?? 0;
    widget.component.textBackgroundImage =
        snapshot.data['background_image']?.toString() ?? '';
    _syncComponent();
    for (final block in oldBlocks) {
      _disposeLater(block);
    }
    _historyCurrent = _captureSnapshot();
    _historySuspended = false;
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _blocks.isEmpty) return;
        final index = _activeBlockIndex.clamp(0, _blocks.length - 1);
        _focusBlock(_blocks[index]);
      });
    }
  }

  void _setActive(int index) {
    if (_activeBlockIndex == index) return;
    setState(() => _activeBlockIndex = index);
  }

  _EditableTextBlock _newBlock({
    required NoteTextBlockKind kind,
    String text = '',
    String mediaPath = '',
    List<DrawingStroke>? strokes,
    _EditableTextBlock? template,
  }) {
    return _EditableTextBlock(
      id: NoteStore.newId(),
      kind: kind,
      text: text,
      mediaPath: mediaPath,
      strokes: strokes,
      fontSize: template?.fontSize ?? 16,
      color: template?.color ?? widget.component.textColor,
      bold: template?.bold ?? widget.component.textBold,
      italic: template?.italic ?? false,
      underline: template?.underline ?? false,
      strikethrough: template?.strikethrough ?? false,
      alignment: template?.alignment ?? TextAlign.left,
    );
  }

  void _dismissBlockFocus({_EditableTextBlock? except}) {
    FocusManager.instance.primaryFocus?.unfocus(
      disposition: UnfocusDisposition.scope,
    );
    for (final block in _blocks) {
      if (!identical(block, except)) block.focusNode.unfocus();
    }
  }

  void _focusBlock(_EditableTextBlock block) {
    // Divider insertion creates a new paragraph while the previous field may
    // still own the IME connection. Explicitly drop every other block focus
    // before requesting the new one so Android cannot leave two visible
    // carets/IME connections behind.
    _dismissBlockFocus(except: block);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = _blocks.indexOf(block);
      if (index < 0) return;
      setState(() => _activeBlockIndex = index);
      FocusScope.of(context).requestFocus(block.focusNode);
    });
  }

  void _handleBlockChanged(int index, String value) {
    // A paragraph is deliberately a multiline field. Newlines are kept inside
    // the block so backspace, selection and IME edits behave like a normal
    // text editor. Blocks are split into individual sentences only when the
    // user applies sentence-level formatting.
    _syncComponent();
  }

  void _disposeLater(_EditableTextBlock block) {
    WidgetsBinding.instance.addPostFrameCallback((_) => block.dispose());
  }

  /// Splits the active editable block into one block per line and returns the
  /// block containing the caret. This keeps formatting scoped to a single
  /// sentence while normal multiline typing remains natural.
  _EditableTextBlock? _splitActiveSentenceAtCaret() {
    final block = _activeTextBlock;
    if (block == null) return null;
    final text = block.controller.text;
    if (!text.contains('\n')) return block;

    final selection = block.controller.selection;
    final caret = selection.isValid
        ? selection.baseOffset.clamp(0, text.length)
        : text.length;
    final starts = <int>[0];
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '\n') starts.add(i + 1);
    }
    var partIndex = 0;
    for (var i = 0; i < starts.length; i++) {
      final end = i + 1 < starts.length ? starts[i + 1] - 1 : text.length;
      if (caret <= end || i == starts.length - 1) {
        partIndex = i;
        break;
      }
    }
    final parts = text.split('\n');
    final index = _blocks.indexOf(block);
    if (index < 0) return block;
    final created = <_EditableTextBlock>[
      for (final part in parts)
        _newBlock(kind: block.kind, text: part, template: block),
    ];
    setState(() {
      _blocks.removeAt(index);
      _blocks.insertAll(index, created);
      _activeBlockIndex = index + partIndex;
    });
    _syncComponent();
    _disposeLater(block);

    final target = created[partIndex];
    final offset = (caret - starts[partIndex]).clamp(
      0,
      target.controller.text.length,
    );
    _dismissBlockFocus(except: target);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetIndex = _blocks.indexOf(target);
      if (targetIndex < 0) return;
      setState(() => _activeBlockIndex = targetIndex);
      FocusScope.of(context).requestFocus(target.focusNode);
      target.controller.selection = TextSelection.collapsed(offset: offset);
    });
    return target;
  }

  String get _documentPlainText => _blocks
      .map((block) {
        if (block.kind == NoteTextBlockKind.divider) return '────────';
        if (block.kind == NoteTextBlockKind.image) {
          return '[${_l10n.component_image}]';
        }
        if (block.kind == NoteTextBlockKind.audio) {
          return '[${_l10n.component_audio}]';
        }
        if (block.kind == NoteTextBlockKind.drawing) {
          return '[${_l10n.component_drawing}]';
        }
        if (block.kind == NoteTextBlockKind.checklist) {
          return '${block.done ? '☑' : '☐'} ${block.controller.text}';
        }
        return block.controller.text;
      })
      .join('\n');

  Future<void> _selectAllDocument() async {
    final text = _documentPlainText;
    if (text.trim().isEmpty) {
      _showNotice(_l10n.no_text_content);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _DocumentSelectionDialog(text: text),
    );
  }

  bool _handleGlobalSelectAll(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.keyA) return false;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return false;
    if (_editableTextBlockCount <= 1) return false;
    final block = _activeBlock;
    if (block == null || !block.focusNode.hasFocus) return false;
    // Let the field perform its normal selection first, then expand the
    // selection/copy operation to the whole document.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_selectAllDocument());
    });
    return false;
  }

  bool _handleGlobalBackspace(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.backspace) return false;
    final block = _activeBlock;
    if (block == null || !block.focusNode.hasFocus) return false;
    final selection = block.controller.selection;
    if (selection.isValid &&
        selection.isCollapsed &&
        selection.baseOffset == 0) {
      _mergeBlockWithPrevious(block);
    }
    return false;
  }

  void _mergeBlockWithPrevious(_EditableTextBlock block) {
    _flushHistory();
    var index = _blocks.indexOf(block);
    if (index <= 0) return;

    // Backspace at the start of a block removes an adjacent divider first.
    while (index > 0 && _blocks[index - 1].kind == NoteTextBlockKind.divider) {
      final divider = _blocks.removeAt(index - 1);
      _disposeLater(divider);
      index--;
    }
    if (index <= 0) {
      setState(() => _activeBlockIndex = 0);
      _focusBlock(block);
      _syncComponent();
      return;
    }

    final previous = _blocks[index - 1];
    final previousLength = previous.controller.text.length;
    final mergedText = previous.controller.text + block.controller.text;
    previous.controller.value = TextEditingValue(
      text: mergedText,
      selection: TextSelection.collapsed(offset: previousLength),
    );
    setState(() {
      _blocks.removeAt(index);
      _activeBlockIndex = index - 1;
    });
    _disposeLater(block);
    _syncComponent();
    _focusBlock(previous);
  }

  KeyEventResult _handleBlockKeyEvent(
    _EditableTextBlock block,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    final command = keyboard.isControlPressed || keyboard.isMetaPressed;
    if (command && event.logicalKey == LogicalKeyboardKey.keyZ) {
      if (keyboard.isShiftPressed) {
        _redo();
      } else {
        _undo();
      }
      return KeyEventResult.handled;
    }
    if (command && event.logicalKey == LogicalKeyboardKey.keyY) {
      _redo();
      return KeyEventResult.handled;
    }
    final selection = block.controller.selection;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        selection.isValid &&
        selection.isCollapsed &&
        selection.baseOffset == 0) {
      _mergeBlockWithPrevious(block);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _insertChecklist() {
    _flushHistory();
    final template = _activeTextBlock;
    final index = (_activeBlockIndex + 1).clamp(0, _blocks.length).toInt();
    final block = _newBlock(
      kind: NoteTextBlockKind.checklist,
      template: template,
    );
    setState(() {
      _blocks.insert(index, block);
      _activeBlockIndex = index;
      _panel = _TextToolbarPanel.none;
    });
    _syncComponent();
    _focusBlock(block);
  }

  void _insertDivider() {
    _flushHistory();
    final template = _activeTextBlock;
    final index = (_activeBlockIndex + 1).clamp(0, _blocks.length).toInt();
    final divider = _newBlock(
      kind: NoteTextBlockKind.divider,
      template: template,
    );
    final paragraph = _newBlock(
      kind: NoteTextBlockKind.paragraph,
      template: template,
    );
    setState(() {
      _blocks.insertAll(index, [divider, paragraph]);
      _activeBlockIndex = index + 1;
      _panel = _TextToolbarPanel.none;
    });
    _syncComponent();
    _focusBlock(paragraph);
  }

  Future<void> _insertImageBlock() async {
    _flushHistory();
    final path = await PlatformMediaService.pickImageFromGallery();
    if (!mounted) return;
    if (path == null || path.isEmpty) {
      _showNotice(_l10n.image_pick_failed);
      return;
    }
    final index = (_activeBlockIndex + 1).clamp(0, _blocks.length).toInt();
    final block = _newBlock(
      kind: NoteTextBlockKind.image,
      mediaPath: path,
      template: _activeTextBlock,
    );
    setState(() {
      _blocks.insert(index, block);
      _activeBlockIndex = index;
      _panel = _TextToolbarPanel.none;
    });
    _syncComponent();
  }

  void _insertDrawingBlock() {
    _flushHistory();
    final index = (_activeBlockIndex + 1).clamp(0, _blocks.length).toInt();
    final block = _newBlock(
      kind: NoteTextBlockKind.drawing,
      strokes: <DrawingStroke>[],
      template: _activeTextBlock,
    );
    setState(() {
      _blocks.insert(index, block);
      _activeBlockIndex = index;
      _panel = _TextToolbarPanel.none;
    });
    _syncComponent();
  }

  Future<void> _toggleAudioRecording() async {
    _flushHistory();
    if (_recordingAudio) {
      final path = await PlatformMediaService.stopRecording();
      if (!mounted) return;
      setState(() => _recordingAudio = false);
      if (path == null || path.isEmpty) {
        _showNotice(_l10n.record_failed);
        return;
      }
      final index = (_activeBlockIndex + 1).clamp(0, _blocks.length).toInt();
      final block = _newBlock(
        kind: NoteTextBlockKind.audio,
        mediaPath: path,
        template: _activeTextBlock,
      );
      setState(() {
        _blocks.insert(index, block);
        _activeBlockIndex = index;
        _panel = _TextToolbarPanel.none;
      });
      _syncComponent();
      return;
    }

    final started = await PlatformMediaService.startRecording();
    if (!mounted) return;
    if (!started) {
      _showNotice(_l10n.mic_permission_denied);
      return;
    }
    setState(() => _recordingAudio = true);
  }

  Future<void> _showImagePreview(String path) async {
    final l10n = _l10n;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.close_image_preview,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, _) => SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SourceImageView(
                      source: path,
                      fit: BoxFit.contain,
                      loading: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                tooltip: l10n.close,
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  void _removeBlock(_EditableTextBlock block) {
    _flushHistory();
    if (_blocks.length <= 1) {
      _showNotice(_l10n.select_sentence_first);
      return;
    }
    final index = _blocks.indexOf(block);
    if (index < 0) return;
    setState(() {
      _blocks.removeAt(index);
      if (_activeBlockIndex >= _blocks.length) {
        _activeBlockIndex = _blocks.length - 1;
      }
    });
    _disposeLater(block);
    _syncComponent();
  }

  void _insertTime() {
    _flushHistory();
    final block = _activeTextBlock;
    if (block == null) {
      _showNotice(_l10n.select_sentence_first);
      return;
    }
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final snippet = '[$hour:$minute] ';
    final selection = block.controller.selection;
    final start = selection.isValid
        ? selection.start
        : block.controller.text.length;
    final end = selection.isValid
        ? selection.end
        : block.controller.text.length;
    final next = block.controller.text.replaceRange(start, end, snippet);
    block.controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
    _syncComponent();
    setState(() => _panel = _TextToolbarPanel.none);
    _focusBlock(block);
  }

  void _applyToActiveSentence(void Function(_EditableTextBlock block) change) {
    _flushHistory();
    final block = _splitActiveSentenceAtCaret();
    if (block == null) {
      _showNotice(_l10n.select_sentence_first);
      return;
    }
    setState(() => change(block));
    _syncComponent();
  }

  void _setFontSize(double size) {
    _applyToActiveSentence((block) => block.fontSize = size);
  }

  void _setAlignment(TextAlign alignment) {
    _applyToActiveSentence((block) => block.alignment = alignment);
  }

  Future<void> _showPalette() async {
    final block = _splitActiveSentenceAtCaret();
    if (block == null) {
      _showNotice(_l10n.select_sentence_first);
      return;
    }
    var picked = block.color == 0
        ? Theme.of(context).colorScheme.onSurface
        : Color(block.color);
    final scheme = Theme.of(context).colorScheme;
    const swatches = <Color>[
      Color(0xFF1F1F1F),
      Color(0xFF4C5B70),
      Color(0xFF7B4B94),
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFFC62828),
      Color(0xFFEF6C00),
      Color(0xFFFFFFFF),
    ];
    final result = await showAdaptiveSurface<Color>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _l10n.text_color,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _l10n.current_sentence_only,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final color in swatches)
                      InkWell(
                        onTap: () => setSheetState(() => picked = color),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: picked == color ? 3 : 1,
                              color: picked == color
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ColorPicker(
                  pickerColor: picked,
                  onColorChanged: (color) =>
                      setSheetState(() => picked = color),
                  enableAlpha: false,
                  labelTypes: const [ColorLabelType.hex],
                  pickerAreaHeightPercent: 0.55,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, picked),
                  child: Text(_l10n.apply_label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => block.color = result.toARGB32());
    _syncComponent();
  }

  Future<void> _applyBackgroundChoice(_TextBackgroundChoice choice) async {
    _flushHistory();
    switch (choice.action) {
      case 'pick_image':
        await _pickBackgroundImage();
        return;
      case 'crop_image':
        await _cropCurrentBackground();
        return;
      case 'remove_image':
        setState(() {
          widget.component.textBackgroundType = 'none';
          widget.component.textBackgroundImage = '';
        });
        _syncComponent();
        return;
    }
    setState(() {
      widget.component.textBackgroundType = choice.type;
      widget.component.textBackgroundColor = choice.color;
    });
    _syncComponent();
  }

  Future<void> _showBackgroundPicker() async {
    final scheme = Theme.of(context).colorScheme;
    var baseColor = widget.component.textBackgroundColor == 0
        ? scheme.surface
        : Color(widget.component.textBackgroundColor);
    const swatches = <Color>[
      Color(0xFFF8F5EF),
      Color(0xFFFFF8E1),
      Color(0xFFE8F5E9),
      Color(0xFFE3F2FD),
      Color(0xFFF3E5F5),
      Color(0xFF1F1F1F),
      Color(0xFF4C5B70),
      Color(0xFFFFFFFF),
    ];

    Widget gridChoice(String type, String label) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(
            context,
            _TextBackgroundChoice(type: type, color: baseColor.toARGB32()),
          ),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: NoteCardGridPainter(
                        style: _noteCardGridStyle(type),
                        backgroundColor: baseColor,
                        lineColor: baseColor.computeLuminance() > 0.55
                            ? const Color(0x33000000)
                            : const Color(0x44FFFFFF),
                      ),
                      isComplex: true,
                      willChange: false,
                      size: Size.infinite,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: scheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: 11,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = await showAdaptiveSurface<_TextBackgroundChoice>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _l10n.choose_background,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _l10n.solid_background,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final color in swatches)
                      InkWell(
                        onTap: () => setSheetState(() => baseColor = color),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: baseColor == color ? 3 : 1,
                              color: baseColor == color
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          _TextBackgroundChoice(
                            type: 'color',
                            color: baseColor.toARGB32(),
                          ),
                        ),
                        child: Text(_l10n.apply_solid_color),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(
                        sheetContext,
                        const _TextBackgroundChoice(type: 'none'),
                      ),
                      child: Text(_l10n.no_background),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _l10n.grid_background,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    gridChoice('grid_square', _l10n.square_grid),
                    const SizedBox(width: 8),
                    gridChoice('grid_dots', _l10n.dot_grid),
                    const SizedBox(width: 8),
                    gridChoice('grid_lines', _l10n.horizontal_lines),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _l10n.image_background,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.component.textBackgroundImage.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: SourceImageView(
                        source: widget.component.textBackgroundImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          const _TextBackgroundChoice(
                            type: 'image',
                            action: 'pick_image',
                          ),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          widget.component.textBackgroundImage.isEmpty
                              ? _l10n.pick_from_gallery
                              : _l10n.change_image,
                        ),
                      ),
                    ),
                    if (widget.component.textBackgroundImage.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          const _TextBackgroundChoice(
                            type: 'image',
                            action: 'crop_image',
                          ),
                        ),
                        child: Text(_l10n.crop_again),
                      ),
                      IconButton(
                        tooltip: _l10n.remove_image_background,
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          const _TextBackgroundChoice(
                            type: 'none',
                            action: 'remove_image',
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    await _applyBackgroundChoice(result);
  }

  Future<void> _pickBackgroundImage() async {
    final path = await PlatformMediaService.pickImageFromGallery();
    if (!mounted) return;
    if (path == null || path.isEmpty) {
      _showNotice(_l10n.image_pick_failed);
      return;
    }
    final cropped = await _showBackgroundCrop(path);
    if (!mounted || cropped == null) return;
    setState(() {
      widget.component.textBackgroundType = 'image';
      widget.component.textBackgroundImage = cropped;
    });
    _syncComponent();
  }

  Future<void> _cropCurrentBackground() async {
    final path = widget.component.textBackgroundImage;
    if (path.isEmpty) return;
    final cropped = await _showBackgroundCrop(path);
    if (!mounted || cropped == null) return;
    setState(() {
      widget.component.textBackgroundType = 'image';
      widget.component.textBackgroundImage = cropped;
    });
    _syncComponent();
  }

  Future<String?> _showBackgroundCrop(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      if (mounted) _showNotice(_l10n.background_image_missing);
      return null;
    }
    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) {
      if (mounted) _showNotice(_l10n.cannot_read_background);
      return null;
    }
    if (!mounted) return null;

    var zoom = 1.0;
    var anchorX = 1;
    var anchorY = 1;
    const cropAspect = 3 / 4;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(_l10n.crop_background),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: cropAspect,
                  child: ClipRect(
                    child: Transform.scale(
                      scale: zoom,
                      alignment: Alignment(
                        (anchorX - 1).toDouble(),
                        (anchorY - 1).toDouble(),
                      ),
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        alignment: Alignment(
                          (anchorX - 1).toDouble(),
                          (anchorY - 1).toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final entry in <(int, String)>[
                      (0, _l10n.crop_top),
                      (1, _l10n.crop_middle),
                      (2, _l10n.crop_bottom),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(entry.$2),
                          selected: anchorY == entry.$1,
                          onSelected: (_) =>
                              setDialogState(() => anchorY = entry.$1),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Text(_l10n.zoom),
                    Expanded(
                      child: Slider(
                        value: zoom,
                        min: 1,
                        max: 3,
                        divisions: 20,
                        label: zoom.toStringAsFixed(1),
                        onChanged: (value) =>
                            setDialogState(() => zoom = value),
                      ),
                    ),
                  ],
                ),
                Text(
                  _l10n.crop_hint,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, sourcePath),
              child: Text(_l10n.use_original),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  var cropWidth = original.width;
                  var cropHeight = (cropWidth / cropAspect).round();
                  if (cropHeight > original.height) {
                    cropHeight = original.height;
                    cropWidth = (cropHeight * cropAspect).round();
                  }
                  cropWidth = (cropWidth / zoom).round().clamp(
                    1,
                    original.width,
                  );
                  cropHeight = (cropHeight / zoom).round().clamp(
                    1,
                    original.height,
                  );
                  final maxX = original.width - cropWidth;
                  final maxY = original.height - cropHeight;
                  final x = (maxX * (anchorX / 2)).round();
                  final y = (maxY * (anchorY / 2)).round();
                  final cropped = img.copyCrop(
                    original,
                    x: x,
                    y: y,
                    width: cropWidth,
                    height: cropHeight,
                  );
                  final encoded = img.encodeJpg(cropped, quality: 92);
                  final directory = await getApplicationDocumentsDirectory();
                  final output = File(
                    '${directory.path}${Platform.pathSeparator}'
                    'note_background_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  );
                  await output.writeAsBytes(encoded, flush: true);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, output.path);
                  }
                } catch (error) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    _showNotice(_l10n.crop_failed(error.toString()));
                  }
                }
              },
              child: Text(_l10n.finish_crop),
            ),
          ],
        ),
      ),
    );
    return result;
  }

  void _togglePanel(_TextToolbarPanel panel) {
    setState(() {
      _panel = _panel == panel ? _TextToolbarPanel.none : panel;
    });
  }

  Color _defaultTextColor(ColorScheme scheme) {
    switch (widget.component.textBackgroundType) {
      case 'color':
      case 'grid_square':
      case 'grid_dots':
      case 'grid_lines':
        final background = widget.component.textBackgroundColor == 0
            ? scheme.surface
            : Color(widget.component.textBackgroundColor);
        return background.computeLuminance() > 0.55
            ? const Color(0xFF1F1F1F)
            : Colors.white;
      default:
        return scheme.onSurface;
    }
  }

  Color _chromeSurface(ColorScheme scheme) {
    switch (widget.component.textBackgroundType) {
      case 'image':
        return scheme.surface.withValues(alpha: 0.64);
      case 'color':
      case 'grid_square':
      case 'grid_dots':
      case 'grid_lines':
        final background = widget.component.textBackgroundColor == 0
            ? scheme.surface
            : Color(widget.component.textBackgroundColor);
        return background.withValues(alpha: 0.86);
      default:
        return scheme.surface.withValues(alpha: 0.92);
    }
  }

  TextStyle _styleFor(_EditableTextBlock block, ColorScheme scheme) {
    TextDecoration? decoration;
    if (block.underline && block.strikethrough) {
      decoration = TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    } else if (block.underline) {
      decoration = TextDecoration.underline;
    } else if (block.strikethrough) {
      decoration = TextDecoration.lineThrough;
    }
    return TextStyle(
      fontFamily: 'ResourceHanCN',
      fontSize: DeviceInfo.pt(block.fontSize),
      fontWeight: block.bold ? FontWeight.w700 : FontWeight.normal,
      fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
      decoration: decoration,
      color: block.color == 0 ? _defaultTextColor(scheme) : Color(block.color),
    );
  }

  Widget _buildBlock(int index, ColorScheme scheme) {
    final block = _blocks[index];
    if (block.kind == NoteTextBlockKind.divider) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: DeviceInfo.pt(4)),
        child: Divider(
          height: 1,
          thickness: 1,
          color: _defaultTextColor(scheme).withValues(alpha: 0.28),
        ),
      );
    }

    if (block.kind == NoteTextBlockKind.drawing) {
      return _InlineDrawingBlock(
        strokes: block.drawingStrokes,
        scheme: scheme,
        l10n: _l10n,
        onChanged: _syncComponent,
        onRemove: () => _removeBlock(block),
      );
    }

    if (block.kind == NoteTextBlockKind.image) {
      if (block.mediaPath.isEmpty) {
        return Text(
          _l10n.no_images,
          style: TextStyle(
            color: _defaultTextColor(scheme).withValues(alpha: 0.5),
          ),
        );
      }
      return Stack(
        children: [
          GestureDetector(
            onTap: () => _showImagePreview(block.mediaPath),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: DeviceInfo.pt(180),
                child: SourceImageView(
                  source: block.mediaPath,
                  fit: BoxFit.cover,
                  error: ColoredBox(
                    color: scheme.onSurface.withValues(alpha: 0.06),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: scheme.surface.withValues(alpha: 0.86),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: _l10n.delete,
                visualDensity: VisualDensity.compact,
                onPressed: () => _removeBlock(block),
                icon: Icon(Icons.close, size: 18, color: scheme.onSurface),
              ),
            ),
          ),
        ],
      );
    }

    if (block.kind == NoteTextBlockKind.audio) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: _l10n.play,
              onPressed: block.mediaPath.isEmpty
                  ? null
                  : () async {
                      final played = await PlatformMediaService.playAudio(
                        block.mediaPath,
                      );
                      if (!played && mounted) {
                        _showNotice(_l10n.audio_unsupported);
                      }
                    },
              icon: Icon(Icons.play_circle_outline, color: scheme.primary),
            ),
            Expanded(
              child: Text(
                block.mediaPath.isEmpty
                    ? _l10n.no_recording
                    : _l10n.component_audio,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  color: _defaultTextColor(scheme),
                ),
              ),
            ),
            IconButton(
              tooltip: _l10n.delete,
              onPressed: () => _removeBlock(block),
              icon: Icon(
                Icons.delete_outline,
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      );
    }

    final field = Focus(
      onKeyEvent: (node, event) => _handleBlockKeyEvent(block, event),
      child: TextField(
        controller: block.controller,
        focusNode: block.focusNode,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        textAlign: block.alignment,
        textAlignVertical: TextAlignVertical.top,
        style: _styleFor(block, scheme),
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: block.kind == NoteTextBlockKind.checklist
              ? _l10n.checklist_item_hint
              : null,
          hintStyle: TextStyle(
            fontFamily: 'ResourceHanCN',
            fontSize: DeviceInfo.pt(block.fontSize),
            color: _defaultTextColor(scheme).withValues(alpha: 0.35),
          ),
        ),
        onTap: () => _setActive(index),
        onChanged: (value) => _handleBlockChanged(index, value),
        contextMenuBuilder: _editableTextBlockCount > 1
            ? (menuContext, editableTextState) {
                final items = editableTextState.contextMenuButtonItems
                    .where(
                      (item) => item.type != ContextMenuButtonType.selectAll,
                    )
                    .toList();
                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: [
                    ContextMenuButtonItem(
                      label: _l10n.select_all_document,
                      onPressed: () {
                        editableTextState.hideToolbar();
                        _selectAllDocument();
                      },
                    ),
                    ...items,
                  ],
                );
              }
            : null,
      ),
    );

    if (block.kind == NoteTextBlockKind.checklist) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: DeviceInfo.pt(2)),
            child: Checkbox(
              value: block.done,
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                _flushHistory();
                setState(() {
                  block.done = value ?? false;
                  _activeBlockIndex = index;
                });
                _syncComponent();
              },
            ),
          ),
          Expanded(child: field),
        ],
      );
    }

    return field;
  }

  Widget _buildInsertPanel(ColorScheme scheme, Color foreground) {
    Widget insertButton({
      required String label,
      required IconData icon,
      required VoidCallback onPressed,
    }) {
      return SizedBox(
        width: DeviceInfo.pt(108),
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: DeviceInfo.pt(4)),
            visualDensity: VisualDensity.compact,
            foregroundColor: foreground,
          ),
          icon: Icon(icon, size: 18),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontFamily: 'ResourceHanCN', fontSize: 11),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          insertButton(
            label: _l10n.insert_checklist_item,
            icon: Icons.check_box_outlined,
            onPressed: _insertChecklist,
          ),
          insertButton(
            label: _l10n.component_drawing,
            icon: Icons.brush_outlined,
            onPressed: _insertDrawingBlock,
          ),
          insertButton(
            label: _l10n.add_image,
            icon: Icons.image_outlined,
            onPressed: _insertImageBlock,
          ),
          insertButton(
            label: _recordingAudio ? _l10n.stop_recording : _l10n.record_audio,
            icon: _recordingAudio ? Icons.stop_circle : Icons.mic_none,
            onPressed: _toggleAudioRecording,
          ),
          insertButton(
            label: _l10n.insert_divider,
            icon: Icons.horizontal_rule,
            onPressed: _insertDivider,
          ),
          insertButton(
            label: _l10n.insert_current_time,
            icon: Icons.schedule_outlined,
            onPressed: _insertTime,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatPanel(ColorScheme scheme, Color foreground) {
    final block = _activeTextBlock;
    Widget toggle(
      IconData icon,
      bool selected,
      VoidCallback onPressed, {
      String? tooltip,
      String? label,
    }) {
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? foreground.withValues(alpha: 0.16)
              : Colors.transparent,
          foregroundColor: foreground,
          visualDensity: VisualDensity.compact,
        ),
        icon: label == null
            ? Icon(icon, size: 20)
            : Text(
                label,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          toggle(
            Icons.title,
            block?.fontSize == 26,
            () => _setFontSize(26),
            tooltip: 'H1',
            label: 'H1',
          ),
          toggle(
            Icons.title,
            block?.fontSize == 21,
            () => _setFontSize(21),
            tooltip: 'H2',
            label: 'H2',
          ),
          toggle(
            Icons.text_fields,
            block?.fontSize == 16,
            () => _setFontSize(16),
            tooltip: _l10n.body_text,
            label: 'Aa',
          ),
          SizedBox(
            height: 28,
            child: VerticalDivider(
              width: 16,
              color: foreground.withValues(alpha: 0.18),
            ),
          ),
          toggle(Icons.format_bold, block?.bold ?? false, () {
            _applyToActiveSentence((value) => value.bold = !value.bold);
          }, tooltip: _l10n.bold),
          toggle(Icons.format_italic, block?.italic ?? false, () {
            _applyToActiveSentence((value) => value.italic = !value.italic);
          }, tooltip: _l10n.italic),
          toggle(Icons.format_underline, block?.underline ?? false, () {
            _applyToActiveSentence(
              (value) => value.underline = !value.underline,
            );
          }, tooltip: _l10n.underline),
          toggle(Icons.format_strikethrough, block?.strikethrough ?? false, () {
            _applyToActiveSentence((value) {
              value.strikethrough = !value.strikethrough;
            });
          }, tooltip: _l10n.strikethrough),
          SizedBox(
            height: 28,
            child: VerticalDivider(
              width: 16,
              color: foreground.withValues(alpha: 0.18),
            ),
          ),
          toggle(
            Icons.format_align_left,
            block?.alignment == TextAlign.left,
            () {
              _setAlignment(TextAlign.left);
            },
            tooltip: _l10n.align_left,
          ),
          toggle(
            Icons.format_align_center,
            block?.alignment == TextAlign.center,
            () {
              _setAlignment(TextAlign.center);
            },
            tooltip: _l10n.align_center,
          ),
          toggle(
            Icons.format_align_right,
            block?.alignment == TextAlign.right,
            () {
              _setAlignment(TextAlign.right);
            },
            tooltip: _l10n.align_right,
          ),
        ],
      ),
    );
  }

  Widget _buildMorePanel(ColorScheme scheme, Color foreground) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: _l10n.choose_background,
          onPressed: _showBackgroundPicker,
          icon: const Icon(Icons.wallpaper_outlined),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _wordCount,
          builder: (context, count, _) => Text(
            _l10n.word_count(count),
            style: TextStyle(
              fontFamily: 'ResourceHanCN',
              fontSize: 12,
              color: foreground.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryPanel(ColorScheme scheme, Color foreground) {
    return switch (_panel) {
      _TextToolbarPanel.insert => _buildInsertPanel(scheme, foreground),
      _TextToolbarPanel.format => _buildFormatPanel(scheme, foreground),
      _TextToolbarPanel.more => _buildMorePanel(scheme, foreground),
      _TextToolbarPanel.none => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final foreground = _defaultTextColor(scheme);
    final chrome = _chromeSurface(scheme);
    final mediaPadding = MediaQuery.paddingOf(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final topInset = mediaPadding.top + kToolbarHeight + DeviceInfo.pt(4);
    final bottomInset =
        mediaPadding.bottom + keyboardInset + DeviceInfo.pt(124);

    return Stack(
      children: [
        Positioned.fill(
          child: _TextNoteBackground(
            type: widget.component.textBackgroundType,
            color: widget.component.textBackgroundColor,
            imagePath: widget.component.textBackgroundImage,
            scheme: scheme,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: foreground,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: foreground.computeLuminance() > 0.55
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: foreground),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              DeviceInfo.pt(20),
              topInset,
              DeviceInfo.pt(20),
              0,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: DeviceInfo.pt(28),
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.title,
                    hintStyle: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: DeviceInfo.pt(28),
                      fontWeight: FontWeight.w600,
                      color: foreground.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    widget.component.title = value;
                    widget.onChanged();
                    if (!_historySuspended) {
                      _scheduleHistoryCommit();
                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: DeviceInfo.pt(8)),
                Expanded(
                  child: Scrollbar(
                    controller: _textScrollController,
                    thumbVisibility: true,
                    trackVisibility: false,
                    interactive: true,
                    thickness: 3,
                    radius: const Radius.circular(4),
                    child: ListView.builder(
                      controller: _textScrollController,
                      primary: false,
                      padding: EdgeInsets.only(
                        top: DeviceInfo.pt(8),
                        right: DeviceInfo.pt(4),
                        bottom: bottomInset,
                      ),
                      itemCount: _blocks.length,
                      itemBuilder: (context, index) {
                        final kind = _blocks[index].kind;
                        final bottom = switch (kind) {
                          NoteTextBlockKind.paragraph => 0.0,
                          NoteTextBlockKind.checklist => 0.0,
                          NoteTextBlockKind.divider => 0.0,
                          _ => DeviceInfo.pt(8),
                        };
                        return Padding(
                          padding: EdgeInsets.only(bottom: bottom),
                          child: _buildBlock(index, scheme),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: _TextToolbar(
              activePanel: _panel,
              onUndo: _undo,
              onRedo: _redo,
              canUndo: _canUndo,
              canRedo: _canRedo,
              onAdd: () => _togglePanel(_TextToolbarPanel.insert),
              onPalette: _showPalette,
              onFormat: () => _togglePanel(_TextToolbarPanel.format),
              onMore: () => _togglePanel(_TextToolbarPanel.more),
              secondary: _buildSecondaryPanel(scheme, foreground),
              backgroundColor: chrome,
              foregroundColor: foreground,
            ),
          ),
        ),
      ],
    );
  }
}

class _TextToolbar extends StatelessWidget {
  const _TextToolbar({
    required this.activePanel,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    required this.onAdd,
    required this.onPalette,
    required this.onFormat,
    required this.onMore,
    required this.secondary,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final _TextToolbarPanel activePanel;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onAdd;
  final VoidCallback onPalette;
  final VoidCallback onFormat;
  final VoidCallback onMore;
  final Widget secondary;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget button({
      required _TextToolbarPanel panel,
      required String tooltip,
      required IconData icon,
      required VoidCallback onPressed,
    }) {
      final selected = activePanel == panel;
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? foregroundColor.withValues(alpha: 0.16)
              : Colors.transparent,
          foregroundColor: foregroundColor,
        ),
        icon: Icon(icon),
      );
    }

    return ClipRect(
      child: Material(
        color: backgroundColor,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: foregroundColor.withValues(alpha: 0.12)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activePanel != _TextToolbarPanel.none)
                    Container(
                      height: 46,
                      padding: EdgeInsets.symmetric(
                        horizontal: DeviceInfo.pt(4),
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: foregroundColor.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      child: secondary,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        tooltip: l10n.undo,
                        onPressed: canUndo ? onUndo : null,
                        icon: const Icon(Icons.undo),
                      ),
                      IconButton(
                        tooltip: l10n.redo,
                        onPressed: canRedo ? onRedo : null,
                        icon: const Icon(Icons.redo),
                      ),
                      button(
                        panel: _TextToolbarPanel.insert,
                        tooltip: l10n.insert_content,
                        icon: Icons.add_box_outlined,
                        onPressed: onAdd,
                      ),
                      IconButton(
                        tooltip: l10n.text_color,
                        onPressed: onPalette,
                        icon: const Icon(Icons.palette_outlined),
                      ),
                      button(
                        panel: _TextToolbarPanel.format,
                        tooltip: l10n.text_format,
                        icon: Icons.text_fields,
                        onPressed: onFormat,
                      ),
                      button(
                        panel: _TextToolbarPanel.more,
                        tooltip: l10n.more,
                        icon: Icons.more_horiz,
                        onPressed: onMore,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _DrawTool { select, eraser, highlighter, pencil, marker }

class _DrawingWorkbench extends StatefulWidget {
  const _DrawingWorkbench({
    required this.component,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteComponent component;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  State<_DrawingWorkbench> createState() => _DrawingWorkbenchState();
}

class _DrawingWorkbenchState extends State<_DrawingWorkbench> {
  _DrawTool _tool = _DrawTool.pencil;
  DrawingStroke? _current;
  final List<Offset> _eraserPoints = <Offset>[];
  bool _eraserChanged = false;
  List<DrawingStroke>? _eraseBackup;
  final List<List<DrawingStroke>> _undoStates = <List<DrawingStroke>>[];
  final List<List<DrawingStroke>> _redoStates = <List<DrawingStroke>>[];
  final perf.FrameCoalescedNotifier _liveRepaint =
      perf.FrameCoalescedNotifier();
  final perf.FrameCoalescedNotifier _strokesRepaint =
      perf.FrameCoalescedNotifier();
  final TransformationController _transformController =
      TransformationController();
  final Set<int> _activePointers = <int>{};
  int _strokesRevision = 0;
  Color? _strokeColor;
  double _strokeWidth = 2.5;
  Size _viewportSize = Size.zero;
  bool _viewInitialized = false;

  static const double _canvasExtent = 16000;

  static const List<Color> _colorChoices = <Color>[
    Color(0xFF1F1F1F),
    Color(0xFF4C5B70),
    Color(0xFF7B4B94),
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFC62828),
    Color(0xFFEF6C00),
    Colors.white,
  ];

  (Color, double) _styleFor(ColorScheme scheme) {
    final base = _strokeColor ?? scheme.onSurface;
    return switch (_tool) {
      _DrawTool.pencil => (base, _strokeWidth),
      _DrawTool.marker => (base, _strokeWidth + 3.5),
      _DrawTool.highlighter => (
        base.withValues(alpha: 0.35),
        _strokeWidth + 11.5,
      ),
      _DrawTool.eraser => (base, _strokeWidth),
      _DrawTool.select => (base, _strokeWidth),
    };
  }

  Rect? _contentBounds() {
    if (widget.component.strokes.isEmpty) return null;
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final stroke in widget.component.strokes) {
      for (final point in stroke.points) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }
    if (!minX.isFinite || !minY.isFinite) return null;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Matrix4 _viewMatrix(double tx, double ty, double scale) {
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  void _centerCanvas([Size? requestedSize]) {
    final viewport = requestedSize ?? _viewportSize;
    if (viewport.isEmpty) return;
    final bounds = _contentBounds();
    final center =
        bounds?.center ?? const Offset(_canvasExtent / 2, _canvasExtent / 2);
    var scale = 1.0;
    if (bounds != null && bounds.width > 0 && bounds.height > 0) {
      final fitX = (viewport.width - 80) / (bounds.width + 120);
      final fitY = (viewport.height - 80) / (bounds.height + 120);
      scale = math.min(1.0, math.min(fitX, fitY)).clamp(0.15, 1.0);
    }
    final tx = viewport.width / 2 - center.dx * scale;
    final ty = viewport.height / 2 - center.dy * scale;
    _transformController.value = _viewMatrix(tx, ty, scale);
  }

  void _setCanvasBackground(String style) {
    if (widget.component.drawingBackgroundStyle == style) return;
    setState(() => widget.component.drawingBackgroundStyle = style);
    widget.onChanged();
  }

  void _zoomBy(double factor) {
    if (_viewportSize.isEmpty) return;
    final viewportCenter = Offset(
      _viewportSize.width / 2,
      _viewportSize.height / 2,
    );
    final sceneCenter = _transformController.toScene(viewportCenter);
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final nextScale = (currentScale * factor).clamp(0.1, 5.0);
    final tx = viewportCenter.dx - sceneCenter.dx * nextScale;
    final ty = viewportCenter.dy - sceneCenter.dy * nextScale;
    _transformController.value = _viewMatrix(tx, ty, nextScale);
  }

  void _onPointerDown(PointerDownEvent event, ColorScheme scheme) {
    _activePointers.add(event.pointer);
    if (_activePointers.length > 1) {
      if (_current != null && mounted) {
        setState(() => _current = null);
      }
      return;
    }
    _startStroke(event.localPosition, scheme);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_activePointers.length != 1) return;
    _updateStroke(event.localPosition);
  }

  void _onPointerEnd(PointerEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.isEmpty) _endStroke();
  }

  void _startStroke(Offset position, ColorScheme scheme) {
    if (_tool == _DrawTool.select) return;
    if (_tool == _DrawTool.eraser) {
      _eraseBackup = List<DrawingStroke>.of(widget.component.strokes);
      _eraserPoints
        ..clear()
        ..add(position);
      _eraserChanged = false;
      if (_eraseAt(position)) {
        _strokesRevision++;
        _strokesRepaint.notifySoon();
      }
      return;
    }
    final (color, width) = _styleFor(scheme);
    setState(() {
      _current = DrawingStroke(
        points: <Offset>[position],
        color: color.toARGB32(),
        width: width,
      );
    });
  }

  void _updateStroke(Offset position) {
    if (_tool == _DrawTool.eraser) {
      final last = _eraserPoints.isEmpty ? position : _eraserPoints.last;
      final delta = position - last;
      final distance = delta.distance;
      final steps = perf.adaptiveStepCount(distance);
      var changed = false;
      if (steps == 0) {
        changed = _eraseAt(position);
      } else {
        for (var i = 1; i <= steps; i++) {
          final point = last + delta * (i / steps);
          _eraserPoints.add(point);
          changed = _eraseAt(point) || changed;
        }
      }
      // Repaint only the completed-stroke layer; the page tree and grid are
      // untouched while erasing.
      if (changed) {
        _strokesRevision++;
        _strokesRepaint.notifySoon();
      }
      return;
    }
    final stroke = _current;
    if (stroke == null) return;
    final points = stroke.points;
    final last = points.last;
    final delta = position - last;
    final distance = delta.distance;
    if (distance < 1.5) return;
    // Raw pointer events can be sparse when drawing quickly. Fill the gap
    // at a bounded 4 px / 12 sample rate.
    final steps = perf.adaptiveStepCount(distance);
    for (var i = 1; i <= steps; i++) {
      points.add(last + delta * (i / steps));
    }
    // Repaint only the live stroke layer; completed strokes stay cached in a
    // separate RepaintBoundary.
    _liveRepaint.notifySoon();
  }

  void _endStroke() {
    if (_tool == _DrawTool.eraser) {
      final changed = _eraserChanged;
      final backup = _eraseBackup;
      _eraseBackup = null;
      _eraserPoints.clear();
      _eraserChanged = false;
      if (changed && backup != null) {
        _pushDrawingUndo(backup);
        setState(() {});
        widget.onChanged();
      }
      return;
    }
    final stroke = _current;
    if (stroke == null) return;
    // Persist a simplified stroke, not every interpolation sample.
    stroke.points = perf.simplifyPolyline(
      stroke.points,
      epsilon: 0.75,
      maxPoints: 512,
    );
    _pushDrawingUndo(List<DrawingStroke>.of(widget.component.strokes));
    setState(() {
      widget.component.strokes.add(stroke);
      _current = null;
      _strokesRevision++;
    });
    _liveRepaint.notifySoon();
    widget.onChanged();
  }

  void _pushDrawingUndo(List<DrawingStroke> snapshot) {
    _undoStates.add(snapshot);
    if (_undoStates.length > 24) _undoStates.removeAt(0);
    _redoStates.clear();
  }

  bool _eraseAt(Offset center) {
    final before = widget.component.strokes.length;
    widget.component.strokes.removeWhere(
      (stroke) => _strokeIntersectsEraser(stroke, center, 20 + _strokeWidth),
    );
    final changed = widget.component.strokes.length != before;
    if (changed) _eraserChanged = true;
    return changed;
  }

  void _undo() {
    if (_undoStates.isEmpty) return;
    final current = List<DrawingStroke>.of(widget.component.strokes);
    final previous = _undoStates.removeLast();
    _redoStates.add(current);
    setState(() {
      widget.component.strokes
        ..clear()
        ..addAll(previous);
      _strokesRevision++;
    });
    widget.onChanged();
  }

  void _redoStroke() {
    if (_redoStates.isEmpty) return;
    final current = List<DrawingStroke>.of(widget.component.strokes);
    final next = _redoStates.removeLast();
    _undoStates.add(current);
    setState(() {
      widget.component.strokes
        ..clear()
        ..addAll(next);
      _strokesRevision++;
    });
    widget.onChanged();
  }

  Future<void> _pickCustomColor() async {
    final scheme = Theme.of(context).colorScheme;
    var picked = _strokeColor ?? scheme.onSurface;
    final result = await showAdaptiveSurface<Color>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.custom_color,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ColorPicker(
                  pickerColor: picked,
                  onColorChanged: (color) =>
                      setSheetState(() => picked = color),
                  enableAlpha: false,
                  labelTypes: const [ColorLabelType.hex],
                  pickerAreaHeightPercent: 0.55,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, picked),
                  child: Text(AppLocalizations.of(context)!.apply_label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _strokeColor = result);
  }

  Future<void> _confirmClearCanvas() async {
    if (widget.component.strokes.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n.clear),
        content: Text(l10n.clear_drawing_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _pushDrawingUndo(List<DrawingStroke>.of(widget.component.strokes));
    setState(() {
      widget.component.strokes.clear();
      _current = null;
      _strokesRevision++;
    });
    widget.onChanged();
  }

  String _canvasStyleLabel(AppLocalizations l10n) {
    return switch (widget.component.drawingBackgroundStyle) {
      'dots' => l10n.canvas_style_dots,
      'none' => l10n.canvas_style_none,
      _ => l10n.canvas_style_grid,
    };
  }

  Future<void> _showCanvasBackgroundPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showAdaptiveSurface<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: Text(l10n.canvas_style_grid),
              trailing: widget.component.drawingBackgroundStyle == 'grid'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(sheetContext, 'grid'),
            ),
            ListTile(
              leading: const Icon(Icons.blur_on),
              title: Text(l10n.canvas_style_dots),
              trailing: widget.component.drawingBackgroundStyle == 'dots'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(sheetContext, 'dots'),
            ),
            ListTile(
              leading: const Icon(Icons.crop_free),
              title: Text(l10n.canvas_style_none),
              trailing: widget.component.drawingBackgroundStyle == 'none'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(sheetContext, 'none'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    _setCanvasBackground(selected);
  }

  Future<void> _showMore() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showAdaptiveSurface<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: Text(l10n.canvas_background),
              subtitle: Text(_canvasStyleLabel(l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(sheetContext, 'background'),
            ),
            ListTile(
              leading: const Icon(Icons.center_focus_strong),
              title: Text(l10n.center_canvas),
              onTap: () => Navigator.pop(sheetContext, 'center'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(l10n.clear),
              onTap: () => Navigator.pop(sheetContext, 'clear'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.delete),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'background') {
      await _showCanvasBackgroundPicker();
    } else if (action == 'center') {
      _centerCanvas();
    } else if (action == 'clear') {
      await _confirmClearCanvas();
    } else if (action == 'delete') {
      widget.onDelete();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _liveRepaint.dispose();
    _strokesRepaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        title: Text(
          l10n.component_drawing,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            fontSize: DeviceInfo.pt(20),
            color: scheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.undo,
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            tooltip: l10n.redo,
            icon: const Icon(Icons.redo),
            onPressed: _redoStroke,
          ),
          IconButton(
            tooltip: l10n.more,
            icon: const Icon(Icons.more_vert),
            onPressed: _showMore,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DeviceInfo.pt(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DeviceInfo.pt(18)),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(DeviceInfo.pt(18)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewport = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  _viewportSize = viewport;
                  if (!_viewInitialized) {
                    _viewInitialized = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _centerCanvas(viewport);
                    });
                  }
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          constrained: false,
                          panEnabled: _tool == _DrawTool.select,
                          scaleEnabled: true,
                          minScale: 0.1,
                          maxScale: 5,
                          boundaryMargin: const EdgeInsets.all(
                            _canvasExtent / 2,
                          ),
                          child: SizedBox(
                            width: _canvasExtent,
                            height: _canvasExtent,
                            child: ColoredBox(
                              color: scheme.surfaceContainerLowest,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: RepaintBoundary(
                                      child: CustomPaint(
                                        painter: DrawingCanvasGridPainter(
                                          style: switch (widget
                                              .component
                                              .drawingBackgroundStyle) {
                                            'dots' =>
                                              DrawingCanvasGridStyle.dots,
                                            'grid' =>
                                              DrawingCanvasGridStyle.grid,
                                            _ => DrawingCanvasGridStyle.none,
                                          },
                                          gridColor: scheme.onSurface
                                              .withValues(alpha: 0.055),
                                          axisColor: scheme.onSurface
                                              .withValues(alpha: 0.11),
                                          spacing: 48,
                                          majorEvery: 5,
                                          devicePixelRatio:
                                              MediaQuery.devicePixelRatioOf(
                                                context,
                                              ),
                                        ),
                                        isComplex: true,
                                        willChange: false,
                                        size: Size.infinite,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Listener(
                                      behavior: HitTestBehavior.opaque,
                                      onPointerDown: (event) =>
                                          _onPointerDown(event, scheme),
                                      onPointerMove: _onPointerMove,
                                      onPointerUp: _onPointerEnd,
                                      onPointerCancel: _onPointerEnd,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: RepaintBoundary(
                                              child: CustomPaint(
                                                painter:
                                                    _WorkbenchDrawingPainter(
                                                      strokes: widget
                                                          .component
                                                          .strokes,
                                                      current: null,
                                                      fallbackColor:
                                                          scheme.onSurface,
                                                      revision:
                                                          _strokesRevision,
                                                      repaint: _strokesRepaint,
                                                    ),
                                                size: Size.infinite,
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: RepaintBoundary(
                                              child: CustomPaint(
                                                painter:
                                                    _WorkbenchDrawingPainter(
                                                      strokes:
                                                          const <
                                                            DrawingStroke
                                                          >[],
                                                      current: _current,
                                                      fallbackColor:
                                                          scheme.onSurface,
                                                      revision:
                                                          _strokesRevision,
                                                      repaint: _liveRepaint,
                                                    ),
                                                size: Size.infinite,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: DeviceInfo.pt(10),
                        bottom: DeviceInfo.pt(10),
                        child: Material(
                          color: scheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(18),
                          elevation: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: l10n.zoom_in,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _zoomBy(1.25),
                                icon: const Icon(Icons.add),
                              ),
                              IconButton(
                                tooltip: l10n.zoom_out,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _zoomBy(0.8),
                                icon: const Icon(Icons.remove),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Material(
        color: scheme.surfaceContainerHighest,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              DeviceInfo.pt(12),
              DeviceInfo.pt(6),
              DeviceInfo.pt(12),
              DeviceInfo.pt(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: DeviceInfo.pt(36),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final color in _colorChoices)
                        GestureDetector(
                          onTap: () => setState(() => _strokeColor = color),
                          child: Container(
                            width: 26,
                            height: 26,
                            margin: EdgeInsets.only(
                              right: DeviceInfo.pt(9),
                              top: DeviceInfo.pt(3),
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width:
                                    (_strokeColor ?? scheme.onSurface) == color
                                    ? 3
                                    : 1,
                                color:
                                    (_strokeColor ?? scheme.onSurface) == color
                                    ? scheme.primary
                                    : scheme.onSurface.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.custom_color,
                        visualDensity: VisualDensity.compact,
                        onPressed: _pickCustomColor,
                        icon: const Icon(Icons.colorize, size: 19),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.line_weight,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth,
                        min: 1,
                        max: 12,
                        divisions: 22,
                        label: _strokeWidth.toStringAsFixed(1),
                        onChanged: (value) =>
                            setState(() => _strokeWidth = value),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _strokeColor ?? scheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _toolButton(
                      scheme,
                      _DrawTool.select,
                      Icons.pan_tool_outlined,
                      l10n.move_canvas,
                    ),
                    _toolButton(
                      scheme,
                      _DrawTool.eraser,
                      Icons.auto_fix_normal,
                      l10n.drawing_eraser,
                    ),
                    _toolButton(
                      scheme,
                      _DrawTool.highlighter,
                      Icons.border_color_outlined,
                      l10n.drawing_highlighter,
                    ),
                    _toolButton(
                      scheme,
                      _DrawTool.pencil,
                      Icons.edit_outlined,
                      l10n.drawing_pencil,
                    ),
                    _toolButton(
                      scheme,
                      _DrawTool.marker,
                      Icons.brush_outlined,
                      l10n.drawing_marker,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolButton(
    ColorScheme scheme,
    _DrawTool tool,
    IconData icon,
    String tooltip,
  ) {
    final selected = _tool == tool;
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.standard,
      onPressed: () => setState(() => _tool = tool),
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: selected
            ? scheme.primaryContainer
            : Colors.transparent,
        foregroundColor: selected
            ? scheme.onPrimaryContainer
            : scheme.onSurface,
      ),
      icon: Icon(icon),
    );
  }
}

class _WorkbenchDrawingPainter extends CustomPainter {
  _WorkbenchDrawingPainter({
    required this.strokes,
    required this.current,
    required this.fallbackColor,
    required this.revision,
    super.repaint,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? current;
  final Color fallbackColor;
  final int revision;

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
  bool shouldRepaint(covariant _WorkbenchDrawingPainter oldDelegate) {
    return oldDelegate.revision != revision ||
        oldDelegate.current != current ||
        oldDelegate.fallbackColor != fallbackColor;
  }
}

class _ImageWorkbench extends StatefulWidget {
  const _ImageWorkbench({
    required this.component,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteComponent component;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  State<_ImageWorkbench> createState() => _ImageWorkbenchState();
}

class _ImageWorkbenchState extends State<_ImageWorkbench> {
  bool _pickerShown = false;
  late final TextEditingController _titleController;
  late List<String> _imagePaths;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.component.title);
    _imagePaths = List<String>.of(widget.component.imagePaths);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _imagePaths.isEmpty) _showSourceSheet();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncComponent() {
    final l10n = AppLocalizations.of(context)!;
    widget.component
      ..title = _titleController.text
      ..textBlocks = [
        for (final path in _imagePaths)
          NoteTextBlock(kind: NoteTextBlockKind.image, mediaPath: path),
      ]
      ..url = _imagePaths.isEmpty ? '' : _imagePaths.first
      ..text = _imagePaths.isEmpty
          ? ''
          : List<String>.filled(
              _imagePaths.length,
              '[${l10n.component_image}]',
            ).join('\n');
    widget.onChanged();
  }

  Future<void> _pick({required bool camera}) async {
    final l10n = AppLocalizations.of(context)!;
    final path = camera
        ? await PlatformMediaService.takePhoto()
        : await PlatformMediaService.pickImageFromGallery();
    if (!mounted) return;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.image_pick_failed)));
      return;
    }
    setState(() => _imagePaths.add(path));
    _syncComponent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _showSourceSheet() async {
    if (_pickerShown) return;
    _pickerShown = true;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    await showAdaptiveSurface<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                DeviceInfo.pt(24),
                DeviceInfo.pt(4),
                DeviceInfo.pt(24),
                DeviceInfo.pt(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.add_image,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: DeviceInfo.pt(22),
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: scheme.onSurface,
              ),
              title: Text(l10n.take_photo),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(camera: true);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: scheme.onSurface,
              ),
              title: Text(l10n.pick_from_gallery),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(camera: false);
              },
            ),
            SizedBox(height: DeviceInfo.pt(12)),
          ],
        ),
      ),
    );
    _pickerShown = false;
  }

  void _removeImage(int index) {
    if (index < 0 || index >= _imagePaths.length) return;
    setState(() => _imagePaths.removeAt(index));
    _syncComponent();
  }

  Future<void> _showImagePreview(String path) async {
    final l10n = AppLocalizations.of(context)!;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.close_image_preview,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, _) => SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SourceImageView(
                      source: path,
                      fit: BoxFit.contain,
                      loading: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                tooltip: l10n.close,
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  Widget _buildImageTile(int index, String path, ColorScheme scheme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: DeviceInfo.pt(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DeviceInfo.pt(16)),
        child: Stack(
          children: [
            Material(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
              child: InkWell(
                onTap: () => _showImagePreview(path),
                child: SizedBox(
                  height: DeviceInfo.pt(230),
                  width: double.infinity,
                  child: SourceImageView(
                    source: path,
                    fit: BoxFit.contain,
                    loading: const Center(child: CircularProgressIndicator()),
                    error: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: scheme.surface.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: l10n.delete,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _removeImage(index),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNote(ColorScheme scheme) {
    final l10n = AppLocalizations.of(context)!;
    final borderRadius = BorderRadius.circular(DeviceInfo.pt(16));
    return Semantics(
      button: true,
      label: l10n.add_image,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _showSourceSheet,
          child: Container(
            height: DeviceInfo.pt(260),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: DeviceInfo.pt(54),
                  color: scheme.onSurface.withValues(alpha: 0.42),
                ),
                SizedBox(height: DeviceInfo.pt(10)),
                Text(
                  l10n.add_image,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: DeviceInfo.pt(16),
                    color: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.close,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          l10n.component_image,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: DeviceInfo.pt(20),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.add_image,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: _showSourceSheet,
          ),
          IconButton(
            tooltip: l10n.component_delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              DeviceInfo.pt(16),
              DeviceInfo.pt(12),
              DeviceInfo.pt(16),
              DeviceInfo.pt(24),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 760,
                  minHeight: (constraints.maxHeight - DeviceInfo.pt(36)).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(DeviceInfo.pt(16)),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(DeviceInfo.pt(22)),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(24),
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.title,
                          hintStyle: TextStyle(
                            fontFamily: 'ResourceHanCN',
                            fontSize: DeviceInfo.pt(24),
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          widget.component.title = value;
                          widget.onChanged();
                        },
                      ),
                      SizedBox(height: DeviceInfo.pt(12)),
                      Divider(height: 1, color: scheme.outlineVariant),
                      SizedBox(height: DeviceInfo.pt(16)),
                      if (_imagePaths.isEmpty)
                        _buildEmptyNote(scheme)
                      else
                        for (var i = 0; i < _imagePaths.length; i++)
                          _buildImageTile(i, _imagePaths[i], scheme),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _showSourceSheet,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(l10n.add_image),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
