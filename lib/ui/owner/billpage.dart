import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
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
                      DateFormat('MMMM yyyy').format(widget.month),
                      style: AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                BlocBuilder<ProductBillsBloc, ProductBillsState>(
                  builder: (context, state) {
                    if (state.status == ProductBillsStatus.loading && state.bills.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: Responsive.h(40)),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.status == ProductBillsStatus.error && state.bills.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: Responsive.h(40)),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                state.errorMessage ?? 'Failed to load bills.',
                                style: AppTextStyles.caption(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: Responsive.h(10)),
                              TextButton(
                                onPressed: () => context.read<ProductBillsBloc>().add(const LoadProductBills()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state.bills.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: Responsive.h(40)),
                        child: Center(
                          child: Text(
                            'No dispatched bills for this period.',
                            style: AppTextStyles.caption(color: AppColors.textSecondary),
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
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                            child: const Center(
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
    );
  }
}

class _ProductDetailHeader extends StatelessWidget {
  const _ProductDetailHeader({required this.product, required this.currency, required this.onBack});

  final IncentiveProductModel product;
  final NumberFormat currency;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(Responsive.w(8), Responsive.h(4), Responsive.w(20), Responsive.h(70)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
            ),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: Colors.white)),
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
                        child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: Responsive.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(18)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              'Incentive Rate: ${product.incentiveRate}%  •  Unit Price: ${currency.format(product.unitPriceValue)}',
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

  final IncentiveProductModel product;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(label: 'Total Sales', value: currency.format(product.totalSalesValue), color: AppColors.primary),
          ),
          Container(width: 1, height: 44, color: AppColors.border, margin: EdgeInsets.symmetric(horizontal: Responsive.w(6))),
          Expanded(
            child: _MiniStat(label: 'Units Sold', value: '${product.totalUnitsInt}', color: AppColors.textPrimary),
          ),
          Container(width: 1, height: 44, color: AppColors.border, margin: EdgeInsets.symmetric(horizontal: Responsive.w(6))),
          Expanded(
            child: _MiniStat(
              label: 'Incentive Earned',
              value: currency.format(product.incentiveEarnedValue),
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
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

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill, required this.currency});

  final ProductBillModel bill;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final date = bill.dateValue;

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
                  Text(bill.estimateNumber, style: AppTextStyles.bodyBold()),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('+${currency.format(bill.incentiveEarnedValue)}', style: AppTextStyles.caption(color: AppColors.success)),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          Row(
            children: [
              Icon(Icons.local_shipping_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text(
                'Dispatched: ${date != null ? dateFmt.format(date) : bill.date}',
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          Row(
            children: [
              Expanded(child: _BillField(label: 'Unit Price', value: currency.format(bill.unitPriceValue))),
              Expanded(child: _BillField(label: 'Units', value: bill.units)),
              Expanded(child: _BillField(label: 'Bill Total', value: currency.format(bill.billTotalValue))),
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