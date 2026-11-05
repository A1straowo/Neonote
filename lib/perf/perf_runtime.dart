// Drop this file at: lib/perf/perf_runtime.dart
// Small, dependency-free primitives used by the Neonote performance hotfix.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Adaptive sample count for a pointer segment.
///
/// The original implementation used `(distance / 2).ceil().clamp(1, 32)`,
/// which retained a point every ~2 px and allowed 32 points from one event.
/// 4 px/12 points keeps ink visually smooth while reducing point count,
/// snapshot payload and eraser work by roughly 4-5x.
int adaptiveStepCount(double distance) {
  if (!distance.isFinite || distance <= 0.0) return 0;
  // Do not emit a sample for sub-pixel jitter; the next event will catch up.
  if (distance < 1.5) return 0;
  return math.max(1, math.min(12, (distance / 4.0).ceil()));
}

/// Ramer-Douglas-Peucker simplification for a polyline.
/// Call once when a stroke ends, before it is put into the document model.
List<Offset> simplifyPolyline(
  List<Offset> points, {
  double epsilon = 0.75,
  int maxPoints = 512,
}) {
  if (points.length <= 2) return List<Offset>.of(points);

  final keep = List<bool>.filled(points.length, false);
  keep[0] = true;
  keep[points.length - 1] = true;

  final stack = <(int, int)>[(0, points.length - 1)];
  while (stack.isNotEmpty) {
    final (first, last) = stack.removeLast();
    if (last <= first + 1) continue;

    final a = points[first];
    final b = points[last];
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final denom = math.sqrt(dx * dx + dy * dy);
    var maxDist = -1.0;
    var maxIndex = -1;

    for (var i = first + 1; i < last; i++) {
      final p = points[i];
      double dist;
      if (denom == 0.0) {
        dist = (p - a).distance;
      } else {
        dist = ((dx * (a.dy - p.dy)) - ((a.dx - p.dx) * dy)).abs() / denom;
      }
      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }

    if (maxIndex >= 0 && maxDist > epsilon) {
      keep[maxIndex] = true;
      stack.add((first, maxIndex));
      stack.add((maxIndex, last));
    }
  }

  final simplified = <Offset>[];
  for (var i = 0; i < points.length; i++) {
    if (keep[i]) simplified.add(points[i]);
  }

  if (simplified.length <= maxPoints) return simplified;

  // Hard cap: uniformly keep endpoints and maxPoints-2 interior points.
  final capped = <Offset>[simplified.first];
  final stride = (simplified.length - 2) / (maxPoints - 2);
  for (var i = 1; i < maxPoints - 1; i++) {
    capped.add(simplified[1 + (i * stride).floor()]);
  }
  capped.add(simplified.last);
  return capped;
}

/// Coalesces bursts of notifications into at most one per frame.
class FrameCoalescedNotifier extends ChangeNotifier {
  FrameCoalescedNotifier({this.delay = const Duration(milliseconds: 16)});

  final Duration delay;
  Timer? _timer;
  bool _pending = false;

  void notifySoon() {
    if (_pending) return;
    _pending = true;
    _timer ??= Timer(delay, () {
      _timer = null;
      _pending = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

/// Keeps a bounded history by both entry count and approximate payload size.
class BudgetedHistory<T> {
  BudgetedHistory({this.maxItems = 24, this.maxPayload = 4 * 1024 * 1024});

  final int maxItems;
  final int maxPayload;
  final List<T> _items = <T>[];
  final List<int> _sizes = <int>[];
  int _payload = 0;

  List<T> get items => List<T>.unmodifiable(_items);
  int get length => _items.length;
  int get payload => _payload;

  void add(T item, int estimatedBytes) {
    _items.add(item);
    _sizes.add(estimatedBytes);
    _payload += estimatedBytes;
    while (_items.length > maxItems ||
        (_items.length > 1 && _payload > maxPayload)) {
      _items.removeAt(0);
      _payload -= _sizes.removeAt(0);
    }
  }

  void clear() {
    _items.clear();
    _sizes.clear();
    _payload = 0;
  }
}
