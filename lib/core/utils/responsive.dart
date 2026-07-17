import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth; // 1% of width
  static late double blockHeight; // 1% of height

  /// Design reference size (matches the Figma / screenshot frame, e.g.
  /// a standard 390x844 mobile canvas). Used to scale font sizes.
  static const double _designWidth = 390;
  static const double _designHeight = 844;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  /// Scaled width — pass a design pixel value, get a responsive value back.
  static double w(double designWidth) => (designWidth / _designWidth) * screenWidth;

  /// Scaled height — pass a design pixel value, get a responsive value back.
  static double h(double designHeight) => (designHeight / _designHeight) * screenHeight;

  /// Scaled font size, clamped to avoid becoming unreadably small/large.
  static double sp(double fontSize) {
    final scaled = (fontSize / _designWidth) * screenWidth;
    return scaled.clamp(fontSize * 0.75, fontSize * 1.3);
  }

  /// Percentage-of-width helper, e.g. Responsive.wp(50) => 50% of width.
  static double wp(double percent) => blockWidth * percent;

  /// Percentage-of-height helper, e.g. Responsive.hp(50) => 50% of height.
  static double hp(double percent) => blockHeight * percent;

  // ---------------- Breakpoints ----------------
  static bool get isMobile => screenWidth < 600;
  static bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  static bool get isDesktop => screenWidth >= 1024;

  /// Returns a different value depending on the current breakpoint.
  static T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  /// Number of grid columns to use for card/grid layouts depending on
  /// the available width (used in dashboards, contractor grids, etc).
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 2; // phones show 2-up stat cards, as in the screenshots
  }

  /// Centers content and caps its width on very large screens (tablet/web)
  /// so the mobile-first design doesn't stretch edge-to-edge awkwardly.
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 480;
    if (width >= 600) return 520;
    return width;
  }
}

/// A convenience wrapper that centers and constrains its child's width
/// on large screens while behaving like a normal full-width container
/// on phones. Use this once near the root of each screen's body.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  const ResponsiveCenter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Responsive.contentMaxWidth(context)),
        child: child,
      ),
    );
  }
}
