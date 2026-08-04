import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../dummymodels/estimate_model.dart';


/// "Monthly Sales" bar chart for the Dashboard Home screen.
/// Built with a plain CustomPainter so no extra chart package is required —
/// swap in fl_chart / syncfusion later if you'd like richer interactions.
class MonthlySalesChart extends StatelessWidget {
  final List<MonthlySale> data;
  const MonthlySalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final currency = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Sales', style: AppTextStyles.h3()),
              Text(currency.format(data.last.amount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ],
          ),
          SizedBox(height: Responsive.h(16)),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((point) {
                final isLast = point == data.last;
                final heightFraction = maxAmount == 0 ? 0.0 : point.amount / maxAmount;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          currency.format(point.amount),
                          style: TextStyle(
                            fontSize: 9,
                            color: isLast ? AppColors.primary : AppColors.textHint,
                            fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 90 * heightFraction.clamp(0.05, 1.0),
                          decoration: BoxDecoration(
                            color: isLast ? AppColors.info : AppColors.infoBg,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(point.monthLabel, style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}