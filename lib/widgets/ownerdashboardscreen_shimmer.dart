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

// ---------------- OWNER DASHBOARD SKELETONS ----------------
// Every skeleton mirrors the dimensions, radii, borders and spacing of the
// real widget in owner_dashboard_screen.dart so there is no layout jump.

/// Mirrors the 4 `_MiniStat` columns (icon 18, value, label).
class HeaderStatsShimmer extends StatelessWidget {
  const HeaderStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget stat() => Column(
      children: [
        ShimmerWidget.circular(size: 18),
        SizedBox(height: Responsive.h(6)),
        ShimmerWidget.rectangular(width: 26, height: Responsive.sp(17), borderRadius: 4),
        SizedBox(height: Responsive.h(2)),
        ShimmerWidget.rectangular(width: 46, height: Responsive.sp(10.5), borderRadius: 4),
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
      Container(width: 1, height: 34, color: AppColors.textSecondary.withOpacity(0.14));
}

/// Mirrors `_OwnerHeader`: icon box + greeting/name on the left,
/// calendar icon + date on the right, and the floating stats card.
class OwnerDashboardHeaderShimmer extends StatelessWidget {
  const OwnerDashboardHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(18),
            Responsive.w(20),
            Responsive.h(54),
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E8EB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                ShimmerWidget.rectangular(width: 46, height: 46, borderRadius: 14),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget.rectangular(
                          width: 70, height: Responsive.sp(12), borderRadius: 4),
                      SizedBox(height: Responsive.h(2) + 4),
                      ShimmerWidget.rectangular(
                          width: 130, height: Responsive.sp(18), borderRadius: 4),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerWidget.circular(size: 14),
                    SizedBox(height: Responsive.h(4)),
                    ShimmerWidget.rectangular(
                        width: 96, height: Responsive.sp(10.5), borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(52),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: Responsive.h(14), horizontal: Responsive.w(6)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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

/// Stand-in for `_SectionTitle`. Pass [withAction] for the "View all" link.
class SectionTitleShimmer extends StatelessWidget {
  const SectionTitleShimmer({super.key, this.width = 120, this.withAction = false});
  final double width;
  final bool withAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerWidget.rectangular(width: width, height: Responsive.sp(16), borderRadius: 4),
        if (withAction)
          ShimmerWidget.rectangular(width: 50, height: Responsive.sp(12.5), borderRadius: 4),
      ],
    );
  }
}

/// Matches the screen's private `_CardWrapper` (radius 18, border).
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Mirrors `_QuickAccessPanel` (collapsed): white bordered card with a
/// 4-column grid of 44x44 icon tiles + 2-line labels, divider and "More" row.
class QuickActionsShimmer extends StatelessWidget {
  const QuickActionsShimmer({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(6), vertical: Responsive.h(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              for (int i = 0; i < count; i++)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(2), vertical: Responsive.h(6)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerWidget.rectangular(width: 44, height: 44, borderRadius: 14),
                      SizedBox(height: Responsive.h(5)),
                      ShimmerWidget.rectangular(width: 44, height: 8, borderRadius: 4),
                      const SizedBox(height: 3),
                      ShimmerWidget.rectangular(width: 30, height: 8, borderRadius: 4),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(6) + 3),
            child: ShimmerWidget.rectangular(width: 56, height: 14, borderRadius: 4),
          ),
        ],
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

/// Mirrors `_RecentEstimateCard`: 42x42 icon box, three text lines,
/// and total + status badge on the right.
class RecentEstimateShimmerCard extends StatelessWidget {
  const RecentEstimateShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ShimmerWidget.rectangular(width: 42, height: 42, borderRadius: 12),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(width: 110, height: 14, borderRadius: 4),
                SizedBox(height: Responsive.h(4)),
                ShimmerWidget.rectangular(width: 80, height: 11, borderRadius: 4),
                SizedBox(height: Responsive.h(4)),
                ShimmerWidget.rectangular(width: 70, height: 11, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerWidget.rectangular(width: 64, height: 14, borderRadius: 4),
              SizedBox(height: Responsive.h(6)),
              ShimmerWidget.rectangular(width: 58, height: 20, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// N shimmer estimate cards with the same 10px spacing as the real list.
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

/// Body shimmer mirroring the real screen's section order and spacing:
/// Quick Actions -> Sales Overview -> Recent Estimates.
List<Widget> _ownerDashboardBodyShimmer() {
  return [
    const SectionTitleShimmer(width: 110),
    SizedBox(height: Responsive.h(10)),
    const QuickActionsShimmer(count: 4),
    SizedBox(height: Responsive.h(14) + Responsive.h(12)),
    const SectionTitleShimmer(width: 130),
    SizedBox(height: Responsive.h(12)),
    const ShimmerCardWrapper(child: SalesOverviewShimmer()),
    SizedBox(height: Responsive.h(26)),
    const SectionTitleShimmer(width: 140, withAction: true),
    SizedBox(height: Responsive.h(12)),
    const RecentEstimateListShimmer(count: 3),
  ];
}

class OwnerDashboardShimmer extends StatelessWidget {
  const OwnerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const OwnerDashboardFullShimmer(),
    );
  }
}

/// Full-screen skeleton for the first load.
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

/// Pull-to-refresh skeleton: same layout, built as slivers so it can sit
/// inside the `RefreshIndicator` (needs `AlwaysScrollableScrollPhysics`).
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