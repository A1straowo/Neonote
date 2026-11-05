import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

/// The three background modes exposed by the drawing workbench.
enum DrawingCanvasGridStyle { none, grid, dots }

/// Optimized and axis-aligned infinite canvas background.
///
/// Why this replaces `_InfiniteCanvasBackgroundPainter`:
/// - The original grid starts at `(0, 0)` while the axes are drawn at
///   `size.center`. Whenever width/height is not an exact multiple of the grid
///   spacing, the axes land between grid lines.
/// - The original grid uses 48 px spacing while its dot mode uses 52 px. The
///   two modes therefore do not share the same coordinate system.
/// - The original dot mode allocates one `Offset` per dot on every paint. On a
///   large canvas this generates thousands of objects per frame and causes GC
///   jank during pan/zoom.
/// - This painter builds one reusable `Float32List` geometry cache and submits
///   grid lines/dots with `Canvas.drawRawPoints`, avoiding per-point objects.
class DrawingCanvasGridPainter extends CustomPainter {
  DrawingCanvasGridPainter({
    required this.style,
    required this.gridColor,
    required this.axisColor,
    this.spacing = 48,
    this.majorEvery = 5,
    this.dotRadius = 1.3,
    this.drawAxes = true,
    this.devicePixelRatio = 1,
  });

  final DrawingCanvasGridStyle style;
  final Color gridColor;
  final Color axisColor;
  final double spacing;
  final int majorEvery;
  final double dotRadius;
  final bool drawAxes;

  /// Pass `MediaQuery.devicePixelRatioOf(context)` from the page. The dot mode
  /// renders a tiny tile image, so using the real DPR keeps dots sharp without
  /// falling back to thousands of per-point draw calls.
  final double devicePixelRatio;

