//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../models/salesmanmodels/salesmanapprovedbillsmodel.dart';
//
// class ApprovedEstimateTile extends StatelessWidget {
//   const ApprovedEstimateTile({super.key, required this.estimate, this.onTap});
//
//   final ApprovedEstimateListItem estimate;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final isPaid = estimate.balanceAmount <= 0;
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: Responsive.h(10)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           padding: EdgeInsets.all(Responsive.w(14)),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: AppColors.success.withOpacity(0.1),
//                 child: Icon(Icons.description_outlined, color: AppColors.success, size: 20),
//               ),
//               SizedBox(width: Responsive.w(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       estimate.estimateNumber.isEmpty ? '#${estimate.id}' : estimate.estimateNumber,
//                       style: AppTextStyles.bodyBold(),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: Responsive.h(4)),
//                     Text(
//                       estimate.customerName.isEmpty ? 'No party name' : estimate.customerName,
//                       style: AppTextStyles.caption(),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: Responsive.w(6)),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     currency.format(estimate.grandTotal),
//                     style: AppTextStyles.bodyBold(color: AppColors.primary),
//                   ),
//                   SizedBox(height: Responsive.h(4)),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: (isPaid ? AppColors.success : Colors.orange).withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       estimate.balanceStatusLabel.isEmpty ? '-' : estimate.balanceStatusLabel,
//                       style: AppTextStyles.caption(color: isPaid ? AppColors.success : Colors.orange),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../models/salesmanmodels/salesmanapprovedbillsmodel.dart';

class ApprovedEstimateTile extends StatelessWidget {
  const ApprovedEstimateTile({super.key, required this.estimate, this.onTap});

  final ApprovedEstimateListItem estimate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final isPaid = estimate.balanceAmount <= 0;
    final balanceColor = isPaid ? AppColors.success : Colors.orange;

    final dateText = estimate.date != null
        ? DateFormat('dd-MM-yyyy').format(estimate.date!)
        : (estimate.dateRaw.isNotEmpty ? estimate.dateRaw : '-');

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- top: icon, number + customer, balance status ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.description_outlined,
                          color: AppColors.success, size: 20),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estimate.estimateNumber.isEmpty
                                ? '#${estimate.id}'
                                : estimate.estimateNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            estimate.customerName.isEmpty
                                ? 'No party name'
                                : estimate.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: balanceColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estimate.balanceStatusLabel.isEmpty
                            ? '-'
                            : estimate.balanceStatusLabel,
                        style: AppTextStyles.caption(color: balanceColor),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.h(12)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(10)),

                // ---- bottom: date + items, total ----
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: AppColors.textSecondary),
                    SizedBox(width: Responsive.w(6)),
                    Expanded(
                      child: Text(
                        '$dateText  •  ${estimate.totalItems} items',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(color: AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      currency.format(estimate.grandTotal),
                      style: AppTextStyles.amount(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}