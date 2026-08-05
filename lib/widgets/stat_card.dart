import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// The small red stat tiles seen on the Dashboard Home screen —
/// "Total Estimates", "Approved", "Pending", "Dispatch Bills".
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.background = AppColors.primary,
    this.foreground = AppColors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(

        padding: EdgeInsets.all(Responsive.w(5)),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: background.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: foreground.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: foreground, size: Responsive.sp(18)),
            ),
            SizedBox(height: Responsive.h(10)),
            Text(value, style: AppTextStyles.h2(color: foreground)),
            SizedBox(height: Responsive.h(2)),
            Text(label, style: AppTextStyles.caption(color: foreground.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }
}