import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

import '../models/owner_models/owner_despatchmodellist.dart';

class DispatchCard extends StatelessWidget {
  const DispatchCard({super.key, required this.dispatch});

  final DispatchListItem dispatch;

  Color _statusColor() {
    if (dispatch.isDelivered) return AppColors.info;
    if (dispatch.isInTransit) return AppColors.primary;
    return AppColors.warning;
  }

  IconData _statusIcon() {
    if (dispatch.isDelivered) return Icons.check_circle_rounded;
    if (dispatch.isInTransit) return Icons.local_shipping_rounded;
    return Icons.schedule_rounded;
  }

  String _statusLabel() {
    if (dispatch.isDelivered) return 'Delivered';
    if (dispatch.isInTransit) return 'In Transit';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final color = _statusColor();

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(12)),
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
              Expanded(child: Text(dispatch.dsNumber, style: AppTextStyles.bodyBold())),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(4)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(), size: 14, color: color),
                    SizedBox(width: Responsive.w(4)),
                    Text(
                      _statusLabel(),
                      style: TextStyle(color: color, fontSize: Responsive.sp(11), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(6)),
          Text(dispatch.partyName, style: AppTextStyles.body()),
          SizedBox(height: Responsive.h(4)),
          Text('Ref: ${dispatch.estimateNumber}', style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${dispatch.totalItems} item(s)', style: AppTextStyles.caption()),
              Text(currency.format(dispatch.totalAmount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
