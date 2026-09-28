import 'package:flutter/material.dart';

/// AppBreakpoints defines the responsive breakpoint thresholds and helper utilities
/// adhering to Material 3 adaptive design and Flutter responsive best practices.
class AppBreakpoints {
  AppBreakpoints._();

  /// Maximum readable content width for cards, forms, and mobile layouts on large displays.
  static const double maxContentWidth = 600.0;

  /// Breakpoint between compact mobile and medium/tablet screens.
  static const double tabletMinWidth = 600.0;

  /// Width threshold for very compact / narrow mobile devices (e.g., iPhone SE 1st gen, 320px).
  static const double compactNarrowWidth = 360.0;

  /// Checks if the window is currently in landscape orientation (width > height).
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  /// Checks if the window width is classified as tablet / large format (>= 600dp).
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletMinWidth;
  }

  /// Checks if the window width is ultra-narrow (< 360dp).
  static bool isNarrow(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactNarrowWidth;
  }
}

/// ResponsiveContent constrains child width to [maxWidth] and centers it on large displays.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// AdaptiveScrollBody provides a scrollable view that expands to at least the full viewport
/// height when space allows (enabling [Spacer] and flexible alignments to work), but enables
/// scrolling when the viewport is restricted (such as in landscape mode on mobile).
class AdaptiveScrollBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdaptiveScrollBody({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