  Size? _geometrySize;
  Float32List? _minorSegments;
  Float32List? _majorSegments;
  Float32List? _axisSegments;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == DrawingCanvasGridStyle.none || size.isEmpty) return;
    _ensureGeometry(size);

    if (style == DrawingCanvasGridStyle.dots) {
      _drawTiledDots(canvas, size);
      if (drawAxes) _drawAxes(canvas, size);
      return;
    }

    final minor = _minorSegments;
    final major = _majorSegments;
    if (minor != null && minor.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.lines,
        minor,
        Paint()
          ..color = gridColor
          ..strokeWidth = 1
          ..isAntiAlias = true,
      );
    }
    if (major != null && major.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.lines,
        major,
        Paint()
          ..color = axisColor.withValues(alpha: axisColor.a * 0.62)
          ..strokeWidth = 1
          ..isAntiAlias = true,
      );
    }
    if (drawAxes) _drawAxes(canvas, size);
  }

  void _drawTiledDots(Canvas canvas, Size size) {
    final dpr = devicePixelRatio <= 0 ? 1.0 : devicePixelRatio;
    final tile = _DotTileCache.imageFor(
      color: axisColor,
      spacing: spacing <= 0 ? 48 : spacing,
      radius: dotRadius,
      devicePixelRatio: dpr,
    );
    if (tile == null) return;

    final origin = size.center(Offset.zero);
    // Equivalent to Translate(origin) * Scale(1 / dpr) without deprecated
    // Matrix4 transform helpers.
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, 1 / dpr)
      ..setEntry(1, 1, 1 / dpr)
      ..setEntry(0, 3, origin.dx)
      ..setEntry(1, 3, origin.dy);
    final shader = ui.ImageShader(
      tile,
      ui.TileMode.repeated,
      ui.TileMode.repeated,
      matrix.storage,
      filterQuality: ui.FilterQuality.medium,
    );
    canvas.drawPaint(Paint()..shader = shader);
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axes = _axisSegments;
    if (axes == null || axes.isEmpty) return;
    canvas.drawRawPoints(
      PointMode.lines,
      axes,
      Paint()
        ..color = axisColor.withValues(alpha: axisColor.a * 0.55)
        ..strokeWidth = 1.5
        ..isAntiAlias = true,
    );
  }

  void _ensureGeometry(Size size) {
    if (_geometrySize == size) return;
    _geometrySize = size;

    final origin = size.center(Offset.zero);
    final safeSpacing = spacing <= 0 ? 48.0 : spacing;
    final safeMajorEvery = majorEvery <= 0 ? 5 : majorEvery;

    final axes = <double>[];
    if (drawAxes) {
      axes
        ..add(origin.dx)
        ..add(0)
        ..add(origin.dx)
        ..add(size.height)
        ..add(0)
        ..add(origin.dy)
        ..add(size.width)
        ..add(origin.dy);
    }
    _axisSegments = Float32List.fromList(axes);

    // Dot mode is rendered with a repeated ImageShader instead of one point
    // per grid intersection. Do not build thousands of line segments here: this
    // code path may run whenever the painter instance is recreated.
    if (style == DrawingCanvasGridStyle.dots) {
      _minorSegments = Float32List(0);
      _majorSegments = Float32List(0);
      return;
    }

    final firstX = ((0 - origin.dx) / safeSpacing).ceil();
    final lastX = ((size.width - origin.dx) / safeSpacing).floor();
    final firstY = ((0 - origin.dy) / safeSpacing).ceil();
    final lastY = ((size.height - origin.dy) / safeSpacing).floor();

    final minor = <double>[];
    final major = <double>[];

    for (var i = firstX; i <= lastX; i++) {
      final x = origin.dx + i * safeSpacing;
      if (i == 0 && drawAxes) continue;
      final target = i % safeMajorEvery == 0 ? major : minor;
      target
        ..add(x)
        ..add(0)
        ..add(x)
        ..add(size.height);
    }
    for (var i = firstY; i <= lastY; i++) {
      final y = origin.dy + i * safeSpacing;
      if (i == 0 && drawAxes) continue;
      final target = i % safeMajorEvery == 0 ? major : minor;
      target
        ..add(0)
        ..add(y)
        ..add(size.width)
        ..add(y);
    }

    _minorSegments = Float32List.fromList(minor);
    _majorSegments = Float32List.fromList(major);
  }

  @override
  bool shouldRepaint(covariant DrawingCanvasGridPainter oldDelegate) {
    return style != oldDelegate.style ||
        gridColor != oldDelegate.gridColor ||
        axisColor != oldDelegate.axisColor ||
        spacing != oldDelegate.spacing ||
        majorEvery != oldDelegate.majorEvery ||
        dotRadius != oldDelegate.dotRadius ||
        drawAxes != oldDelegate.drawAxes ||
        devicePixelRatio != oldDelegate.devicePixelRatio;
  }
}

/// Background patterns used behind a text note card.
enum NoteCardGridStyle { none, square, dots, horizontalLines }

/// Optimized replacement for `_NoteGridPainter`.
///
/// The original dot mode calls `canvas.drawCircle` once for every dot inside a
/// nested loop. A card rendered at a large text scale, or during a long list
/// scroll, can issue thousands of individual draw calls. This version batches
/// all dots into one `drawRawPoints` call and caches the generated geometry.
class NoteCardGridPainter extends CustomPainter {
  NoteCardGridPainter({
    required this.style,
    required this.backgroundColor,
    required this.lineColor,
    this.spacing = 24,
    this.majorEvery = 5,
    this.dotRadius = 1.3,
  });

  final NoteCardGridStyle style;
  final Color backgroundColor;
  final Color lineColor;
  final double spacing;
  final int majorEvery;
  final double dotRadius;

  Size? _geometrySize;
  Float32List? _minorSegments;
  Float32List? _majorSegments;
  Float32List? _dots;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    if (style == NoteCardGridStyle.none || size.isEmpty) return;
    _ensureGeometry(size);

    if (style == NoteCardGridStyle.dots) {
      final dots = _dots;
      if (dots != null && dots.isNotEmpty) {
        canvas.drawRawPoints(
          PointMode.points,
          dots,
          Paint()
            ..color = lineColor
            ..strokeWidth = dotRadius * 2
            ..strokeCap = StrokeCap.round
            ..isAntiAlias = true,
        );
      }
      return;
    }

