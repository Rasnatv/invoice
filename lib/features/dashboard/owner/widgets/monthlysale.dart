import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/owner_widgets.dart'; // OwnerSectionTitle, OwnerEmptyState

// ---------------- MONTHLY SALES SECTION ----------------
//
// Model: add this (or similar) to your models, and a
// `List<MonthlySales> monthlySales` field to OwnerState, populated with
// the last 6 months (oldest -> newest).
//
class MonthlySales {
  final String monthLabel; // 'Jan', 'Feb', ...
  final double amount;
  const MonthlySales({required this.monthLabel, required this.amount});
}

// Usage inside owner_dashboard_screen.dart, right after Quick Actions:
//
//   _MonthlySalesSection(monthlySales: state.monthlySales, currency: currency),
//   SizedBox(height: Responsive.h(28)),

class MonthlySalesSection extends StatelessWidget {
  const MonthlySalesSection({
    required this.monthlySales,
    required this.currency,
  });

  final List<MonthlySales> monthlySales;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OwnerSectionTitle(title: 'Monthly Sales'),
        SizedBox(height: Responsive.h(12)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: monthlySales.isEmpty
              ? const OwnerEmptyState(
            message: 'No sales data yet',
            icon: Icons.bar_chart_rounded,
          )
              : MonthlySalesBody(monthlySales: monthlySales, currency: currency),
        ),
      ],
    );
  }
}

class MonthlySalesBody extends StatelessWidget {
  const MonthlySalesBody({required this.monthlySales, required this.currency});

  final List<MonthlySales> monthlySales;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final currentMonth = monthlySales.last;
    final previousMonth =
    monthlySales.length > 1 ? monthlySales[monthlySales.length - 2] : null;

    double? percentChange;
    if (previousMonth != null && previousMonth.amount > 0) {
      percentChange =
          ((currentMonth.amount - previousMonth.amount) / previousMonth.amount) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big number + trend badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: AppTextStyles.caption(),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currency.format(currentMonth.amount),
                      style: AppTextStyles.h3(),
                    ),
                  ),
                ],
              ),
            ),
            if (percentChange != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(8),
                  vertical: Responsive.h(4),
                ),
                decoration: BoxDecoration(
                  color: (percentChange >= 0 ? AppColors.success : AppColors.error)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      percentChange >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 13,
                      color: percentChange >= 0 ? AppColors.success : AppColors.error,
                    ),
                    SizedBox(width: Responsive.w(2)),
                    Text(
                      '${percentChange.abs().toStringAsFixed(1)}%',
                      style: AppTextStyles.caption(
                        color: percentChange >= 0 ? AppColors.success : AppColors.error,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: Responsive.h(20)),
        // Bar chart
        SizedBox(
          height: Responsive.h(110),
          child: MonthlyBarChart(data: monthlySales),
        ),
      ],
    );
  }
}

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({required this.data});

  final List<MonthlySales> data;

  @override
  Widget build(BuildContext context) {
    final maxAmount = data.map((e) => e.amount).fold<double>(0, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < data.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
              child: MonthlyBar(
                heightFraction: maxAmount == 0 ? 0 : data[i].amount / maxAmount,
                isLast: i == data.length - 1,
                label: data[i].monthLabel,
              ),
            ),
          ),
      ],
    );
  }
}

class MonthlyBar extends StatelessWidget {
  const MonthlyBar({
    required this.heightFraction,
    required this.isLast,
    required this.label,
  });

  final double heightFraction; // 0.0 - 1.0
  final bool isLast;
  final String label;

  static const double _maxBarHeight = 72;

  @override
  Widget build(BuildContext context) {
    final barColor = isLast ? AppColors.info : AppColors.infoBg;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _maxBarHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: heightFraction.clamp(0.03, 1.0)),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Container(
                  height: _maxBarHeight * value,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: Responsive.h(6)),
        Text(
          label,
          style: AppTextStyles.caption(
            color: isLast ? AppColors.black : AppColors.textSecondary,
          ).copyWith(fontWeight: isLast ? FontWeight.w700 : FontWeight.w400),
        ),
      ],
    );
  }
}
