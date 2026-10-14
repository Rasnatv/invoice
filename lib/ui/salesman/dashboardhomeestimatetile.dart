
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';

import '../../models/salesmanmodels/salesman_dashboardmodel.dart';

class DashboardRecentEstimateTile extends StatelessWidget {
  const DashboardRecentEstimateTile({
    super.key,
    required this.estimate,
    this.onTap,
  });

  final DashboardHomeRecentEstimate estimate;
  final VoidCallback? onTap;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF16A34A); // green
      case 'pending':
        return const Color(0xFFF59E0B); // amber
      case 'draft':
        return const Color(0xFF6B7280); // grey
      case 'rejected':
        return const Color(0xFFDC2626); // red
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(estimate.statusLabel);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_rounded,
                size: 18,
                color: statusColor,
              ),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 14 / w600 - estimate number
                  Text(
                    estimate.estimateNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3(color: AppColors.black),
                  ),
                  SizedBox(height: Responsive.h(2)),
                  // 12 / w400 - customer name
                  Text(
                    estimate.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle(),
                  ),
                  SizedBox(height: Responsive.h(2)),
                  // 11 / w400 - date
                  Text(
                    estimate.dateFormatted,
                    style: AppTextStyles.captionnew(),
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 14 / w600 - amount
                Text(
                  estimate.grandTotalFormatted,
                  style: AppTextStyles.balanceamount(color: AppColors.black),
                ),
                SizedBox(height: Responsive.h(6)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(8),
                    vertical: Responsive.h(3),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // 11 / w600 - status
                  child: Text(
                    estimate.statusLabel,
                    style: AppTextStyles.captioref(color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}