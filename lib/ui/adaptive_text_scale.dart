import 'package:flutter/widgets.dart';

/// The app's user-controlled scale slider.
const double kMinAppTextScale = 0.8;
const double kMaxAppTextScale = 2.0;

/// Multiplies the OS accessibility text scale by the app preference.
///
/// The current app replaces MediaQuery.textScaleFactor with its own slider
/// value, which makes the Android "Display size / Font size" setting have no
/// effect. Keep both factors but clamp the result to a usable range.
double resolveEffectiveTextScale({
  required double systemScale,
  required double appScale,
}) {
  final safeSystem = systemScale.isFinite ? systemScale : 1.0;
  final safeApp = appScale.isFinite ? appScale : 1.0;
  return (safeSystem * safeApp)
      .clamp(kMinAppTextScale, kMaxAppTextScale)
      .toDouble();
}

/// Returns a TextScaler that preserves OS scaling and applies the in-app
/// preference on top of it.
TextScaler resolveTextScaler(BuildContext context, double appScale) {
  final systemScale = MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
  return TextScaler.linear(
    resolveEffectiveTextScale(systemScale: systemScale, appScale: appScale),
  );
}
