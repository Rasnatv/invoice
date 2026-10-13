
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';

// ---------------------------------------------------------------------
// Currency formatter
// ---------------------------------------------------------------------

class CurrencyFmt {
  const CurrencyFmt();
  String f(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(v);
}

const currencyFmt = CurrencyFmt();

// ---------------------------------------------------------------------
// Standard column widths for the items grid.
// Every row uses the same widths so the table looks uniform.
// ---------------------------------------------------------------------

class EstCol {
  static const double sl = 60; // Sl.No
  static const double text = 250; // Item / Company
  static const double size = 120; // Size
  static const double unit = 190; // Unit
  static const double num = 150; // Qty, Box Qty, Piece Qty, MRP, Rate
  static const double money = 200; // Amount, Incentive
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

/// Payment display helpers — prefer the server's pre-formatted labels
/// ("Cash", "05 Oct 2026") and fall back to the raw values.
String paymentMethodText(EstimatePayment p) {
  if (p.methodLabel.isNotEmpty) return p.methodLabel;
  return p.method.isEmpty ? 'Payment' : p.method;
}

String paymentDateText(EstimatePayment p) {
  return p.dateFormatted.isNotEmpty ? p.dateFormatted : p.date;
}

IconData statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'delivered':
      return Icons.check_circle_rounded;
    case 'rejected':
      return Icons.cancel_rounded;
    case 'despatched':
      return Icons.local_shipping_rounded;
    default:
      return Icons.hourglass_top_rounded;
  }
}

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'delivered':
      return AppColors.success;
    case 'rejected':
      return Colors.red;
    case 'despatched':
      return AppColors.primary;
    default:
      return Colors.orange;
  }
}

String statusLabel(String status) {
  if (status.isEmpty) return 'Pending';
  return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
}

/// Shared card decoration so every block on the page looks consistent.
BoxDecoration cardDecoration({double radius = 14}) => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border.withOpacity(0.8)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

/// Small rounded icon badge used in section titles.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.color, this.size = 16});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

// ---------------------------------------------------------------------
// Small widgets
// ---------------------------------------------------------------------

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class DetailRow {
  final String label;
  final String value;
  final IconData? icon;
  DetailRow(this.label, this.value, {this.icon});
}

