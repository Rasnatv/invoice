import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/salesman/quatation/quotationpreview.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../dummymodels/estimate_model.dart';
import 'dummy quotation.dart';

class QuotationListScreen extends StatelessWidget {
  const QuotationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final quotations = dummyQuotations
        .where((e) => e.billType == EstimateBillType.quotation)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quotations', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: quotations.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.request_quote_outlined, size: 48, color: AppColors.textHint),
              SizedBox(height: Responsive.h(10)),
              Text('No quotations yet', style: AppTextStyles.body(color: AppColors.textHint)),
            ],
          ),
        )
            : ListView.separated(
          padding: EdgeInsets.all(Responsive.w(18)),
          itemCount: quotations.length,
          separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
          itemBuilder: (context, index) {
            final estimate = quotations[index];

            return _QuotationTile(
              estimate: estimate,
              currency: currency,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuotationPreviewScreen(estimate: estimate),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _QuotationTile extends StatelessWidget {
  const _QuotationTile({
    required this.estimate,
    required this.currency,
    required this.onTap,
  });

  final EstimateModel estimate;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.request_quote_outlined, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(estimate.id, style: AppTextStyles.bodyBold()),
                      SizedBox(width: Responsive.w(8)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(estimate.status, style: AppTextStyles.caption()),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    estimate.contractorName.isEmpty ? 'No party name' : estimate.contractorName,
                    style: AppTextStyles.body(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    '${DateFormat('dd-MM-yyyy').format(estimate.date)}  •  ${estimate.items.length} items',
                    style: AppTextStyles.caption(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(estimate.totalAmount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
                SizedBox(height: Responsive.h(4)),
                Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
