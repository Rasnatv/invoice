import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/productbill/productbillbloc.dart';
import '../../bloc/ownerbloc/productbill/productbillevent.dart';
import '../../bloc/ownerbloc/productbill/productbillstate.dart';
import '../../models/salesmanmodels/salesmanowner_incentivemodel.dart';

class OwnerProductBillsPage extends StatelessWidget {
  const OwnerProductBillsPage({
    super.key,
    required this.product,
    required this.month,
    this.salesmanId, // owner-only; null when a salesman views their own data
  });

  final IncentiveProductModel product;
  final DateTime month;
  final String? salesmanId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBillsBloc(
        salesmanId: salesmanId != null ? int.tryParse(salesmanId!) : null,
        productId: int.tryParse(product.productId) ?? 0,
        year: month.year,
        month: month.month,
      )..add(const LoadProductBills()),
      child: _OwnerProductBillsView(product: product, month: month),
    );
  }
}

class _OwnerProductBillsView extends StatefulWidget {
  const _OwnerProductBillsView({required this.product, required this.month});

  final IncentiveProductModel product;
  final DateTime month;

  @override
  State<_OwnerProductBillsView> createState() => _OwnerProductBillsViewState();
}

class _OwnerProductBillsViewState extends State<_OwnerProductBillsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBillsBloc>().add(const LoadMoreProductBills());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final product = widget.product;

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Incentive / Estimates) ----------
        appBar: AppBar(
          title: Text('Product Incentive Detail', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBillsBloc>().add(const LoadProductBills());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ---- product info + summary ----
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(20), Responsive.h(14), Responsive.w(20), 0),
                    child: Column(
                      children: [
                        _ProductInfoTile(product: product, currency: currency),
                        SizedBox(height: Responsive.h(10)),
                        _MonthTile(month: widget.month),
                        SizedBox(height: Responsive.h(14)),
                        _ProductSummaryCard(
                            product: product, currency: currency),
                      ],
                    ),
                  ),
                ),

                // ---- bills list ----
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: Responsive.h(18)),
                      Text(
                        'Dispatched Bills',
                        style: AppTextStyles.bodyBold()
                            .copyWith(fontSize: Responsive.sp(15)),
                      ),
                      SizedBox(height: Responsive.h(10)),
                      BlocBuilder<ProductBillsBloc, ProductBillsState>(
                        builder: (context, state) {
                          if (state.status == ProductBillsStatus.loading &&
                              state.bills.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: Responsive.h(40)),
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          if (state.status == ProductBillsStatus.error &&
                              state.bills.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: Responsive.h(30)),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline_rounded,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.5),
                                        size: 38),
                                    SizedBox(height: Responsive.h(10)),
                                    Text(
                                      state.errorMessage ??
                                          'Failed to load bills.',
                                      style: AppTextStyles.subtitle(),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: Responsive.h(10)),
                                    TextButton(
                                      onPressed: () => context
                                          .read<ProductBillsBloc>()
                                          .add(const LoadProductBills()),
                                      child: Text('Try again',
                                          style: AppTextStyles.bodyBold()),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (state.bills.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(Responsive.w(20)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Text(
                                  'No dispatched bills for this period.',
                                  style: AppTextStyles.caption(
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (final bill in state.bills) ...[
                                _BillCard(bill: bill, currency: currency),
                                SizedBox(height: Responsive.h(12)),
                              ],
                              if (state.status == ProductBillsStatus.loadingMore)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Responsive.h(12)),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: Responsive.h(30)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PRODUCT INFO + MONTH TILES
// =====================================================================

class _ProductInfoTile extends StatelessWidget {
  const _ProductInfoTile({required this.product, required this.currency});

  final IncentiveProductModel product;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2_outlined,
                color: AppColors.primary, size: 20),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Unit Price: ${currency.format(product.unitPriceValue)}',
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          //_Pill(label: 'Incentive ${product.incentiveRate}%', color: AppColors.success),
        ],
      ),
    );
  }
}

class _MonthTile extends StatelessWidget {
  const _MonthTile({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              color: AppColors.primary, size: 18),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: AppTextStyles.body(),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SUMMARY CARD
// =====================================================================

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.product, required this.currency});

  final IncentiveProductModel product;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    color: AppColors.success, size: 18),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Text('Product Summary', style: AppTextStyles.bodyBold()),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Total Sales',
                  value: currency.format(product.totalSalesValue),
                  color: AppColors.primary,
                ),
              ),
              _vDivider(),
              Expanded(
                child: _MiniStat(
                  label: 'Units Sold',
                  value: '${product.totalUnitsInt}',
                  color: AppColors.textPrimary,
                ),
              ),
              _vDivider(),
              Expanded(
                child: _MiniStat(
                  label: 'Incentive Earned',
                  value: currency.format(product.incentiveEarnedValue),
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 44,
    color: AppColors.border,
    margin: EdgeInsets.symmetric(horizontal: Responsive.w(8)),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: Responsive.h(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.amount(color: color)),
        ),
      ],
    );
  }
}

// =====================================================================
// BILL CARD
// =====================================================================

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill, required this.currency});

  final ProductBillModel bill;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final date = bill.dateValue;

    return Container(
      width: double.infinity,
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
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary, size: 18),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.estimateNumber,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Row(
                      children: [
                        Icon(Icons.local_shipping_rounded,
                            size: 13, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(4)),
                        Flexible(
                          child: Text(
                            'Dispatched: ${date != null ? dateFmt.format(date) : bill.date}',
                            style: AppTextStyles.caption(
                                color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _Pill(
                label: '+${currency.format(bill.incentiveEarnedValue)}',
                color: AppColors.success,
              ),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: _BillField(
                    label: 'Unit Price',
                    value: currency.format(bill.unitPriceValue)),
              ),
              Expanded(child: _BillField(label: 'Units', value: bill.units)),
              Expanded(
                child: _BillField(
                    label: 'Bill Total',
                    value: currency.format(bill.billTotalValue)),
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
        Text(label,
            style: AppTextStyles.caption(color: AppColors.textSecondary)),
        SizedBox(height: Responsive.h(2)),
        Text(value,
            style: AppTextStyles.bodyBold(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// =====================================================================
// PILL (same as incentive screen)
// =====================================================================

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(10.5),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}