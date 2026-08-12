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

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.success.withOpacity(0.1),
                child: Icon(Icons.local_shipping_outlined, color: AppColors.success, size: 20),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estimate.estimateNumber.isEmpty ? '#${estimate.id}' : estimate.estimateNumber,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      estimate.customerName.isEmpty ? 'No party name' : estimate.customerName,
                      style: AppTextStyles.body(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      '${estimate.date != null ? DateFormat('dd-MM-yyyy').format(estimate.date!) : '-'}  •  ${estimate.totalItems} items',
                      style: AppTextStyles.caption(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(estimate.grandTotal),
                      style: AppTextStyles.bodyBold(color: AppColors.primary)),
                  SizedBox(height: Responsive.h(4)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? AppColors.success : Colors.orange).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estimate.balanceStatusLabel.isEmpty ? '-' : estimate.balanceStatusLabel,
                      style: AppTextStyles.caption(color: isPaid ? AppColors.success : Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}