class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.rows, this.icon});
  final String title;
  final List<DetailRow> rows;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: AppColors.border.withOpacity(0.7)),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  IconBadge(icon!),
                  SizedBox(width: Responsive.w(10)),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyBold(color: AppColors.primary)
                        .copyWith(fontSize: Responsive.sp(14)),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(4)),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rows[i].icon != null) ...[
                          Icon(rows[i].icon, size: 16, color: AppColors.textHint),
                          SizedBox(width: Responsive.w(10)),
                        ],
                        SizedBox(
                          width: 92,
                          child: Text(rows[i].label, style: AppTextStyles.caption()),
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                            rows[i].value.isEmpty ? '-' : rows[i].value,
                            style: AppTextStyles.bodyBold(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != rows.length - 1)
                    Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.valueColor, this.bold = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold ? AppTextStyles.bodyBold() : AppTextStyles.body()),
        Text(
          value,
          style: AppTextStyles.body(color: valueColor ?? Colors.black).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------

class EstimateHeader extends StatelessWidget {
  const EstimateHeader({super.key, required this.detail});
  final EstimateDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(detail.status);
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.10),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(Icons.receipt_long_rounded, size: 20),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon(detail.status), size: 14, color: color),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      statusLabel(detail.status),
                      style: AppTextStyles.bodyBold(color: color)
                          .copyWith(fontSize: Responsive.sp(12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REFERENCE NO.',
                        style: AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      detail.estimateNumber,
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DATE', style: AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
                  SizedBox(height: Responsive.h(4)),
                  Text(detail.dateRaw, style: AppTextStyles.bodyBold()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Items table (bill-style) — horizontal-scroll grid, standard widths
// ---------------------------------------------------------------------

class EstimateItemsTable extends StatelessWidget {
  const EstimateItemsTable({
    super.key,
    required this.detail,
    required this.number,
    required this.isOwner,
  });

  final EstimateDetailModel detail;
  final NumberFormat number;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final totalQty = detail.items.fold<double>(0, (sum, i) => sum + i.quantity);
    final totalAmount = detail.items.fold<double>(0, (sum, i) => sum + i.amount);
    final totalIncentive = detail.items.fold<double>(
        0, (sum, i) => sum + (i.isIncentiveEligible ? i.incentiveAmount : 0));

    // Only show these columns if at least one item has a value for them.
    final hasBoxQty = detail.items.any((i) => i.boxQuantity > 0);
    final hasPieceQty = detail.items.any((i) => i.pieceQuantity > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const IconBadge(Icons.list_alt_rounded),
                SizedBox(width: Responsive.w(10)),
                Text('Items', style: AppTextStyles.h3()),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(12), vertical: Responsive.h(5)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${detail.items.length} ${detail.items.length == 1 ? 'item' : 'items'}',
                style: AppTextStyles.bodyBold(color: AppColors.primary)
                    .copyWith(fontSize: Responsive.sp(12)),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(12)),
        if (detail.items.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(18)),
            decoration: cardDecoration(),
            child: Text('No items on this estimate.', style: AppTextStyles.caption()),
          )
        else
          Container(
            decoration: cardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.45)),
                  verticalInside: BorderSide(color: AppColors.border.withOpacity(0.30)),
                ),
                // Keyed by index, so built dynamically — every column after
                // Qty shifts depending on which optional columns are shown.
                columnWidths: (() {
                  final widths = <int, TableColumnWidth>{};
                  var col = 0;
                  widths[col++] = const FixedColumnWidth(EstCol.sl); // Sl.No
                  widths[col++] = const FixedColumnWidth(EstCol.text); // Item
                  widths[col++] = const FixedColumnWidth(EstCol.text); // Company
                  widths[col++] = const FixedColumnWidth(EstCol.size); // Size
                  widths[col++] = const FixedColumnWidth(EstCol.unit); // Unit
                  widths[col++] = const FixedColumnWidth(EstCol.num); // Qty
                  if (hasBoxQty) widths[col++] = const FixedColumnWidth(EstCol.num);
                  if (hasPieceQty) widths[col++] = const FixedColumnWidth(EstCol.num);
                  widths[col++] = const FixedColumnWidth(EstCol.num); // MRP
                  widths[col++] = const FixedColumnWidth(EstCol.num); // Rate
                  widths[col++] = const FixedColumnWidth(EstCol.money); // Amount
                  if (!isOwner) widths[col++] = const FixedColumnWidth(EstCol.money); // Incentive
                  return widths;
                })(),
                children: [
                  // ---- Header row ----
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.09),
                      border: Border(
                        bottom: BorderSide(
                            color: AppColors.primary.withOpacity(0.35), width: 1.4),
                      ),
                    ),
                    children: [
                      estHeaderCell('Sl.No', align: TextAlign.center),
                      estHeaderCell('Item'),
                      estHeaderCell('Company'),
                      estHeaderCell('Size'),
                      estHeaderCell('Unit'),
                      estHeaderCell('Qty', align: TextAlign.right),
                      if (hasBoxQty) estHeaderCell('Box Qty', align: TextAlign.right),
                      if (hasPieceQty) estHeaderCell('Piece Qty', align: TextAlign.right),
                      estHeaderCell('MRP', align: TextAlign.right),
                      estHeaderCell('Rate', align: TextAlign.right),
                      estHeaderCell('Amount', align: TextAlign.right),
                      if (!isOwner) estHeaderCell('Incentive', align: TextAlign.right),
                    ],
                  ),
                  // ---- Data rows ----
                  for (var i = 0; i < detail.items.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? AppColors.surface
                            : AppColors.surfaceAlt.withOpacity(0.45),
                      ),
                      children: [
                        estDataCell('${i + 1}', align: TextAlign.center),
                        estDataCell(detail.items[i].productName, bold: true),
                        estDataCell(detail.items[i].companyName.isEmpty
                            ? '-'
                            : detail.items[i].companyName),
                        estDataCell(detail.items[i].productSize.isEmpty
                            ? '-'
                            : detail.items[i].productSize),
                        estDataCell(detail.items[i].unitName.isEmpty
                            ? '-'
                            : detail.items[i].unitName),
                        estDataCell(number.format(detail.items[i].quantity),
                            align: TextAlign.right),
                        if (hasBoxQty)
                          estDataCell(
                            detail.items[i].boxQuantity > 0
                                ? number.format(detail.items[i].boxQuantity)
                                : '-',
                            align: TextAlign.right,
                          ),
                        if (hasPieceQty)
                          estDataCell(
                            detail.items[i].pieceQuantity > 0
                                ? number.format(detail.items[i].pieceQuantity)
                                : '-',
                            align: TextAlign.right,
                          ),
                        estDataCell(
                            detail.items[i].mrp > 0
                                ? number.format(detail.items[i].mrp)
                                : '-',
                            align: TextAlign.right),
                        estDataCell(number.format(detail.items[i].rate),
                            align: TextAlign.right),
                        estDataCell(currencyFmt.f(detail.items[i].amount),
                            align: TextAlign.right, bold: true),
                        if (!isOwner)
                          estDataCell(
                            detail.items[i].isIncentiveEligible
                                ? currencyFmt.f(detail.items[i].incentiveAmount)
                                : '-',
                            align: TextAlign.right,
                            bold: true,
                            color: AppColors.success,
                          ),
                      ],
                    ),
                  // ---- Totals footer row ----
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.07),
                      border: Border(
                        top: BorderSide(
                            color: AppColors.primary.withOpacity(0.35), width: 1.2),
                      ),
                    ),
                    children: [
                      estDataCell(''),
                      estDataCell('Total', bold: true),
                      estDataCell(''),
                      estDataCell(''),
                      estDataCell(''),
                      estDataCell(number.format(totalQty),
                          align: TextAlign.right, bold: true),
                      if (hasBoxQty) estDataCell(''),
                      if (hasPieceQty) estDataCell(''),
                      estDataCell(''),
                      estDataCell(''),
                      estDataCell(currencyFmt.f(totalAmount),
                          align: TextAlign.right, bold: true, color: AppColors.primary),
                      if (!isOwner)
                        estDataCell(currencyFmt.f(totalIncentive),
                            align: TextAlign.right, bold: true, color: AppColors.success),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (detail.items.isNotEmpty) ...[
          SizedBox(height: Responsive.h(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_rounded, size: 14, color: AppColors.textHint),
              SizedBox(width: Responsive.w(4)),
              Text('Swipe sideways to see all columns',
                  style: AppTextStyles.caption().copyWith(fontSize: Responsive.sp(11))),
            ],
          ),
        ],
      ],
    );
  }

  // One font size shared by the header and every data cell
  static double get cellFontSize => Responsive.sp(12.5);

  Widget estHeaderCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(12)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(
          fontSize: cellFontSize,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget estDataCell(
      String text, {
        TextAlign align = TextAlign.left,
        bool bold = false,
        Color? color,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(10)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(
          color: color,
          fontSize: cellFontSize,
          fontFeatures: const [FontFeature.tabularFigures()], // digits line up
        ),
      ),
    );
  }
}


