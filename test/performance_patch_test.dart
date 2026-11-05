import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/main.dart' show themeBox;
import 'package:neonote/perf/perf_runtime.dart';
import 'package:neonote/store/note_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.openBox(themeBox, bytes: Uint8List(0));
  });

  setUp(() async {
    await Hive.box(themeBox).clear();
    NoteStore.revision.value = 0;
  });

  test('adaptive drawing sampling is bounded', () {
    expect(adaptiveStepCount(0), 0);
    expect(adaptiveStepCount(1.0), 0);
    expect(adaptiveStepCount(4.0), 1);
    expect(adaptiveStepCount(40.0), 10);
    expect(adaptiveStepCount(1000.0), 12);
  });

  test('polyline simplification keeps endpoints and caps points', () {
    final points = <Offset>[
      for (var i = 0; i < 2000; i++) Offset(i.toDouble(), i.isEven ? 0 : 0.1),
    ];
    final simplified = simplifyPolyline(points, epsilon: 0.75, maxPoints: 512);
    expect(simplified.first, points.first);
    expect(simplified.last, points.last);
    expect(simplified.length, lessThanOrEqualTo(512));
    expect(simplified.length, lessThan(points.length ~/ 3));
  });

  test('note store cache is invalidated by external box changes', () async {
    final note = await NoteStore.addComponent(NoteComponentType.text);
    note.text = 'first';
    await NoteStore.saveComponent(note, bump: true);
    expect(NoteStore.components().single.text, 'first');

    await Hive.box(themeBox).clear();
    expect(NoteStore.components(), isEmpty);

    final second = await NoteStore.addComponent(NoteComponentType.text);
    expect(NoteStore.components().single.id, second.id);
  });
}
