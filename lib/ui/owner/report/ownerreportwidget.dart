
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

// ---------------------------------------------------------------------
// Shared widgets for the Salesman / Contractor report screens, styled
// like the Estimate Details and Estimates list screens:
// white cards, radius 16, 1px AppColors.border, no shadow.
// ---------------------------------------------------------------------

const Color _redColor = Color(0xFFDC2626);
const Color _amberColor = Color(0xFFF59E0B);

BoxDecoration reportCardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

/// Status colour by label. Statuses come from the API, so unknown ones
/// fall back to amber (same as "pending" on the Estimates list).
Color reportStatusColor(String status) {
  switch (status.toLowerCase().trim()) {
    case 'approved':
    case 'delivered':
    case 'converted':
    case 'paid':
    case 'accepted':
      return AppColors.success;
    case 'rejected':
    case 'cancelled':
    case 'expired':
      return _redColor;
    case 'despatched':
      return AppColors.primary;
    case 'draft':
      return AppColors.textSecondary;
    default:
      return _amberColor;
  }
}

/// Blue-bar section heading.
class ReportSectionHeader extends StatelessWidget {
  const ReportSectionHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(title, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}

class ReportStatusPill extends StatelessWidget {
  const ReportStatusPill({super.key, required this.label, required this.color});
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
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Avatar + name + subtitle card at the top of a person report.
class ReportPersonCard extends StatelessWidget {
  const ReportPersonCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarColor,
  });

  final String name;
  final String subtitle;
  final Color avatarColor;

  // Trim, drop empty parts, and fall back to '?' for an empty name.
  String get _initials {
    final parts =
    name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Unknown' : name;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: reportCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _initials,
              style: AppTextStyles.bodyBold(color: avatarColor),
            ),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportStat {
  const ReportStat({required this.value, required this.label, this.color});
  final String value;
  final String label;
  final Color? color;
}

/// "Summary" card with the stats in a 2-per-row grid.
class ReportStatsCard extends StatelessWidget {
  const ReportStatsCard({super.key, required this.stats, this.title = 'Summary'});
  final List<ReportStat> stats;
  final String title;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += 2) {
      final second = i + 1 < stats.length ? stats[i + 1] : null;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _tile(stats[i])),
          Expanded(child: second != null ? _tile(second) : const SizedBox()),
        ],
      ));
      if (i + 2 < stats.length) rows.add(SizedBox(height: Responsive.h(16)));
    }

    return Container(
      width: double.infinity,
      decoration: reportCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calculate_outlined,
                      size: 16, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(10)),
                Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _tile(ReportStat s) {
    return Padding(
      padding: EdgeInsets.only(right: Responsive.w(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              s.value,
              style: AppTextStyles.amount(color: s.color ?? AppColors.textPrimary),
            ),
          ),
          SizedBox(height: Responsive.h(2)),
          Text(
            s.label,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Two-way "Quotations / Estimates" switcher.
class ReportTabSwitcher extends StatelessWidget {
  const ReportTabSwitcher({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(4)),
      decoration: reportCardDecoration(radius: 14),
      child: Row(
        children: [
          Expanded(child: _tab(leftLabel, isLeftSelected, () => onChanged(true))),
          Expanded(child: _tab(rightLabel, !isLeftSelected, () => onChanged(false))),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: Responsive.sp(12.5),
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// One quotation / estimate row (same layout as the Estimates list card).
class ReportEntryCard extends StatelessWidget {
  const ReportEntryCard({
    super.key,
    required this.code,
    required this.statusLabel,
    required this.subtitle,
    required this.amountText,
    required this.dateText,
    this.onTap,
  });

  final String code;
  final String statusLabel;
  final String subtitle;
  final String amountText;
  final String dateText;
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
          decoration: reportCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.description_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold(),
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Text(
                          subtitle.isEmpty ? '-' : subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  ReportStatusPill(
                    label: statusLabel,
                    color: reportStatusColor(statusLabel),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(12)),
              const Divider(height: 1, color: AppColors.border),
              SizedBox(height: Responsive.h(10)),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 13, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(6)),
                  Expanded(
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                          color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    amountText,
                    style: AppTextStyles.amount(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportErrorView extends StatelessWidget {
  const ReportErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}