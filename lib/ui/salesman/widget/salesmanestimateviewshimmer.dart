import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../widgets/owner_estimateshimmer.dart';

class EstimateCardShimmer extends StatelessWidget {
  const EstimateCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerCircle(diameter: 42),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: Responsive.w(130), height: 14),
                    ShimmerBox(width: Responsive.w(58), height: 20, borderRadius: 10),
                  ],
                ),
                SizedBox(height: Responsive.h(8)),
                ShimmerBox(width: Responsive.w(90), height: 10),
                SizedBox(height: Responsive.h(10)),
                Container(height: 1, color: Colors.grey.shade100),
                SizedBox(height: Responsive.h(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: Responsive.w(70), height: 10),
                    ShimmerBox(width: Responsive.w(60), height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the horizontal filter-chip row (All / Pending / Approved...)
/// shown above the list — same pill shape as the real ChoiceChips, just
/// blank boxes that pick up the ShimmerLoading sweep.
class EstimateFilterChipsShimmer extends StatelessWidget {
  const EstimateFilterChipsShimmer({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    final widths = [70.0, 100.0, 84.0, 92.0, 76.0];
    return ShimmerLoading(
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ShimmerBox(
            width: Responsive.w(widths[i % widths.length]),
            height: 32,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }
}

/// Drop-in replacement for the ListView.builder branch in
/// MyEstimatesScreen while estimates are loading — same shimmer sweep
/// as the owner screen, just wrapping N EstimateCardShimmer rows.
class MyEstimatesListShimmer extends StatelessWidget {
  const MyEstimatesListShimmer({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerListPlaceholder(
      itemCount: itemCount,
      padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
      separatorHeight: Responsive.h(12),
      itemBuilder: (_, __) => const EstimateCardShimmer(),
    );
  }
}