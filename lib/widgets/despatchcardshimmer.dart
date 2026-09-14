// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/utils/responsive.dart';
// import 'owner_estimateshimmer.dart';
//
//
// class DispatchCardShimmer extends StatelessWidget {
//   const DispatchCardShimmer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(child: ShimmerBox(height: Responsive.h(16))),
//               SizedBox(width: Responsive.w(10)),
//               ShimmerBox(
//                 width: Responsive.w(70),
//                 height: Responsive.h(22),
//                 borderRadius: 20,
//               ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(10)),
//           ShimmerBox(width: Responsive.w(160), height: Responsive.h(14)),
//           SizedBox(height: Responsive.h(6)),
//           ShimmerBox(width: Responsive.w(110), height: Responsive.h(12)),
//           SizedBox(height: Responsive.h(14)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               ShimmerBox(width: Responsive.w(60), height: Responsive.h(12)),
//               ShimmerBox(width: Responsive.w(80), height: Responsive.h(14)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'owner_estimateshimmer.dart';

class DispatchCardShimmer extends StatelessWidget {
  const DispatchCardShimmer({super.key});

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
            children: [
              Expanded(child: ShimmerBox(height: Responsive.h(16))),
              SizedBox(width: Responsive.w(10)),
              ShimmerBox(
                width: Responsive.w(70),
                height: Responsive.h(22),
                borderRadius: 20,
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          ShimmerBox(width: Responsive.w(160), height: Responsive.h(14)),
          SizedBox(height: Responsive.h(6)),
          ShimmerBox(width: Responsive.w(110), height: Responsive.h(12)),
          SizedBox(height: Responsive.h(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: Responsive.w(60), height: Responsive.h(12)),
              ShimmerBox(width: Responsive.w(80), height: Responsive.h(14)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Drop-in replacement for the CircularProgressIndicator branch in
/// SalesmanDispatchListScreen's _buildBody — N shimmering DispatchCardShimmer
/// rows with the same spacing as the real ListView.separated below it.
class DispatchListShimmer extends StatelessWidget {
  const DispatchListShimmer({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (_, __) => const DispatchCardShimmer(),
      ),
    );
  }
}