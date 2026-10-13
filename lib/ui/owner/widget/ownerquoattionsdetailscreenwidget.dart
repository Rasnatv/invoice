
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_models/owner_quotationapprovemodel.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';

// ---------------------------------------------------------------------
// Standard column widths for the items grid.
// Every row uses the same widths so the table looks uniform.
// ---------------------------------------------------------------------

class QCol {
  static const double sl = 60; // Sl.No
  static const double text = 180; // Item / Company
  static const double size = 120; // Size
  static const double unit = 120; // Unit
  static const double num = 120; // Qty, Box Qty, Piece Qty, MRP, Rate
  static const double money = 170; // Amount, Incentive
}

// ---------------------------------------------------------------------
// Shared look
// ---------------------------------------------------------------------

/// One card style for every block on the page.
BoxDecoration qCardDecoration({double radius = 14}) => BoxDecoration(
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
class QIconBadge extends StatelessWidget {
  const QIconBadge(this.icon, {super.key, this.color, this.size = 16});
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

/// Tinted title bar used at the top of cards.
class QCardTitle extends StatelessWidget {
  const QCardTitle({super.key, required this.title, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7))),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            QIconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyBold(color: AppColors.primary)
                  .copyWith(fontSize: Responsive.sp(14)),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Small widgets
// ---------------------------------------------------------------------

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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

/// `icon` is optional, so existing calls `DetailSection(title:, rows:)`
/// keep working. Pass an icon to get the badge in the title bar.
class DetailSection extends StatelessWidget {
  const DetailSection({required this.title, required this.rows, this.icon});
  final String title;
  final List<DetailRow> rows;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: qCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QCardTitle(title: title, icon: icon),
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

// ---------------------------------------------------------------------
// Header + incentive (new — use these in the screen file)
// ---------------------------------------------------------------------

/// Quotation number, date and status pill in one card.
class QuotationHeader extends StatelessWidget {
  const QuotationHeader({super.key, required this.q});
  final QuotationDetailModel q;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(q.status);
    final dateText =
    q.date != null ? DateFormat('dd-MM-yyyy').format(q.date!) : q.dateRaw;

    return Container(
      width: double.infinity,
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
            children: [
              const QIconBadge(Icons.description_outlined, size: 20),
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
                    Icon(_quotationStatusIcon(q.status), size: 14, color: color),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      q.status.isEmpty ? '-' : capitalize(q.status),
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
                    Text('QUOTATION NO.',
                        style: AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      q.quotationNumber,
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
                  Text('DATE',
                      style: AppTextStyles.caption().copyWith(letterSpacing: 0.8)),
                  SizedBox(height: Responsive.h(4)),
                  Text(dateText, style: AppTextStyles.bodyBold()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _quotationStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Icons.check_circle_rounded;
    case 'rejected':
    case 'cancelled':
      return Icons.cancel_rounded;
    case 'draft':
      return Icons.edit_note_rounded;
    default:
      return Icons.hourglass_top_rounded;
  }
}

/// Total incentive banner (hidden by the screen when the Owner created it).
class IncentiveCard extends StatelessWidget {
  const IncentiveCard({super.key, required this.amountText});
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(14)),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              QIconBadge(Icons.percent_rounded, color: AppColors.success),
              SizedBox(width: Responsive.w(10)),
              Text('Total Incentive',
                  style: AppTextStyles.bodyBold(color: AppColors.success)),
            ],
          ),
          Text(amountText, style: AppTextStyles.h3(color: AppColors.success)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Items table — horizontal-scroll grid, standard column widths
// ---------------------------------------------------------------------

class InvoiceTable extends StatelessWidget {
  const InvoiceTable({
    required this.items,
    required this.showCompany,
    required this.showMrp,
    required this.showBox,
    required this.showPiece,
    required this.showIncentive,
    required this.currency,
    required this.number,
  });

  final List<QuotationDetailItem> items;
  final bool showCompany, showMrp, showBox, showPiece, showIncentive;
  final NumberFormat currency;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(18)),
        decoration: qCardDecoration(),
        child: Text('No items on this quotation.', style: AppTextStyles.caption()),
      );
    }

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(0, (s, i) => s + i.incentiveAmount);

    // Keyed by index, so built dynamically — every column after Size
    // shifts depending on which optional columns are shown.
    final widths = <int, TableColumnWidth>{};
    var col = 0;
    widths[col++] = const FixedColumnWidth(QCol.sl); // Sl.No
    widths[col++] = const FixedColumnWidth(QCol.text); // Item
    if (showCompany) widths[col++] = const FixedColumnWidth(QCol.text); // Company
    widths[col++] = const FixedColumnWidth(QCol.size); // Size
    widths[col++] = const FixedColumnWidth(QCol.num); // Qty
    widths[col++] = const FixedColumnWidth(QCol.unit); // Unit
    if (showBox) widths[col++] = const FixedColumnWidth(QCol.num); // Box Qty
    if (showPiece) widths[col++] = const FixedColumnWidth(QCol.num); // Piece Qty
    if (showMrp) widths[col++] = const FixedColumnWidth(QCol.num); // MRP
    widths[col++] = const FixedColumnWidth(QCol.num); // Rate
    widths[col++] = const FixedColumnWidth(QCol.money); // Amount
    if (showIncentive) widths[col++] = const FixedColumnWidth(QCol.money); // Incentive

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: qCardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.45)),
                verticalInside: BorderSide(color: AppColors.border.withOpacity(0.30)),
              ),
              columnWidths: widths,
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
                    headerCell('Sl.No', align: TextAlign.center),
                    headerCell('Item'),
                    if (showCompany) headerCell('Company'),
                    headerCell('Size'),
                    headerCell('Qty', align: TextAlign.right),
                    headerCell('Unit'),
                    if (showBox) headerCell('Box Qty', align: TextAlign.right),
                    if (showPiece) headerCell('Piece Qty', align: TextAlign.right),
                    if (showMrp) headerCell('MRP', align: TextAlign.right),
                    headerCell('Rate', align: TextAlign.right),
                    headerCell('Amount', align: TextAlign.right),
                    if (showIncentive) headerCell('Incentive', align: TextAlign.right),
                  ],
                ),

                // ---- Data rows ----
                for (var i = 0; i < items.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? AppColors.surface
                          : AppColors.surfaceAlt.withOpacity(0.45),
                    ),
                    children: [
                      dataCell('${i + 1}', align: TextAlign.center),
                      dataCell(
                          items[i].productName.isEmpty ? '-' : items[i].productName,
                          bold: true),
                      if (showCompany)
                        dataCell(
                            items[i].companyName.isEmpty ? '-' : items[i].companyName),
                      dataCell(
                          items[i].productSize.isEmpty ? '-' : items[i].productSize),
                      dataCell(number.format(items[i].quantity), align: TextAlign.right),
                      dataCell(
                          items[i].productUnit.isEmpty ? '-' : items[i].productUnit),
                      if (showBox)
                        dataCell(
                          items[i].boxQuantity > 0
                              ? number.format(items[i].boxQuantity)
                              : '-',
                          align: TextAlign.right,
                        ),
                      if (showPiece)
                        dataCell(
                          items[i].pieceQuantity > 0
                              ? number.format(items[i].pieceQuantity)
                              : '-',
                          align: TextAlign.right,
                        ),
                      if (showMrp)
                        dataCell(
                          items[i].mrp > 0 ? number.format(items[i].mrp) : '-',
                          align: TextAlign.right,
                        ),
                      dataCell(number.format(items[i].rate), align: TextAlign.right),
                      dataCell(currency.format(items[i].amount),
                          align: TextAlign.right, bold: true),
                      if (showIncentive)
                        dataCell(
                          items[i].isIncentiveEligible
                              ? currency.format(items[i].incentiveAmount)
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
                    dataCell(''),
                    dataCell('Total', bold: true),
                    if (showCompany) dataCell(''),
                    dataCell(''),
                    dataCell(number.format(totalQty),
                        align: TextAlign.right, bold: true),
                    dataCell(''),
                    if (showBox) dataCell(''),
                    if (showPiece) dataCell(''),
                    if (showMrp) dataCell(''),
                    dataCell(''),
                    dataCell(currency.format(totalAmount),
                        align: TextAlign.right, bold: true, color: AppColors.primary),
                    if (showIncentive)
                      dataCell(currency.format(totalIncentive),
                          align: TextAlign.right, bold: true, color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    );
  }

  // One font size shared by the header and every data cell
  static double get cellFontSize => Responsive.sp(12.5);

  Widget headerCell(String text, {TextAlign align = TextAlign.left}) {
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

  Widget dataCell(
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

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green;
    case 'send':
    case 'submitted':
    case 'pending':
      return Colors.orange;
    case 'rejected':
      return Colors.red;
    case 'cancelled':
      return Colors.red;
    case 'draft':
      return Colors.blueGrey;
    default:
      return AppColors.primary;
  }
}

/// paid -> green, partial -> orange, unpaid -> red.
Color balanceStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return AppColors.success;
    case 'partial':
      return Colors.orange;
    case 'unpaid':
      return Colors.red;
    default:
      return AppColors.primary;
  }
}

String capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String buildShareText(
    QuotationDetailModel q,
    NumberFormat currency,
    NumberFormat number,
    ) {
  final buffer = StringBuffer()
    ..writeln('Quotation ${q.quotationNumber}')
    ..writeln('Customer: ${q.customer.name}')
    ..writeln('Address: ${q.customer.address}')
    ..writeln('Contractor: ${q.contractor.name}')
    ..writeln(
        'Date: ${q.date != null ? DateFormat('dd MMM yyyy').format(q.date!) : q.dateRaw}')
    ..writeln('---');
  for (final item in q.items) {
    buffer.writeln(
      '${item.productName} (${item.productSize}) x ${number.format(item.quantity)} ${item.productUnit} = ${currency.format(item.amount)}',
    );
  }
  buffer
    ..writeln('---')
    ..writeln('Handling Charge: ${currency.format(q.handlingCharge)}');
  if (q.hasDiscount) {
    buffer
      ..writeln('Total: ${currency.format(q.grandTotal)}')
      ..writeln('${q.discountLabel}: - ${currency.format(q.discountAmount)}')
      ..writeln('Amount After Discount: ${currency.format(q.amountAfterDiscount)}');
  }
  buffer.writeln('Grand Total: ${currency.format(q.amountAfterDiscount)}');
  if (q.showPaymentSummary) {
    buffer
      ..writeln('Total Paid: ${currency.format(q.totalPaid)}')
      ..writeln('Balance Amount: ${currency.format(q.balanceAmount)}');
  }
  if (q.salesman.name.isNotEmpty) {
    buffer.writeln('Salesman: ${q.salesman.name}');
  }
  buffer.writeln('Total Sqft: ${number.format(q.totalSquareFeet)}');
  return buffer.toString();
}