class EstimateSummary extends StatelessWidget {
  const EstimateSummary({super.key, required this.detail, required this.number});
  final EstimateDetailModel detail;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    final hasBalance = detail.balanceAmount > 0;
    final balanceColor = hasBalance ? Colors.red : AppColors.success;
    final discountLabel =
    detail.discountTypeLabel.isEmpty ? detail.discountType : detail.discountTypeLabel;

    return Container(
      decoration: cardDecoration(radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7))),
            ),
            child: Row(
              children: [
                const IconBadge(Icons.calculate_outlined),
                SizedBox(width: Responsive.w(10)),
                Text('Summary',
                    style: AppTextStyles.bodyBold(color: AppColors.primary)
                        .copyWith(fontSize: Responsive.sp(14))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Column(
              children: [
                SummaryRow('Total Sqrft', number.format(detail.totalSquareFeet)),
                SizedBox(height: Responsive.h(10)),
                SummaryRow('Subtotal', currencyFmt.f(detail.subtotal)),
                SizedBox(height: Responsive.h(10)),
                SummaryRow('Handling Charge', currencyFmt.f(detail.handlingCharge)),
                if (detail.hasDiscount) ...[
                  SizedBox(height: Responsive.h(10)),
                  SummaryRow('Amount Before Discount', currencyFmt.f(detail.grandTotal)),
                  SizedBox(height: Responsive.h(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Discount ($discountLabel)',
                            style: AppTextStyles.body()),
                      ),
                      Text(
                        '- ${currencyFmt.f(detail.discountAmount)}',
                        style: AppTextStyles.bodyBold(color: Colors.red).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                // Grand total highlighted
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: AppTextStyles.h3()),
                    Text(
                      currencyFmt.f(
                          detail.hasDiscount ? detail.amountAfterDiscount : detail.grandTotal),
                      style: AppTextStyles.balanceamount(),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                SummaryRow('Total Paid', currencyFmt.f(detail.totalPaid),
                    valueColor: AppColors.success),
              ],
            ),
          ),
          // Balance strip
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16), vertical: Responsive.h(14)),
            decoration: BoxDecoration(
              color: balanceColor.withOpacity(0.08),
              border: Border(top: BorderSide(color: balanceColor.withOpacity(0.25))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      hasBalance
                          ? Icons.account_balance_wallet_outlined
                          : Icons.verified_rounded,
                      size: 18,
                      color: balanceColor,
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Text('Balance Amount', style: AppTextStyles.h3()),
                  ],
                ),
                Text(currencyFmt.f(detail.balanceAmount),
                    style: AppTextStyles.balanceamount(color: balanceColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Payments
// ---------------------------------------------------------------------

class EstimatePayments extends StatelessWidget {
  const EstimatePayments({super.key, required this.detail});
  final EstimateDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final totalPaid = detail.payments.fold<double>(0, (s, p) => s + p.amount);

    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7))),
            ),
            child: Row(
              children: [
                const IconBadge(Icons.payments_outlined),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: Text('Payments',
                      style: AppTextStyles.bodyBold(color: AppColors.primary)
                          .copyWith(fontSize: Responsive.sp(14))),
                ),
                Text(
                  '${detail.payments.length} ${detail.payments.length == 1 ? 'entry' : 'entries'}',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          for (var i = 0; i < detail.payments.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(12)),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 18, color: AppColors.success),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(paymentMethodText(detail.payments[i]),
                            style: AppTextStyles.bodyBold()),
                        SizedBox(height: Responsive.h(2)),
                        Text(
                          paymentDateText(detail.payments[i]).isEmpty
                              ? '-'
                              : paymentDateText(detail.payments[i]),
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFmt.f(detail.payments[i].amount),
                    style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i != detail.payments.length - 1)
              Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ],
          // Footer total
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.7))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Received', style: AppTextStyles.bodyBold()),
                Text(currencyFmt.f(totalPaid),
                    style: AppTextStyles.bodyBold(color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// PDF builders
// ---------------------------------------------------------------------

const _pdfPrimary = PdfColors.blueGrey800;
const _pdfLine = PdfColors.grey400;
const _pdfSoft = PdfColors.grey100;

/// Two-column bordered info block (long values like address / notes go
/// full-width underneath).
pw.Widget pdfInfoSection(EstimateDetailModel d) {
  final pairs = <List<String>>[
    ['Reference No.', d.estimateNumber],
    ['Date', d.dateRaw],
    ['Status', statusLabel(d.status)],
    if (d.salesman.name.isNotEmpty) ['Salesman', d.salesman.name],
    ['Customer Name', d.customerName],
    ['Customer Phone', d.customerPhone],
    if (d.customerEmail.isNotEmpty) ['Customer Email', d.customerEmail],
    if (d.customer.name.isNotEmpty) ['Contractor Name', d.customer.name],
    if (d.customer.phone.isNotEmpty) ['Contractor Phone', d.customer.phone],
  ];
  final wide = <List<String>>[
    if (d.customerAddress.isNotEmpty) ['Customer Address', d.customerAddress],
    if (d.notes.isNotEmpty) ['Notes', d.notes],
  ];

  pw.Widget cell(List<String> r) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(r[0].toUpperCase(),
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.SizedBox(height: 1.5),
        pw.Text(r[1].isEmpty ? '-' : r[1],
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );

  final rowsWidgets = <pw.Widget>[];
  for (var i = 0; i < pairs.length; i += 2) {
    rowsWidgets.add(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: cell(pairs[i])),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: i + 1 < pairs.length ? cell(pairs[i + 1]) : pw.SizedBox(),
          ),
        ],
      ),
    );
  }
  for (final w in wide) {
    rowsWidgets.add(cell(w));
  }

  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 4),
    decoration: pw.BoxDecoration(
      color: _pdfSoft,
      border: pw.Border.all(color: _pdfLine, width: 0.5),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rowsWidgets,
    ),
  );
}


