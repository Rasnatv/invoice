
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../widgets/status_badge.dart';
import 'cubit/dummy.dart';


class NewCard extends StatelessWidget {
  final DummyDispatchModel dispatch;
  final VoidCallback? onTap;
  const NewCard({super.key, required this.dispatch, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final date = DateFormat('dd MMM yyyy').format(dispatch.date);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.w(44),
              height: Responsive.w(44),
              decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_shipping_rounded, color: AppColors.info),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dispatch.id, style: AppTextStyles.bodyBold()),
                  Text(
                    dispatch.contractorName,
                    style: AppTextStyles.body(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(date, style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(2)),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: Responsive.w(4)),
                      Expanded(
                        child: Text(
                          'Despatched by ${dispatch.despatchedBy}',
                          style: AppTextStyles.caption(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: dispatch.status),
                SizedBox(height: Responsive.h(6)),
                Text(currency.format(dispatch.amount), style: AppTextStyles.bodyBold()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
