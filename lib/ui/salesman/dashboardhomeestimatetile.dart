import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';

import '../../models/salesmanmodels/salesman_dashboardmodel.dart';

/// Recent-estimate card for the dashboard — same card pieces as the
/// Dispatch / Quotations / Approved Bills lists (icon tile, status pill,
/// divider, info row).
class DashboardRecentEstimateTile extends StatelessWidget {
  const DashboardRecentEstimateTile({
    super.key,
    required this.estimate,
    this.onTap,
  });

  final DashboardHomeRecentEstimate estimate;
  final VoidCallback? onTap;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
      case 'sent':
        return const Color(0xFFF59E0B); // amber
      case 'rejected':
        return const Color(0xFFDC2626); // red
      case 'draft':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(estimate.statusLabel);
    final number = estimate.estimateNumber;
    final customer = estimate.customerName;
    final status = estimate.statusLabel;

    return Padding(
      // Spacing between cards. Remove if the parent list already adds a gap.
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: _ListCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- top: icon, estimate number + party, status ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IconTile(icon: Icons.description_outlined),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        number.isEmpty ? '-' : number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyBold(),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        customer.isEmpty ? 'No party name' : customer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                _StatusPill(
                  label: status.isEmpty ? '-' : status,
                  color: statusColor,
                ),
              ],
            ),

            SizedBox(height: Responsive.h(12)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(10)),

            // ---- bottom: date + amount ----
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    text: estimate.dateFormatted,
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                Text(
                  estimate.grandTotalFormatted,
                  style: AppTextStyles.amount(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (same as the dispatch list card)
// =====================================================================

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionnew(color: color)
                .copyWith(fontSize: Responsive.sp(11)),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.link(color: color)
            .copyWith(fontSize: Responsive.sp(10.5)),
      ),
    );
  }
}