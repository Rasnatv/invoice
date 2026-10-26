
import 'dart:io';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatedetailscreenwidget.dart';
import 'package:tileshop/ui/salesman/quotation_editscreen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';

import '../../bloc/salemanbloc/salesmancancelquoattion/salesmancancelquotation_bloc.dart';
import '../../bloc/salemanbloc/salesmancancelquoattion/salesmancancelquotation_event.dart';
import '../../bloc/salemanbloc/salesmancancelquoattion/salesmancancelquotation_state.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Noto Sans -> has the ₹ glyph
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Excel export
import 'package:excel/excel.dart' as xls;

const Color _redColor = Color(0xFFDC2626);

class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key, required this.id});

  final String id;

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen>
    with WidgetsBindingObserver {
  late final SalesmanQuotationBloc _bloc;

  // Separate bloc for cancel, owned by this screen.
  final SalesmanCancelQuotationBloc _cancelBloc = SalesmanCancelQuotationBloc();

  // Spinner state while a PDF / Excel is being built and shared.
  bool _isGeneratingPdf = false;
  bool _isGeneratingExcel = false;

  static const _appBarSpinner = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SalesmanQuotationBloc>();
    _bloc.add(QuotationDetailRequested(widget.id));
    // Auto refresh when the app returns to the foreground.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.add(const QuotationDetailCleared());
    _cancelBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only when this screen is the visible one (not while Edit is open).
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      _bloc.add(QuotationDetailRequested(widget.id));
    }
  }

  /// Pull-to-refresh. Waits until loading finishes so the RefreshIndicator
  /// spinner stays visible for the right duration.
  Future<void> _refresh() async {
    _bloc.add(QuotationDetailRequested(widget.id));
    await _bloc.stream
        .firstWhere((s) => s.detailStatus != QuotationLoadStatus.loading)
        .timeout(const Duration(seconds: 20), onTimeout: () => _bloc.state);
  }

  /// Whether the quotation's `created_by` is an Owner, derived straight
  /// from the response. Incentive figures are salesman-facing, so they're
  /// hidden for Owner-created ones.
  bool _isOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  bool _isApproved(QuotationDetailModel q) =>
      q.status.trim().toLowerCase() == 'approved';

  bool _isCancelled(QuotationDetailModel q) =>
      q.status.trim().toLowerCase() == 'cancelled';

  /// Salesman can cancel only after submitting, before approval.
  bool _canCancel(QuotationDetailModel q) =>
      q.status.trim().toLowerCase() == 'send';

  Color _quotationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return _redColor;
      case 'draft':
        return AppColors.textSecondary;
      default:
        return const Color(0xFFF59E0B); // send / submitted / pending
    }
  }

  void _showError(String msg) => AppSnackbar.error(msg);

  void _editQuotation(QuotationDetailModel estimate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _bloc,
          child: QuotationEditScreen(estimate: estimate),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(QuotationDetailModel estimate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete quotation?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will permanently delete ${estimate.quotationNumber.isNotEmpty ? estimate.quotationNumber : 'this quotation'}. This action cannot be undone.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel',
                style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete',
                style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _bloc.add(QuotationDeleteRequested(estimate.id));
    }
  }

  Future<void> _confirmCancel(QuotationDetailModel estimate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel quotation?', style: AppTextStyles.bodyBold()),
        content: Text(
          'Are you sure you want to cancel ${estimate.quotationNumber.isNotEmpty ? estimate.quotationNumber : 'this quotation'}? This cannot be undone.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('No',
                style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Yes, Cancel',
                style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _cancelBloc.add(SalesmanCancelQuotationRequested(estimate.id));
    }
  }

  void _sendForApproval(QuotationDetailModel estimate) {
    _bloc.add(QuotationSubmitForApprovalRequested(estimate.id));
  }

  // ---------------------------------------------------------------------
  // Share helpers (PDF / Excel)
  // ---------------------------------------------------------------------

  static final NumberFormat _money =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  String _safeRef(QuotationDetailModel q) => q.quotationNumber.isNotEmpty
      ? q.quotationNumber.replaceAll(RegExp(r'[^\w\-]'), '_')
      : q.id;

  String _dateText(QuotationDetailModel q) =>
      q.date != null ? DateFormat('dd-MM-yyyy').format(q.date!) : q.dateRaw;

  /// Returns the loaded detail, or shows an error and returns null.
  QuotationDetailModel? _requireDetail() {
    final detail = _bloc.state.detail;
    if (detail == null) {
      AppSnackbar.error('Quotation data not loaded yet');
    }
    return detail;
  }

  /// PDF (no incentive figures).
  Future<void> _sharePdf(QuotationDetailModel q) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final bytes = await _buildPdfBytes(q);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Quotation_${_safeRef(q)}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Quotation - ${q.quotationNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate PDF: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<List<int>> _buildPdfBytes(QuotationDetailModel q) async {
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );

    final approved = _isApproved(q);
    final title = approved ? 'Bill' : 'Quotation Details';
    final hasBoxQty = q.items.any((i) => i.boxQuantity > 0);
    final hasPieceQty = q.items.any((i) => i.pieceQuantity > 0);

    // ---- info block ----
    final pairs = <List<String>>[
      ['Reference No.', q.quotationNumber],
      ['Date', _dateText(q)],
      ['Status', statusLabel(q.status)],
      if (q.salesman.name.isNotEmpty) ['Salesman', q.salesman.name],
      ['Customer Name', q.customer.name],
      ['Customer Phone', q.customer.phone],
      if (q.customer.email.isNotEmpty) ['Customer Email', q.customer.email],
      if (q.contractor.name.isNotEmpty) ['Contractor Name', q.contractor.name],
      if (q.contractor.mobile.isNotEmpty)
        ['Contractor Phone', q.contractor.mobile],
    ];
    final wide = <List<String>>[
      if (q.customer.address.isNotEmpty)
        ['Customer Address', q.customer.address],
      if (q.notes.isNotEmpty) ['Notes', q.notes],
    ];

    pw.Widget infoCell(List<String> r) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(r[0].toUpperCase(),
              style: const pw.TextStyle(
                  fontSize: 7, color: PdfColors.grey600)),
          pw.SizedBox(height: 1.5),
          pw.Text(r[1].isEmpty ? '-' : r[1],
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );

    final infoRows = <pw.Widget>[];
    for (var i = 0; i < pairs.length; i += 2) {
      infoRows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: infoCell(pairs[i])),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: i + 1 < pairs.length
                  ? infoCell(pairs[i + 1])
                  : pw.SizedBox(),
            ),
          ],
        ),
      );
    }
    for (final w in wide) {
      infoRows.add(infoCell(w));
    }

    final infoBlock = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: infoRows,
      ),
    );

    // ---- items table (no incentive column) ----
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
    ];
    final data = <List<String>>[
      for (var i = 0; i < q.items.length; i++)
        [
          '${i + 1}',
          q.items[i].productName.isEmpty ? '-' : q.items[i].productName,
          q.items[i].companyName.isEmpty ? '-' : q.items[i].companyName,
          q.items[i].productSize.isEmpty ? '-' : q.items[i].productSize,
          q.items[i].productUnit.isEmpty ? '-' : q.items[i].productUnit,
          q.items[i].quantity.toStringAsFixed(0),
          if (hasBoxQty)
            q.items[i].boxQuantity > 0
                ? q.items[i].boxQuantity.toStringAsFixed(0)
                : '-',
          if (hasPieceQty)
            q.items[i].pieceQuantity > 0
                ? q.items[i].pieceQuantity.toStringAsFixed(0)
                : '-',
          q.items[i].mrp > 0 ? q.items[i].mrp.toStringAsFixed(0) : '-',
          q.items[i].rate.toStringAsFixed(0),
          _money.format(q.items[i].amount),
        ],
    ];

    final aligns = <int, pw.Alignment>{
      0: pw.Alignment.center,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerLeft,
      3: pw.Alignment.centerLeft,
      4: pw.Alignment.centerLeft,
    };
    final widths = <int, pw.TableColumnWidth>{
      0: const pw.IntrinsicColumnWidth(),
      1: const pw.FlexColumnWidth(),
      2: const pw.FlexColumnWidth(),
      3: const pw.FlexColumnWidth(),
      4: const pw.IntrinsicColumnWidth(),
    };
    for (var c = 5; c < headers.length; c++) {
      aligns[c] = pw.Alignment.centerRight;
      widths[c] = const pw.IntrinsicColumnWidth();
    }

    final itemsTable = pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      columnWidths: widths,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      headerStyle: pw.TextStyle(
          fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      headerAlignments: aligns,
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignments: aligns,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );

    // ---- summary ----
    final showDiscount = approved && q.hasDiscount;
    final showPayment = approved && q.showPaymentSummary;
    final payable = approved ? q.amountAfterDiscount : q.grandTotal;
    final hasBalance = q.balanceAmount > 0;

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
                    fontWeight:
                    bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            pw.SizedBox(width: 14),
            pw.Text(value,
                softWrap: false,
                style: pw.TextStyle(
                    fontSize: size,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
          ],
        ),
      );
    }

    final summary = pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 300,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            line('Total Sq.Ft', q.totalSquareFeet.toStringAsFixed(0)),
            line('Sub Total', _money.format(q.subtotal)),
            line('Handling Charge', _money.format(q.handlingCharge)),
            if (showDiscount) ...[
              line('Total Before Discount', _money.format(q.grandTotal)),
              line(q.discountLabel, '- ${_money.format(q.discountAmount)}',
                  color: PdfColors.red700),
            ],
            pw.Divider(color: PdfColors.grey400, thickness: 0.5, height: 10),
            line('Grand Total', _money.format(payable), bold: true, size: 12),
            if (showPayment) ...[
              line('Total Paid', _money.format(q.totalPaid),
                  color: PdfColors.green800),
              pw.SizedBox(height: 4),
              pw.Container(
                width: double.infinity,
                padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: hasBalance ? PdfColors.red50 : PdfColors.green50,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Balance Due',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 14),
                    pw.Text(
                      _money.format(q.balanceAmount),
                      softWrap: false,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color:
                        hasBalance ? PdfColors.red700 : PdfColors.green800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // ---- payments (approved only) ----
    pw.Widget? paymentsTable;
    if (approved && q.payments.isNotEmpty) {
      const pAligns = <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerLeft,
      };
      paymentsTable = pw.TableHelper.fromTextArray(
        headers: const ['Method', 'Amount', 'Date'],
        data: [
          for (final p in q.payments)
            [
              p.methodLabel.toString().isEmpty
                  ? 'Payment'
                  : p.methodLabel.toString(),
              _money.format(p.amount),
              p.date.toString().isEmpty ? '-' : p.date.toString(),
            ],
        ],
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
        headerAlignments: pAligns,
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignments: pAligns,
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.grey400),
          ],
        ),
        build: (context) => [
          infoBlock,
          pw.SizedBox(height: 18),
          pw.Text('Items',
              style:
              pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          itemsTable,
          pw.SizedBox(height: 14),
          summary,
          if (paymentsTable != null) ...[
            pw.SizedBox(height: 14),
            pw.Text('Payments',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            paymentsTable,
          ],
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _shareExcel(QuotationDetailModel q) async {
    setState(() => _isGeneratingExcel = true);
    try {
      final isOwner = _isOwner(q);
      final approved = _isApproved(q);
      final excelFile = xls.Excel.createExcel();
      const sheetName = 'Quotation';
      final sheet = excelFile[sheetName];
      excelFile.setDefaultSheet(sheetName);

      void addRow(List<dynamic> values) {
        sheet.appendRow(
            values.map((v) => xls.TextCellValue(v.toString())).toList());
      }

      final hasBoxQty = q.items.any((i) => i.boxQuantity > 0);
      final hasPieceQty = q.items.any((i) => i.pieceQuantity > 0);

      addRow(['Quotation Details']);
      addRow([]);
      addRow(['Reference No.', q.quotationNumber]);
      addRow(['Date', _dateText(q)]);
      addRow(['Status', statusLabel(q.status)]);
      addRow(['Customer Name', q.customer.name]);
      addRow(['Customer Phone', q.customer.phone]);
      addRow(['Customer Email', q.customer.email]);
      addRow(['Customer Address', q.customer.address]);
      addRow(['Contractor Name', q.contractor.name]);
      addRow(['Contractor Phone', q.contractor.mobile]);
      if (q.salesman.name.isNotEmpty) addRow(['Salesman', q.salesman.name]);
      if (q.notes.isNotEmpty) addRow(['Notes', q.notes]);
      addRow([]);

      addRow([
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
      ]);
      for (var i = 0; i < q.items.length; i++) {
        final item = q.items[i];
        addRow([
          i + 1,
          item.productName,
          item.companyName.isEmpty ? '-' : item.companyName,
          item.productSize.isEmpty ? '-' : item.productSize,
          item.productUnit.isEmpty ? '-' : item.productUnit,
          item.quantity.toStringAsFixed(0),
          if (hasBoxQty)
            (item.boxQuantity > 0 ? item.boxQuantity.toStringAsFixed(0) : '-'),
          if (hasPieceQty)
            (item.pieceQuantity > 0
                ? item.pieceQuantity.toStringAsFixed(0)
                : '-'),
          item.mrp > 0 ? item.mrp.toStringAsFixed(0) : '-',
          item.rate.toStringAsFixed(0),
          _money.format(item.amount),
          if (!isOwner)
            (item.incentiveAmount > 0
                ? _money.format(item.incentiveAmount)
                : '-'),
        ]);
      }
      addRow([]);

      addRow(['Total Sq.Ft', q.totalSquareFeet.toStringAsFixed(0)]);
      addRow(['Sub Total', _money.format(q.subtotal)]);
      addRow(['Handling Charge', _money.format(q.handlingCharge)]);
      if (approved && q.hasDiscount) {
        addRow(['Total Before Discount', _money.format(q.grandTotal)]);
        addRow([q.discountLabel, '- ${_money.format(q.discountAmount)}']);
        addRow(['Grand Total', _money.format(q.amountAfterDiscount)]);
      } else {
        addRow(['Grand Total', _money.format(q.grandTotal)]);
      }
      if (approved && q.showPaymentSummary) {
        addRow(['Total Paid', _money.format(q.totalPaid)]);
        addRow(['Balance Due', _money.format(q.balanceAmount)]);
      }

      if (approved && q.payments.isNotEmpty) {
        addRow([]);
        addRow(['Payments']);
        addRow(['Method', 'Amount', 'Date']);
        for (final p in q.payments) {
          addRow([
            p.methodLabel.toString().isEmpty
                ? 'Payment'
                : p.methodLabel.toString(),
            _money.format(p.amount),
            p.date.toString().isEmpty ? '-' : p.date.toString(),
          ]);
        }
      }

      final bytes = excelFile.save();
      if (bytes == null) throw Exception('Could not generate Excel file');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Quotation_${_safeRef(q)}.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        text: 'Quotation - ${q.quotationNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate Excel file: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingExcel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    // Approved bills show paise in the totals, like the owner screens.
    final money =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final number = NumberFormat.decimalPattern('en_IN');

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (PDF + Excel share) ----------
        appBar: AppBar(
          title: Text('Quotation Preview', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            // Share as PDF
            IconButton(
              tooltip: 'Share as PDF',
              icon: _isGeneratingPdf
                  ? _appBarSpinner
                  : const Icon(Icons.picture_as_pdf_rounded),
              onPressed: _isGeneratingPdf
                  ? null
                  : () {
                final detail = _requireDetail();
                if (detail != null) _sharePdf(detail);
              },
            ),
            // Share as Excel
            IconButton(
              tooltip: 'Share as Excel',
              icon: _isGeneratingExcel
                  ? _appBarSpinner
                  : const Icon(Icons.grid_on_rounded),
              onPressed: _isGeneratingExcel
                  ? null
                  : () {
                final detail = _requireDetail();
                if (detail != null) _shareExcel(detail);
              },
            ),
          ],
        ),
        body: SafeArea(
          // ---- Cancel listener (separate cancel bloc) ----
          child: BlocListener<SalesmanCancelQuotationBloc,
              SalesmanCancelQuotationState>(
            bloc: _cancelBloc,
            listenWhen: (prev, curr) =>
            prev.status != curr.status &&
                curr.status != SalesmanCancelQuotationStatus.initial,
            listener: (context, state) {
              if (state.status == SalesmanCancelQuotationStatus.success) {
                AppSnackbar.success(state.message ?? 'Quotation cancelled.');
                _cancelBloc.add(const SalesmanCancelQuotationResultConsumed());
                // Reload so the status shows "Cancelled".
                _bloc.add(QuotationDetailRequested(widget.id));
              } else if (state.status ==
                  SalesmanCancelQuotationStatus.failure) {
                _showError(state.errorMessage ?? 'Failed to cancel quotation.');
                _cancelBloc.add(const SalesmanCancelQuotationResultConsumed());
              }
            },
            child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
              // This screen shares SalesmanQuotationBloc with QuotationEditScreen,
              // so only react to submitStatus while this is the visible route.
              listenWhen: (prev, curr) =>
              prev.deleteStatus != curr.deleteStatus ||
                  (prev.submitStatus != curr.submitStatus &&
                      curr.submitStatus != QuotationActionStatus.idle &&
                      ModalRoute.of(context)?.isCurrent == true),
              listener: (context, state) {
                if (state.deleteStatus == QuotationActionStatus.success) {
                  AppSnackbar.success('Quotation deleted.');
                  _bloc.add(const QuotationActionResultConsumed());
                  Navigator.of(context).pop();
                } else if (state.deleteStatus ==
                    QuotationActionStatus.failure) {
                  _showError(
                      state.deleteError ?? 'Failed to delete quotation.');
                  _bloc.add(const QuotationActionResultConsumed());
                } else if (state.submitStatus ==
                    QuotationActionStatus.success) {
                  AppSnackbar.success(
                      state.submitMessage ?? 'Submitted for approval.');
                  _bloc.add(const QuotationActionResultConsumed());
                } else if (state.submitStatus ==
                    QuotationActionStatus.failure) {
                  _showError(
                      state.submitError ?? 'Failed to submit for approval.');
                  _bloc.add(const QuotationActionResultConsumed());
                }
              },
              child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
                buildWhen: (prev, curr) =>
                prev.detailStatus != curr.detailStatus ||
                    prev.detail != curr.detail,
                builder: (context, state) {
                  // ---- loading skeleton ----
                  // Only when there is nothing to show yet. During a refresh
                  // the old data stays on screen.
                  if (state.detail == null &&
                      state.detailStatus != QuotationLoadStatus.failure) {
                    return ShimmerListPlaceholder(
                      itemCount: 5,
                      padding: listPadding,
                      separatorHeight: Responsive.h(10),
                      itemBuilder: (context, i) => const _DetailCardSkeleton(),
                    );
                  }

                  // ---- error ----
                  if (state.detail == null) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refresh,
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints:
                                BoxConstraints(minHeight: constraints.maxHeight),
                                child: _ErrorView(
                                  message: state.detailError ??
                                      'Failed to load quotation.',
                                  onRetry: () => _bloc
                                      .add(QuotationDetailRequested(widget.id)),
                                ),
                              ),
                            ),
                      ),
                    );
                  }

                  final estimate = state.detail!;
                  final isOwner = _isOwner(estimate);
                  final isApproved = _isApproved(estimate);
                  // Only show these columns if at least one item has a value.
                  final hasBoxQty =
                  estimate.items.any((i) => i.boxQuantity > 0);
                  final hasPieceQty =
                  estimate.items.any((i) => i.pieceQuantity > 0);
                  final totalIncentive = estimate.items
                      .fold<double>(0, (s, r) => s + r.incentiveAmount);

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _refresh,
                          child: ListView(
                            // Needed so pull-to-refresh works on short content.
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: listPadding,
                            children: [
                              _QuotationHeader(
                                estimate: estimate,
                                statusColor:
                                _quotationStatusColor(estimate.status),
                              ),
                              SizedBox(height: Responsive.h(14)),
                              if (estimate.notes.isNotEmpty) ...[
                                DetailSection(
                                  title: 'Notes',
                                  icon: Icons.sticky_note_2_outlined,
                                  rows: [
                                    DetailRow('Notes', estimate.notes,
                                        icon: Icons.sticky_note_2_outlined),
                                  ],
                                ),
                                SizedBox(height: Responsive.h(14)),
                              ],
                              DetailSection(
                                title: 'Customer Details',
                                icon: Icons.groups_2_outlined,
                                rows: [
                                  DetailRow('Name', estimate.customer.name,
                                      icon: Icons.groups_2_outlined),
                                  DetailRow('Phone', estimate.customer.phone,
                                      icon: Icons.phone_outlined),
                                  DetailRow('Email', estimate.customer.email,
                                      icon: Icons.email_outlined),
                                  DetailRow(
                                      'Address', estimate.customer.address,
                                      icon: Icons.location_on_outlined),
                                ],
                              ),
                              SizedBox(height: Responsive.h(14)),
                              DetailSection(
                                title: 'Contractor Details',
                                icon: Icons.person_outline,
                                rows: [
                                  DetailRow('Name', estimate.contractor.name,
                                      icon: Icons.person_outline),
                                  DetailRow(
                                      'Phone', estimate.contractor.mobile,
                                      icon: Icons.phone_outlined),
                                  DetailRow('Email', estimate.contractor.email,
                                      icon: Icons.email_outlined),
                                ],
                              ),
                              SizedBox(height: Responsive.h(14)),
                              DetailSection(
                                title: 'Salesman',
                                icon: Icons.badge_outlined,
                                rows: [
                                  DetailRow('Name', estimate.salesman.name,
                                      icon: Icons.badge_outlined),
                                ],
                              ),
                              SizedBox(height: Responsive.h(18)),

                              _InvoiceTable(
                                items: estimate.items,
                                showBox: hasBoxQty,
                                showPiece: hasPieceQty,
                                showIncentive: !isOwner,
                                currency: currency,
                                number: number,
                              ),
                              SizedBox(height: Responsive.h(14)),

                              // Totals. For approved quotations this also shows
                              // discount, total paid and balance.
                              _SummaryCard(
                                q: estimate,
                                fmt: isApproved ? money : currency,
                                number: number,
                                isApproved: isApproved,
                              ),

                              if (isApproved &&
                                  estimate.payments.isNotEmpty) ...[
                                SizedBox(height: Responsive.h(14)),
                                _PaymentsCard(
                                    payments: estimate.payments, money: money),
                              ],

                              if (!isOwner && totalIncentive > 0) ...[
                                SizedBox(height: Responsive.h(14)),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.w(14),
                                      vertical: Responsive.h(14)),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color:
                                        AppColors.success.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconBadge(Icons.percent_rounded,
                                              color: AppColors.success),
                                          SizedBox(width: Responsive.w(10)),
                                          Text('Incentive Total',
                                              style: AppTextStyles.bodyBold(
                                                  color: AppColors.success)),
                                        ],
                                      ),
                                      Text(
                                        currency.format(totalIncentive),
                                        style: AppTextStyles.amount(
                                            color: AppColors.success),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // ---- Bottom action bar ----
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          border:
                          Border(top: BorderSide(color: AppColors.border)),
                        ),
                        padding: EdgeInsets.fromLTRB(
                            Responsive.w(20),
                            Responsive.h(10),
                            Responsive.w(20),
                            Responsive.h(14)),
                        child: BlocBuilder<SalesmanCancelQuotationBloc,
                            SalesmanCancelQuotationState>(
                          bloc: _cancelBloc,
                          builder: (context, cancelState) {
                            final cancelling = cancelState.status ==
                                SalesmanCancelQuotationStatus.inProgress;

                            return BlocBuilder<SalesmanQuotationBloc,
                                SalesmanQuotationState>(
                              buildWhen: (prev, curr) =>
                              prev.deleteStatus != curr.deleteStatus ||
                                  prev.submitStatus != curr.submitStatus,
                              builder: (context, state) {
                                final deleting = state.deleteStatus ==
                                    QuotationActionStatus.inProgress;
                                final submitting = state.submitStatus ==
                                    QuotationActionStatus.inProgress;
                                final busy =
                                    deleting || submitting || cancelling;
                                final buttonShape = RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14));
                                final buttonHeight = Responsive.h(48);

                                // ---- Draft: Edit / Delete / Submit ----
                                if (estimate.isDraft) {
                                  return Row(
                                    children: [
                                      RoundIconButton(
                                        icon: Icons.edit_outlined,
                                        tooltip: 'Edit',
                                        onPressed: busy
                                            ? null
                                            : () => _editQuotation(estimate),
                                      ),
                                      SizedBox(width: Responsive.w(10)),
                                      Expanded(
                                        child: SizedBox(
                                          height: buttonHeight,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _redColor,
                                              side: const BorderSide(
                                                  color: _redColor),
                                              shape: buttonShape,
                                            ),
                                            onPressed: busy
                                                ? null
                                                : () =>
                                                _confirmDelete(estimate),
                                            child: deleting
                                                ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                              CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: _redColor),
                                            )
                                                : Text('Delete',
                                                style:
                                                AppTextStyles.bodyBold(
                                                    color: _redColor)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Responsive.w(10)),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          height: buttonHeight,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: buttonShape,
                                            ),
                                            onPressed: busy
                                                ? null
                                                : () =>
                                                _sendForApproval(estimate),
                                            child: Text(
                                              submitting
                                                  ? 'Submitting…'
                                                  : 'Submit for Approval',
                                              style: AppTextStyles.bodyBold(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                // ---- Submitted ('send'): Cancel button ----
                                if (_canCancel(estimate)) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _redColor,
                                        side:
                                        const BorderSide(color: _redColor),
                                        shape: buttonShape,
                                      ),
                                      onPressed: busy
                                          ? null
                                          : () => _confirmCancel(estimate),
                                      icon: cancelling
                                          ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _redColor),
                                      )
                                          : const Icon(Icons.cancel_outlined,
                                          size: 18),
                                      label: Text(
                                        cancelling
                                            ? 'Cancelling...'
                                            : 'Cancel Quotation',
                                        style: AppTextStyles.bodyBold(
                                            color: _redColor),
                                      ),
                                    ),
                                  );
                                }

                                // ---- Approved / Cancelled / other: info pill ----
                                final cancelled = _isCancelled(estimate);
                                final pillColor = isApproved
                                    ? AppColors.success
                                    : cancelled
                                    ? _redColor
                                    : AppColors.textSecondary;

                                return Container(
                                  width: double.infinity,
                                  constraints:
                                  BoxConstraints(minHeight: buttonHeight),
                                  padding: EdgeInsets.symmetric(
                                      vertical: Responsive.h(10),
                                      horizontal: Responsive.w(14)),
                                  decoration: BoxDecoration(
                                    color: pillColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: pillColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isApproved
                                            ? Icons.check_circle_outline
                                            : cancelled
                                            ? Icons.cancel_outlined
                                            : Icons.lock_outline,
                                        size: 16,
                                        color: pillColor,
                                      ),
                                      SizedBox(width: Responsive.w(8)),
                                      Expanded(
                                        child: Text(
                                          isApproved
                                              ? 'This quotation has been approved.'
                                              : cancelled
                                              ? 'This quotation has been cancelled.'
                                              : 'This quotation has already been submitted and can no longer be edited or deleted.',
                                          textAlign: TextAlign.center,
                                          style: (isApproved || cancelled)
                                              ? AppTextStyles.bodyBold(
                                              color: pillColor)
                                              : AppTextStyles.caption(
                                              color:
                                              AppColors.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// HEADER (same look as the owner estimate header)
// =====================================================================

class _QuotationHeader extends StatelessWidget {
  const _QuotationHeader({required this.estimate, required this.statusColor});
  final QuotationDetailModel estimate;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final dateText = estimate.date != null
        ? DateFormat('dd-MM-yyyy').format(estimate.date!)
        : estimate.dateRaw;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: cardDecoration(),
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
            child: Icon(Icons.request_quote_outlined,
                color: AppColors.primary, size: 20),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estimate.quotationNumber.isEmpty
                      ? '#${estimate.id}'
                      : estimate.quotationNumber,
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
                        style: AppTextStyles.caption(
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          StatusPill(
            label: estimate.status.isEmpty ? '-' : statusLabel(estimate.status),
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SUMMARY CARD
// =====================================================================

/// Not approved: Sq.Ft / Sub Total / Handling Charge / Grand Total.
/// Approved: additionally Total Before Discount + Discount (if any),
/// Grand Total (= amount after discount), Total Paid and a Balance strip.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.q,
    required this.fmt,
    required this.number,
    required this.isApproved,
  });

  final QuotationDetailModel q;
  final NumberFormat fmt;
  final NumberFormat number;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: Responsive.h(10));
    final showDiscount = isApproved && q.hasDiscount;
    final showPayment = isApproved && q.showPaymentSummary;
    final payable = isApproved ? q.amountAfterDiscount : q.grandTotal;
    final hasBalance = q.balanceAmount > 0;
    final balanceColor = hasBalance ? _redColor : AppColors.success;

    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitleBar(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                _SummaryLine('Total Sq.Ft', number.format(q.totalSquareFeet)),
                gap,
                _SummaryLine('Sub Total', fmt.format(q.subtotal)),
                gap,
                _SummaryLine('Handling Charge', fmt.format(q.handlingCharge)),
                if (showDiscount) ...[
                  gap,
                  _SummaryLine(
                      'Total Before Discount', fmt.format(q.grandTotal)),
                  gap,
                  _SummaryLine(
                    q.discountLabel,
                    '- ${fmt.format(q.discountAmount)}',
                    valueColor: _redColor,
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  child: const Divider(height: 1, color: AppColors.border),
                ),
                _SummaryLine(
                  'Grand Total',
                  fmt.format(payable),
                  valueColor: AppColors.primary,
                  large: true,
                ),
                if (showPayment) ...[
                  gap,
                  _SummaryLine('Total Paid', fmt.format(q.totalPaid),
                      valueColor: AppColors.success),
                ],
              ],
            ),
          ),
          // Balance strip: red while money is due, green once fully paid.
          if (showPayment)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(12)),
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.06),
                border: Border(
                    top: BorderSide(color: balanceColor.withOpacity(0.25))),
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
                      Text('Balance Due', style: AppTextStyles.bodyBold()),
                    ],
                  ),
                  Text(fmt.format(q.balanceAmount),
                      style: AppTextStyles.amount(color: balanceColor)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Label + value row. The value scales down instead of overflowing when
/// the amount is very large.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value,
      {this.valueColor, this.large = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final labelStyle = large
        ? AppTextStyles.bodyBold()
        : AppTextStyles.body(color: AppColors.textSecondary);
    final valueStyle = (large
        ? AppTextStyles.amount(color: valueColor ?? AppColors.primary)
        : AppTextStyles.bodyBold(
        color: valueColor ?? AppColors.textPrimary))
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child:
              Text(value, style: valueStyle, maxLines: 1, softWrap: false),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// PAYMENTS CARD
// =====================================================================

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.payments, required this.money});
  final List<dynamic> payments;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final total = payments.fold<double>(0, (s, p) => s + (p.amount as num));

    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitleBar(
            title: 'Payments',
            icon: Icons.payments_outlined,
            trailing: Text(
              '${payments.length} ${payments.length == 1 ? 'entry' : 'entries'}',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ),
          for (var i = 0; i < payments.length; i++) ...[
            Padding(
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
                          payments[i].methodLabel.toString().isEmpty
                              ? 'Payment'
                              : payments[i].methodLabel.toString(),
                          style: AppTextStyles.bodyBold(),
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Text(
                          _subtitle(payments[i]),
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    money.format(payments[i].amount),
                    style: AppTextStyles.bodyBold(color: AppColors.success)
                        .copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i != payments.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
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
                Text(money.format(total),
                    style: AppTextStyles.bodyBold(color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "2026-10-05 · Ref: ABC" (date and reference are both optional).
  String _subtitle(dynamic p) {
    final raw = p.date.toString();
    final parsed = DateTime.tryParse(raw);
    final dateText =
    parsed != null ? DateFormat('yyyy-MM-dd').format(parsed) : raw;
    final ref = p.reference.toString();
    final parts = <String>[
      if (dateText.isNotEmpty) dateText,
      if (ref.isNotEmpty) 'Ref: $ref',
    ];
    return parts.isEmpty ? '-' : parts.join(' · ');
  }
}

/// White card header row (icon badge + title) with a divider underneath.
class _CardTitleBar extends StatelessWidget {
  const _CardTitleBar({required this.title, this.icon, this.trailing});
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
            IconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// =====================================================================
// ITEMS TABLE (same look as the owner items table)
// =====================================================================

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({
    required this.items,
    required this.showBox,
    required this.showPiece,
    required this.showIncentive,
    required this.currency,
    required this.number,
  });

  final List<QuotationDetailItem> items;
  final bool showBox, showPiece, showIncentive;
  final NumberFormat currency;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    // label, width, alignment (same column order as the owner table)
    final cols = <(String, double, TextAlign)>[
      ('Sl.No', EstCol.sl, TextAlign.center),
      ('Item', EstCol.text, TextAlign.left),
      ('Company', EstCol.text, TextAlign.left),
      ('Size', EstCol.size, TextAlign.left),
      ('Unit', EstCol.unit, TextAlign.left),
      ('Qty', EstCol.num, TextAlign.right),
      if (showBox) ('Box Qty', EstCol.num, TextAlign.right),
      if (showPiece) ('Piece Qty', EstCol.num, TextAlign.right),
      ('MRP', EstCol.num, TextAlign.right),
      ('Rate', EstCol.num, TextAlign.right),
      ('Amount', EstCol.money, TextAlign.right),
      if (showIncentive) ('Incentive', EstCol.money, TextAlign.right),
    ];

    final amountCol = cols.indexWhere((c) => c.$1 == 'Amount');
    final qtyCol = cols.indexWhere((c) => c.$1 == 'Qty');
    final incentiveCol = cols.indexWhere((c) => c.$1 == 'Incentive');

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(
        0, (s, i) => s + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));

    final cellFont = Responsive.sp(12.5);

    Alignment alignOf(int c) => switch (cols[c].$3) {
      TextAlign.right => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      _ => Alignment.centerLeft,
    };

    // Header stays on one line so every header looks the same.
    Widget headerCell(int c) => Container(
      alignment: alignOf(c),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(12)),
      child: Text(
        cols[c].$1,
        textAlign: cols[c].$3,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyBold(color: AppColors.primary)
            .copyWith(fontSize: cellFont),
      ),
    );

    // Data cells are capped at two lines with an ellipsis.
    Widget dataCell(String text, int c, {bool bold = false, Color? color}) =>
        Container(
          alignment: alignOf(c),
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(10), vertical: Responsive.h(10)),
          child: Text(
            text,
            textAlign: cols[c].$3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
                .copyWith(
              color: color,
              fontSize: cellFont,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    TableRow itemRow(int i, QuotationDetailItem it) {
      final values = <String>[
        '${i + 1}',
        it.productName.isEmpty ? '-' : it.productName,
        it.companyName.isNotEmpty ? it.companyName : '-',
        it.productSize.isEmpty ? '-' : it.productSize,
        it.productUnit.isEmpty ? '-' : it.productUnit,
        number.format(it.quantity),
        if (showBox) it.boxQuantity > 0 ? number.format(it.boxQuantity) : '-',
        if (showPiece)
          it.pieceQuantity > 0 ? number.format(it.pieceQuantity) : '-',
        it.mrp > 0 ? currency.format(it.mrp) : '-',
        number.format(it.rate),
        currency.format(it.amount),
        if (showIncentive)
          it.incentiveAmount > 0 ? currency.format(it.incentiveAmount) : '-',
      ];
      return TableRow(
        decoration: BoxDecoration(
          color: i.isEven ? Colors.white : AppColors.background,
        ),
        children: [
          for (var c = 0; c < values.length; c++)
            dataCell(
              values[c],
              c,
              bold: c == 1 ||
                  c == amountCol ||
                  (showIncentive && c == incentiveCol),
              color: (showIncentive && c == incentiveCol)
                  ? AppColors.success
                  : null,
            ),
        ],
      );
    }

    TableRow totalRow() {
      final values = List<String>.filled(cols.length, '');
      values[1] = 'Total';
      values[qtyCol] = number.format(totalQty);
      values[amountCol] = currency.format(totalAmount);
      if (showIncentive) values[incentiveCol] = currency.format(totalIncentive);
      return TableRow(
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06)),
        children: [
          for (var c = 0; c < values.length; c++)
            dataCell(
              values[c],
              c,
              bold: true,
              color: c == amountCol
                  ? AppColors.primary
                  : (showIncentive && c == incentiveCol)
                  ? AppColors.success
                  : null,
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const EstimateSectionHeader('Items'),
            StatusPill(
              label: '${items.length} ${items.length == 1 ? 'item' : 'items'}',
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: Responsive.h(10)),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(18)),
            decoration: cardDecoration(),
            child: Text('No items on this quotation.',
                style: AppTextStyles.caption(color: AppColors.textSecondary)),
          )
        else ...[
          Container(
            decoration: cardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder(
                  horizontalInside:
                  BorderSide(color: AppColors.border.withOpacity(0.6)),
                  verticalInside:
                  BorderSide(color: AppColors.border.withOpacity(0.4)),
                ),
                columnWidths: {
                  for (var c = 0; c < cols.length; c++)
                    c: FixedColumnWidth(cols[c].$2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08)),
                    children: [
                      for (var c = 0; c < cols.length; c++) headerCell(c)
                    ],
                  ),
                  for (var i = 0; i < items.length; i++) itemRow(i, items[i]),
                  totalRow(),
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
      ],
    );
  }
}

// =====================================================================
// ERROR / SKELETON (same as owner screen)
// =====================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
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

class _DetailCardSkeleton extends StatelessWidget {
  const _DetailCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 13),
          SizedBox(height: 10),
          ShimmerBox(width: 200, height: 11),
          SizedBox(height: 10),
          ShimmerBox(width: 160, height: 11),
        ],
      ),
    );
  }
}