// ---------------------------------------------------------------------
// Row widgets
// ---------------------------------------------------------------------

class PreviewRow extends StatelessWidget {
  const PreviewRow(
      this.label,
      this.value, {
        super.key,
        this.bold = false,
        this.color,
        this.size = 0,
      });

  final String label;
  final String value;
  final bool bold;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = bold ? AppTextStyles.bodyBold() : AppTextStyles.body();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body()),
          Text(
            value,
            style: base.copyWith(
              color: color,
              fontSize: size > 0 ? size : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class TotalRow extends StatelessWidget {
  const TotalRow(
      this.label,
      this.value, {
        super.key,
        this.bold = false,
        this.valueColor,
      });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final valueStyle = (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(
      color: valueColor,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Totals card
// ---------------------------------------------------------------------

/// Totals card:
///   Total Sqft / Subtotal / Handling Charge
///   [Total Before Discount / Discount]   (only if a discount exists)
///   Grand Total
///   [Total Paid + Balance band]          (only once payments are tracked)
class TotalsCard extends StatelessWidget {
  const TotalsCard({
    super.key,
    required this.q,
    required this.money,
    required this.number,
  });

  final QuotationDetailModel q;
  final NumberFormat money;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: Responsive.h(10));
    final balanceColor = q.balanceAmount > 0 ? Colors.red : AppColors.success;

    return Container(
      width: double.infinity,
      decoration: qCardDecoration(radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QCardTitle(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Column(
              children: [
                TotalRow('Total Sqft', number.format(q.totalSquareFeet)),
                gap,
                TotalRow('Subtotal', money.format(q.subtotal)),
                gap,
                TotalRow('Handling Charge', money.format(q.handlingCharge)),
                if (q.hasDiscount) ...[
                  gap,
                  TotalRow('Total Before Discount', money.format(q.grandTotal)),
                  gap,
                  TotalRow(
                    q.discountLabel,
                    '- ${money.format(q.discountAmount)}',
                    bold: true,
                    valueColor: Colors.red,
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: AppTextStyles.h3()),
                    Text(money.format(q.amountAfterDiscount), style: AppTextStyles.h3()),
                  ],
                ),
                if (q.showPaymentSummary) ...[
                  gap,
                  TotalRow(
                    'Total Paid',
                    money.format(q.totalPaid),
                    bold: true,
                    valueColor: AppColors.success,
                  ),
                ],
              ],
            ),
          ),

          // Balance band — red while money is due, green when fully paid.
          if (q.showPaymentSummary)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.08),
                border: Border(top: BorderSide(color: balanceColor.withOpacity(0.25))),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(16), vertical: Responsive.h(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          q.balanceAmount > 0
                              ? Icons.account_balance_wallet_outlined
                              : Icons.verified_rounded,
                          size: 18,
                          color: balanceColor,
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Flexible(
                          child: Text('Balance Amount',
                              style: AppTextStyles.h3(), overflow: TextOverflow.ellipsis),
                        ),
                        if (q.balanceStatus.isNotEmpty) ...[
                          SizedBox(width: Responsive.w(8)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: balanceStatusColor(q.balanceStatus).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              capitalize(q.balanceStatus),
                              style: AppTextStyles.caption(
                                  color: balanceStatusColor(q.balanceStatus)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(
                    money.format(q.balanceAmount),
                    style: AppTextStyles.h2(color: balanceColor),
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
// Payments card
// ---------------------------------------------------------------------

/// "Payments" card: one line per payment — method, date (+ reference), amount.
class PaymentsCard extends StatelessWidget {
  const PaymentsCard({
    super.key,
    required this.q,
    required this.money,
  });

  final QuotationDetailModel q;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final totalReceived = q.payments.fold<double>(0, (s, p) => s + p.amount);

    return Container(
      width: double.infinity,
      decoration: qCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QCardTitle(
            title: 'Payments',
            icon: Icons.payments_outlined,
            trailing: Text(
              '${q.payments.length} ${q.payments.length == 1 ? 'entry' : 'entries'}',
              style: AppTextStyles.caption(),
            ),
          ),
          for (var i = 0; i < q.payments.length; i++) ...[
            Builder(builder: (context) {
              final p = q.payments[i];
              final parsed = DateTime.tryParse(p.date);
              final dateText =
              parsed != null ? DateFormat('yyyy-MM-dd').format(parsed) : p.date;

              return Padding(
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
                          Text(
                            p.methodLabel.isEmpty ? 'Payment' : p.methodLabel,
                            style: AppTextStyles.bodyBold(),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(dateText.isEmpty ? '-' : dateText,
                              style: AppTextStyles.caption()),
                          if (p.reference.isNotEmpty)
                            Text('Ref: ${p.reference}', style: AppTextStyles.caption()),
                        ],
                      ),
                    ),
                    Text(
                      money.format(p.amount),
                      style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (i != q.payments.length - 1)
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
                Text(money.format(totalReceived),
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
// Approve dialog
// ---------------------------------------------------------------------

InputDecoration _fieldDecoration({
  String? label,
  String? prefix,
  String? suffix,
}) {
  return InputDecoration(
    labelText: label,
    prefixText: prefix,
    suffixText: suffix,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary, width: 1.6),
    ),
  );
}

Widget _dialogSectionLabel(String text, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 6),
      Text(text, style: AppTextStyles.bodyBold(color: AppColors.primary)),
    ],
  );
}

/// Shows the approve dialog. Returns the request to send, or null if the
/// owner cancelled.
Future<QuotationApproveRequest?> showApproveQuotationDialog(
    BuildContext context,
    QuotationDetailModel q,
    String quotationId,
    ) async {
  final formKey = GlobalKey<FormState>();

  final handlingCtrl = TextEditingController(
    text: q.handlingCharge > 0 ? q.handlingCharge.toStringAsFixed(0) : '',
  );
  String discountType = 'none'; // none | percentage | fixed
  final discountValueCtrl = TextEditingController();
  final discountNotesCtrl = TextEditingController();

  final paymentAmountCtrl = TextEditingController();
  String paymentMethod = 'cash'; // cash | online | cheque | credit | bank_transfer
  final paymentReferenceCtrl = TextEditingController();
  DateTime? paymentDate;
  final paymentNotesCtrl = TextEditingController();

  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  // Pure frontend calculation — no API call. Re-run on every keystroke.
  // subtotal + handling - discount = payable; payable - received = balance.
  ({double handling, double discount, double payable, double received, double balance})
  calcPreview() {
    // Empty handling field falls back to the quotation's current charge.
    final handling = double.tryParse(handlingCtrl.text.trim()) ?? q.handlingCharge;
    final discountValue = double.tryParse(discountValueCtrl.text.trim()) ?? 0;
    final beforeDiscount = q.subtotal + handling;

    double discount = 0;
    if (discountType == 'percentage') {
      discount = beforeDiscount * (discountValue / 100);
    } else if (discountType == 'fixed') {
      discount = discountValue;
    }
    if (discount > beforeDiscount) discount = beforeDiscount;

    final payable = beforeDiscount - discount;
    final received = double.tryParse(paymentAmountCtrl.text.trim()) ?? 0;
    final balance = (payable - received).clamp(0, double.infinity).toDouble();

    return (
    handling: handling,
    discount: discount,
    payable: payable,
    received: received,
    balance: balance,
    );
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final preview = calcPreview();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            title: Row(
              children: [
                const QIconBadge(Icons.verified_outlined),
                const SizedBox(width: 10),
                Text('Approve Quotation', style: AppTextStyles.h3()),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Handling charge ----
                      TextFormField(
                        controller: handlingCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: _fieldDecoration(
                          label: 'Handling Charge (optional)',
                          prefix: '₹ ',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      // ---- Discount ----
                      const SizedBox(height: 18),
                      _dialogSectionLabel('Discount', Icons.sell_outlined),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: discountType,
                        decoration: _fieldDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('No discount')),
                          DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                          DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                        ],
                        onChanged: (v) => setDialogState(() => discountType = v ?? 'none'),
                      ),
                      if (discountType != 'none') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: discountValueCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: _fieldDecoration(
                            label: discountType == 'percentage'
                                ? 'Discount %'
                                : 'Discount Amount',
                            prefix: discountType == 'fixed' ? '₹ ' : null,
                            suffix: discountType == 'percentage' ? '%' : null,
                          ),
                          onChanged: (_) => setDialogState(() {}),
                          validator: (v) {
                            if (discountType == 'none') return null;
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final parsed = double.tryParse(v.trim());
                            if (parsed == null || parsed < 0) return 'Enter a valid value';
                            if (discountType == 'percentage' && parsed > 100) {
                              return 'Cannot exceed 100%';
                            }
                            return null;
                          },
                        ),
                      ],

                      // ---- PAYABLE AMOUNT PREVIEW (right before Initial Payment) ----
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PreviewRow('Subtotal', currency.format(q.subtotal)),
                            PreviewRow('Handling Charge',
                                '+ ${currency.format(preview.handling)}'),
                            if (discountType != 'none')
                              PreviewRow(
                                discountType == 'percentage'
                                    ? 'Discount (${discountValueCtrl.text.trim().isEmpty ? '0' : discountValueCtrl.text.trim()}%)'
                                    : 'Discount',
                                '- ${currency.format(preview.discount)}',
                                color: Colors.red,
                              ),
                            const Divider(height: 18),
                            PreviewRow(
                              'Payable Amount',
                              currency.format(preview.payable),
                              bold: true,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),

                      // ---- Initial Payment ----
                      const SizedBox(height: 18),
                      _dialogSectionLabel(
                          'Initial Payment (optional)', Icons.payments_outlined),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: paymentAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: _fieldDecoration(
                          label: 'Amount Received',
                          prefix: '₹ ',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null; // optional
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                          final payable = calcPreview().payable;
                          if (parsed > payable + 0.009) {
                            return 'Cannot exceed payable amount (${currency.format(payable)})';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Live balance after the amount received.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: (preview.balance > 0 ? Colors.red : AppColors.success)
                              .withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Balance Due', style: AppTextStyles.balanceamount()),
                            Text(
                              currency.format(preview.balance),
                              style: AppTextStyles.balanceamount(
                                color: preview.balance > 0 ? Colors.red : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        decoration: _fieldDecoration(label: 'Payment Method'),
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'online', child: Text('Online')),
                          DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                          DropdownMenuItem(value: 'credit', child: Text('Credit')),
                          DropdownMenuItem(
                              value: 'bank_transfer', child: Text('Bank Transfer')),
                        ],
                        onChanged: (v) => setDialogState(() => paymentMethod = v ?? 'cash'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentReferenceCtrl,
                        decoration: _fieldDecoration(label: 'Payment Reference (optional)'),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: paymentDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setDialogState(() => paymentDate = picked);
                        },
                        child: InputDecorator(
                          decoration: _fieldDecoration(label: 'Payment Date (optional)')
                              .copyWith(
                            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                          ),
                          child: Text(paymentDate == null
                              ? 'Select date'
                              : DateFormat('yyyy-MM-dd').format(paymentDate!)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentNotesCtrl,
                        decoration: _fieldDecoration(label: 'Payment Notes (optional)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Approve'),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmed != true) return null;

  final handlingCharge = double.tryParse(handlingCtrl.text.trim());
  final discountValue = double.tryParse(discountValueCtrl.text.trim());
  final paymentAmount = double.tryParse(paymentAmountCtrl.text.trim());
  final hasDiscount = discountType != 'none';

  final request = QuotationApproveRequest(
    id: quotationId,
    handlingCharge: handlingCharge,
    discountType: hasDiscount ? discountType : null,
    discountValue: hasDiscount ? discountValue : null,
    discountNotes: hasDiscount && discountNotesCtrl.text.trim().isNotEmpty
        ? discountNotesCtrl.text.trim()
        : null,
    paymentAmount: paymentAmount,
    paymentMethod: paymentAmount != null ? paymentMethod : null,
    paymentReference: paymentAmount != null && paymentReferenceCtrl.text.trim().isNotEmpty
        ? paymentReferenceCtrl.text.trim()
        : null,
    paymentDate: paymentAmount != null && paymentDate != null
        ? DateFormat('yyyy-MM-dd').format(paymentDate!)
        : null,
    paymentNotes: paymentAmount != null && paymentNotesCtrl.text.trim().isNotEmpty
        ? paymentNotesCtrl.text.trim()
        : null,
  );

  return request;
}