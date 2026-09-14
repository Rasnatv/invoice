
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Base shimmer effect wrapper — animates a moving gradient sheen
/// across whatever child you give it. No external package required.
class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE6E8EB),
    this.highlightColor = const Color(0xFFF6F7F8),
    this.duration = const Duration(milliseconds: 1300),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  /// Rounded-rectangle placeholder block (text lines, cards, images).
  factory ShimmerWidget.rectangular({
    Key? key,
    double width = double.infinity,
    required double height,
    double borderRadius = 8,
  }) {
    return ShimmerWidget(
      key: key,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Circular placeholder (avatars, round icon badges).
  factory ShimmerWidget.circular({Key? key, required double size}) {
    return ShimmerWidget(
      key: key,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: widget.duration)..repeat();

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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
            stops: const [0.1, 0.5, 0.9],
            begin: const Alignment(-1.0, -0.3),
            end: const Alignment(1.0, 0.3),
            transform: _SlidingGradientTransform(slidePercent: _controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

// ---------------- SCREEN-SPECIFIC SKELETONS (Owner Dashboard) ----------------

/// Skeleton for the 4 mini-stat columns in the owner header
/// (Total / Dispatched / Quotations / Pending).
class HeaderStatsShimmer extends StatelessWidget {
  const HeaderStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget stat() => Column(
      children: [
        ShimmerWidget.circular(size: 26),
        SizedBox(height: Responsive.h(6)),
        ShimmerWidget.rectangular(width: 28, height: 14, borderRadius: 4),
        SizedBox(height: Responsive.h(4)),
        ShimmerWidget.rectangular(width: 42, height: 9, borderRadius: 4),
      ],
    );

    return Row(
      children: [
        Expanded(child: stat()),
        _divider(),
        Expanded(child: stat()),
        _divider(),
        Expanded(child: stat()),
        _divider(),
        Expanded(child: stat()),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: AppColors.textSecondary.withOpacity(0.08));
}

/// Skeleton for the whole owner header — avatar, greeting/name lines,
/// notification icon, date line, and the floating stats card. Used in
/// place of the real `_OwnerHeader` for first load and pull-to-refresh,
/// so nothing in the header (not just the numbers) reads as "live" while
/// data is still in flight.
class OwnerDashboardHeaderShimmer extends StatelessWidget {
  const OwnerDashboardHeaderShimmer({super.key});

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
            Responsive.h(46),
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E8EB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerWidget.circular(size: 48),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget.rectangular(width: 90, height: Responsive.sp(12), borderRadius: 4),
                          SizedBox(height: Responsive.h(6)),
                          ShimmerWidget.rectangular(width: 140, height: Responsive.sp(17), borderRadius: 4),
                        ],
                      ),
                    ),
                    ShimmerWidget.circular(size: 38),
                  ],
                ),
                SizedBox(height: Responsive.h(14)),
                ShimmerWidget.rectangular(width: 150, height: Responsive.sp(12), borderRadius: 4),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(60),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16), horizontal: Responsive.w(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const HeaderStatsShimmer(),
          ),
        ),
      ],
    );
  }
}

/// Shimmer stand-in for a `_SectionTitle` label ("Quick Actions", "Sales
/// Overview", "Recent Estimates"), so section headings shimmer too instead
/// of sitting there as static real text while everything below them loads.
class SectionTitleShimmer extends StatelessWidget {
  const SectionTitleShimmer({super.key, this.width = 120});
  final double width;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget.rectangular(width: width, height: Responsive.sp(16), borderRadius: 4);
  }
}

