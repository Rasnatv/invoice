import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';

// ============================================================
// GENERIC SHIMMER WIDGET
// Reusable anywhere in the app — not tied to the driver dashboard.
// ============================================================

/// Generic, reusable shimmer loading effect. Wrap any skeleton built from
/// plain white [ShimmerBox]es with [ShimmerEffect] to get an animated
/// left-to-right sheen. No external `shimmer` package needed.
///
/// Usage:
/// ```dart
/// ShimmerEffect(
///   child: Column(
///     children: [
///       ShimmerBox(width: 120, height: 14),
///       SizedBox(height: 8),
///       ShimmerBox(width: 80, height: 10),
///     ],
///   ),
/// )
/// ```
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE9EBEE),
    this.highlightColor = const Color(0xFFF7F8FA),
    this.duration = const Duration(milliseconds: 1400),
  });

  /// The skeleton to animate. Build it out of [ShimmerBox]/plain white
  /// shapes — the shader tints whatever's here, so real content or icons
  /// underneath will look wrong.
  final Widget child;

  /// Darker tone of the sweep.
  final Color baseColor;

  /// Lighter tone that sweeps across [baseColor].
  final Color highlightColor;

  /// How long one full sweep takes.
  final Duration duration;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dx = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
            stops: const [0.35, 0.5, 0.65],
            begin: Alignment(-1 - dx * 2, 0),
            end: Alignment(1 - dx * 2, 0),
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A solid rounded-rect (or circle) placeholder block for use inside a
/// [ShimmerEffect]. Always plain white — the shimmer shader does the
/// coloring, so don't give this its own color/opacity.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
    this.shape = BoxShape.rectangle,
  });

  /// Fixed width, or null to fill available width (e.g. inside a Row's
  /// Expanded/Flexible).
  final double? width;
  final double height;

  /// Corner radius. Ignored when [shape] is [BoxShape.circle].
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

// ============================================================
// DRIVER DASHBOARD SKELETONS
// Screen-specific, built on the generic widgets above.
// ============================================================

/// Full-screen skeleton for the driver dashboard's first load. Mirrors the
/// real layout (header + stat strip + search bar + a handful of list
/// tiles) so there's no layout jump once real data arrives.
class DriverDashboardShimmer extends StatelessWidget {
  const DriverDashboardShimmer({super.key, this.tileCount = 5});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DriverDashboardHeaderShimmer(),
            SizedBox(height: Responsive.h(66)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: ShimmerBox(height: Responsive.h(48), radius: 16),
            ),
            SizedBox(height: Responsive.h(14)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: Column(
                children: List.generate(
                  tileCount,
                      (i) => Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(12)),
                    child: const DriverBillTileShimmer(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for just the header (avatar, greeting, date pill, stat strip).
/// Split out on its own so it can drop straight into a `SliverToBoxAdapter`
/// during pull-to-refresh, not only inside the full first-load skeleton.
/// Not wrapped in [ShimmerEffect] itself -- wrap it (or a parent containing
/// it) once so the whole screen sweeps together.
class DriverDashboardHeaderShimmer extends StatelessWidget {
  const DriverDashboardHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(20),
            Responsive.w(20),
            Responsive.h(52),
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFE9EBEE),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerBox(width: 50, height: 50, shape: BoxShape.circle),
                    SizedBox(width: Responsive.w(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: Responsive.w(110), height: 12),
                          // Just spacing here -- the date itself renders in
                          // the pill below, same as in the real header.
                          SizedBox(height: Responsive.h(6)),
                        ],
                      ),
                    ),
                    const ShimmerBox(width: 38, height: 38, shape: BoxShape.circle),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                ShimmerBox(width: Responsive.w(150), height: Responsive.h(26), radius: 20),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(50),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16), horizontal: Responsive.w(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Column(
                    children: [
                      const ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
                      SizedBox(height: Responsive.h(8)),
                      ShimmerBox(width: 28, height: 14),
                      SizedBox(height: Responsive.h(4)),
                      ShimmerBox(width: 44, height: 9),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton for a single bill tile, matching `_BillTile`'s shape (left
/// status stripe, avatar + name + DS number, address line, meta chips,
/// total row).
class DriverBillTileShimmer extends StatelessWidget {
  const DriverBillTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.06)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFE9EBEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(13)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ShimmerBox(width: 34, height: 34, shape: BoxShape.circle),
                        SizedBox(width: Responsive.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: Responsive.w(120), height: 13),
                              SizedBox(height: Responsive.h(6)),
                              ShimmerBox(width: Responsive.w(70), height: 10),
                            ],
                          ),
                        ),
                        ShimmerBox(width: Responsive.w(60), height: Responsive.h(20), radius: 20),
                      ],
                    ),
                    SizedBox(height: Responsive.h(10)),
                    Divider(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.06)),
                    SizedBox(height: Responsive.h(10)),
                    ShimmerBox(width: double.infinity, height: 10),
                    SizedBox(height: Responsive.h(8)),
                    Row(
                      children: [
                        ShimmerBox(width: Responsive.w(70), height: Responsive.h(20), radius: 8),
                        SizedBox(width: Responsive.w(6)),
                        Expanded(child: ShimmerBox(height: Responsive.h(20), radius: 8)),
                      ],
                    ),
                    SizedBox(height: Responsive.h(12)),
                    ShimmerBox(width: Responsive.w(90), height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Drop-in replacement for the bill list while a pull-to-refresh is in
/// flight. Keeps the same outer padding as `_BillList` so nothing jumps
/// when real data swaps back in.
class DriverBillListShimmer extends StatelessWidget {
  const DriverBillListShimmer({super.key, this.tileCount = 4});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(20),
          Responsive.h(4),
          Responsive.w(20),
          Responsive.h(24),
        ),
        itemCount: tileCount,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
        itemBuilder: (_, __) => const DriverBillTileShimmer(),
      ),
    );
  }
}

/// Full-screen shimmer for pull-to-refresh: header + search bar + list
/// tiles, all sweeping together as one [ShimmerEffect] so the whole page
/// reads as "refreshing", not just the list underneath. Meant to sit
/// inside the same `CustomScrollView`/`RefreshIndicator` the real content
/// uses, as a drop-in set of slivers.
class DriverDashboardRefreshShimmer extends StatelessWidget {
  const DriverDashboardRefreshShimmer({super.key, this.tileCount = 4});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: DriverDashboardHeaderShimmer()),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: Responsive.h(55)),
                ShimmerBox(height: Responsive.h(48), radius: 16),
                SizedBox(height: Responsive.h(14)),
              ]),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                for (var i = 0; i < tileCount; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(12)),
                    child: const DriverBillTileShimmer(),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}