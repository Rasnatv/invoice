import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../models/salesmanmodels/salesmanownerestimatemodel.dart';

class EstimateCard extends StatelessWidget {
  final SalesmanowrEstimateModel estimate;
  final VoidCallback onTap;

  const EstimateCard({super.key, required this.estimate, required this.onTap});

  Color _statusColor() {
    switch (estimate.statusKey) {
      case 'draft':
        return Colors.orange;
      case 'sent':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'new':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.h(12)),
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
                Expanded(
                  child: Text(
                    estimate.estimateNumber,
                    style: AppTextStyles.bodyBold(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estimate.statusLabel,
                    style: AppTextStyles.caption(color: statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(6)),
            Text(estimate.customerName, style: AppTextStyles.subtitle()),
            if (estimate.contractorName.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: Responsive.h(2)),
                child: Text(
                  'Contractor: ${estimate.contractorName}',
                  style: AppTextStyles.caption(),
                ),
              ),
            SizedBox(height: Responsive.h(8)),
            Row(
              children: [
                Icon(Icons.call_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Text(estimate.customerPhone, style: AppTextStyles.caption()),
                SizedBox(width: Responsive.w(16)),
                Icon(Icons.event_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Text(estimate.date, style: AppTextStyles.caption()),
              ],
            ),
            SizedBox(height: Responsive.h(10)),
            const Divider(height: 1),
            SizedBox(height: Responsive.h(10)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     // Text('Grand Total', style: AppTextStyles.caption()),
                      Text(estimate.grandTotalFormatted, style: AppTextStyles.bodyBold()),
                    ],
                  ),
                ),
              ],
            ),
            if (estimate.quotationNumber.trim().isNotEmpty) ...[
              SizedBox(height: Responsive.h(8)),
              Text('Quotation: ${estimate.quotationNumber}', style: AppTextStyles.caption()),
            ],
            // Shows who approved it, when it's approved - hidden otherwise.
            if (estimate.isApproved) ...[
              SizedBox(height: Responsive.h(6)),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 14, color: Colors.green),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      'Approved by ${estimate.approvedBy}'
                          '${estimate.approvedAt.trim().isNotEmpty ? ' on ${estimate.approvedAt}' : ''}',
                      style: AppTextStyles.caption(color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            // if (estimate.canPayNowBool) ...[
            //   SizedBox(height: Responsive.h(8)),
            //   Align(
            //     alignment: Alignment.centerRight,
            //     child: Container(
            //       padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
            //       decoration: BoxDecoration(
            //         color: AppColors.primary.withOpacity(0.1),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: Text('Pay Now Available', style: AppTextStyles.caption(color: AppColors.primary)),
            //     ),
          //     ),
          //   ],
           ],
         ),
      ),
     );
  }
}
