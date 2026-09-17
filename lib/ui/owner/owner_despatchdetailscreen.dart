

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail/ownerdespatchdetail_bloc.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail/ownerdespatchdetail_event.dart';
import '../../bloc/ownerbloc/ownerdespatchdetail/ownerdespatchdetail_state.dart';

import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/owner_despatchdetailmodel.dart';
import '../../widgets/appsnackbar.dart';

// PDF generation + native share sheet (WhatsApp, Email, Drive, etc.)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // gives us a Unicode font (Noto Sans) that has the ₹ glyph
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Excel export
import 'package:excel/excel.dart' as xls;

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

class _OwnerDispatchDetailView extends StatefulWidget {
  const _OwnerDispatchDetailView({required this.dispatchId});
  final String dispatchId;

  @override
  State<_OwnerDispatchDetailView> createState() => _OwnerDispatchDetailViewState();
}

class _OwnerDispatchDetailViewState extends State<_OwnerDispatchDetailView> {
  // Signature capture is upload-only now (no draw pad) and optional — the
  // driver can mark a dispatch delivered with either, both, or neither
  // signature attached.
  File? _customerSigFile;
  File? _driverSigFile;
  final _picker = ImagePicker();

  // becomes true once a mark-in-transit / mark-delivered call
  // succeeds. We hand this back to the list screen via Navigator.pop so
  // it knows to re-fetch instead of showing a stale status.
  bool _statusChanged = false;

  // spinner state while the PDF is being built + handed to the share sheet.
  bool _isGeneratingPdf = false;

