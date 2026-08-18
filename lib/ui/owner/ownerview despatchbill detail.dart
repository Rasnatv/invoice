import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail_bloc.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail_event.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail_state.dart';
import '../../models/owner_models/owner_despatchdetailmodel.dart';
import '../../widgets/signature_capturesheet.dart';

class OwnerDispatchDetailScreen extends StatelessWidget {
  const OwnerDispatchDetailScreen({super.key, required this.dispatchId});

  final String dispatchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DispatchDetailBloc(DispatchProvider())..add(FetchDispatchDetail(dispatchId)),
      child: _OwnerDispatchDetailView(dispatchId: dispatchId),
    );
  }
}

class _OwnerDispatchDetailView extends StatelessWidget {
  const _OwnerDispatchDetailView({required this.dispatchId});
  final String dispatchId;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocConsumer<DispatchDetailBloc, DispatchDetailState>(
      listenWhen: (previous, current) =>
      current.errorMessage != null && current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        final dispatch = state.dispatch;

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
          body: _buildBody(context, state),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------

  Widget _buildBody(BuildContext context, DispatchDetailState state) {
    if (state.status == DispatchDetailStatus.loading || state.status == DispatchDetailStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.dispatch == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
              SizedBox(height: Responsive.h(10)),
              Text(
                state.errorMessage ?? 'This dispatch bill is no longer available',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(),
              ),
              SizedBox(height: Responsive.h(14)),
              ElevatedButton(
                onPressed: () => context.read<DispatchDetailBloc>().add(FetchDispatchDetail(dispatchId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final dispatch = state.dispatch!;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    final busy = state.status == DispatchDetailStatus.actionInProgress;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(Responsive.w(18)),
        children: [
          _StatusBanner(dispatch: dispatch, dateFmt: dateFmt),
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
                _infoRow('Party Name', dispatch.partyName),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Contact Number', dispatch.contactNumber),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Delivery Address', dispatch.deliveryAddress),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Driver Name', dispatch.driverName),
                SizedBox(height: Responsive.h(6)),
                _infoRow('Vehicle Number', dispatch.vehicleNumber),
                SizedBox(height: Responsive.h(6)),
                _infoRow(
                  'Despatched At',
                  dispatch.despatchedAt != null ? dateFmt.format(dispatch.despatchedAt!) : '-',
                ),
                if (dispatch.deliveryNotes.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(6)),
                  _infoRow('Delivery Notes', dispatch.deliveryNotes),
                ],
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
                      SizedBox(width: 20, child: Text('#', style: AppTextStyles.captionnew())),
                      Expanded(flex: 3, child: Text('Item', style: AppTextStyles.captionnew())),
                      Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
                      Expanded(flex: 2, child: Text('Packing', style: AppTextStyles.captionnew())),
                      SizedBox(width: 40, child: Text('Box', style: AppTextStyles.captionnew())),
                      SizedBox(width: 40, child: Text('Pcs', style: AppTextStyles.captionnew())),
                    ],
                  ),
                ),
                for (var i = 0; i < dispatch.items.length; i++)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                    child: Row(
                      children: [
                        SizedBox(width: 20, child: Text('${i + 1}', style: AppTextStyles.body())),
                        Expanded(
                          flex: 3,
                          child: Text(dispatch.items[i].productName,
                              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(dispatch.items[i].productSize,
                              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(dispatch.items[i].packing,
                              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: 40, child: Text(_num(dispatch.items[i].boxes), style: AppTextStyles.body())),
                        SizedBox(width: 40, child: Text(_num(dispatch.items[i].pieces), style: AppTextStyles.body())),
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
                currency.format(dispatch.grandTotal),
                style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(20)),
          _SignatureSection(dispatch: dispatch),
          SizedBox(height: Responsive.h(24)),
          _ActionSection(dispatch: dispatch, busy: busy),
          SizedBox(height: Responsive.h(12)),
        ],
      ),
    );
  }

  static String _num(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Menu actions: PDF / Excel / WhatsApp / Share (unchanged from the
  // original, wired to the real DispatchDetail model).
  // ---------------------------------------------------------------------

  Future<void> _handleMenuAction(BuildContext context, String value, DispatchDetail dispatch) async {
    switch (value) {
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

  Future<Uint8List> _buildPdfBytes(DispatchDetail dispatch) async {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pwContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dispatch Details', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                dispatch.isDelivered
                    ? 'Delivered on ${dispatch.deliveredAt != null ? dateFmt.format(dispatch.deliveredAt!) : '-'}'
                    : dispatch.isInTransit
                    ? 'In transit'
                    : 'Pending despatch',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(),
              _pdfInfoRow('DS Number', dispatch.dsNumber),
              _pdfInfoRow('Ref. No.', dispatch.refNo),
              _pdfInfoRow('Party Name', dispatch.partyName),
              _pdfInfoRow('Contact Number', dispatch.contactNumber),
              _pdfInfoRow('Delivery Address', dispatch.deliveryAddress),
              _pdfInfoRow('Driver Name', dispatch.driverName),
              _pdfInfoRow('Vehicle Number', dispatch.vehicleNumber),
              _pdfInfoRow(
                'Despatched At',
                dispatch.despatchedAt != null ? dateFmt.format(dispatch.despatchedAt!) : '-',
              ),
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
                      _pdfCell('Size', header: true),
                      _pdfCell('Packing', header: true),
                      _pdfCell('Box', header: true),
                      _pdfCell('Pcs', header: true),
                    ],
                  ),
                  for (var i = 0; i < dispatch.items.length; i++)
                    pw.TableRow(
                      children: [
                        _pdfCell('${i + 1}'),
                        _pdfCell(dispatch.items[i].productName),
                        _pdfCell(dispatch.items[i].productSize),
                        _pdfCell(dispatch.items[i].packing),
                        _pdfCell(_num(dispatch.items[i].boxes)),
                        _pdfCell(_num(dispatch.items[i].pieces)),
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
                    currency.format(dispatch.grandTotal),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                children: [
                  pw.Expanded(child: _pdfSignatureBlock('Customer Signature', dispatch.customerSignature)),
                  pw.SizedBox(width: 20),
                  pw.Expanded(child: _pdfSignatureBlock('Driver Signature', dispatch.driverSignature)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfSignatureBlock(String label, String? base64Signature) {
    pw.Widget content = pw.SizedBox(height: 50);
    if (base64Signature != null && base64Signature.contains(',')) {
      try {
        final bytes = base64Decode(base64Signature.split(',').last);
        content = pw.Image(pw.MemoryImage(bytes), height: 50, fit: pw.BoxFit.contain);
      } catch (_) {
        // Keep the blank placeholder if decoding fails.
      }
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 50,
          width: double.infinity,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
          child: content,
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
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
            child: pw.Text(value.isEmpty ? '-' : value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
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

  Future<void> _exportPdf(BuildContext context, DispatchDetail dispatch) async {
    try {
      final bytes = await _buildPdfBytes(dispatch);
      final file = await _savePdfToFile(bytes, 'Dispatch_${dispatch.dsNumber}.pdf');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF exported')));
      }
      await Share.shareXFiles([XFile(file.path)], text: 'Dispatch ${dispatch.dsNumber}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
      }
    }
  }

  Future<void> _exportExcel(BuildContext context, DispatchDetail dispatch) async {
    try {
      final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
      final workbook = Excel.createExcel();
      const sheetName = 'Dispatch';
      final sheet = workbook[sheetName];
      workbook.setDefaultSheet(sheetName);

      void addInfoRow(String label, String value) {
        sheet.appendRow([TextCellValue(label), TextCellValue(value.isEmpty ? '-' : value)]);
      }

      addInfoRow('DS Number', dispatch.dsNumber);
      addInfoRow('Ref. No.', dispatch.refNo);
      addInfoRow('Party Name', dispatch.partyName);
      addInfoRow('Contact Number', dispatch.contactNumber);
      addInfoRow('Delivery Address', dispatch.deliveryAddress);
      addInfoRow('Driver Name', dispatch.driverName);
      addInfoRow('Vehicle Number', dispatch.vehicleNumber);
      addInfoRow('Despatched At', dispatch.despatchedAt != null ? dateFmt.format(dispatch.despatchedAt!) : '-');
      addInfoRow('Status', dispatch.status);

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([
        TextCellValue('#'),
        TextCellValue('Item'),
        TextCellValue('Size'),
        TextCellValue('Packing'),
        TextCellValue('Box'),
        TextCellValue('Pcs'),
      ]);

      for (var i = 0; i < dispatch.items.length; i++) {
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(dispatch.items[i].productName),
          TextCellValue(dispatch.items[i].productSize),
          TextCellValue(dispatch.items[i].packing),
          TextCellValue(_num(dispatch.items[i].boxes)),
          TextCellValue(_num(dispatch.items[i].pieces)),
        ]);
      }

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([TextCellValue('Grand Total'), TextCellValue(dispatch.grandTotal.toString())]);

      final bytes = workbook.save();
      if (bytes == null) throw Exception('Could not generate Excel file');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Dispatch_${dispatch.dsNumber}.xlsx');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excel exported')));
      }
      await Share.shareXFiles([XFile(file.path)], text: 'Dispatch ${dispatch.dsNumber}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export Excel: $e')));
      }
    }
  }

  String _buildSummaryText(DispatchDetail dispatch) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    final buffer = StringBuffer()
      ..writeln('Dispatch ${dispatch.dsNumber}')
      ..writeln('Party: ${dispatch.partyName}')
      ..writeln('Address: ${dispatch.deliveryAddress}')
      ..writeln('Despatched At: ${dispatch.despatchedAt != null ? dateFmt.format(dispatch.despatchedAt!) : '-'}')
      ..writeln('Driver: ${dispatch.driverName}')
      ..writeln('Grand Total: ${currency.format(dispatch.grandTotal)}')
      ..writeln('Status: ${dispatch.status}');

    return buffer.toString();
  }

  Future<void> _shareDispatch(BuildContext context, DispatchDetail dispatch) async {
    await Share.share(_buildSummaryText(dispatch), subject: 'Dispatch ${dispatch.dsNumber}');
  }

  Future<void> _shareViaWhatsApp(BuildContext context, String text) async {
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('https://wa.me/?text=$encoded');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WhatsApp: $e')));
      }
    }
  }
}

