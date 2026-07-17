import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/incentivemodel.dart';
import '../../../../core/utils/responsive.dart';

/// Date-wise sale details of a single product for one salesman, for the
/// selected month — opened by tapping a product row on the Salesman
/// Incentive screen.
///
/// For every sale this shows: sale date, dispatched date, estimation
/// number, contractor name, quantity (Sq.Ft / Running Ft / Units depending
/// on the product), sale value and incentive earned.
class ProductIncentiveDetailScreen extends StatelessWidget {
  const ProductIncentiveDetailScreen({
    super.key,
    required this.product,
    required this.month,
    required this.salesmanName,
    required this.currency,
  });

  final IncentiveProduct product;
  final DateTime month;
  final String salesmanName;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final sales = IncentiveMockData.salesFor(
      product: product,
      month: month,
      salesmanName: salesmanName,
    );
    final dateFmt = DateFormat('dd MMM, yyyy');
    final monthFmt = DateFormat('MMMM yyyy');
    final totalUnits = sales.fold<int>(0, (s, e) => s + e.units);
    final totalSale = sales.fold<double>(0, (s, e) => s + e.saleValue);
    final totalIncentive = sales.fold<double>(0, (s, e) => s + e.incentiveEarned);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(product.name, style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(24)),
          children: [
            // ---------- Summary card ----------
            Container(
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
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: product.iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(product.icon, color: product.iconColor, size: 18),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(salesmanName, style: AppTextStyles.bodyBold()),
                            Text(monthFmt.format(month), style: AppTextStyles.caption()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  const Divider(height: 1, color: AppColors.border),
                  SizedBox(height: Responsive.h(14)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${product.unitLabel} Sold', style: AppTextStyles.caption()),
                            Text('$totalUnits', style: AppTextStyles.bodyBold().copyWith(fontSize: 15)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Sale', style: AppTextStyles.caption()),
                            Text(currency.format(totalSale), style: AppTextStyles.bodyBold().copyWith(fontSize: 15)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Incentive (${product.incentivePercent.toStringAsFixed(0)}%)', style: AppTextStyles.caption()),
                            Text(
                              currency.format(totalIncentive),
                              style: AppTextStyles.bodyBold(color: const Color(0xFF2E7D32)).copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(20)),
            Text('Date-wise Sale Details', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
            SizedBox(height: Responsive.h(10)),

            // ---------- Sale entry cards ----------
            for (final sale in sales)
              Container(
                margin: EdgeInsets.only(bottom: Responsive.h(10)),
                padding: EdgeInsets.all(Responsive.w(14)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estimation number + sale value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: Responsive.w(6)),
                            Text(sale.estimationNumber, style: AppTextStyles.bodyBold().copyWith(fontSize: 13)),
                          ],
                        ),
                        Text(currency.format(sale.saleValue), style: AppTextStyles.bodyBold().copyWith(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: Responsive.h(8)),
                    const Divider(height: 1, color: AppColors.border),
                    SizedBox(height: Responsive.h(8)),

                    // Contractor name
                    _DetailRow(
                      icon: Icons.engineering_rounded,
                      label: 'Contractor',
                      value: sale.contractorName,
                    ),
                    SizedBox(height: Responsive.h(6)),

                    // Sale date
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Sale Date',
                      value: dateFmt.format(sale.saleDate),
                    ),
                    SizedBox(height: Responsive.h(6)),

                    // Dispatched date
                    _DetailRow(
                      icon: Icons.local_shipping_rounded,
                      label: 'Dispatched Date',
                      value: dateFmt.format(sale.dispatchedDate),
                    ),

                    SizedBox(height: Responsive.h(8)),
                    const Divider(height: 1, color: AppColors.border),
                    SizedBox(height: Responsive.h(8)),

                    // Quantity + incentive earned
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
                          decoration: BoxDecoration(
                            color: product.iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${sale.units} ${product.unitLabel}',
                            style: AppTextStyles.bodyBold(color: product.iconColor).copyWith(fontSize: 12),
                          ),
                        ),
                        Row(
                          children: [
                            Text('Incentive: ', style: AppTextStyles.caption()),
                            Text(
                              currency.format(sale.incentiveEarned),
                              style: AppTextStyles.bodyBold(color: const Color(0xFF2E7D32)).copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        SizedBox(width: Responsive.w(6)),
        Text(label, style: AppTextStyles.caption()),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold().copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}