    final minor = _minorSegments;
    final major = _majorSegments;
    if (minor != null && minor.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.lines,
        minor,
        Paint()
          ..color = lineColor.withValues(alpha: lineColor.a * 0.7)
          ..strokeWidth = 1
          ..isAntiAlias = true,
      );
    }
    if (major != null && major.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.lines,
        major,
        Paint()
          ..color = lineColor
          ..strokeWidth = 1
          ..isAntiAlias = true,
      );
    }
  }

  void _ensureGeometry(Size size) {
    if (_geometrySize == size) return;
    _geometrySize = size;

    final safeSpacing = spacing <= 0 ? 24.0 : spacing;
    final safeMajorEvery = majorEvery <= 0 ? 5 : majorEvery;
    final minor = <double>[];
    final major = <double>[];

    if (style == NoteCardGridStyle.square) {
      final firstX = (0 / safeSpacing).ceil();
      final lastX = (size.width / safeSpacing).floor();
      for (var i = firstX; i <= lastX; i++) {
        final x = i * safeSpacing;
        final target = i % safeMajorEvery == 0 ? major : minor;
        target
          ..add(x)
          ..add(0)
          ..add(x)
          ..add(size.height);
      }
    }

    if (style == NoteCardGridStyle.square ||
        style == NoteCardGridStyle.horizontalLines) {
      final firstY = (0 / safeSpacing).ceil();
      final lastY = (size.height / safeSpacing).floor();
      for (var i = firstY; i <= lastY; i++) {
        final y = i * safeSpacing;
        final target = i % safeMajorEvery == 0 ? major : minor;
        target
          ..add(0)
          ..add(y)
          ..add(size.width)
          ..add(y);
      }
    }

    _minorSegments = Float32List.fromList(minor);
    _majorSegments = Float32List.fromList(major);

    if (style == NoteCardGridStyle.dots) {
      final points = <double>[];
      final firstX = (0 / safeSpacing).ceil();
      final lastX = (size.width / safeSpacing).floor();
      final firstY = (0 / safeSpacing).ceil();
      final lastY = (size.height / safeSpacing).floor();
      for (var xIndex = firstX; xIndex <= lastX; xIndex++) {
        final x = xIndex * safeSpacing;
        for (var yIndex = firstY; yIndex <= lastY; yIndex++) {
          points
            ..add(x)
            ..add(yIndex * safeSpacing);
        }
      }
      _dots = Float32List.fromList(points);
    } else {}
  }

  @override
  bool shouldRepaint(covariant NoteCardGridPainter oldDelegate) {
    return style != oldDelegate.style ||
        backgroundColor != oldDelegate.backgroundColor ||
        lineColor != oldDelegate.lineColor ||
        spacing != oldDelegate.spacing ||
        majorEvery != oldDelegate.majorEvery ||
        dotRadius != oldDelegate.dotRadius;
  }
}

/// Caches one transparent dot tile per color/size/DPR combination.
///
/// The tile has quarter-dots in its corners. When repeated, the corners of four
/// neighbouring tiles complete a dot exactly on the integer grid, which lets the
/// pattern start at the canvas center without any half-pixel offset.
abstract final class _DotTileCache {
  static final Map<String, ui.Image> _images = <String, ui.Image>{};

  static ui.Image? imageFor({
    required Color color,
    required double spacing,
    required double radius,
    required double devicePixelRatio,
  }) {
    final tileSize = (spacing * devicePixelRatio).round().clamp(1, 2048);
    final key =
        '${color.toARGB32()}|$tileSize|${radius.toStringAsFixed(3)}|${devicePixelRatio.toStringAsFixed(3)}';
    final cached = _images[key];
    if (cached != null) return cached;

    if (_images.length >= 6) {
      final firstKey = _images.keys.first;
      _images.remove(firstKey)?.dispose();
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final radiusPx = radius * devicePixelRatio;
    canvas
      ..drawCircle(Offset.zero, radiusPx, paint)
      ..drawCircle(Offset(tileSize.toDouble(), 0), radiusPx, paint)
      ..drawCircle(Offset(0, tileSize.toDouble()), radiusPx, paint)
      ..drawCircle(
        Offset(tileSize.toDouble(), tileSize.toDouble()),
        radiusPx,
        paint,
      );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(tileSize, tileSize);
    picture.dispose();
    _images[key] = image;
    return image;
  }
}
