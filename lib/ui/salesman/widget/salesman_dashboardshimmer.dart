import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/ownerdashboardscreen_shimmer.dart';

class SalesmanDashboardShimmer extends StatelessWidget {
  const SalesmanDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _SalesmanHeaderShimmer()),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: Responsive.h(70)),
                _titleBlock(),
                SizedBox(height: Responsive.h(14)),
                const QuickActionsShimmer(count: 5),
                SizedBox(height: Responsive.h(28)),
                _titleBlock(width: 120),
                SizedBox(height: Responsive.h(14)),
                const _CardWrapperShimmer(child: SalesOverviewShimmer()),
                SizedBox(height: Responsive.h(28)),
                _titleBlock(width: 150),
                SizedBox(height: Responsive.h(12)),
                const _CardWrapperShimmer(
                  padding: EdgeInsets.zero,
                  child: RecentEstimateTileListShimmer(count: 4),
                ),
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

/// Mimics _DashboardHeader: gradient block + floating white stat strip.
/// This one is specific to the salesman screen (different curve/height
/// than the owner header), so it lives here rather than in the shared file.
class _SalesmanHeaderShimmer extends StatelessWidget {
  const _SalesmanHeaderShimmer();

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
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: const BorderRadius.only(
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
                          ShimmerWidget.rectangular(width: 90, height: 10, borderRadius: 4),
                          SizedBox(height: Responsive.h(6)),
                          ShimmerWidget.rectangular(width: 140, height: 16, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(14)),
                ShimmerWidget.rectangular(width: 160, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(60),
          child: const HeaderStatsShimmer(),
        ),
      ],
    );
  }
}

/// Same rounded white card shell as _CardWrapper in the real screen.
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

/// Skeleton for one DashboardRecentEstimateTile row (title + trailing chip,
/// subtitle line) plus a divider — matches the flat list-with-dividers
/// style used inside the recent-estimates card, unlike the owner screen's
/// separately bordered cards.
class RecentEstimateTileShimmer extends StatelessWidget {
  const RecentEstimateTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(14)),
      child: Row(
        children: [
          ShimmerWidget.circular(size: 40),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(width: 130, height: 13, borderRadius: 4),
                SizedBox(height: Responsive.h(6)),
                ShimmerWidget.rectangular(width: 80, height: 10, borderRadius: 4),
              ],
            ),
          ),
          ShimmerWidget.rectangular(width: 54, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}

/// A list of tile shimmers with the same dividers the real widget uses,
/// so it can drop straight into the zero-padding _CardWrapper.
class RecentEstimateTileListShimmer extends StatelessWidget {
  const RecentEstimateTileListShimmer({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          const RecentEstimateTileShimmer(),
          if (i != count - 1)
            Divider(
              height: 1,
              indent: Responsive.w(16),
              endIndent: Responsive.w(16),
              color: AppColors.textSecondary.withOpacity(0.1),
            ),
        ],
      ],
    );
  }
}