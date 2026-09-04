
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerincentiveprovider.dart';
import '../../models/salesmanmodels/salesmanowner_incentivemodel.dart';


class OwnerProductBillsPage extends StatefulWidget {
  const OwnerProductBillsPage({
    super.key,
    required this.product,
    required this.month,
    this.salesmanId,
  });

  final IncentiveProductModel product;
  final DateTime month;
  final String? salesmanId;

  @override
  State<OwnerProductBillsPage> createState() => _OwnerProductBillsPageState();
}

class _OwnerProductBillsPageState extends State<OwnerProductBillsPage> {
  final OwnerIncentiveProvider _provider = OwnerIncentiveProvider();
  static const int _perPage = 10;

  final List<ProductBillModel> _bills = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _bills.clear();
        _loading = true;
        _error = null;
      });
    }

    final request = ProductBillsRequest(
      salesmanId: widget.salesmanId != null ? int.tryParse(widget.salesmanId!) : null,
      productId: int.tryParse(widget.product.productId) ?? 0,
      year: widget.month.year,
      month: widget.month.month,
      page: _page,
      perPage: _perPage,
    );

    final result = await _provider.getProductBills(request);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      if (result.success) {
        if (reset) _bills.clear();
        _bills.addAll(result.bills);
        _total = result.total;
        _error = null;
      } else {
        _error = result.errorMessage ?? 'Failed to load bills.';
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || _bills.length >= _total) return;
    setState(() {
      _loadingMore = true;
      _page++;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM, yyyy');
    final monthFmt = DateFormat('MMMM yyyy');
    final product = widget.product;

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(product.productName, style: AppTextStyles.h6())),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(reset: true),
          child: _buildBody(context, currency, dateFmt, monthFmt),
        ),
      ),
    ));
  }

  Widget _buildBody(
      BuildContext context,
      NumberFormat currency,
      DateFormat dateFmt,
      DateFormat monthFmt,
      ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _bills.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: Responsive.h(100)),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(24)),
        children: [
          _SummaryCard(
            product: widget.product,
            month: widget.month,
            currency: currency,
            monthFmt: monthFmt,
          ),
          SizedBox(height: Responsive.h(20)),
          Text('Bill-wise Sale Details', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
          SizedBox(height: Responsive.h(10)),
          if (_bills.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
              child: Center(
                child: Text(
                  'No bills for this period.',
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (final bill in _bills)
              _BillTile(bill: bill, product: widget.product, currency: currency, dateFmt: dateFmt),
          if (_loadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.product,
    required this.month,
    required this.currency,
    required this.monthFmt,
  });

  final IncentiveProductModel product;
  final DateTime month;
  final NumberFormat currency;
  final DateFormat monthFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 18),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.productName, style: AppTextStyles.bodyBold()),
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
                    Text('Units Sold', style: AppTextStyles.caption()),
                    Text('${product.totalUnitsInt}', style: AppTextStyles.bodyBold().copyWith(fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Sale', style: AppTextStyles.caption()),
                    Text(
                      currency.format(product.totalSalesValue),
                      style: AppTextStyles.bodyBold().copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Incentive (${product.incentiveRate}%)', style: AppTextStyles.caption()),
                    Text(
                      currency.format(product.incentiveEarnedValue),
                      style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({
    required this.bill,
    required this.product,
    required this.currency,
    required this.dateFmt,
  });

  final ProductBillModel bill;
  final IncentiveProductModel product;
  final NumberFormat currency;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final date = bill.dateValue;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(6)),
                  Text(bill.estimateNumber, style: AppTextStyles.bodyBold().copyWith(fontSize: 13)),
                ],
              ),
              Text(currency.format(bill.billTotalValue), style: AppTextStyles.bodyBold().copyWith(fontSize: 14)),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text('Bill Date', style: AppTextStyles.caption()),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  date != null ? dateFmt.format(date) : bill.date,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(6)),
          Row(
            children: [
              const Icon(Icons.currency_rupee_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Text('Unit Price', style: AppTextStyles.caption()),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  currency.format(bill.unitPriceValue),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(8)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${bill.unitsValue.toStringAsFixed(bill.unitsValue.truncateToDouble() == bill.unitsValue ? 0 : 2)} units',
                  style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: 12),
                ),
              ),
              Row(
                children: [
                  Text('Incentive: ', style: AppTextStyles.caption()),
                  Text(
                    currency.format(bill.incentiveEarnedValue),
                    style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}