// =============================================================================
// Status banner
// =============================================================================

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.dispatch, required this.dateFmt});
  final DispatchDetail dispatch;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;

    if (dispatch.isDelivered) {
      color = AppColors.info;
      icon = Icons.check_circle_rounded;
      label = 'Delivered on ${dispatch.deliveredAt != null ? dateFmt.format(dispatch.deliveredAt!) : '-'}';
    } else if (dispatch.isInTransit) {
      color = AppColors.primary;
      icon = Icons.local_shipping_rounded;
      label = 'In transit${dispatch.despatchedAt != null ? ' since ${dateFmt.format(dispatch.despatchedAt!)}' : ''}';
    } else {
      color = AppColors.warning;
      icon = Icons.schedule_rounded;
      label = 'Pending despatch';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5))),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Signature section — blank boxes until delivered, then shows the actual
// captured signatures returned by the API.
// =============================================================================

class _SignatureSection extends StatelessWidget {
  const _SignatureSection({required this.dispatch});
  final DispatchDetail dispatch;

  Widget _block(String label, String? base64Signature) {
    Uint8List? bytes;
    if (base64Signature != null && base64Signature.contains(',')) {
      try {
        bytes = base64Decode(base64Signature.split(',').last);
      } catch (_) {
        bytes = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 70,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: bytes != null
              ? Image.memory(bytes, fit: BoxFit.contain)
              : Icon(Icons.draw_outlined, color: AppColors.border, size: 20),
        ),
        SizedBox(height: Responsive.h(6)),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _block('Customer Signature', dispatch.customerSignature)),
        SizedBox(width: Responsive.w(12)),
        Expanded(child: _block('Driver Signature', dispatch.driverSignature)),
      ],
    );
  }
}