pw.Widget pdfItemsTable(EstimateDetailModel d, bool isOwner) {
  // Same "only if at least one item has it" rule as the Excel export.
  final hasBoxQty = d.items.any((i) => i.boxQuantity > 0);
  final hasPieceQty = d.items.any((i) => i.pieceQuantity > 0);

  final headers = [
    'Sl No',
    'Item',
    'Company',
    'Size',
    'Unit',
    'Qty',
    if (hasBoxQty) 'Box Qty',
    if (hasPieceQty) 'Piece Qty',
    'MRP',
    'Rate',
    'Amount',
    if (!isOwner) 'Incentive',
  ];
  final data = <List<String>>[
    for (var i = 0; i < d.items.length; i++)
      [
        '${i + 1}',
        d.items[i].productName,
        d.items[i].companyName.isEmpty ? '-' : d.items[i].companyName,
        d.items[i].productSize.isEmpty ? '-' : d.items[i].productSize,
        d.items[i].unitName.isEmpty ? '-' : d.items[i].unitName,
        d.items[i].quantity.toStringAsFixed(0),
        if (hasBoxQty)
          d.items[i].boxQuantity > 0 ? d.items[i].boxQuantity.toStringAsFixed(0) : '-',
        if (hasPieceQty)
          d.items[i].pieceQuantity > 0 ? d.items[i].pieceQuantity.toStringAsFixed(0) : '-',
        d.items[i].mrp > 0 ? d.items[i].mrp.toStringAsFixed(0) : '-',
        d.items[i].rate.toStringAsFixed(0),
        currencyFmt.f(d.items[i].amount),
        if (!isOwner)
          d.items[i].isIncentiveEligible ? currencyFmt.f(d.items[i].incentiveAmount) : '-',
      ],
  ];

  // Alignments are keyed by column index — built dynamically so they follow
  // wherever Box Qty / Piece Qty / Incentive land.
  final cellAlignments = <int, pw.Alignment>{
    0: pw.Alignment.center,
    1: pw.Alignment.centerLeft,
    2: pw.Alignment.centerLeft,
    3: pw.Alignment.centerLeft,
    4: pw.Alignment.centerLeft,
  };
  var col = 5; // Qty is always column index 5
  cellAlignments[col++] = pw.Alignment.centerRight; // Qty
  if (hasBoxQty) cellAlignments[col++] = pw.Alignment.centerRight;
  if (hasPieceQty) cellAlignments[col++] = pw.Alignment.centerRight;
  cellAlignments[col++] = pw.Alignment.centerRight; // MRP
  cellAlignments[col++] = pw.Alignment.centerRight; // Rate
  cellAlignments[col++] = pw.Alignment.centerRight; // Amount
  if (!isOwner) cellAlignments[col++] = pw.Alignment.centerRight; // Incentive

  // Number columns size themselves to their content, so Amount (and other
  // numbers) never wrap onto a second line. Text columns share what's left.
  final colWidths = <int, pw.TableColumnWidth>{};
  var c = 0;
  colWidths[c++] = const pw.IntrinsicColumnWidth(); // Sl
  colWidths[c++] = const pw.FlexColumnWidth(); // Item
  colWidths[c++] = const pw.FlexColumnWidth(); // Company
  colWidths[c++] = const pw.FlexColumnWidth(); // Size
  colWidths[c++] = const pw.IntrinsicColumnWidth(); // Unit
  colWidths[c++] = const pw.IntrinsicColumnWidth(); // Qty
  if (hasBoxQty) colWidths[c++] = const pw.IntrinsicColumnWidth();
  if (hasPieceQty) colWidths[c++] = const pw.IntrinsicColumnWidth();
  colWidths[c++] = const pw.IntrinsicColumnWidth(); // MRP
  colWidths[c++] = const pw.IntrinsicColumnWidth(); // Rate
  colWidths[c++] = const pw.IntrinsicColumnWidth(); // Amount
  if (!isOwner) colWidths[c++] = const pw.IntrinsicColumnWidth(); // Incentive

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data,
    columnWidths: colWidths,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    headerStyle:
    pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: _pdfPrimary),
    headerAlignments: cellAlignments, // header aligns with its column
    cellStyle: const pw.TextStyle(fontSize: 8),
    cellAlignments: cellAlignments,
    border: pw.TableBorder.all(color: _pdfLine, width: 0.5),
    rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    oddRowDecoration: const pw.BoxDecoration(color: _pdfSoft),
  );
}