  // spinner state while the Excel file is being built + shared.
  bool _isGeneratingExcel = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // WillPopScope intercepts BOTH the AppBar back arrow (whose
    // onPressed also calls Navigator.pop below) and the system back
    // gesture/button, making sure _statusChanged is always passed back.
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _statusChanged);
        return false;
      },
      child: NetworkAwareWrapper(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Dispatch Details', style: AppTextStyles.h6()),
            // custom back button so a direct tap also carries the flag.
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, _statusChanged),
            ),
            actions: [
              // Share as PDF -> native share sheet -> WhatsApp/etc.
              IconButton(
                tooltip: 'Share as PDF',
                icon: _isGeneratingPdf
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.picture_as_pdf_rounded),
                onPressed: _isGeneratingPdf
                    ? null
                    : () {
                  final dispatch = context.read<DispatchDetailBloc>().state.dispatch;
                  if (dispatch == null) {
                    AppSnackbar.error('Dispatch data not loaded yet');
                    return;
                  }
                  _generateAndSharePdf(dispatch);
                },
              ),
              // Share as Excel -> native share sheet -> WhatsApp/etc.
              IconButton(
                tooltip: 'Share as Excel',
                icon: _isGeneratingExcel
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.grid_on_rounded),
                onPressed: _isGeneratingExcel
                    ? null
                    : () {
                  final dispatch = context.read<DispatchDetailBloc>().state.dispatch;
                  if (dispatch == null) {
                    AppSnackbar.error('Dispatch data not loaded yet');
                    return;
                  }
                  _generateAndShareExcel(dispatch);
                },
              ),
            ],
          ),
          body: BlocConsumer<DispatchDetailBloc, DispatchDetailState>(
            listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
            listener: (context, state) {
              if (state.actionStatus == DispatchActionStatus.success) {
                _statusChanged = true;
                AppSnackbar.success(state.actionMessage ?? 'Updated successfully');
                setState(() {
                  _customerSigFile = null;
                  _driverSigFile = null;
                });
                context.read<DispatchDetailBloc>().add(const ClearDispatchActionStatus());
              } else if (state.actionStatus == DispatchActionStatus.failure) {
                AppSnackbar.error(state.actionMessage ?? 'Something went wrong');
                context.read<DispatchDetailBloc>().add(const ClearDispatchActionStatus());
              }
            },
            builder: (context, state) {
              if (state.status == DispatchDetailStatus.initial ||
                  state.status == DispatchDetailStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == DispatchDetailStatus.failure && state.dispatch == null) {
                return _ErrorView(
                  message: state.errorMessage ?? 'Failed to load dispatch bill',
                  onRetry: () => context
                      .read<DispatchDetailBloc>()
                      .add(FetchDispatchDetail(widget.dispatchId)),
                );
              }

              final dispatch = state.dispatch!;
              final isActing = state.actionStatus == DispatchActionStatus.inProgress;

              return RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<DispatchDetailBloc>();
                  bloc.add(RefreshDispatchDetail(widget.dispatchId));
                  await bloc.stream.firstWhere(
                        (s) => s.status == DispatchDetailStatus.success || s.status == DispatchDetailStatus.failure,
                  );
                },
                child: ListView(
                  padding: EdgeInsets.all(Responsive.w(18)),
                  children: [
                    _StatusBanner(dispatch: dispatch),
                    SizedBox(height: Responsive.h(16)),
                    _infoCard(dispatch),
                    SizedBox(height: Responsive.h(18)),
                    Text('Items', style: AppTextStyles.h3()),
                    SizedBox(height: Responsive.h(10)),
                    _itemsTable(dispatch),
                    SizedBox(height: Responsive.h(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: AppTextStyles.bodyBold()),
                        Text(
                          _currency(dispatch.grandTotal),
                          style: AppTextStyles.bodyBold(color: AppColors.primary)
                              .copyWith(fontSize: Responsive.sp(16)),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(22)),
                    _actionSection(context, dispatch, isActing),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------- sections ----------

  Widget _infoCard(DispatchDetail d) {
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow('DS Number', d.dsNumber),
          _infoRow('Ref. No.', d.refNo),
          _infoRow('Party Name', d.partyName),
          _infoRow('Contact Number', d.contactNumber),
          _infoRow('Delivery Address', d.deliveryAddress),
          _infoRow('Driver Name', d.driverName),
          // _infoRow('Vehicle Number', d.vehicleNumber),
          if (d.despatchedAt != null) _infoRow('Despatched At', dateFmt.format(d.despatchedAt!)),
          if (d.deliveryNotes.isNotEmpty) _infoRow('Delivery Notes', d.deliveryNotes),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
        ],
      ),
    );
  }

  Widget _itemsTable(DispatchDetail d) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.6)),
            verticalInside: BorderSide(color: AppColors.border.withOpacity(0.6)),
          ),
          // Fixed widths (not Flex) — needed so the table can be wider
          // than the screen and scroll, instead of squeezing text.
          columnWidths: const {
            0: FixedColumnWidth(32),   // #
            1: FixedColumnWidth(160),  // Item
            2: FixedColumnWidth(140),  // Company
            3: FixedColumnWidth(110),  // Size
            4: FixedColumnWidth(50),   // Box
            5: FixedColumnWidth(50),   // Pcs
            6: FixedColumnWidth(60),   // Qty
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppColors.surfaceAlt),
              children: [
                _headerCell('#'),
                _headerCell('Item'),
                _headerCell('Company'),
                _headerCell('Size'),
                _headerCell('Box', align: TextAlign.right),
                _headerCell('Pcs', align: TextAlign.right),
                _headerCell('Qty', align: TextAlign.right),
              ],
            ),
            for (var i = 0; i < d.items.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i.isEven ? AppColors.surface : AppColors.surfaceAlt.withOpacity(0.35),
                ),
                children: [
                  _dataCell('${i + 1}'),
                  _dataCell(d.items[i].productName),
                  _dataCell(d.items[i].companyName.isEmpty ? '-' : d.items[i].companyName),
                  _dataCell(d.items[i].productSize),
                  _dataCell(d.items[i].boxes.toStringAsFixed(0), align: TextAlign.right),
                  _dataCell(d.items[i].pieces.toStringAsFixed(0), align: TextAlign.right),
                  _dataCell(d.items[i].quantity.toStringAsFixed(0), align: TextAlign.right, bold: true),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(9)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // header labels are short, fine as-is
        style: AppTextStyles.captionnew().copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _dataCell(String text, {TextAlign align = TextAlign.left, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(8)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,                 // single line, fixed row height
        softWrap: false,
        overflow: TextOverflow.visible, // don't cut it — table scrolls instead
        style: bold ? AppTextStyles.bodyBold() : AppTextStyles.body(),
      ),
    );
  }
  Widget _actionSection(BuildContext context, DispatchDetail d, bool isActing) {
    if (d.isDelivered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signatures', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(10)),
          _signatureImage('Customer Signature', d.customerSignature),
          SizedBox(height: Responsive.h(14)),
          _signatureImage('Driver Signature', d.driverSignature),
        ],
      );
    }

    if (d.isInTransit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Capture Signatures', style: AppTextStyles.h3()),
          SizedBox(height: Responsive.h(4)),
          Text('Optional — you can mark as delivered without these.',
              style: AppTextStyles.caption()),
          SizedBox(height: Responsive.h(10)),
          _signatureUploadBlock(
            label: 'Customer Signature (optional)',
            file: _customerSigFile,
            onPick: () => _pickSignatureImage(isCustomer: true),
            onClearFile: () => setState(() => _customerSigFile = null),
          ),
          SizedBox(height: Responsive.h(18)),
          _signatureUploadBlock(
            label: 'Driver Signature (optional)',
            file: _driverSigFile,
            onPick: () => _pickSignatureImage(isCustomer: false),
            onClearFile: () => setState(() => _driverSigFile = null),
          ),
          SizedBox(height: Responsive.h(18)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isActing ? null : () => _confirmMarkDelivered(context, d.id),
              child: isActing
                  ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Mark as Delivered'),
            ),
          ),
        ],
      );
    }

    // pending
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActing ? null : () => _confirmMarkInTransit(context, d.id),
        child: isActing
            ? const SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text('Mark as In Transit'),
      ),
    );
  }

  /// Upload-only signature block: shows a picked-image preview, or a tap
  /// target to pick one from the gallery. No drawing option.
  Widget _signatureUploadBlock({
    required String label,
    required File? file,
    required VoidCallback onPick,
    required VoidCallback onClearFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(6)),
        if (file != null)
          _pickedImagePreview(file, onClear: onClearFile)
        else
          _uploadPlaceholder(onTap: onPick),
      ],
    );
  }

  Widget _uploadPlaceholder({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 100,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file_rounded, size: 22),
            SizedBox(height: Responsive.h(4)),
            Text('Tap to upload signature image', style: AppTextStyles.caption()),
          ],
        ),
      ),
    );
  }

  Widget _pickedImagePreview(File file, {required VoidCallback onClear}) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(file, fit: BoxFit.contain),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onClear,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// Renders an already-saved signature. The mark-delivered API now
  /// returns these as plain hosted image URLs (e.g.
  /// "https://.../storage/signatures/xxx.png") rather than base64 data
  /// URIs, so we branch on that; base64 handling stays as a fallback for
  /// any older records that still carry a data URI.
  Widget _signatureImage(String label, String? sigData) {
    Widget content;

    if (sigData == null || sigData.isEmpty) {
      content = _placeholderBox('Not captured');
    } else if (sigData.startsWith('http://') || sigData.startsWith('https://')) {
      content = Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.network(
          sigData,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _placeholderBox('Could not load signature'),
        ),
      );
    } else {
      try {
        final raw = sigData.contains(',') ? sigData.split(',').last : sigData;
        content = Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.memory(base64Decode(raw), fit: BoxFit.contain),
        );
      } catch (_) {
        content = _placeholderBox('Could not load signature');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        SizedBox(height: Responsive.h(6)),
        content,
      ],
    );
  }

  Widget _placeholderBox(String text) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: AppTextStyles.caption()),
    );
  }

  // ---------- actions ----------

  Future<void> _pickSignatureImage({required bool isCustomer}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      if (isCustomer) {
        _customerSigFile = File(picked.path);
      } else {
        _driverSigFile = File(picked.path);
      }
    });
  }

  /// Reads the picked file and returns it as a base64 data URI matching
  /// what the API already accepts (data:image/png;base64,...).
  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    return 'data:image/png;base64,$base64Str';
  }

  void _confirmMarkInTransit(BuildContext context, String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Mark as In Transit?',
      message: 'This confirms the dispatch has left for delivery.',
      confirmText: 'Confirm',
    );
    if (confirmed) {
      context.read<DispatchDetailBloc>().add(MarkInTransitRequested(id));
    }
  }

  /// Signatures are optional — whatever was (or wasn't) uploaded just gets
  /// sent straight through. No blocking validation here anymore.
  Future<void> _confirmMarkDelivered(BuildContext context, String id) async {
    final customerSig = await _fileToBase64(_customerSigFile);
    final driverSig = await _fileToBase64(_driverSigFile);

    if (!context.mounted) return;
    context.read<DispatchDetailBloc>().add(MarkDeliveredRequested(
      id: id,
      customerSignatureBase64: customerSig,
      driverSignatureBase64: driverSig,
    ));
  }

  String _currency(double value) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

  // ---------- PDF export + share ----------

  /// Builds a PDF mirroring the on-screen info card + items table + grand
  /// total, saves it to a temp file, then hands it to the OS share sheet.
  /// WhatsApp shows up there directly (if installed) alongside Email,
  /// Drive, Bluetooth, etc. — no print dialog is shown anywhere in this
  /// flow, this purely shares the generated file.
  Future<void> _generateAndSharePdf(DispatchDetail d) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

      // Noto Sans includes the ₹ glyph, unlike the default Helvetica
      // font — without this the rupee symbol renders as a blank box.
      final baseFont = await PdfGoogleFonts.notoSansRegular();
      final boldFont = await PdfGoogleFonts.notoSansBold();

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dispatch Bill Details',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColors.grey400),
            ],
          ),
          build: (context) => [
            _pdfInfoSection(d, dateFmt),
            pw.SizedBox(height: 18),
            pw.Text('Items', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _pdfItemsTable(d),
            pw.SizedBox(height: 14),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: ${_currency(d.grandTotal)}',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      final safeDs =
      d.dsNumber.isNotEmpty ? d.dsNumber.replaceAll(RegExp(r'[^\w\-]'), '_') : d.id;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Dispatch_$safeDs.pdf');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Dispatch Bill - ${d.dsNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate PDF: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _pdfInfoSection(DispatchDetail d, DateFormat dateFmt) {
    final rows = <List<String>>[
      ['DS Number', d.dsNumber],
      ['Ref. No.', d.refNo],
      ['Party Name', d.partyName],
      ['Contact Number', d.contactNumber],
      ['Delivery Address', d.deliveryAddress],
      ['Driver Name', d.driverName],
      if (d.despatchedAt != null) ['Despatched At', dateFmt.format(d.despatchedAt!)],
      if (d.deliveryNotes.isNotEmpty) ['Delivery Notes', d.deliveryNotes],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows
          .map((r) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 120,
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

  pw.Widget _pdfItemsTable(DispatchDetail d) {
    final headers = ['#', 'Item', 'Company', 'Size', 'Box', 'Pcs', 'Qty'];
    final data = <List<String>>[
      for (var i = 0; i < d.items.length; i++)
        [
          '${i + 1}',
          d.items[i].productName,
          d.items[i].companyName.isEmpty ? '-' : d.items[i].companyName,
          d.items[i].productSize,
          d.items[i].boxes.toStringAsFixed(0),
          d.items[i].pieces.toStringAsFixed(0),
          d.items[i].quantity.toStringAsFixed(0),
        ],
    ];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  // ---------- Excel export + share ----------

  /// Same idea as the PDF flow: build the .xlsx in memory, write it to a
  /// temp file, then hand it straight to the native share sheet. No
  /// separate "share" button — this icon both generates and shares.
  Future<void> _generateAndShareExcel(DispatchDetail d) async {
    setState(() => _isGeneratingExcel = true);
    try {
      final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
      final excelFile = xls.Excel.createExcel();
      final sheetName = 'Dispatch Bill';
      final sheet = excelFile[sheetName];
      excelFile.setDefaultSheet(sheetName);

      void addRow(List<dynamic> values) {
        sheet.appendRow(values.map((v) => xls.TextCellValue(v.toString())).toList());
      }

      addRow(['Dispatch Bill Details']);
      addRow([]);
      addRow(['DS Number', d.dsNumber]);
      addRow(['Ref. No.', d.refNo]);
      addRow(['Party Name', d.partyName]);
      addRow(['Contact Number', d.contactNumber]);
      addRow(['Delivery Address', d.deliveryAddress]);
      addRow(['Driver Name', d.driverName]);
      if (d.despatchedAt != null) addRow(['Despatched At', dateFmt.format(d.despatchedAt!)]);
      if (d.deliveryNotes.isNotEmpty) addRow(['Delivery Notes', d.deliveryNotes]);
      addRow([]);
      addRow(['#', 'Item', 'Company', 'Size', 'Box', 'Pcs', 'Qty']);
      for (var i = 0; i < d.items.length; i++) {
        final item = d.items[i];
        addRow([
          i + 1,
          item.productName,
          item.companyName.isEmpty ? '-' : item.companyName,
          item.productSize,
          item.boxes.toStringAsFixed(0),
          item.pieces.toStringAsFixed(0),
          item.quantity.toStringAsFixed(0),
        ]);
      }
      addRow([]);
      addRow(['Grand Total', _currency(d.grandTotal)]);

      final bytes = excelFile.save();
      if (bytes == null) throw Exception('Could not generate Excel file');

      final safeDs =
      d.dsNumber.isNotEmpty ? d.dsNumber.replaceAll(RegExp(r'[^\w\-]'), '_') : d.id;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Dispatch_$safeDs.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        text: 'Dispatch Bill - ${d.dsNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate Excel file: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingExcel = false);
    }
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.dispatch});
  final DispatchDetail dispatch;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    late Color color;
    late IconData icon;
    late String text;

    if (dispatch.isDelivered) {
      color = AppColors.info;
      icon = Icons.check_circle_rounded;
      text = 'Delivered on ${dispatch.deliveredAt != null ? dateFmt.format(dispatch.deliveredAt!) : '-'}';
    } else if (dispatch.isInTransit) {
      color = AppColors.warning;
      icon = Icons.local_shipping_rounded;
      text = 'In transit${dispatch.despatchedAt != null ? ' since ${dateFmt.format(dispatch.despatchedAt!)}' : ''}';
    } else {
      color = AppColors.warning;
      icon = Icons.local_shipping_outlined;
      text = 'Pending delivery';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5))),
          ),
        ],
      ),
    );
  }
}

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
            const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
            SizedBox(height: Responsive.h(10)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(14)),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}