
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/features/dashboard/salesman/incentive/productsummary.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class ProductIncentive {
  final String name;
  final IconData icon;
  final Color iconColor;
  final double incentivePercent;
  final double totalSales;
  final int units;
  final double incentiveEarned;
  final double unitPrice;

  const ProductIncentive({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.incentivePercent,
    required this.totalSales,
    required this.units,
    required this.incentiveEarned,
    required this.unitPrice,
  });
}

// Sanitary / Tile shop product catalogue (dummy data)
const List<ProductIncentive> _dummyProductIncentives = [
  ProductIncentive(
    name: 'Ceramic Floor Tile 2x2 ft',
    icon: Icons.grid_4x4_rounded,
    iconColor: Color(0xFFB26A00),
    incentivePercent: 5,
    totalSales: 187500,
    units: 250,
    incentiveEarned: 9375,
    unitPrice: 750,
  ),
  ProductIncentive(
    name: 'PVC Pipe 4 inch',
    icon: Icons.plumbing_rounded,
    iconColor: Color(0xFF546E7A),
    incentivePercent: 4,
    totalSales: 102000,
    units: 170,
    incentiveEarned: 4080,
    unitPrice: 600,
  ),
  ProductIncentive(
    name: 'Wash Basin Premium',
    icon: Icons.countertops_rounded,
    iconColor: Color(0xFF00897B),
    incentivePercent: 6,
    totalSales: 175000,
    units: 100,
    incentiveEarned: 10500,
    unitPrice: 1750,
  ),
  ProductIncentive(
    name: 'CP Taps & Fittings',
    icon: Icons.water_drop_rounded,
    iconColor: Color(0xFF1E88E5),
    incentivePercent: 3,
    totalSales: 72000,
    units: 120,
    incentiveEarned: 2160,
    unitPrice: 600,
  ),
  ProductIncentive(
    name: 'Designer Wall Tile',
    icon: Icons.dashboard_rounded,
    iconColor: Color(0xFF7B1FA2),
    incentivePercent: 4,
    totalSales: 97500,
    units: 195,
    incentiveEarned: 3900,
    unitPrice: 500,
  ),
  ProductIncentive(
    name: 'Sanitaryware Commode Set',
    icon: Icons.bathtub_rounded,
    iconColor: Color(0xFF3F51B5),
    incentivePercent: 7,
    totalSales: 168000,
    units: 60,
    incentiveEarned: 11760,
    unitPrice: 2800,
  ),
];

const double _dummyPendingIncentive = 8250;
const double _dummySalesTarget = 1000000;

class SalesmanIncentiveScreen extends StatefulWidget {
  const SalesmanIncentiveScreen({
    super.key,
    required this.salesmanName,
    this.role = 'Sales Executive',
  });

  final String salesmanName;
  final String role;

  @override
  State<SalesmanIncentiveScreen> createState() => _SalesmanIncentiveScreenState();
}

class _SalesmanIncentiveScreenState extends State<SalesmanIncentiveScreen> {
  DateTime _selectedMonth = DateTime.now();
  double get _totalSales => _dummyProductIncentives.fold(0.0, (s, p) => s + p.totalSales);
  double get _totalIncentiveEarned => _dummyProductIncentives.fold(0.0, (s, p) => s + p.incentiveEarned);
  double get _totalIncentiveTarget => _totalIncentiveEarned + _dummyPendingIncentive;

