import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../dummymodels/estimate_model.dart';
import '../widgets/biltypebadge.dart';
import '../../../../widgets/status_badge.dart';

const double _dummyIncentivePercent = 5.0;

double _incentiveAmountFor(EstimateItem item) =>
    item.amount * _dummyIncentivePercent / 100;

class EstimateFullDetailsScreen extends StatelessWidget {
  final EstimateModel estimate;
  const EstimateFullDetailsScreen({super.key, required this.estimate});

  double get _incentiveTotal =>
      estimate.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');
    final date = DateFormat('dd MMM yyyy').format(estimate.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title:  Text('Full Estimate Details',style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.w(18)),
          children: [
            // ---- Document header ----
            Container(
              padding: EdgeInsets.all(Responsive.w(16)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimate ${estimate.id}', style: AppTextStyles.h2()),
                      Row(
                        children: [
                          BillTypeBadge(billType: estimate.billType),
                          const SizedBox(width: 6),
                          StatusBadge(status: estimate.status),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text('Date: $date', style: AppTextStyles.caption()),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(20)),

            // ---- Party / Bill To section ----
            Text('Bill To', style: AppTextStyles.h3()),
            SizedBox(height: Responsive.h(10)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.w(16)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailLine(label: 'Contractor / Party', value: estimate.contractorName),
                  _DetailLine(label: 'Site Address', value: estimate.siteAddress),
                  _DetailLine(label: 'Phone', value: estimate.phone),
                  if (estimate.salesmanName.isNotEmpty)
                    _DetailLine(label: 'Salesman', value: estimate.salesmanName),
                  _DetailLine(label: 'Bill Type', value: estimate.billType.label),
                  _DetailLine(
                      label: 'Status', value: estimate.status.toString().split('.').last),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(24)),

            // ---- Items ----
            Text('Items (${estimate.items.length})', style: AppTextStyles.h3()),
            SizedBox(height: Responsive.h(10)),
            if (estimate.items.isEmpty)
              Text('No item breakdown available.', style: AppTextStyles.subtitle())
            else
              ...estimate.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: Responsive.h(10)),
                  padding: EdgeInsets.all(Responsive.w(14)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${item.name}', style: AppTextStyles.bodyBold()),
                      SizedBox(height: Responsive.h(4)),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (item.company.isNotEmpty)
                            Text('Company: ${item.company}', style: AppTextStyles.caption()),
                          if (item.size.isNotEmpty)
                            Text('Size: ${item.size}', style: AppTextStyles.caption()),
                          Text('Qty: ${number.format(item.quantity)} ${item.unit}',
                              style: AppTextStyles.caption()),
                          Text('MRP: ${number.format(item.mrp)}', style: AppTextStyles.caption()),
                          Text('Rate: ${number.format(item.rate)}', style: AppTextStyles.caption()),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Amount', style: AppTextStyles.body()),
                          Text(currency.format(item.amount), style: AppTextStyles.bodyBold()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Incentive', style: AppTextStyles.body()),
                          Text(
                            currency.format(_incentiveAmountFor(item)),
                            style: AppTextStyles.bodyBold(color: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            SizedBox(height: Responsive.h(16)),

            // ---- Totals summary ----
            Container(
              padding: EdgeInsets.all(Responsive.w(16)),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _TotalRow(label: 'Total Items', value: '${estimate.items.length}'),
                  _TotalRow(label: 'MRP Total', value: currency.format(estimate.mrpTotal)),
                  _TotalRow(
                      label: 'Handling Charge', value: currency.format(estimate.handlingCharge)),
                  _TotalRow(label: 'Total Incentive', value: currency.format(_incentiveTotal)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: AppTextStyles.h3()),
                      Text(currency.format(estimate.totalAmount),
                          style: AppTextStyles.h2(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(28)),

            SizedBox(height: Responsive.h(20)),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body()),
          Text(value, style: AppTextStyles.body()),
        ],
      ),
    );
  }
}

class _SignatureBlock extends StatelessWidget {
  final String label;
  const _SignatureBlock({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 130, height: 1, color: AppColors.border),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }
}