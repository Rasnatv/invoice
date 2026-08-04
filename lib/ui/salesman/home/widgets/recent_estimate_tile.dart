import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../dummymodels/estimate_model.dart';


/// A single row in "Recent Estimates" (Dashboard Home) or in the
/// "My Estimates" list — estimate id, contractor, date, amount, status.
class RecentEstimateTile extends StatelessWidget {
  final EstimateModel estimate;
  final VoidCallback? onTap;

  const RecentEstimateTile({super.key, required this.estimate, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(estimate.totalAmount);
    final formattedDate = DateFormat('dd MMM yyyy').format(estimate.date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.h(12)),
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.w(44),
              height: Responsive.w(44),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_rounded, color: AppColors.primary),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(estimate.id, style: AppTextStyles.bodyBold()),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          estimate.contractorName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(formattedDate, style: AppTextStyles.caption()),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: estimate.status),
                SizedBox(height: Responsive.h(6)),
                Text(formattedAmount, style: AppTextStyles.bodyBold()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
