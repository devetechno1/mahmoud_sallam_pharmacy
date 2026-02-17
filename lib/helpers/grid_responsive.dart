import 'package:flutter/material.dart';

@immutable
class GridResponsive {
  const GridResponsive._();

  // Breakpoints aligned with app usage
  static const double bpSm = 600;
  static const double bpMd = 900;
  static const double bpLg = 1200;

  /// Columns based on width & min tile width; capped by breakpoints.
  ///
  /// make [minTileWidth] in range [140,280] for denser grids.
  static int columnsForWidth(
    BuildContext context, {
    double minTileWidth = 180,
    int maxXs = 2,
    int maxSm = 3,
    int maxMd = 4,
    int maxLg = 5,
  }) {
    final double width = MediaQuery.sizeOf(context).width;
    final byBp = width >= bpLg
        ? maxLg
        : width >= bpMd
            ? maxMd
            : width >= bpSm
                ? maxSm
                : maxXs;
    final int byMin = width ~/ minTileWidth;
    return byMin.clamp(1, byBp);
  }

  /// Aspect ratio per breakpoint; returns [fallback] if disabled.
  static double aspectRatioForWidth(
    BuildContext context, {
    bool useResponsiveAspectRatio = true,
    double fallback = 0.62,
    double maxSm = 0.68,
    double maxMd = 0.70,
    double maxLg = 0.72,
  }) {
    if (!useResponsiveAspectRatio) return fallback;
    final double width = MediaQuery.sizeOf(context).width;

    if (width >= bpLg) return maxLg;
    if (width >= bpMd) return maxMd;
    if (width >= bpSm) return maxSm;
    return fallback;
  }
}
