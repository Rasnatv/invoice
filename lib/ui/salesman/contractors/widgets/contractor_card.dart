import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../dummymodels/contractor_model.dart';

class ContractorCard extends StatelessWidget {
  final ContractorModel contractor;
  final VoidCallback? onTap;
  const ContractorCard({super.key, required this.contractor, this.onTap});

  @override
  Widget build(BuildContext context) {
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
              width: Responsive.w(46),
              height: Responsive.w(46),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.apartment_rounded, color: AppColors.primary),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contractor.name, style: AppTextStyles.bodyBold()),
                  SizedBox(height: Responsive.h(2)),
                  Text(contractor.phone, style: AppTextStyles.body()),
                  Text(contractor.address, style: AppTextStyles.caption()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
