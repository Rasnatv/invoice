import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';

class QuotationExportService {
  static final _money =
  NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);
  static final _num = NumberFormat.decimalPattern('en_IN');

  static String _date(QuotationDetailModel q) =>
      q.date != null ? DateFormat('dd-MM-yyyy').format(q.date!) : q.dateRaw;

  static String _fileName(QuotationDetailModel q, String ext) {
    final safe = q.quotationNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    return 'Quotation_$safe.$ext';
  }

  // ------------------------------------------------------------------
  // PDF
  // ------------------------------------------------------------------
  static Future<void> sharePdf(QuotationDetailModel q,
      {required bool showIncentive}) async {
    final doc = pw.Document();

    final hasCompany = q.items.any((i) => i.companyName.trim().isNotEmpty);
    final hasMrp = q.items.any((i) => i.mrp > 0);
    final hasBox = q.items.any((i) => i.boxQuantity > 0);
    final hasPiece = q.items.any((i) => i.pieceQuantity > 0);

    final headers = <String>[
      'Sl.No',
      'Item',
      if (hasCompany) 'Company',
      'Size',
      'Qty',
      'Unit',
      if (hasBox) 'Box Qty',
      if (hasPiece) 'Piece Qty',
      if (hasMrp) 'MRP',
      'Rate',
      'Amount',
      if (showIncentive) 'Incentive',
    ];

    final data = <List<String>>[];
    for (var i = 0; i < q.items.length; i++) {
      final it = q.items[i];
      data.add([
        '${i + 1}',
        it.productName,
        if (hasCompany) it.companyName.isEmpty ? '-' : it.companyName,
        it.productSize.isEmpty ? '-' : it.productSize,
        _num.format(it.quantity),
        it.productUnit,
        if (hasBox) it.boxQuantity > 0 ? _num.format(it.boxQuantity) : '-',
        if (hasPiece) it.pieceQuantity > 0 ? _num.format(it.pieceQuantity) : '-',
        if (hasMrp) it.mrp > 0 ? _num.format(it.mrp) : '-',
        _num.format(it.rate),
        _money.format(it.amount),
        if (showIncentive)
          it.isIncentiveEligible ? _money.format(it.incentiveAmount) : '-',
      ]);
    }

    // Total row
    final totalQty = q.items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmt = q.items.fold<double>(0, (s, i) => s + i.amount);
    final totalInc = q.items.fold<double>(0, (s, i) => s + i.incentiveAmount);
    final totalRow = List<String>.filled(headers.length, '');
    totalRow[1] = 'Total';
    totalRow[headers.indexOf('Qty')] = _num.format(totalQty);
    totalRow[headers.indexOf('Amount')] = _money.format(totalAmt);
    if (showIncentive) totalRow[headers.indexOf('Incentive')] = _money.format(totalInc);
    data.add(totalRow);

    pw.Widget kv(String k, String v, {bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(k,
              style: pw.TextStyle(
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(v,
              style: pw.TextStyle(
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('QUOTATION',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('No: ${q.quotationNumber}'),
                pw.Text('Date: ${_date(q)}'),
                pw.Text('Status: ${q.status}'),
              ]),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Customer',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(q.customer.name),
                pw.Text(q.customer.address),
                pw.Text(q.customer.phone),
              ]),
            ),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Contractor',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(q.contractor.name),
                pw.Text(q.contractor.mobile),
              ]),
            ),
          ]),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            cellAlignments: {
              for (var c = 0; c < headers.length; c++)
                c: (headers[c] == 'Item' || headers[c] == 'Company')
                    ? pw.Alignment.centerLeft
                    : pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 14),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 260,
              child: pw.Column(children: [
                kv('Total Sqft', _num.format(q.totalSquareFeet)),
                kv('Subtotal', _money.format(q.subtotal)),
                kv('Handling Charge', _money.format(q.handlingCharge)),
                if (q.hasDiscount) ...[
                  kv('Total Before Discount', _money.format(q.grandTotal)),
                  kv(q.discountLabel, '- ${_money.format(q.discountAmount)}'),
                ],
                pw.Divider(),
                kv('Grand Total', _money.format(q.amountAfterDiscount), bold: true),
                if (q.showPaymentSummary) ...[
                  kv('Total Paid', _money.format(q.totalPaid)),
                  kv('Balance Amount', _money.format(q.balanceAmount), bold: true),
                ],
              ]),
            ),
          ),
          if (q.notes.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Notes: ${q.notes}'),
          ],
        ],
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: _fileName(q, 'pdf'));
  }

  // ------------------------------------------------------------------
  // Excel
  // ------------------------------------------------------------------
  static Future<void> shareExcel(QuotationDetailModel q,
      {required bool showIncentive}) async {
    final excel = Excel.createExcel();
    final sheetName = 'Quotation';
    excel.rename(excel.getDefaultSheet()!, sheetName);
    final sheet = excel[sheetName];

    final bold = CellStyle(bold: true);

    void row(List<CellValue?> cells, {bool isBold = false}) {
      sheet.appendRow(cells);
      if (isBold) {
        final r = sheet.maxRows - 1;
        for (var c = 0; c < cells.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
              .cellStyle = bold;
        }
      }
    }

    row([TextCellValue('QUOTATION')], isBold: true);
    row([TextCellValue('Quotation No.'), TextCellValue(q.quotationNumber)]);
    row([TextCellValue('Date'), TextCellValue(_date(q))]);
    row([TextCellValue('Status'), TextCellValue(q.status)]);
    row([TextCellValue('Customer'), TextCellValue(q.customer.name)]);
    row([TextCellValue('Address'), TextCellValue(q.customer.address)]);
    row([TextCellValue('Phone'), TextCellValue(q.customer.phone)]);
    row([TextCellValue('Contractor'), TextCellValue(q.contractor.name)]);
    row([]);

    final headers = <String>[
      'Sl.No', 'Item', 'Company', 'Size', 'Qty', 'Unit',
      'Box Qty', 'Piece Qty', 'MRP', 'Rate', 'Amount',
      if (showIncentive) 'Incentive',
    ];
    row(headers.map((h) => TextCellValue(h)).toList(), isBold: true);

    for (var i = 0; i < q.items.length; i++) {
      final it = q.items[i];
      row([
        IntCellValue(i + 1),
        TextCellValue(it.productName),
        TextCellValue(it.companyName),
        TextCellValue(it.productSize),
        DoubleCellValue(it.quantity.toDouble()),
        TextCellValue(it.productUnit),
        DoubleCellValue(it.boxQuantity.toDouble()),
        DoubleCellValue(it.pieceQuantity.toDouble()),
        DoubleCellValue(it.mrp.toDouble()),
        DoubleCellValue(it.rate.toDouble()),
        DoubleCellValue(it.amount.toDouble()),
        if (showIncentive) DoubleCellValue(it.incentiveAmount.toDouble()),
      ]);
    }

    final totalQty = q.items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmt = q.items.fold<double>(0, (s, i) => s + i.amount);
    final totalInc = q.items.fold<double>(0, (s, i) => s + i.incentiveAmount);
    row([
      null,
      TextCellValue('Total'),
      null, null,
      DoubleCellValue(totalQty),
      null, null, null, null, null,
      DoubleCellValue(totalAmt),
      if (showIncentive) DoubleCellValue(totalInc),
    ], isBold: true);

    row([]);
    row([TextCellValue('Total Sqft'), DoubleCellValue(q.totalSquareFeet.toDouble())]);
    row([TextCellValue('Subtotal'), DoubleCellValue(q.subtotal.toDouble())]);
    row([TextCellValue('Handling Charge'), DoubleCellValue(q.handlingCharge.toDouble())]);
    if (q.hasDiscount) {
      row([TextCellValue('Total Before Discount'), DoubleCellValue(q.grandTotal.toDouble())]);
      row([TextCellValue(q.discountLabel), DoubleCellValue(-q.discountAmount.toDouble())]);
    }
    row([TextCellValue('Grand Total'), DoubleCellValue(q.amountAfterDiscount.toDouble())],
        isBold: true);
    if (q.showPaymentSummary) {
      row([TextCellValue('Total Paid'), DoubleCellValue(q.totalPaid.toDouble())]);
      row([TextCellValue('Balance Amount'), DoubleCellValue(q.balanceAmount.toDouble())],
          isBold: true);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('Could not generate Excel file');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_fileName(q, 'xlsx')}');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([XFile(file.path)], subject: 'Quotation ${q.quotationNumber}');
  }
}