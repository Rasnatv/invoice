import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_models/owner_quotationapprovemodel.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';

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
    final button = InkWell(
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
  const DetailSection({required this.title, required this.rows});
  final String title;
  final List<DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
          SizedBox(height: Responsive.h(10)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                SizedBox(
                  width: r.icon != null ? 88 : 100,
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
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('No items on this quotation.', style: AppTextStyles.caption()),
      );
    }

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(0, (s, i) => s + i.incentiveAmount);

    // Text columns: fixed width (can wrap).
    // Numeric columns: IntrinsicColumnWidth -> grow to fit the value, one line.
    const numCol = IntrinsicColumnWidth();
    final widths = <int, TableColumnWidth>{};
    var col = 0;
    widths[col++] = const FixedColumnWidth(50); // Sl.No
    widths[col++] = const FixedColumnWidth(150); // Item
    if (showCompany) widths[col++] = const FixedColumnWidth(120); // Company
    widths[col++] = const FixedColumnWidth(90); // Size
    widths[col++] = numCol; // Qty
    widths[col++] = const FixedColumnWidth(95); // Unit
    if (showBox) widths[col++] = numCol; // Box Qty
    if (showPiece) widths[col++] = numCol; // Piece Qty
    if (showMrp) widths[col++] = numCol; // MRP
    widths[col++] = numCol; // Rate
    widths[col++] = numCol; // Amount
    if (showIncentive) widths[col++] = numCol; // Incentive

    return Container(
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
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: widths,
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
                      : AppColors.surfaceAlt.withOpacity(0.4),
                ),
                children: [
                  dataCell('${i + 1}', align: TextAlign.center),
                  dataCell(items[i].productName.isEmpty ? '-' : items[i].productName),
                  if (showCompany)
                    dataCell(items[i].companyName.isEmpty ? '-' : items[i].companyName),
                  dataCell(items[i].productSize.isEmpty ? '-' : items[i].productSize),
                  dataCell(number.format(items[i].quantity), align: TextAlign.right),
                  dataCell(items[i].productUnit.isEmpty ? '-' : items[i].productUnit),
                  if (showBox)
                    dataCell(
                      items[i].boxQuantity > 0 ? number.format(items[i].boxQuantity) : '-',
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
                color: AppColors.primary.withOpacity(0.06),
                border: Border(
                  top: BorderSide(
                      color: AppColors.primary.withOpacity(0.3), width: 1.2),
                ),
              ),
              children: [
                dataCell(''),
                dataCell('Total', bold: true),
                if (showCompany) dataCell(''),
                dataCell(''),
                dataCell(number.format(totalQty), align: TextAlign.right, bold: true),
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
    );
  }

  Widget headerCell(String text, {TextAlign align = TextAlign.left}) {
    final isNumeric = align == TextAlign.right;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(8), vertical: Responsive.h(10)),
      child: Text(
        text,
        textAlign: align,
        maxLines: isNumeric ? 1 : 2,
        softWrap: !isNumeric,
        overflow: isNumeric ? TextOverflow.visible : TextOverflow.ellipsis,
        style: AppTextStyles.captionnew().copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
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
    final isNumeric = align == TextAlign.right;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(8), vertical: Responsive.h(9)),
      child: Text(
        text,
        textAlign: align,
        maxLines: isNumeric ? 1 : 3,
        softWrap: !isNumeric, // numbers always stay on one line
        overflow: isNumeric ? TextOverflow.visible : TextOverflow.ellipsis,
        style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
            .copyWith(color: color),
      ),
    );
  }
}


// ---------------------------------------------------------------------
// Helper functions
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body()),
          Text(
            value,
            style: base.copyWith(color: color, fontSize: size > 0 ? size : null),
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
    final valueStyle = (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
        .copyWith(color: valueColor);
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
///   [Total Before Discount / Discount / Grand Total]  (only if a discount exists)
///   [Total Paid]                                      (only once payments are tracked)
///   ── Balance Amount band                            (only once payments are tracked)
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
    final gap = SizedBox(height: Responsive.h(6));
    final balanceColor = q.balanceAmount > 0 ? Colors.red : AppColors.success;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
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
                  gap,
                  TotalRow(
                    'Grand Total',
                    money.format(q.amountAfterDiscount),
                    bold: true,
                  ),
                ],
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
              color: balanceColor.withValues(alpha: 0.06),
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text('Balance Amount',
                              style: AppTextStyles.h3(), overflow: TextOverflow.ellipsis),
                        ),
                        if (q.balanceStatus.isNotEmpty) ...[
                          SizedBox(width: Responsive.w(8)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: balanceStatusColor(q.balanceStatus).withValues(alpha: 0.12),
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

/// "Payments" card listing each payment: method, amount · date (+ reference).
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
    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
              ),
              SizedBox(width: Responsive.w(10)),
              Text('Payments', style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          ...q.payments.map((p) {
            final parsed = DateTime.tryParse(p.date);
            final dateText = parsed != null
                ? DateFormat('yyyy-MM-dd').format(parsed)
                : p.date;

            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.h(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                  SizedBox(
                    width: 96,
                    child: Text(p.methodLabel, style: AppTextStyles.caption()),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText.isEmpty
                              ? money.format(p.amount)
                              : '${money.format(p.amount)} · $dateText',
                          style: AppTextStyles.bodyBold(),
                        ),
                        if (p.reference.isNotEmpty)
                          Text('Ref: ${p.reference}', style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Approve dialog
// ---------------------------------------------------------------------

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Approve Quotation'),
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
                        decoration: const InputDecoration(
                          labelText: 'Handling Charge (optional)',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      // ---- Discount ----
                      const SizedBox(height: 16),
                      const Text('Discount', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: discountType,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
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
                          decoration: InputDecoration(
                            labelText:
                            discountType == 'percentage' ? 'Discount %' : 'Discount Amount',
                            prefixText: discountType == 'fixed' ? '₹ ' : null,
                            suffixText: discountType == 'percentage' ? '%' : null,
                            border: const OutlineInputBorder(),
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
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
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
                            const Divider(height: 14),
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
                      const SizedBox(height: 16),
                      const Text('Initial Payment (optional)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: paymentAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Amount Received',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
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
                                color: preview.balance > 0 ? Colors.red : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Payment Reference (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
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
                          decoration: const InputDecoration(
                            labelText: 'Payment Date (optional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(paymentDate == null
                              ? 'Select date'
                              : DateFormat('yyyy-MM-dd').format(paymentDate!)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentNotesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Payment Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
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