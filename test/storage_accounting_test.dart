import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/main.dart' show themeBox;
import 'package:neonote/services/app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.openBox(themeBox, bytes: Uint8List(0));
  });

  setUp(() async {
    await Hive.box(themeBox).clear();
  });

  test('formatBytes uses compact binary units', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(1024), '1.0 KB');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(5 * 1024 * 1024), '5.0 MB');
  });

  test('storage optimization result totals released bytes', () {
    const result = StorageOptimizationResult(
      orphanedMediaBytes: 100,
      legacyExportBytes: 50,
      databaseBytes: 25,
      deletedFiles: 2,
    );
    expect(result.releasedBytes, 175);
  });

  test(
    'storage optimization is safe when platform paths are unavailable',
    () async {
      final result = await AppStorage.optimize();
      expect(result.releasedBytes, greaterThanOrEqualTo(0));
    },
  );
}