// =============================================================================
// Action section — drives the pending -> in_transit -> delivered flow.
// =============================================================================

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.dispatch, required this.busy});
  final DispatchDetail dispatch;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (dispatch.isDelivered) {
      // Terminal state — nothing more to do here.
      return const SizedBox.shrink();
    }

    if (dispatch.isPending) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: busy ? null : () => _confirmMarkInTransit(context),
          icon: busy
              ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.local_shipping_outlined),
          label: Text(busy ? 'Marking as in transit...' : 'Mark as In Transit'),
        ),
      );
    }

    // in_transit -> the only remaining step is delivery.
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: busy ? null : () => _openMarkDelivered(context),
        icon: busy
            ? const SizedBox(
            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_circle_outline),
        label: Text(busy ? 'Marking as delivered...' : 'Mark as Delivered'),
      ),
    );
  }

  Future<void> _confirmMarkInTransit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as In Transit?'),
        content: Text('This will mark dispatch ${dispatch.dsNumber} as in transit.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<DispatchDetailBloc>().add(MarkInTransitRequested(dispatch.id));
    }
  }

  Future<void> _openMarkDelivered(BuildContext context) async {
    final bloc = context.read<DispatchDetailBloc>();
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SignatureCaptureSheet(dsNumber: dispatch.dsNumber),
    );

    if (result != null) {
      bloc.add(MarkDeliveredRequested(
        dispatchId: dispatch.id,
        customerSignatureBase64: result['customer']!,
        driverSignatureBase64: result['driver']!,
      ));
    }
  }
}
