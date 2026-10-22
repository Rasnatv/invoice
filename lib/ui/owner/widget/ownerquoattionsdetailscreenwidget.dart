import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_models/owner_quotationapprovemodel.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';

const Color _redColor = Color(0xFFDC2626);

// ---------------------------------------------------------------------
// Standard column widths for the items grid.
// ---------------------------------------------------------------------

class QCol {
  static const double sl = 60; // Sl.No
  static const double text = 250; // Item / Company
  static const double size = 120; // Size
  static const double unit = 150; // Unit
  static const double num = 150; // Qty, Box Qty, Piece Qty, MRP, Rate
  static const double money = 200; // Amount, Incentive
}

// ---------------------------------------------------------------------
// Shared look (same as the Estimate detail screen)
// ---------------------------------------------------------------------

/// White card, radius 16, 1px border, no shadow.
BoxDecoration qCardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

/// Status pill — identical to the Estimates one.
class QStatusPill extends StatelessWidget {
  const QStatusPill({super.key, required this.label, required this.color});
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

/// Blue-bar section heading.
class QSectionHeader extends StatelessWidget {
  const QSectionHeader(this.title, {super.key});
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

/// White card header row (icon badge + title) with a divider underneath.
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            QIconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
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
    super.key,
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: Responsive.h(48),
          height: Responsive.h(48),
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

class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.rows, this.icon});
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
                          Icon(rows[i].icon, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: Responsive.w(10)),
                        ],
                        SizedBox(
                          width: 92,
                          child: Text(rows[i].label,
                              style: AppTextStyles.caption(color: AppColors.textSecondary)),
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
                    const Divider(height: 1, color: AppColors.border),
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
// Header (same look as the Estimate header)
// ---------------------------------------------------------------------

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
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: qCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.quotationNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(),
                ),
                SizedBox(height: Responsive.h(2)),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textSecondary),
                    SizedBox(width: Responsive.w(5)),
                    Expanded(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          QStatusPill(
            label: q.status.isEmpty ? '-' : capitalize(q.status),
            color: color,
          ),
        ],
      ),
    );
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
          Text(amountText, style: AppTextStyles.amount(color: AppColors.success)),
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
    super.key,
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
        child: Text('No items on this quotation.',
            style: AppTextStyles.caption(color: AppColors.textSecondary)),
      );
    }

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(0, (s, i) => s + i.incentiveAmount);

    final widths = <int, TableColumnWidth>{};
    var col = 0;
    widths[col++] = const FixedColumnWidth(QCol.sl); // Sl.No
    widths[col++] = const FixedColumnWidth(QCol.text); // Item
    if (showCompany) widths[col++] = const FixedColumnWidth(QCol.text); // Company
    widths[col++] = const FixedColumnWidth(QCol.size); // Size
    widths[col++] = const FixedColumnWidth(QCol.num); // Qty
    widths[col++] = const FixedColumnWidth(QCol.unit); // Unit
    if (showBox) widths[col++] = const FixedColumnWidth(QCol.num);
    if (showPiece) widths[col++] = const FixedColumnWidth(QCol.num);
    if (showMrp) widths[col++] = const FixedColumnWidth(QCol.num);
    widths[col++] = const FixedColumnWidth(QCol.num); // Rate
    widths[col++] = const FixedColumnWidth(QCol.money); // Amount
    if (showIncentive) widths[col++] = const FixedColumnWidth(QCol.money);

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
                horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.6)),
                verticalInside: BorderSide(color: AppColors.border.withOpacity(0.4)),
              ),
              columnWidths: widths,
              children: [
                // ---- Header row ----
                TableRow(
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
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
                      color: i.isEven ? Colors.white : AppColors.background,
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
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06)),
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
                style: AppTextStyles.caption(color: AppColors.textSecondary)
                    .copyWith(fontSize: Responsive.sp(11))),
          ],
        ),
      ],
    );
  }

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
        style: AppTextStyles.bodyBold(color: AppColors.primary)
            .copyWith(fontSize: cellFontSize),
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
          fontFeatures: const [FontFeature.tabularFigures()],
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
      return AppColors.success;
    case 'send':
    case 'submitted':
    case 'pending':
      return const Color(0xFFF59E0B);
    case 'rejected':
    case 'cancelled':
      return _redColor;
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
      return const Color(0xFFF59E0B);
    case 'unpaid':
      return _redColor;
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

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value,
      {super.key, this.valueColor, this.bold = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? AppTextStyles.bodyBold()
                : AppTextStyles.body(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.bodyBold(color: valueColor ?? AppColors.textPrimary)
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Totals card (Summary)
// ---------------------------------------------------------------------

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
    final hasBalance = q.balanceAmount > 0;
    final balanceColor = hasBalance ? _redColor : AppColors.success;

    return Container(
      width: double.infinity,
      decoration: qCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QCardTitle(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                SummaryRow('Total Sqrft', number.format(q.totalSquareFeet)),
                gap,
                SummaryRow('Subtotal', money.format(q.subtotal)),
                gap,
                SummaryRow('Handling Charge', money.format(q.handlingCharge)),
                if (q.hasDiscount) ...[
                  gap,
                  SummaryRow('Total Before Discount', money.format(q.grandTotal)),
                  gap,
                  SummaryRow(
                    q.discountLabel,
                    '- ${money.format(q.discountAmount)}',
                    valueColor: _redColor,
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  child: const Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: AppTextStyles.bodyBold()),
                    Text(money.format(q.amountAfterDiscount),
                        style: AppTextStyles.amount(color: AppColors.primary)),
                  ],
                ),
                if (q.showPaymentSummary) ...[
                  gap,
                  SummaryRow('Total Paid', money.format(q.totalPaid),
                      valueColor: AppColors.success),
                ],
              ],
            ),
          ),

          // Balance strip — red while money is due, green when fully paid.
          if (q.showPaymentSummary)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(12)),
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.06),
                border: Border(top: BorderSide(color: balanceColor.withOpacity(0.25))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasBalance
                              ? Icons.account_balance_wallet_outlined
                              : Icons.verified_rounded,
                          size: 18,
                          color: balanceColor,
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Flexible(
                          child: Text('Balance Amount',
                              style: AppTextStyles.bodyBold(),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (q.balanceStatus.isNotEmpty) ...[
                          SizedBox(width: Responsive.w(8)),
                          QStatusPill(
                            label: capitalize(q.balanceStatus),
                            color: balanceStatusColor(q.balanceStatus),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(money.format(q.balanceAmount),
                      style: AppTextStyles.amount(color: balanceColor)),
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

class PaymentsCard extends StatelessWidget {
  const PaymentsCard({super.key, required this.q, required this.money});

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
              style: AppTextStyles.caption(color: AppColors.textSecondary),
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_outlined,
                          size: 20, color: AppColors.success),
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
                              style: AppTextStyles.caption(color: AppColors.textSecondary)),
                          if (p.reference.isNotEmpty)
                            Text('Ref: ${p.reference}',
                                style: AppTextStyles.caption(color: AppColors.textSecondary)),
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
              const Divider(height: 1, color: AppColors.border),
          ],
          // Footer total
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              border: const Border(top: BorderSide(color: AppColors.border)),
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
// Approve dialog (same look as the Estimate approve dialog)
// ---------------------------------------------------------------------

/// Shows the approve dialog. Returns the request to send, or null if the
/// owner cancelled.
Future<QuotationApproveRequest?> showApproveQuotationDialog(
    BuildContext context,
    QuotationDetailModel q,
    String quotationId,
    ) async {
  final formKey = GlobalKey<FormState>();

  // One set of styles for the whole dialog.
  final headingStyle = AppTextStyles.bodyBold();
  final inputStyle = AppTextStyles.body();
  final labelStyle = AppTextStyles.body(color: AppColors.textSecondary);
  final errorStyle = AppTextStyles.caption(color: AppColors.error);

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

  // Pure frontend calculation — no API call.
  // subtotal + handling - discount = payable; payable - received = balance.
  ({double handling, double discount, double payable, double received, double balance})
  calcPreview() {
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

  Widget previewRow(String label, String value, {bool bold = false, Color? color}) {
    final valueStyle = bold
        ? AppTextStyles.bodyBold(color: color ?? AppColors.textPrimary)
        : AppTextStyles.body(color: color ?? AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: bold
                  ? AppTextStyles.bodyBold()
                  : AppTextStyles.body(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(value, maxLines: 1, softWrap: false, style: valueStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final preview = calcPreview();

          return Theme(
            data: Theme.of(dialogContext).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: labelStyle,
                floatingLabelStyle: labelStyle,
                hintStyle: labelStyle,
                prefixStyle: inputStyle,
                suffixStyle: inputStyle,
                errorStyle: errorStyle,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14),
                  vertical: Responsive.h(14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              textTheme: Theme.of(dialogContext).textTheme.copyWith(
                titleMedium: inputStyle,
                bodyLarge: inputStyle,
              ),
            ),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Approve Quotation', style: headingStyle),
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
                          style: inputStyle,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Handling Charge (optional)',
                            prefixText: '₹ ',
                          ),
                          onChanged: (_) => setDialogState(() {}),
                        ),

                        // ---- Discount ----
                        const SizedBox(height: 16),
                        Text('Discount', style: headingStyle),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: discountType,
                          style: inputStyle,
                          items: [
                            DropdownMenuItem(
                                value: 'none',
                                child: Text('No discount', style: inputStyle)),
                            DropdownMenuItem(
                                value: 'percentage',
                                child: Text('Percentage', style: inputStyle)),
                            DropdownMenuItem(
                                value: 'fixed', child: Text('Fixed', style: inputStyle)),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => discountType = v ?? 'none'),
                        ),
                        if (discountType != 'none') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: discountValueCtrl,
                            style: inputStyle,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              labelText: discountType == 'percentage'
                                  ? 'Discount %'
                                  : 'Discount Amount',
                              prefixText: discountType == 'fixed' ? '₹ ' : null,
                              suffixText: discountType == 'percentage' ? '%' : null,
                            ),
                            onChanged: (_) => setDialogState(() {}),
                            validator: (v) {
                              if (discountType == 'none') return null;
                              if (v == null || v.trim().isEmpty) return 'Required';
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed < 0) {
                                return 'Enter a valid value';
                              }
                              if (discountType == 'percentage' && parsed > 99) {
                                return 'Cannot exceed 99%';
                              }
                              return null;
                            },
                          ),
                        ],

                        // ---- Payable amount preview ----
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              previewRow('Subtotal', currency.format(q.subtotal)),
                              previewRow('Handling Charge',
                                  '+ ${currency.format(preview.handling)}'),
                              if (discountType != 'none')
                                previewRow(
                                  discountType == 'percentage'
                                      ? 'Discount (${discountValueCtrl.text.trim().isEmpty ? '0' : discountValueCtrl.text.trim()}%)'
                                      : 'Discount',
                                  '- ${currency.format(preview.discount)}',
                                  color: _redColor,
                                ),
                              const Divider(height: 14, color: AppColors.border),
                              previewRow(
                                'Payable Amount',
                                currency.format(preview.payable),
                                bold: true,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),

                        // ---- Initial Payment ----
                        const SizedBox(height: 16),
                        Text('Initial Payment (optional)', style: headingStyle),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: paymentAmountCtrl,
                          style: inputStyle,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Amount Received',
                            prefixText: '₹ ',
                          ),
                          onChanged: (_) => setDialogState(() {}),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null; // optional
                            final parsed = double.tryParse(v.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid amount';
                            }
                            final payable = calcPreview().payable;
                            if (parsed > payable + 0.009) {
                              return 'Cannot exceed payable amount (${currency.format(payable)})';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Live balance after the amount received.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Balance Due', style: AppTextStyles.bodyBold()),
                              Text(
                                currency.format(preview.balance),
                                style: AppTextStyles.bodyBold(
                                  color: preview.balance > 0
                                      ? _redColor
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: paymentMethod,
                          style: inputStyle,
                          decoration: const InputDecoration(labelText: 'Payment Method'),
                          items: [
                            DropdownMenuItem(
                                value: 'cash', child: Text('Cash', style: inputStyle)),
                            DropdownMenuItem(
                                value: 'online', child: Text('Online', style: inputStyle)),
                            DropdownMenuItem(
                                value: 'cheque', child: Text('Cheque', style: inputStyle)),
                            DropdownMenuItem(
                                value: 'credit', child: Text('Credit', style: inputStyle)),
                            DropdownMenuItem(
                                value: 'bank_transfer',
                                child: Text('Bank Transfer', style: inputStyle)),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => paymentMethod = v ?? 'cash'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: paymentReferenceCtrl,
                          style: inputStyle,
                          decoration: const InputDecoration(
                              labelText: 'Payment Reference (optional)'),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: paymentDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() => paymentDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'Payment Date (optional)'),
                            child: Text(
                              paymentDate == null
                                  ? 'Select date'
                                  : DateFormat('yyyy-MM-dd').format(paymentDate!),
                              style: inputStyle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: paymentNotesCtrl,
                          style: inputStyle,
                          decoration: const InputDecoration(
                              labelText: 'Payment Notes (optional)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancel',
                      style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text('Approve',
                      style: AppTextStyles.bodyBold(color: Colors.white)),
                ),
              ],
            ),
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

  return QuotationApproveRequest(
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
}