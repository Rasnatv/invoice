
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
// Adjust this path to wherever dashboard_model.dart actually lives in your project.
import '../../models/salesmanmodels/salesman_dashboardmodel.dart';

class DashboardMonthlySalesChart extends StatelessWidget {
  const DashboardMonthlySalesChart({super.key, required this.data});

  final List<DashboardHomeMonthlySales> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyChart();
    }
    return _MonthlySalesBody(data: data);
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(24)),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 36,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          SizedBox(height: Responsive.h(10)),
          // 12 / w400
          Text('No sales data yet', style: AppTextStyles.subtitle()),
        ],
      ),
    );
  }
}

class _MonthlySalesBody extends StatelessWidget {
  const _MonthlySalesBody({required this.data});

  final List<DashboardHomeMonthlySales> data;

  @override
  Widget build(BuildContext context) {
    final currentMonth = data.last;
    final previousMonth = data.length > 1 ? data[data.length - 2] : null;

    double? percentChange;
    if (previousMonth != null && previousMonth.total > 0) {
      percentChange =
          ((currentMonth.total - previousMonth.total) / previousMonth.total) *
              100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 12 / w400
                  Text('This Month', style: AppTextStyles.subtitle()),
                  SizedBox(height: Responsive.h(4)),
                  // 20 / w600
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currentMonth.totalFormatted,
                      maxLines: 1,
                      style: AppTextStyles.h3(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            if (percentChange != null) ...[
              SizedBox(width: Responsive.w(8)),
              _TrendBadge(percentChange: percentChange),
            ],
          ],
        ),
        SizedBox(height: Responsive.h(20)),
        SizedBox(
          height: Responsive.h(110),
          child: _MonthlyBarChart(data: data),
        ),
      ],
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.percentChange});

  final double percentChange;

  @override
  Widget build(BuildContext context) {
    final isUp = percentChange >= 0;
    final color = isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(8),
            vertical: Responsive.h(4),
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUp
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: color,
              ),
              SizedBox(width: Responsive.w(2)),
              // 11 / w600
              Text(
                '${percentChange.abs().toStringAsFixed(1)}%',
                style: AppTextStyles.captioref(color: color),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(3)),
        // 11 / w400
        Text('vs last month', style: AppTextStyles.captionnew()),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.data});

  final List<DashboardHomeMonthlySales> data;

  @override
  Widget build(BuildContext context) {
    final maxAmount = data
        .map((e) => e.total.toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < data.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
              child: _MonthlyBar(
                heightFraction:
                maxAmount == 0 ? 0 : data[i].total.toDouble() / maxAmount,
                isLast: i == data.length - 1,
                label: data[i].month,
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthlyBar extends StatelessWidget {
  const _MonthlyBar({
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
        // 11 / w600 for current month, 11 / w400 for the rest
        Text(
          label,
          style: isLast
              ? AppTextStyles.captioref(color: AppColors.black)
              : AppTextStyles.captionnew(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