  /// Opens a Year + Month picker.
  /// - Defaults to the currently selected month/year (today, initially).
  /// - Year is changed with arrows (no giant scrolling list of months).
  /// - Months for the current year that are in the future are disabled.
  Future<void> _pickMonth() async {
    final now = DateTime.now();
    int pickedYear = _selectedMonth.year;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isCurrentYear = pickedYear == now.year;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Little drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // ---- Year selector ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => setModalState(() => pickedYear--),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            '$pickedYear',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(18)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: isCurrentYear ? null : () => setModalState(() => pickedYear++),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(14)),

                    // ---- Month grid for the selected year ----
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                      children: List.generate(12, (i) {
                        final m = i + 1;
                        final isFuture = isCurrentYear && m > now.month;
                        final isSelected = pickedYear == _selectedMonth.year && m == _selectedMonth.month;
                        final label = DateFormat('MMM').format(DateTime(pickedYear, m));

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isFuture ? null : () => Navigator.of(ctx).pop(DateTime(pickedYear, m, 1)),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : isFuture
                                  ? AppColors.border.withOpacity(0.25)
                                  : AppColors.border.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? null
                                  : Border.all(color: AppColors.border.withOpacity(0.6)),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: Responsive.sp(13.5),
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : isFuture
                                    ? AppColors.textSecondary.withOpacity(0.4)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null) setState(() => _selectedMonth = picked);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final salesFraction = (_totalSales / _dummySalesTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _IncentiveHeader(
              salesmanName: widget.salesmanName,
              role: widget.role,
              selectedMonth: _selectedMonth,
              onTapMonth: _pickMonth,
              onBack: () => Navigator.of(context).maybePop(),
              totalSales: currency.format(_totalSales),
              totalIncentive: currency.format(_totalIncentiveEarned),
              pendingIncentive: currency.format(_dummyPendingIncentive),
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
                    Text('Product Wise Incentive', style: AppTextStyles.h3()),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.sp(13),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < _dummyProductIncentives.length; i++) ...[
                        _ProductIncentiveTile(
                          item: _dummyProductIncentives[i],
                          currency: currency,
                          selectedMonth: _selectedMonth,
                        ),
                        if (i != _dummyProductIncentives.length - 1)
                          Divider(
                            height: 1,
                            indent: Responsive.w(16),
                            endIndent: Responsive.w(16),
                            color: AppColors.border,
                          ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(20)),

                // ---- Monthly Sales Target ----
                _TargetProgressCard(
                  title: 'Monthly Sales Target',
                  icon: Icons.track_changes_rounded,
                  color: AppColors.success,
                  headlineValue: currency.format(_dummySalesTarget),
                  achievedAmount: currency.format(_totalSales),
                  targetTotal: currency.format(_dummySalesTarget),
                  fraction: salesFraction,
                  achievedLabel: 'Achieved',
                ),
                SizedBox(height: Responsive.h(16)),

                SizedBox(height: Responsive.h(50)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}


class _IncentiveHeader extends StatelessWidget {
  const _IncentiveHeader({
    required this.salesmanName,
    required this.role,
    required this.selectedMonth,
    required this.onTapMonth,
    required this.onBack,
    required this.totalSales,
    required this.totalIncentive,
    required this.pendingIncentive,
  });

  final String salesmanName;
  final String role;
  final DateTime selectedMonth;
  final VoidCallback onTapMonth;
  final VoidCallback onBack;
  final String totalSales;
  final String totalIncentive;
  final String pendingIncentive;

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
                        'Salesman Incentives',
                        style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(17)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(14)),
                Padding(
                  padding: EdgeInsets.only(left: Responsive.w(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${salesmanName.isEmpty ? '-' : salesmanName}',
                              style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(19)),
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              role,
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: Responsive.sp(13)),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: onTapMonth,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                              SizedBox(width: Responsive.w(6)),
                              Text(
                                DateFormat('MMMM yyyy').format(selectedMonth),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(12.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                            ],
                          ),
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
          child: _SummaryCard(
            totalSales: totalSales,
            totalIncentive: totalIncentive,
            pendingIncentive: pendingIncentive,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalSales,
    required this.totalIncentive,
    required this.pendingIncentive,
  });

  final String totalSales;
  final String totalIncentive;
  final String pendingIncentive;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Monthly Incentive Summary', style: AppTextStyles.bodyBold()),
              ),
              Container(
                padding: EdgeInsets.all(Responsive.w(8)),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded, color: AppColors.success, size: 20),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'Total Sales',
                  value: totalSales,
                  sub: 'This Month',
                  color: AppColors.primary,
                ),
              ),
              _vDivider(),
              Expanded(
                child: _SummaryStat(
                  label: 'Total Incentive Earned',
                  value: totalIncentive,
                  sub: 'This Month',
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
    height: 50,
    color: AppColors.border,
    margin: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
  );
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: Responsive.h(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.h3(color: color)),
        ),
        SizedBox(height: Responsive.h(1)),
        Text(sub, style: AppTextStyles.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// =====================================================================
// PRODUCT WISE INCENTIVE ROW (tap to open detailed bill-wise breakdown)
// =====================================================================

class _ProductIncentiveTile extends StatelessWidget {
  const _ProductIncentiveTile({
    required this.item,
    required this.currency,
    required this.selectedMonth,
  });

  final ProductIncentive item;
  final NumberFormat currency;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: item,
              month: selectedMonth,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'Incentive: ${item.incentivePercent.toStringAsFixed(0)}%',
                    style: AppTextStyles.caption(color: AppColors.success),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(item.totalSales), style: AppTextStyles.body(), textAlign: TextAlign.right),
                  SizedBox(height: Responsive.h(2)),
                  Text('${item.units} Units', style: AppTextStyles.caption(), textAlign: TextAlign.right),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(4)),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      currency.format(item.incentiveEarned),
                      style: AppTextStyles.bodyBold(color: AppColors.success),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetProgressCard extends StatelessWidget {
  const _TargetProgressCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.headlineValue,
    required this.achievedAmount,
    required this.targetTotal,
    required this.fraction,
    required this.achievedLabel,
    this.footerNote,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String headlineValue;
  final String achievedAmount;
  final String targetTotal;
  final double fraction;
  final String achievedLabel;
  final String? footerNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(10)),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.bodyBold()),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(headlineValue, style: AppTextStyles.h3(color: color)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Text(
                      'Rs:8000'
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                SizedBox(height: Responsive.h(6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '$achievedAmount / $targetTotal',
                        style: AppTextStyles.caption(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(achievedLabel, style: AppTextStyles.caption(color: color)),
                  ],
                ),
                if (footerNote != null) ...[
                  SizedBox(height: Responsive.h(4)),
                  Text(footerNote!, style: AppTextStyles.caption(color: AppColors.warning)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
