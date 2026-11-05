import 'package:flutter/material.dart';

/// Shared breakpoints for phone, tablet and desktop-sized windows.
///
/// The app already has a landscape drawer, but most pages still stretch their
/// content to the full window width. Using one set of breakpoints keeps pages
/// consistent and avoids a second, ad-hoc responsive system.
enum NeonoteWindowSize { compact, medium, expanded }

abstract final class AppBreakpoints {
  static const double compactMax = 599;
  static const double mediumMax = 839;

  static const double readableContentMax = 760;
  static const double wideContentMax = 1040;

  static NeonoteWindowSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= compactMax) return NeonoteWindowSize.compact;
    if (width <= mediumMax) return NeonoteWindowSize.medium;
    return NeonoteWindowSize.expanded;
  }

  static bool isCompact(BuildContext context) =>
      of(context) == NeonoteWindowSize.compact;

  static bool isExpanded(BuildContext context) =>
      of(context) == NeonoteWindowSize.expanded;
}

/// Centers a page on large screens while preserving edge-to-edge layout on
/// phones. Use this around settings, forms, chat history and note lists.
class ContentPane extends StatelessWidget {
  const ContentPane({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.wideContentMax,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A keyboard- and safe-area-aware scroll body. It is intentionally a
/// separate widget so pages can retain their own scroll controller and
/// refresh indicators.
class AdaptiveScrollBody extends StatelessWidget {
  const AdaptiveScrollBody({
    super.key,
    required this.child,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
    this.maxWidth = AppBreakpoints.wideContentMax,
  });

  final Widget child;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ContentPane(maxWidth: maxWidth, padding: padding, child: child),
      ),
    );
  }
}

/// Uses a dialog on tablets/desktop and a bottom sheet on phones.
///
/// AI history, tag pickers, color pickers and student pickers currently use
/// sheets everywhere. A dialog is substantially easier to scan with a mouse or
/// keyboard on a wide screen.
Future<T?> showAdaptiveSurface<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
}) {
  final isWide = MediaQuery.sizeOf(context).width >= 600;
  if (isWide) {
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: size.height * 0.86,
            ),
            child: builder(dialogContext),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    useRootNavigator: useRootNavigator,
    showDragHandle: true,
    builder: builder,
  );
}

/// A small helper for action rows that should wrap instead of overflowing at
/// large text scales or on narrow devices.
class AdaptiveActionBar extends StatelessWidget {
  const AdaptiveActionBar({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.end,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<Widget> children;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(
        alignment: alignment,
        spacing: spacing,
        runSpacing: runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
