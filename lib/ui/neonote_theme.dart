import 'package:flutter/material.dart';

/// App-specific spacing and radius tokens.
///
/// Keeping these values in a ThemeExtension makes it possible to tune density
/// per window size without scattering magic numbers through every page.
@immutable
class NeonoteThemeTokens extends ThemeExtension<NeonoteThemeTokens> {
  const NeonoteThemeTokens({
    required this.pageGutter,
    required this.sectionGap,
    required this.cardRadius,
    required this.controlRadius,
    required this.cardPadding,
    required this.compactCardPadding,
  });

  final double pageGutter;
  final double sectionGap;
  final double cardRadius;
  final double controlRadius;
  final EdgeInsets cardPadding;
  final EdgeInsets compactCardPadding;

  @override
  NeonoteThemeTokens copyWith({
    double? pageGutter,
    double? sectionGap,
    double? cardRadius,
    double? controlRadius,
    EdgeInsets? cardPadding,
    EdgeInsets? compactCardPadding,
  }) {
    return NeonoteThemeTokens(
      pageGutter: pageGutter ?? this.pageGutter,
      sectionGap: sectionGap ?? this.sectionGap,
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      cardPadding: cardPadding ?? this.cardPadding,
      compactCardPadding: compactCardPadding ?? this.compactCardPadding,
    );
  }

  @override
  NeonoteThemeTokens lerp(
    covariant ThemeExtension<NeonoteThemeTokens>? other,
    double t,
  ) {
    if (other is! NeonoteThemeTokens) return this;
    return NeonoteThemeTokens(
      pageGutter: _lerpDouble(pageGutter, other.pageGutter, t),
      sectionGap: _lerpDouble(sectionGap, other.sectionGap, t),
      cardRadius: _lerpDouble(cardRadius, other.cardRadius, t),
      controlRadius: _lerpDouble(controlRadius, other.controlRadius, t),
      cardPadding:
          EdgeInsets.lerp(cardPadding, other.cardPadding, t) ?? cardPadding,
      compactCardPadding:
          EdgeInsets.lerp(compactCardPadding, other.compactCardPadding, t) ??
          compactCardPadding,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension NeonoteThemeContext on BuildContext {
  NeonoteThemeTokens get neonoteTokens =>
      Theme.of(this).extension<NeonoteThemeTokens>() ??
      const NeonoteThemeTokens(
        pageGutter: 16,
        sectionGap: 16,
        cardRadius: 16,
        controlRadius: 14,
        cardPadding: EdgeInsets.all(16),
        compactCardPadding: EdgeInsets.all(12),
      );
}

/// Single source of truth for the app's Material theme.
///
/// The current app only passes a ColorScheme, a font and a page transition to
/// ThemeData. Everything else falls back to framework defaults, which is why
/// cards, dialogs, inputs and icon buttons can look inconsistent across pages.
ThemeData buildNeonoteTheme({
  required ColorScheme colorScheme,
  required String fontFamily,
  PageTransitionsTheme? pageTransitionsTheme,
  InteractiveInkFeatureFactory? splashFactory,
  bool useMaterial3 = true,
}) {
  final base = ThemeData(
    useMaterial3: useMaterial3,
    colorScheme: colorScheme,
    fontFamily: fontFamily,
    pageTransitionsTheme: pageTransitionsTheme,
    splashFactory: splashFactory ?? InkSparkle.splashFactory,
  );

  final controlBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );
  final focusedBorder = controlBorder.copyWith(
    borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
  );

  return base.copyWith(
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: controlBorder,
      enabledBorder: controlBorder,
      focusedBorder: focusedBorder,
      errorBorder: controlBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: controlBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size.square(48),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      labelStyle: base.textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.65),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 450),
      showDuration: const Duration(seconds: 4),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: base.textTheme.bodySmall?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      NeonoteThemeTokens(
        pageGutter: 16,
        sectionGap: 16,
        cardRadius: 18,
        controlRadius: 14,
        cardPadding: EdgeInsets.all(16),
        compactCardPadding: EdgeInsets.all(12),
      ),
    ],
  );
}

/// Parses the persisted theme preference while remaining compatible with the
/// old boolean `darkMode` key. The returned ThemeMode includes support for
/// following the system theme, which the current settings screen lacks.
ThemeMode neonoteThemeModeFromSetting({
  required Object? storedMode,
  required bool legacyDarkMode,
}) {
  switch (storedMode?.toString().toLowerCase()) {
    case 'system':
      return ThemeMode.system;
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return legacyDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