/// Plain white rounded card, matching the screen's private `_CardWrapper`
/// styling, for wrapping shimmer content (e.g. `SalesOverviewShimmer`)
/// without depending on that private widget.
class ShimmerCardWrapper extends StatelessWidget {
  const ShimmerCardWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Skeleton for the horizontal "Quick Actions" row — mimics N icon+label tiles.
class QuickActionsShimmer extends StatelessWidget {
  const QuickActionsShimmer({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.h(100),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(12)),
        itemBuilder: (context, i) => SizedBox(
          width: Responsive.w(84),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(10), horizontal: Responsive.w(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerWidget.circular(size: 36),
                SizedBox(height: Responsive.h(8)),
                ShimmerWidget.rectangular(width: 52, height: 9, borderRadius: 4),
                SizedBox(height: Responsive.h(4)),
                ShimmerWidget.rectangular(width: 36, height: 9, borderRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton for the Sales Overview card content (bar-chart style).
class SalesOverviewShimmer extends StatelessWidget {
  const SalesOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final heights = [40.0, 70.0, 55.0, 90.0, 65.0, 48.0];
    return SizedBox(
      height: Responsive.h(140),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final h in heights)
            ShimmerWidget.rectangular(width: 22, height: Responsive.h(h), borderRadius: 6),
        ],
      ),
    );
  }
}

/// Skeleton mimicking a single _RecentEstimateCard.
class RecentEstimateShimmerCard extends StatelessWidget {
  const RecentEstimateShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangular(width: 120, height: 14, borderRadius: 4),
              ShimmerWidget.rectangular(width: 60, height: 18, borderRadius: 9),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          ShimmerWidget.rectangular(width: 90, height: 10, borderRadius: 4),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangular(width: 70, height: 10, borderRadius: 4),
              ShimmerWidget.rectangular(width: 60, height: 14, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Convenience list of N shimmer estimate cards with spacing already applied.
/// Use this in place of the loading branch for the "Recent Estimates" section.
class RecentEstimateListShimmer extends StatelessWidget {
  const RecentEstimateListShimmer({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          const RecentEstimateShimmerCard(),
          if (i != count - 1) SizedBox(height: Responsive.h(10)),
        ],
      ],
    );
  }
}

// ---------------- FULL-PAGE SKELETONS ----------------

/// Full-screen skeleton for OwnerDashboardScreen, self-contained with its
/// own `Scaffold` — same pattern as `SalesmanDashboardShimmer`.
///
/// Drop this in place of the loading branch for the very first load
/// (before any cached data exists), returned directly ahead of the real
/// `Scaffold`/`RefreshIndicator`:
///
///   if (state.isLoading) {
///     return const OwnerDashboardShimmer();
///   }
///
/// For pull-to-refresh on a screen that already has data, use
/// [OwnerDashboardRefreshShimmer] instead — that one has no `Scaffold` of
/// its own so it can sit inside the existing `RefreshIndicator`.
class OwnerDashboardShimmer extends StatelessWidget {
  const OwnerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: OwnerDashboardHeaderShimmer()),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: Responsive.h(70)),
                ..._ownerDashboardBodyShimmer(),
                SizedBox(height: Responsive.h(30)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Body content shared by first load and pull-to-refresh: header, quick
/// actions, sales overview, and recent estimates, all as shimmer. Kept as
/// a plain list of widgets (not a Column) so it can be reused inside
/// either a `SingleChildScrollView` (first load) or a `SliverList`
/// (refresh, inside a `CustomScrollView`/`RefreshIndicator`).
List<Widget> _ownerDashboardBodyShimmer() {
  return [
    const SectionTitleShimmer(width: 110),
    SizedBox(height: Responsive.h(14)),
    const QuickActionsShimmer(count: 6),
    SizedBox(height: Responsive.h(28)),
    const SectionTitleShimmer(width: 130),
    SizedBox(height: Responsive.h(14)),
    const ShimmerCardWrapper(child: SalesOverviewShimmer()),
    SizedBox(height: Responsive.h(28)),
    const SectionTitleShimmer(width: 140),
    SizedBox(height: Responsive.h(14)),
    const RecentEstimateListShimmer(count: 3),
  ];
}

/// Full-screen skeleton for the owner dashboard's first load — header,
/// quick actions, sales overview, and recent estimates, all shimmering
/// together so the whole page reads as loading, not just a few numbers.
class OwnerDashboardFullShimmer extends StatelessWidget {
  const OwnerDashboardFullShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OwnerDashboardHeaderShimmer(),
          SizedBox(height: Responsive.h(76)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._ownerDashboardBodyShimmer(),
                SizedBox(height: Responsive.h(30)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen shimmer for pull-to-refresh: same header + sections as
/// [OwnerDashboardFullShimmer], but built as slivers so it can sit inside
/// the same `CustomScrollView`/`RefreshIndicator` the real content uses
/// (needs `AlwaysScrollableScrollPhysics` for the pull gesture to work).
class OwnerDashboardRefreshShimmer extends StatelessWidget {
  const OwnerDashboardRefreshShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: OwnerDashboardHeaderShimmer()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(76),
            Responsive.w(20),
            Responsive.h(30),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(_ownerDashboardBodyShimmer()),
          ),
        ),
      ],
    );
  }
}