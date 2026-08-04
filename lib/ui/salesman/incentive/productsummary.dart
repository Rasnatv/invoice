import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/salesman/incentive/salesmanincentivescreen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';


/// A single dispatched bill / estimation line for a product.
class _BillEntry {
  final String estimationNo;
  final DateTime dispatchedDate;
  final int units;
  final double unitPrice;
  final double incentivePercent;

  const _BillEntry({
    required this.estimationNo,
    required this.dispatchedDate,
    required this.units,
    required this.unitPrice,
    required this.incentivePercent,
  });

  double get totalPrice => units * unitPrice;
  double get incentiveEarned => totalPrice * incentivePercent / 100;
}

/// Splits a product's monthly totals into a set of dummy dispatched bills.
List<_BillEntry> _buildDummyBills(ProductIncentive product, DateTime month) {
  final int billCount = (product.units / 35).ceil().clamp(2, 6);
  final List<int> unitSplits = [];
  int remainingUnits = product.units;
  for (int i = 0; i < billCount; i++) {
    if (i == billCount - 1) {
      unitSplits.add(remainingUnits);
    } else {
      final share = (product.units / billCount).round();
      final take = share.clamp(1, remainingUnits - (billCount - i - 1));
      unitSplits.add(take);
      remainingUnits -= take;
    }
  }

  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
  final now = DateTime.now();
  final isCurrentMonth = now.year == month.year && now.month == month.month;
  final maxDay = isCurrentMonth ? now.day : daysInMonth;

  final bills = <_BillEntry>[];
  for (int i = 0; i < unitSplits.length; i++) {
    final dayStep = (maxDay / unitSplits.length).floor().clamp(1, maxDay);
    final day = ((i + 1) * dayStep).clamp(1, maxDay);
    bills.add(
      _BillEntry(
        estimationNo: 'EST-${month.year}${month.month.toString().padLeft(2, '0')}-${(1000 + i + 1)}',
        dispatchedDate: DateTime(month.year, month.month, day),
        units: unitSplits[i],
        unitPrice: product.unitPrice,
        incentivePercent: product.incentivePercent,
      ),
    );
  }
  return bills.reversed.toList(); // most recent dispatch first
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.month,
  });

  final ProductIncentive product;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final bills = _buildDummyBills(product, month);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProductDetailHeader(
              product: product,
              currency: currency,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: Responsive.h(66)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dispatched Bills', style: AppTextStyles.h3()),
                    Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                for (final bill in bills) ...[
                  _BillCard(bill: bill, currency: currency),
                  SizedBox(height: Responsive.h(12)),
                ],
                SizedBox(height: Responsive.h(30)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// HEADER + FLOATING SUMMARY CARD
// =====================================================================

class _ProductDetailHeader extends StatelessWidget {
  const _ProductDetailHeader({
    required this.product,
    required this.currency,
    required this.onBack,
  });

  final ProductIncentive product;
  final NumberFormat currency;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(8),
            Responsive.h(4),
            Responsive.w(20),
            Responsive.h(70),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Product Incentive Detail',
                        style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(17)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                Padding(
                  padding: EdgeInsets.only(left: Responsive.w(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(product.icon, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: Responsive.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(18)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              'Incentive Rate: ${product.incentivePercent.toStringAsFixed(0)}%  •  Unit Price: ${currency.format(product.unitPrice)}',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: Responsive.sp(12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(50),
          child: _ProductSummaryCard(product: product, currency: currency),
        ),
      ],
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.product, required this.currency});

  final ProductIncentive product;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Total Sales',
              value: currency.format(product.totalSales),
              color: AppColors.primary,
            ),
          ),
          _vDivider(),
          Expanded(
            child: _MiniStat(
              label: 'Units Sold',
              value: '${product.units}',
              color: AppColors.textPrimary,
            ),
          ),
          _vDivider(),
          Expanded(
            child: _MiniStat(
              label: 'Incentive Earned',
              value: currency.format(product.incentiveEarned),
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 44,
    color: AppColors.border,
    margin: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: Responsive.h(4)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.bodyBold(color: color)),
        ),
      ],
    );
  }
}

// =====================================================================
// BILL / ESTIMATION CARD
// =====================================================================

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill, required this.currency});

  final _BillEntry bill;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: Responsive.w(6)),
                  Text(
                    bill.estimationNo,
                    style: AppTextStyles.bodyBold(),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${currency.format(bill.incentiveEarned)}',
                  style: AppTextStyles.caption(color: AppColors.success),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          Row(
            children: [
              Icon(Icons.local_shipping_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text(
                'Dispatched: ${dateFmt.format(bill.dispatchedDate)}',
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          Row(
            children: [
              Expanded(
                child: _BillField(label: 'Unit Price', value: currency.format(bill.unitPrice)),
              ),
              Expanded(
                child: _BillField(label: 'Units', value: '${bill.units}'),
              ),
              Expanded(
                child: _BillField(label: 'Bill Total', value: currency.format(bill.totalPrice)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillField extends StatelessWidget {
  const _BillField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(2)),
        Text(value, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}