/// Device metrics should not make tablets render like a 1.8x phone.
///
/// The current implementation uses
///   (shortestSide / 375).clamp(0.75, 1.8)
/// for fonts, paddings, radii and button sizes. On a tablet this inflates
/// nearly every visual dimension, often interacting badly with accessibility
/// text scaling. Keep a modest scale and use adaptive layouts for large
/// windows instead.
const double kDesignShortSide = 375.0;

double resolveDeviceScale(double shortestSide) {
  final safeSide = shortestSide.isFinite && shortestSide > 0
      ? shortestSide
      : kDesignShortSide;
  return (safeSide / kDesignShortSide).clamp(0.85, 1.25).toDouble();
}
