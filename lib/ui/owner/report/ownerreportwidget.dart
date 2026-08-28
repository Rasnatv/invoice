import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../widgets/owner_widgets.dart'; // StatusBadge

/// Shared white rounded card used across the Reports flow.
/// Mirrors the private `_CardWrapper` used on the Owner Dashboard.
class ReportCardWrapper extends StatelessWidget {
  const ReportCardWrapper({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Maroon gradient header used on every screen in the Reports flow,
/// with an optional back button and an optional trailing action
/// (e.g. the "Edit filter" pill on result screens).
class ReportHeaderBar extends StatelessWidget {
  const ReportHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(16),
        Responsive.h(10),
        Responsive.w(16),
        Responsive.h(20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showBack)
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: EdgeInsets.only(right: Responsive.w(8)),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyBold(color: Colors.white)
                        .copyWith(fontSize: Responsive.sp(19)),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (subtitle != null) ...[
              SizedBox(height: Responsive.h(6)),
              Padding(
                padding: EdgeInsets.only(left: showBack ? Responsive.w(28) : 0),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: Responsive.sp(12.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Edit filter" pill button shown on the result screens.
class EditFilterButton extends StatelessWidget {
  const EditFilterButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(7)),
          child: Text(
            'Edit filter',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(12),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar + name + subtitle card shown at the top of a report result screen.
class ReportPersonHeaderCard extends StatelessWidget {
  const ReportPersonHeaderCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarColor,
  });

  final String name;
  final String subtitle;
  final Color avatarColor;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ReportCardWrapper(
      child: Row(
        children: [
          CircleAvatar(
            radius: Responsive.w(26),
            backgroundColor: avatarColor.withOpacity(0.15),
            child: Text(
              _initials,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.w700,
                fontSize: Responsive.sp(15),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyBold(color: AppColors.black)
                      .copyWith(fontSize: Responsive.sp(15.5)),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single value/label stat cell, e.g. "42 / Quotations Made".
class ReportStatTile extends StatelessWidget {
  const ReportStatTile({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyBold(color: valueColor ?? AppColors.black)
              .copyWith(fontSize: Responsive.sp(18)),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }
}

/// Lays out stat tiles in a simple 2-per-row grid inside a card.
class ReportStatGrid extends StatelessWidget {
  const ReportStatGrid({super.key, required this.tiles});

  final List<ReportStatTile> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      final second = i + 1 < tiles.length ? tiles[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: tiles[i]),
            if (second != null) Expanded(child: second),
          ],
        ),
      );
      if (i + 2 < tiles.length) rows.add(SizedBox(height: Responsive.h(18)));
    }
    return ReportCardWrapper(child: Column(children: rows));
  }
}

/// Two-way "Quotations / Estimates" tab switcher.
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(leftLabel, isLeftSelected, () => onChanged(true))),
          Expanded(child: _tab(rightLabel, !isLeftSelected, () => onChanged(false))),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyBold(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ).copyWith(fontSize: Responsive.sp(13)),
        ),
      ),
    );
  }
}

/// A single row item in a report result list (quotation/estimate row).
/// e.g. "QUO-202608-118 · Delivered · Sunrise Interiors · ₹64,200"
class ReportListItemCard extends StatelessWidget {
  const ReportListItemCard({
    super.key,
    required this.code,
    required this.status,
    required this.subtitle,
    required this.amountFormatted,
    required this.dateFormatted,
    this.onTap,
    this.linkedLabel,
  });

  final String code;
  final String status;
  final String subtitle;
  final String amountFormatted;
  final String dateFormatted;
  final VoidCallback? onTap;

  /// Optional secondary line shown under the amount row, e.g.
  /// "→ QUO-202608-118" linking an estimate back to its quotation.
  final String? linkedLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                Expanded(
                  child: Text(
                    code,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            SizedBox(height: Responsive.h(4)),
            Text(subtitle, style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFormatted, style: AppTextStyles.caption()),
                Text(
                  amountFormatted,
                  style: AppTextStyles.bodyBold(color: AppColors.primary),
                ),
              ],
            ),
            if (linkedLabel != null) ...[
              SizedBox(height: Responsive.h(6)),
              Row(
                children: [
                  Icon(Icons.subdirectory_arrow_right_rounded,
                      size: 14, color: AppColors.primary.withOpacity(0.7)),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    linkedLabel!,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: Responsive.sp(11.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Widgets shared by the list-style reports:
// Quotation Report, Estimate Report, Incentive Report.
// ---------------------------------------------------------------------

/// Formats a value the compact Indian way: ₹18.4L / ₹1.2Cr / ₹9,400.
String formatIndianCompactCurrency(num value) {
  final v = value.toDouble();
  if (v >= 10000000) {
    return '₹${(v / 10000000).toStringAsFixed(v % 10000000 == 0 ? 0 : 1)}Cr';
  }
  if (v >= 100000) {
    return '₹${(v / 100000).toStringAsFixed(v % 100000 == 0 ? 0 : 1)}L';
  }
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  final digitsBeforeDecimal = s.length;
  for (int i = 0; i < digitsBeforeDecimal; i++) {
    final posFromEnd = digitsBeforeDecimal - i;
    buf.write(s[i]);
    if (posFromEnd > 3 && (posFromEnd - 3) % 2 == 0) buf.write(',');
  }
  return '₹${buf.toString()}';
}

/// A single value/label used in the 3-across summary strip
/// at the top of a report result screen (e.g. "42 / Quotations").
class SummaryStat {
  const SummaryStat({required this.value, required this.label, this.valueColor});
  final String value;
  final String label;
  final Color? valueColor;
}

/// Three stats laid out in a single row inside a card — used on the
/// Quotation / Estimate / Incentive report result screens.
class SummaryStatsRow extends StatelessWidget {
  const SummaryStatsRow({super.key, required this.stats});
  final List<SummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return ReportCardWrapper(
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats[i].value,
                    style: AppTextStyles.bodyBold(color: stats[i].valueColor ?? AppColors.black)
                        .copyWith(fontSize: Responsive.sp(16.5)),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    stats[i].label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
            if (i != stats.length - 1)
              Container(width: 1, height: 32, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

/// Section label used above filter fields, e.g. "SELECT TYPE".
class ReportFieldLabel extends StatelessWidget {
  const ReportFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: Responsive.sp(11),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Two-way pill toggle used for "Select Type" (Salesman / Contractor,
/// or Salesman / Field Staff).
class ReportTypeToggle extends StatelessWidget {
  const ReportTypeToggle({
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
    return Row(
      children: [
        _pill(leftLabel, isLeftSelected, () => onChanged(true)),
        SizedBox(width: Responsive.w(10)),
        _pill(rightLabel, !isLeftSelected, () => onChanged(false)),
      ],
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(18), vertical: Responsive.h(11)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.black,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(13),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrap of single-select status chips, e.g. All / Draft / Pending / Delivered.
class ReportStatusChips extends StatelessWidget {
  const ReportStatusChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Responsive.w(10),
      runSpacing: Responsive.h(10),
      children: options.map((o) {
        final isSelected = o == selected;
        return Material(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(o),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                o,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.sp(12.5),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Dropdown field with a label above it. Supports a null value shown
/// as muted [hint] text, e.g. "Choose salesman".
class ReportDropdownField extends StatelessWidget {
  const ReportDropdownField({
    super.key,
    required this.options,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  final List<String> options;
  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          style: AppTextStyles.bodyBold(color: AppColors.black).copyWith(fontSize: Responsive.sp(14)),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Date field with a label above it. Shows muted [hint] text
/// (e.g. "Select date") when [date] is null.
class ReportDateField extends StatelessWidget {
  const ReportDateField({
    super.key,
    required this.date,
    required this.hint,
    required this.onTap,
  });

  final DateTime? date;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                date != null ? _fmt(date!) : hint,
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: date != null ? AppColors.black : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}

/// Full-width maroon "Generate Report" button.
class GenerateReportButton extends StatelessWidget {
  const GenerateReportButton({super.key, required this.onPressed, this.label = 'Generate Report'});
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: Responsive.h(15)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(15)),
        ),
      ),
    );
  }
}