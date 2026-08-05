
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'cubit/dummymodel.dart';


class OwnerDispatchDetailScreen extends StatelessWidget {
  const OwnerDispatchDetailScreen({super.key, required this.dispatchId});

  final String dispatchId;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final dispatch = DispatchDummyData.billById(dispatchId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dispatch Details', style: AppTextStyles.h6()),
        actions: dispatch == null
            ? null
            : [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _shareDispatch(context, dispatch),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, value, dispatch),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'update',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Update'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined),
                  title: Text('Export as PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'excel',
                child: ListTile(
                  leading: Icon(Icons.grid_on_outlined),
                  title: Text('Export as Excel'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'whatsapp',
                child: ListTile(
                  leading: Icon(Icons.chat_outlined),
                  title: Text('Share via WhatsApp'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: dispatch == null
          ? Center(
        child: Text('This dispatch bill is no longer available', style: AppTextStyles.body()),
      )
          : _buildBody(dispatch),
    );
  }


  Future<void> _handleMenuAction(BuildContext context, String value, dynamic dispatch) async {
    switch (value) {
      case 'update':
        _navigateToUpdate(context, dispatch);
        break;
      case 'print':
        await _printDispatch(context, dispatch);
        break;
      case 'pdf':
        await _exportPdf(context, dispatch);
        break;
      case 'excel':
        await _exportExcel(context, dispatch);
        break;
      case 'whatsapp':
        await _shareViaWhatsApp(context, _buildSummaryText(dispatch));
        break;
    }
  }

  void _navigateToUpdate(BuildContext context, dynamic dispatch) {
    // Adjust the route name / arguments to match your app's navigation setup.
    Navigator.pushNamed(
      context,
      '/owner-dispatch-update',
      arguments: dispatch.id ?? dispatchId,
    );
  }

  // ---------------------------------------------------------------------
  // PDF generation (shared by Print / Export PDF / Share)
  // ---------------------------------------------------------------------

  Future<dynamic> _buildPdfBytes(dynamic dispatch) async {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    final delivered = dispatch.status.toLowerCase() == 'delivered';

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pwContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dispatch Details',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                delivered
                    ? 'Delivered on ${dispatch.deliveredAt != null ? dateFmt.format(dispatch.deliveredAt!) : '-'}'
                    : 'Pending delivery',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(),
              _pdfInfoRow('DS Number', dispatch.dsNumber),
              _pdfInfoRow('Ref. No.', dispatch.refNo),
              _pdfInfoRow('Party Name', dispatch.contractorName),
              _pdfInfoRow('Contact Number', dispatch.phone),
              _pdfInfoRow('Delivery Address', dispatch.siteAddress),
              _pdfInfoRow('Despatched By', dispatch.despatchedBy),
              _pdfInfoRow('Despatched At', dateFmt.format(dispatch.date)),
              _pdfInfoRow('Driver Name', dispatch.driverName),
              pw.SizedBox(height: 16),
              pw.Text('Items', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(24),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FixedColumnWidth(44),
                  5: pw.FixedColumnWidth(44),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _pdfCell('#', header: true),
                      _pdfCell('Item', header: true),
                      _pdfCell('Company', header: true),
                      _pdfCell('Size', header: true),
                      _pdfCell('Box', header: true),
                      _pdfCell('Pcs', header: true),
                    ],
                  ),
                  for (var i = 0; i < dispatch.items.length; i++)
                    pw.TableRow(
                      children: [
                        _pdfCell('${i + 1}'),
                        _pdfCell(dispatch.items[i].name),
                        _pdfCell(dispatch.items[i].company),
                        _pdfCell(dispatch.items[i].size),
                        _pdfCell(dispatch.items[i].boxes),
                        _pdfCell(dispatch.items[i].pieces),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    currency.format(dispatch.amount),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                height: 50,
                width: double.infinity,
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(value.isEmpty ? '-' : value,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfCell(String text, {bool header = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: header ? 9 : 9.5, fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  Future<File> _savePdfToFile(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _printDispatch(BuildContext context, dynamic dispatch) async {
    final bytes = await _buildPdfBytes(dispatch);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  Future<void> _exportPdf(BuildContext context, dynamic dispatch) async {
    try {
      final bytes = await _buildPdfBytes(dispatch);
      final file = await _savePdfToFile(bytes, 'Dispatch_${dispatch.dsNumber}.pdf');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported')),
        );
      }
      // Opens the native share sheet — WhatsApp will appear here automatically
      // if it's installed on the device, alongside other apps.
      await Share.shareXFiles([XFile(file.path)], text: 'Dispatch ${dispatch.dsNumber}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    }
  }

  // ---------------------------------------------------------------------
  // Excel export
  // ---------------------------------------------------------------------

  Future<void> _exportExcel(BuildContext context, dynamic dispatch) async {
    try {
      final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
      final workbook = Excel.createExcel();
      final sheetName = 'Dispatch';
      final sheet = workbook[sheetName];
      workbook.setDefaultSheet(sheetName);

      void addInfoRow(String label, String value) {
        sheet.appendRow([TextCellValue(label), TextCellValue(value.isEmpty ? '-' : value)]);
      }

      addInfoRow('DS Number', dispatch.dsNumber);
      addInfoRow('Ref. No.', dispatch.refNo);
      addInfoRow('Party Name', dispatch.contractorName);
      addInfoRow('Contact Number', dispatch.phone);
      addInfoRow('Delivery Address', dispatch.siteAddress);
      addInfoRow('Despatched By', dispatch.despatchedBy);
      addInfoRow('Despatched At', dateFmt.format(dispatch.date));
      addInfoRow('Driver Name', dispatch.driverName);
      addInfoRow('Status', dispatch.status);

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([
        TextCellValue('#'),
        TextCellValue('Item'),
        TextCellValue('Company'),
        TextCellValue('Size'),
        TextCellValue('Box'),
        TextCellValue('Pcs'),
      ]);

      for (var i = 0; i < dispatch.items.length; i++) {
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(dispatch.items[i].name),
          TextCellValue(dispatch.items[i].company),
          TextCellValue(dispatch.items[i].size),
          TextCellValue(dispatch.items[i].boxes),
          TextCellValue(dispatch.items[i].pieces),
        ]);
      }

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([TextCellValue('Grand Total'), TextCellValue(dispatch.amount.toString())]);

      final bytes = workbook.save();
      if (bytes == null) throw Exception('Could not generate Excel file');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Dispatch_${dispatch.dsNumber}.xlsx');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel exported')),
        );
      }
      // Opens the native share sheet — WhatsApp will appear here automatically
      // if it's installed on the device, alongside other apps.
      await Share.shareXFiles([XFile(file.path)], text: 'Dispatch ${dispatch.dsNumber}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export Excel: $e')),
        );
      }
    }
  }


  String _buildSummaryText(dynamic dispatch) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    final buffer = StringBuffer()
      ..writeln('Dispatch ${dispatch.dsNumber}')
      ..writeln('Party: ${dispatch.contractorName}')
      ..writeln('Address: ${dispatch.siteAddress}')
      ..writeln('Despatched At: ${dateFmt.format(dispatch.date)}')
      ..writeln('Driver: ${dispatch.driverName}')
      ..writeln('Grand Total: ${currency.format(dispatch.amount)}')
      ..writeln('Status: ${dispatch.status}');

    return buffer.toString();
  }

  Future<void> _shareDispatch(BuildContext context, dynamic dispatch) async {
    await Share.share(_buildSummaryText(dispatch), subject: 'Dispatch ${dispatch.dsNumber}');
  }

  Future<void> _shareViaWhatsApp(BuildContext context, String text) async {
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('https://wa.me/?text=$encoded');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp: $e')),
        );
      }
    }
  }

  Future<void> _shareFileViaWhatsApp(BuildContext context, File file, String text) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
  }


  Widget _buildBody(dispatch) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    final delivered = dispatch.status.toLowerCase() == 'delivered';

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(Responsive.w(18)),
        children: [
          _StatusBanner(delivered: delivered, deliveredAt: dispatch.deliveredAt, dateFmt: dateFmt),
          SizedBox(height: Responsive.h(16)),
          Container(
            padding: EdgeInsets.all(Responsive.w(14)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _infoRow('DS Number', dispatch.dsNumber),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Ref. No.', dispatch.refNo),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Party Name', dispatch.contractorName),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Contact Number', dispatch.phone),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Delivery Address', dispatch.siteAddress),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Despatched By', dispatch.despatchedBy),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Despatched At', dateFmt.format(dispatch.date)),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Driver Name', dispatch.driverName),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(18)),
          Text('Items', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(10)),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  color: AppColors.surfaceAlt,
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                  child: Row(
                    children: [
                      SizedBox(width: 24, child: Text('#', style: AppTextStyles.captionnew())),
                      Expanded(flex: 3, child: Text('Item', style: AppTextStyles.captionnew())),
                      Expanded(flex: 2, child: Text('Company', style: AppTextStyles.captionnew())),
                      Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
                      SizedBox(width: 44, child: Text('Box', style: AppTextStyles.captionnew())),
                      SizedBox(width: 44, child: Text('Pcs', style: AppTextStyles.captionnew())),
                    ],
                  ),
                ),
                for (var i = 0; i < dispatch.items.length; i++)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.body())),
                        Expanded(
                          flex: 3,
                          child: Text(dispatch.items[i].name,
                              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(dispatch.items[i].company,
                              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(dispatch.items[i].size,
                              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: 44, child: Text(dispatch.items[i].boxes, style: AppTextStyles.body())),
                        SizedBox(width: 44, child: Text(dispatch.items[i].pieces, style: AppTextStyles.body())),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: AppTextStyles.bodyBold()),
              Text(
                currency.format(dispatch.amount),
                style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(20)),
          const _SignatureBlock(),
          SizedBox(height: Responsive.h(12)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.delivered, required this.deliveredAt, required this.dateFmt});
  final bool delivered;
  final DateTime? deliveredAt;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final color = delivered ? AppColors.info : AppColors.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(delivered ? Icons.check_circle_rounded : Icons.local_shipping_outlined, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(
              delivered
                  ? 'Delivered on ${deliveredAt != null ? dateFmt.format(deliveredAt!) : '-'}'
                  : 'Pending delivery',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureBlock extends StatelessWidget {
  const _SignatureBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: Responsive.h(6)),
        Text('Customer Signature', style: AppTextStyles.caption()),
      ],
    );
  }
}