pw.Widget pdfSummarySection(EstimateDetailModel d) {
  final discountLabel = d.discountTypeLabel.isEmpty ? d.discountType : d.discountTypeLabel;

  pw.Widget line(String label, String value,
      {bool bold = false, PdfColor? color, double size = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: size,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.SizedBox(width: 14),
          pw.Text(value,
              softWrap: false, // amount always stays on one line
              style: pw.TextStyle(
                  fontSize: size, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  final hasBalance = d.balanceAmount > 0;

  return pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Container(
      width: 300, // was 250
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _pdfLine, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          line('Subtotal', currencyFmt.f(d.subtotal)),
          line('Handling Charge', currencyFmt.f(d.handlingCharge)),
          if (d.hasDiscount) ...[
            line('Amount Before Discount', currencyFmt.f(d.grandTotal)),
            line('Discount ($discountLabel)', '- ${currencyFmt.f(d.discountAmount)}',
                color: PdfColors.red700),
          ],
          pw.Divider(color: _pdfLine, thickness: 0.5, height: 10),
          line('Grand Total',
              currencyFmt.f(d.hasDiscount ? d.amountAfterDiscount : d.grandTotal),
              bold: true, size: 12),
          line('Total Paid', currencyFmt.f(d.totalPaid), color: PdfColors.green800),
          pw.SizedBox(height: 4),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: hasBalance ? PdfColors.red50 : PdfColors.green50,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Balance Amount',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(width: 14),
                pw.Text(
                  currencyFmt.f(d.balanceAmount),
                  softWrap: false,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: hasBalance ? PdfColors.red700 : PdfColors.green800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget pdfPaymentsTable(EstimateDetailModel d) {
  final headers = ['Method', 'Amount', 'Date'];
  final data = d.payments
      .map((p) => [
    paymentMethodText(p),
    currencyFmt.f(p.amount),
    paymentDateText(p).isEmpty ? '-' : paymentDateText(p),
  ])
      .toList();

  const alignments = <int, pw.Alignment>{
    0: pw.Alignment.centerLeft,
    1: pw.Alignment.centerRight,
    2: pw.Alignment.centerLeft,
  };

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    headerStyle:
    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: _pdfPrimary),
    headerAlignments: alignments,
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignments: alignments,
    border: pw.TableBorder.all(color: _pdfLine, width: 0.5),
    rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    oddRowDecoration: const pw.BoxDecoration(color: _pdfSoft),
  );
}