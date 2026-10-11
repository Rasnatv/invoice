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
// Helper functions
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
    final button = InkWell(
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
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(8)),
              ],
              Text(title,
                  style: AppTextStyles.bodyBold(color: AppColors.primary)
                      .copyWith(fontSize: Responsive.sp(13.5))),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 15, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                SizedBox(
                  width: r.icon != null ? 86 : 100,
                  child: Text(r.label, style: AppTextStyles.caption()),
                ),
                Expanded(
                  child: Text(
                    r.value.isEmpty ? '-' : r.value,
                    style: AppTextStyles.bodyBold(),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value,
            style: AppTextStyles.bodyBold(color: valueColor ?? Colors.black)),
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
            AppColors.primary.withOpacity(0.07),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reference NO.',
                        style: AppTextStyles.captionnew().copyWith(letterSpacing: 0.6)),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      detail.estimateNumber,
                      style: AppTextStyles.bodyBold(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DATE', style: AppTextStyles.caption().copyWith(letterSpacing: 0.6)),
                  SizedBox(height: Responsive.h(4)),
                  Text(detail.dateRaw, style: AppTextStyles.bodyBold()),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
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
    );
  }
}

// ---------------------------------------------------------------------
// Items table (bill-style) — horizontal-scroll grid, print/export style
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

    // Only show these columns if at least one item across the whole
    // estimate actually has a value for them — otherwise the column
    // would just be a strip of dashes. Rows without a value still show
    // '-' in that column once it's visible.
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.list_alt_rounded, size: 15, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(8)),
                Text('Items', style: AppTextStyles.h3()),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(10), vertical: Responsive.h(4)),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Total Items: ${detail.items.length}',
                  style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(12)),
        if (detail.items.isEmpty)
          Container(
            padding: EdgeInsets.all(Responsive.w(14)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('No items on this estimate.', style: AppTextStyles.caption()),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  verticalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  bottom: BorderSide(color: AppColors.border),
                ),
                // Column widths are keyed by index, so build the map
                // dynamically — the index of every column after Unit
                // shifts depending on which of Box Qty / Piece Qty /
                // Incentive are actually shown.
                columnWidths: (() {
                  final widths = <int, TableColumnWidth>{};
                  var col = 0;
                  widths[col++] = const FixedColumnWidth(34); // Sl.No
                  widths[col++] = const FixedColumnWidth(150); // Item
                  widths[col++] = const FixedColumnWidth(120); // Company
                  widths[col++] = const FixedColumnWidth(90); // Size
                  widths[col++] = const FixedColumnWidth(95); // Unit
                  widths[col++] = const FixedColumnWidth(55); // Qty
                  if (hasBoxQty) widths[col++] = const FixedColumnWidth(70); // Box Qty
                  if (hasPieceQty) widths[col++] = const FixedColumnWidth(70); // Piece Qty
                  widths[col++] = const FixedColumnWidth(75); // MRP
                  widths[col++] = const FixedColumnWidth(75); // Rate
                  widths[col++] = const FixedColumnWidth(110); // Amount
                  if (!isOwner) widths[col++] = const FixedColumnWidth(110); // Incentive
                  return widths;
                })(),
                children: [
                  // ---- Header row ----
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(
                            color: AppColors.primary.withOpacity(0.3), width: 1.4),
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
                            : AppColors.surfaceAlt.withOpacity(0.4),
                      ),
                      children: [
                        estDataCell('${i + 1}', align: TextAlign.center),
                        estDataCell(detail.items[i].productName),
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
                      color: AppColors.primary.withOpacity(0.06),
                      border: Border(
                        top: BorderSide(
                            color: AppColors.primary.withOpacity(0.3), width: 1.2),
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
      ],
    );
  }

  Widget estHeaderCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(10)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.captionnew().copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
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
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(9)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 3,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Summary card
//   Subtotal, Handling Charge
//   with discount : Amount Before Discount, Discount, Grand Total (after)
//   no discount   : Grand Total
//   then Total Paid and the Balance strip.
// ---------------------------------------------------------------------

