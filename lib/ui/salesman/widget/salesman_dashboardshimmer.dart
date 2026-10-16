import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
// Only used for ShimmerWidget (rectangular / circular).
import '../../../widgets/ownerdashboardscreen_shimmer.dart';

/// Skeleton that mirrors _DashboardHomeView layout 1:1:
/// header (46px rounded avatar, greeting/name, date) + floating 4-stat strip,
/// 76px gap, Quick Actions (4-column grid), Sales Overview card,
/// Recent Estimates (separate bordered cards, 10px apart).
class SalesmanDashboardShimmer extends StatelessWidget {
  const SalesmanDashboardShimmer({super.key, this.actionCount = 4});

  /// Number of quick-action tiles to show (real screen shows 4 collapsed).
  final int actionCount;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _SalesmanHeaderShimmer()),
          SliverToBoxAdapter(child: SizedBox(height: Responsive.h(76))),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ---- Quick Actions ----
                _titleBlock(width: 110),
                SizedBox(height: Responsive.h(10)),
                _QuickActionsPanelShimmer(count: actionCount),
                SizedBox(height: Responsive.h(14)),

                SizedBox(height: Responsive.h(6)),

                // ---- Sales Overview ----
                _titleBlock(width: 120),
                SizedBox(height: Responsive.h(12)),
                const _CardWrapperShimmer(child: _SalesChartShimmer()),
                SizedBox(height: Responsive.h(26)),

                // ---- Recent Estimates ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _titleBlock(width: 150),
                    ShimmerWidget.rectangular(
                        width: 48, height: 12, borderRadius: 4),
                  ],
                ),
                SizedBox(height: Responsive.h(12)),
                const RecentEstimateTileListShimmer(count: 4),
                SizedBox(height: Responsive.h(30)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleBlock({double width = 100}) =>
      ShimmerWidget.rectangular(width: width, height: 16, borderRadius: 4);
}

// ---------------------------------------------------------------------
// HEADER  (mirrors _DashboardHeader)
// ---------------------------------------------------------------------

class _SalesmanHeaderShimmer extends StatelessWidget {
  const _SalesmanHeaderShimmer();

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
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // rounded-square avatar 46x46 (radius 14)
                ShimmerWidget.rectangular(
                    width: 46, height: 46, borderRadius: 14),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget.rectangular(
                          width: 80, height: 10, borderRadius: 4),
                      SizedBox(height: Responsive.h(6)),
                      ShimmerWidget.rectangular(
                          width: 140, height: 16, borderRadius: 4),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                // calendar icon + date (right side)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerWidget.rectangular(
                        width: 14, height: 14, borderRadius: 4),
                    SizedBox(height: Responsive.h(4)),
                    ShimmerWidget.rectangular(
                        width: 90, height: 10, borderRadius: 4),
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
          child: const _HeaderStatsStripShimmer(),
        ),
      ],
    );
  }
}

/// Floating white strip with 4 stats (icon, value, label) + dividers.
class _HeaderStatsStripShimmer extends StatelessWidget {
  const _HeaderStatsStripShimmer();

  @override
  Widget build(BuildContext context) {
    Widget stat() => Expanded(
      child: Column(
        children: [
          ShimmerWidget.rectangular(width: 18, height: 18, borderRadius: 5),
          SizedBox(height: Responsive.h(6)),
          ShimmerWidget.rectangular(width: 26, height: 15, borderRadius: 4),
          SizedBox(height: Responsive.h(2)),
          ShimmerWidget.rectangular(width: 42, height: 9, borderRadius: 4),
        ],
      ),
    );

    Widget divider() => Container(
      width: 1,
      height: 34,
      color: AppColors.textSecondary.withOpacity(0.14),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.h(14),
        horizontal: Responsive.w(6),
      ),
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
      child: Row(
        children: [
          stat(),
          divider(),
          stat(),
          divider(),
          stat(),
          divider(),
          stat(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// QUICK ACTIONS  (mirrors _QuickAccessPanel)
// ---------------------------------------------------------------------

class _QuickActionsPanelShimmer extends StatelessWidget {
  const _QuickActionsPanelShimmer({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(6), vertical: Responsive.h(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.9,
        children: [
          for (int i = 0; i < count; i++) const _ActionTileShimmer(),
        ],
      ),
    );
  }
}

class _ActionTileShimmer extends StatelessWidget {
  const _ActionTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(2), vertical: Responsive.h(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerWidget.rectangular(width: 44, height: 44, borderRadius: 14),
          SizedBox(height: Responsive.h(5)),
          ShimmerWidget.rectangular(width: 46, height: 9, borderRadius: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// SALES OVERVIEW  (mirrors _CardWrapper + chart)
// ---------------------------------------------------------------------

/// Same rounded white shell as _CardWrapper in the real screen
/// (radius 18 + border, no shadow).
class _CardWrapperShimmer extends StatelessWidget {
  const _CardWrapperShimmer({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _SalesChartShimmer extends StatelessWidget {
  const _SalesChartShimmer();

  @override
  Widget build(BuildContext context) {
    // screen width - page padding (20*2) - card padding (14*2)
    final w = MediaQuery.of(context).size.width -
        Responsive.w(20) * 2 -
        Responsive.w(14) * 2;
    return ShimmerWidget.rectangular(
        width: w, height: Responsive.h(180), borderRadius: 12);
  }
}

// ---------------------------------------------------------------------
// RECENT ESTIMATES  (mirrors _RecentEstimateCard)
// ---------------------------------------------------------------------

/// One bordered card: 42px icon box, 3 text lines, amount + badge on right.
class RecentEstimateTileShimmer extends StatelessWidget {
  const RecentEstimateTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                ShimmerWidget.rectangular(
                    width: 110, height: 13, borderRadius: 4),
                SizedBox(height: Responsive.h(6)),
                ShimmerWidget.rectangular(
                    width: 90, height: 10, borderRadius: 4),
                SizedBox(height: Responsive.h(6)),
                ShimmerWidget.rectangular(
                    width: 70, height: 10, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerWidget.rectangular(width: 70, height: 13, borderRadius: 4),
              SizedBox(height: Responsive.h(8)),
              ShimmerWidget.rectangular(
                  width: 54, height: 20, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// Separate cards with 10px gaps — same as the real list.
class RecentEstimateTileListShimmer extends StatelessWidget {
  const RecentEstimateTileListShimmer({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          const RecentEstimateTileShimmer(),
          if (i != count - 1) SizedBox(height: Responsive.h(10)),
        ],
      ],
    );
  }
}