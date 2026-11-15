import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:neonote/services/student_avatar_cache.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'neonote_avatar_cache_test_',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('avatar cache writes a compact square JPEG', () async {
    final source = img.Image(width: 512, height: 512);
    final random = math.Random(42);
    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        source.setPixelRgba(
          x,
          y,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          255,
        );
      }
    }
    final sourceBytes = img.encodePng(source);
    final client = MockClient(
      (_) async => http.Response.bytes(
        sourceBytes,
        200,
        headers: const <String, String>{'content-type': 'image/png'},
      ),
    );
    final cache = StudentAvatarCache(
      directoryProvider: () async => tempDirectory,
      client: client,
    );

    final file = await cache.resolve('https://example.com/avatar.png');
    expect(file, isNotNull);
    expect(file!.path, endsWith('_v2.jpg'));

    final cachedBytes = await file.readAsBytes();
    expect(cachedBytes.length, lessThan(sourceBytes.length ~/ 2));
    final decoded = img.decodeImage(cachedBytes);
    expect(decoded, isNotNull);
    expect(decoded!.width, 256);
    expect(decoded.height, 256);
    expect(
      tempDirectory.listSync().whereType<File>().where(
        (item) => item.path.endsWith('.tmp'),
      ),
      isEmpty,
    );
  });

  test('avatar cache removes legacy entries and caps the file count', () async {
    for (var i = 0; i < 8; i++) {
      await File(
        '${tempDirectory.path}/legacy_$i.img',
      ).writeAsBytes(const <int>[1, 2, 3]);
    }
    await File(
      '${tempDirectory.path}/partial.tmp',
    ).writeAsBytes(const <int>[1]);
    for (var i = 0; i < 210; i++) {
      await File(
        '${tempDirectory.path}/avatar_${i}_v2.jpg',
      ).writeAsBytes(const <int>[1, 2, 3]);
    }

    final cache = StudentAvatarCache(
      directoryProvider: () async => tempDirectory,
      client: MockClient((_) async => http.Response('', 404)),
    );
    await cache.resolve('https://example.com/missing.png');

    final files = tempDirectory.listSync().whereType<File>().toList();
    expect(files.length, lessThanOrEqualTo(200));
    expect(files.where((file) => file.path.endsWith('.img')), isEmpty);
    expect(files.where((file) => file.path.endsWith('.tmp')), isEmpty);
  });
}