class EstimateSummary extends StatelessWidget {
  const EstimateSummary({super.key, required this.detail, required this.number});
  final EstimateDetailModel detail;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Column(
              children: [
                SummaryRow('Total Sqrft', number.format(detail.totalSquareFeet)),
                SizedBox(height: Responsive.h(8)),
                SummaryRow('Subtotal', currencyFmt.f(detail.subtotal)),
                SizedBox(height: Responsive.h(8)),
                SummaryRow('Handling Charge', currencyFmt.f(detail.handlingCharge)),
                SizedBox(height: Responsive.h(8)),
                if (detail.hasDiscount) ...[
                  SummaryRow('Amount Before Discount', currencyFmt.f(detail.grandTotal)),
                  SizedBox(height: Responsive.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Discount (${detail.discountTypeLabel.isEmpty ? detail.discountType : detail.discountTypeLabel})',
                          style: AppTextStyles.body(),
                        ),
                      ),
                      Text('- ${currencyFmt.f(detail.discountAmount)}',
                          style: AppTextStyles.bodyBold(color: Colors.red)),
                    ],
                  ),
                  SizedBox(height: Responsive.h(8)),
                  SummaryRow('Grand Total', currencyFmt.f(detail.amountAfterDiscount)),
                ] else
                  SummaryRow('Grand Total', currencyFmt.f(detail.grandTotal)),
                SizedBox(height: Responsive.h(8)),
                SummaryRow('Total Paid', currencyFmt.f(detail.totalPaid),
                    valueColor: AppColors.success),
              ],
            ),
          ),
          // Balance strip
          Container(
            width: double.infinity,
            padding:
            EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(14)),
            decoration: BoxDecoration(
              color: detail.balanceAmount > 0
                  ? Colors.red.withOpacity(0.06)
                  : AppColors.success.withOpacity(0.08),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance Amount', style: AppTextStyles.h3()),
                Text(
                  currencyFmt.f(detail.balanceAmount),
                  style: AppTextStyles.h2(
                      color: detail.balanceAmount > 0 ? Colors.red : AppColors.success),
                ),
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
    return DetailSection(
      title: 'Payments',
      icon: Icons.payments_outlined,
      rows: detail.payments.map((p) {
        final date = paymentDateText(p);
        return DetailRow(
          paymentMethodText(p),
          '${currencyFmt.f(p.amount)}${date.isNotEmpty ? ' · $date' : ''}',
          icon: Icons.receipt_long_outlined,
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------
// PDF builders
// ---------------------------------------------------------------------

pw.Widget pdfInfoSection(EstimateDetailModel d) {
  final rows = <List<String>>[
    ['Reference No.', d.estimateNumber],
    ['Date', d.dateRaw],
    ['Status', statusLabel(d.status)],
    ['Customer Name', d.customerName],
    ['Customer Phone', d.customerPhone],
    if (d.customerEmail.isNotEmpty) ['Customer Email', d.customerEmail],
    if (d.customerAddress.isNotEmpty) ['Customer Address', d.customerAddress],
    if (d.customer.name.isNotEmpty) ['Contractor Name', d.customer.name],
    if (d.customer.phone.isNotEmpty) ['Contractor Phone', d.customer.phone],
    if (d.salesman.name.isNotEmpty) ['Salesman', d.salesman.name],
    if (d.notes.isNotEmpty) ['Notes', d.notes],
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: rows
        .map((r) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(r[0],
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(
              r[1].isEmpty ? '-' : r[1],
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    ))
        .toList(),
  );
}

pw.Widget pdfItemsTable(EstimateDetailModel d, bool isOwner) {
  // Same "only if at least one item has it" rule as the on-screen table,
  // so the PDF/Excel exports stay consistent with what's shown on screen.
  final hasBoxQty = d.items.any((i) => i.boxQuantity > 0);
  final hasPieceQty = d.items.any((i) => i.pieceQuantity > 0);

  final headers = [
    '#',
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

  // Cell alignments are keyed by column index, so build the map
  // dynamically to match wherever Box Qty / Piece Qty / Incentive
  // land once the optional headers above are counted in.
  final cellAlignments = <int, pw.Alignment>{0: pw.Alignment.center};
  var col = 5; // Qty is always column index 5
  cellAlignments[col++] = pw.Alignment.centerRight; // Qty
  if (hasBoxQty) cellAlignments[col++] = pw.Alignment.centerRight; // Box Qty
  if (hasPieceQty) cellAlignments[col++] = pw.Alignment.centerRight; // Piece Qty
  cellAlignments[col++] = pw.Alignment.centerRight; // MRP
  cellAlignments[col++] = pw.Alignment.centerRight; // Rate
  cellAlignments[col++] = pw.Alignment.centerRight; // Amount
  if (!isOwner) cellAlignments[col++] = pw.Alignment.centerRight; // Incentive

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data,
    headerStyle:
    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignments: cellAlignments,
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
  );
}

/// Same order as the on-screen summary card.
pw.Widget pdfSummarySection(EstimateDetailModel d) {
  final rows = <List<String>>[
    ['Subtotal', currencyFmt.f(d.subtotal)],
    ['Handling Charge', currencyFmt.f(d.handlingCharge)],
    if (d.hasDiscount) ...[
      ['Amount Before Discount', currencyFmt.f(d.grandTotal)],
      [
        'Discount (${d.discountTypeLabel.isEmpty ? d.discountType : d.discountTypeLabel})',
        '- ${currencyFmt.f(d.discountAmount)}'
      ],
      ['Grand Total', currencyFmt.f(d.amountAfterDiscount)],
    ] else
      ['Grand Total', currencyFmt.f(d.grandTotal)],
    ['Total Paid', currencyFmt.f(d.totalPaid)],
    ['Balance Amount', currencyFmt.f(d.balanceAmount)],
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: rows
        .map((r) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('${r[0]}: ', style: const pw.TextStyle(fontSize: 10)),
          pw.Text(r[1], style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ))
        .toList(),
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

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data,
    headerStyle:
    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
    cellStyle: const pw.TextStyle(fontSize: 9),
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
  );
}