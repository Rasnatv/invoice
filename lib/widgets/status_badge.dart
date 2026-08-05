import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Small pill used everywhere a status is shown: "Pending", "Approved",
/// "Rejected", "Delivered", "In Transit".
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.statusColor(status);
    final bg = AppColors.statusBg(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: AppTextStyles.caption(color: fg).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
