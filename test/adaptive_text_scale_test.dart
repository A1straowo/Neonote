import 'package:flutter_test/flutter_test.dart';
import 'package:neonote/ui/adaptive_text_scale.dart';
import 'package:neonote/ui/device_scale.dart';

void main() {
  test('preserves system text scaling', () {
    expect(
      resolveEffectiveTextScale(systemScale: 1.3, appScale: 1.0),
      closeTo(1.3, 0.001),
    );
  });

  test('multiplies system and app text scaling', () {
    expect(
      resolveEffectiveTextScale(systemScale: 1.25, appScale: 1.2),
      closeTo(1.5, 0.001),
    );
  });

  test('clamps pathological scaling values', () {
    expect(
      resolveEffectiveTextScale(systemScale: 9.0, appScale: 9.0),
      kMaxAppTextScale,
    );
  });

  test('device scale is bounded for tablets', () {
    expect(resolveDeviceScale(375), closeTo(1.0, 0.001));
    expect(resolveDeviceScale(1200), 1.25);
    expect(resolveDeviceScale(200), 0.85);
  });
}
