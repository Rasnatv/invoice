
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as xls;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/estimate_model.dart';

/// One row of the Despatch Sheet table. Boxes/Pieces aren't part of
/// EstimateModel yet, so they're seeded with dummy values (Boxes =
/// quantity, Pieces = 1) and left editable here until a real
/// packing/inventory source is wired in.
class _DespatchRow {
  final String item;
  final String company;
  final String size;
  final TextEditingController boxesCtrl;
  final TextEditingController piecesCtrl;

  _DespatchRow({
    required this.item,
    required this.company,
    required this.size,
    required String boxes,
    required String pieces,
  })  : boxesCtrl = TextEditingController(text: boxes),
        piecesCtrl = TextEditingController(text: pieces);

  void dispose() {
    boxesCtrl.dispose();
    piecesCtrl.dispose();
  }
}

/// TODO(backend): replace with real driver list from OwnerCubit / repository
/// (see OwnerDriverScreen's DriverModel list once that's backed by data).
/// Holds a driver's name + phone number so the number can auto-fill when
/// a driver is selected from the dropdown.
class _DriverOption {
  final String name;
  final String number;
  const _DriverOption(this.name, this.number);
}

class DespatchSheetScreen extends StatefulWidget {
  const DespatchSheetScreen({super.key, required this.estimate});

  final EstimateModel estimate;

  @override
  State<DespatchSheetScreen> createState() => _DespatchSheetScreenState();
}

class _DespatchSheetScreenState extends State<DespatchSheetScreen> {
  // TODO(backend): DS Number should come from a real despatch counter once
  // the despatch module has its own model/cubit. Dummy for now.
  late final String _dsNumber;
  late final String _refNo;

  // TODO(backend): Delivery Address isn't part of EstimateModel yet.
  // Seeded here as an editable field (empty by default) until a real
  // address field/source (e.g. estimate.deliveryAddress) is wired in.
  late final TextEditingController _deliveryAddressCtrl;
  bool _deliveryAddressError = false;

  // TODO(backend): replace with real driver list from OwnerCubit / repository
  // (see OwnerDriverScreen's DriverModel list once that's backed by data).
  final List<_DriverOption> _driverOptions = const [
    _DriverOption('Ramesh Kumar', '9876543210'),
    _DriverOption('Suresh Nair', '9876501234'),
    _DriverOption('Anil Varma', '9812345678'),
  ];
  String? _selectedDriverName;
  bool _driverError = false;

  // Auto-filled from the selected driver's record (see _driverOptions).
  // Currently read-only; flip readOnly to false below if drivers should
  // be able to override the number on-screen.
  late final TextEditingController _driverNumberCtrl;

  late final List<_DespatchRow> _rows;

  static const int _minVisibleRows = 20;

  @override
  void initState() {
    super.initState();
    _dsNumber = 'DS-${widget.estimate.id}';
    _refNo = widget.estimate.id;
    _deliveryAddressCtrl = TextEditingController();
    _driverNumberCtrl = TextEditingController();
    _rows = widget.estimate.items
        .map((item) => _DespatchRow(
      item: item.name,
      company: item.company,
      size: item.size,
      boxes: item.quantity == item.quantity.roundToDouble()
          ? item.quantity.toStringAsFixed(0)
          : item.quantity.toString(),
      pieces: '1',
    ))
        .toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    _deliveryAddressCtrl.dispose();
    _driverNumberCtrl.dispose();
    super.dispose();
  }

  bool _validateDriverSelected() {
    final ok = _selectedDriverName != null;
    setState(() => _driverError = !ok);
    return ok;
  }

  bool _validateDeliveryAddress() {
    final ok = _deliveryAddressCtrl.text.trim().isNotEmpty;
    setState(() => _deliveryAddressError = !ok);
    return ok;
  }

  /// Called when a driver is picked from the dropdown. Auto-fills the
  /// driver number field from _driverOptions; falls back to blank if
  /// somehow no match is found.
  void _onDriverSelected(String? value) {
    setState(() {
      _selectedDriverName = value;
      _driverError = false;
      final match = _driverOptions.firstWhere(
            (d) => d.name == value,
        orElse: () => const _DriverOption('', ''),
      );
      _driverNumberCtrl.text = match.number;
    });
  }

  void _shareOnWhatsApp() {
    if (!_validateDriverSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a driver first')),
      );
      return;
    }
    if (!_validateDeliveryAddress()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the delivery address')),
      );
      return;
    }
    final buffer = StringBuffer()
      ..writeln('*Despatch Sheet*')
      ..writeln('DS Number: $_dsNumber')
      ..writeln('Ref No: $_refNo')
      ..writeln('Party Name: ${widget.estimate.contractorName}')
      ..writeln('Contact Number: ${widget.estimate.phone}')
      ..writeln('Delivery Address: ${_deliveryAddressCtrl.text}')
      ..writeln('');
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      buffer.writeln(
        '${i + 1}. ${r.item} | ${r.company} | ${r.size} | Boxes: ${r.boxesCtrl.text} | Pieces: ${r.piecesCtrl.text}',
      );
    }
    buffer
      ..writeln('')
      ..writeln('Driver Name: ${_selectedDriverName ?? '-'}')
      ..writeln('Driver Number: ${_driverNumberCtrl.text.isEmpty ? '-' : _driverNumberCtrl.text}');
    Share.share(buffer.toString(), subject: 'Despatch Sheet $_dsNumber');
  }

  // ---------------- PDF (print / save / share as PDF) ----------------

  Future<Uint8List> _buildPdfBytes() async {
    final pdf = pw.Document();
    final headers = ['Sl.No', 'Item', 'Company', 'Size', 'Boxes', 'Pieces'];
    final data = List.generate(_rows.length, (i) {
      final r = _rows[i];
      return [
        '${i + 1}',
        r.item,
        r.company.isEmpty ? '-' : r.company,
        r.size.isEmpty ? '-' : r.size,
        r.boxesCtrl.text,
        r.piecesCtrl.text,
      ];
    });

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Despatch Sheet',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text('Party Name: ${widget.estimate.contractorName}'),
              pw.Text('Contact Number: ${widget.estimate.phone.isEmpty ? '-' : widget.estimate.phone}'),
              pw.Text(
                'Delivery Address: ${_deliveryAddressCtrl.text.trim().isEmpty ? '-' : _deliveryAddressCtrl.text.trim()}',
              ),
              pw.Text('DS Number: $_dsNumber'),
              pw.Text('Ref. No.: $_refNo'),
              pw.SizedBox(height: 14),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(width: 0.6),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                headerAlignment: pw.Alignment.center,
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.6),
                  1: const pw.FlexColumnWidth(2.2),
                  2: const pw.FlexColumnWidth(1.6),
                  3: const pw.FlexColumnWidth(1.4),
                  4: const pw.FlexColumnWidth(0.8),
                  5: const pw.FlexColumnWidth(0.8),
                },
              ),
              pw.SizedBox(height: 28),
              pw.Text('Driver Name: ${_selectedDriverName ?? '_______________________'}'),
              pw.Text(
                'Driver Number: ${_driverNumberCtrl.text.isEmpty ? '_______________________' : _driverNumberCtrl.text}',
              ),
              pw.SizedBox(height: 24),
              pw.Text('Customer Signature: _______________________'),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> _printDespatchSheet() async {
    final bytes = await _buildPdfBytes();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _sharePdf() async {
    final bytes = await _buildPdfBytes();
    await Printing.sharePdf(bytes: bytes, filename: 'despatch_$_dsNumber.pdf');
  }

  // ---------------- Excel export ----------------

  Future<void> _exportToExcel() async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Despatch Sheet'];
    workbook.delete('Sheet1');

    sheet.appendRow([xls.TextCellValue('Despatch Sheet')]);
    sheet.appendRow([xls.TextCellValue('Party Name:'), xls.TextCellValue(widget.estimate.contractorName)]);
    sheet.appendRow([
      xls.TextCellValue('Contact Number:'),
      xls.TextCellValue(widget.estimate.phone.isEmpty ? '-' : widget.estimate.phone),
    ]);
    sheet.appendRow([
      xls.TextCellValue('Delivery Address:'),
      xls.TextCellValue(
        _deliveryAddressCtrl.text.trim().isEmpty ? '-' : _deliveryAddressCtrl.text.trim(),
      ),
    ]);
    sheet.appendRow([xls.TextCellValue('DS Number:'), xls.TextCellValue(_dsNumber)]);
    sheet.appendRow([xls.TextCellValue('Ref. No.:'), xls.TextCellValue(_refNo)]);
    sheet.appendRow([]);
    sheet.appendRow([
      xls.TextCellValue('Sl.No'),
      xls.TextCellValue('Item'),
      xls.TextCellValue('Company'),
      xls.TextCellValue('Size'),
      xls.TextCellValue('Boxes'),
      xls.TextCellValue('Pieces'),
    ]);
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      sheet.appendRow([
        xls.IntCellValue(i + 1),
        xls.TextCellValue(r.item),
        xls.TextCellValue(r.company.isEmpty ? '-' : r.company),
        xls.TextCellValue(r.size.isEmpty ? '-' : r.size),
        xls.TextCellValue(r.boxesCtrl.text),
        xls.TextCellValue(r.piecesCtrl.text),
      ]);
    }
    sheet.appendRow([]);
    sheet.appendRow([
      xls.TextCellValue('Driver Name:'),
      xls.TextCellValue(_selectedDriverName ?? '-'),
    ]);
    sheet.appendRow([
      xls.TextCellValue('Driver Number:'),
      xls.TextCellValue(_driverNumberCtrl.text.isEmpty ? '-' : _driverNumberCtrl.text),
    ]);
    sheet.appendRow([xls.TextCellValue('Customer Signature:')]);

    final bytes = workbook.encode();
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not generate the Excel file')),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/despatch_$_dsNumber.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([XFile(file.path)], subject: 'Despatch Sheet $_dsNumber (Excel)');
  }

  void _onExportSelected(String value) {
    switch (value) {
      case 'print':
        _printDespatchSheet();
        break;
      case 'pdf_share':
        _sharePdf();
        break;
      case 'excel':
        _exportToExcel();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Despatch Sheet', style: AppTextStyles.h6()),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _onExportSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Print'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pdf_share',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Share as PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.grid_on_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Export to Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Party Name', widget.estimate.contractorName),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Contact Number', widget.estimate.phone.isEmpty ? '-' : widget.estimate.phone),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('DS Number', _dsNumber),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Ref. No.', _refNo),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  Text('Delivery Address', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(8)),
                  TextField(
                    controller: _deliveryAddressCtrl,
                    minLines: 2,
                    maxLines: 4,
                    style: AppTextStyles.body(),
                    onChanged: (_) {
                      if (_deliveryAddressError) {
                        setState(() => _deliveryAddressError = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter delivery address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      errorText: _deliveryAddressError ? 'Please enter the delivery address' : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14),
                        vertical: Responsive.h(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

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
                              SizedBox(width: 28, child: Text('#', style: AppTextStyles.captionnew())),
                              Expanded(flex: 3, child: Text('Item', style: AppTextStyles.captionnew())),
                              Expanded(flex: 2, child: Text('Company', style: AppTextStyles.captionnew())),
                              Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
                              SizedBox(width: 56, child: Text('Boxes', style: AppTextStyles.captionnew())),
                              SizedBox(width: 56, child: Text('Pieces', style: AppTextStyles.captionnew())),
                            ],
                          ),
                        ),
                        for (var i = 0; i < _rows.length; i++)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(6)),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.border)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 28, child: Text('${i + 1}', style: AppTextStyles.body())),
                                Expanded(
                                  flex: 3,
                                  child: Text(_rows[i].item, style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _rows[i].company.isEmpty ? '-' : _rows[i].company,
                                    style: AppTextStyles.body(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _rows[i].size.isEmpty ? '-' : _rows[i].size,
                                    style: AppTextStyles.body(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: TextField(
                                    controller: _rows[i].boxesCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: TextField(
                                    controller: _rows[i].piecesCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Blank rows to visually match the printed sheet
                        // (up to _minVisibleRows), purely cosmetic.
                        for (var i = _rows.length; i < _minVisibleRows; i++)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(10)),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.border)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 28, child: Text('${i + 1}', style: AppTextStyles.caption())),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(20)),

                  Text('Driver Name', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(8)),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDriverName,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    decoration: InputDecoration(
                      hintText: 'Select driver',
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: _driverError ? 'Please select a driver' : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14),
                        vertical: Responsive.h(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: _driverOptions
                        .map((d) => DropdownMenuItem<String>(
                      value: d.name,
                      child: Text(d.name, style: AppTextStyles.body()),
                    ))
                        .toList(),
                    onChanged: _onDriverSelected,
                  ),
                  SizedBox(height: Responsive.h(12)),

                  Text('Driver Number', style: AppTextStyles.h3()),
                  SizedBox(height: Responsive.h(8)),
                  TextField(
                    controller: _driverNumberCtrl,
                    // Auto-filled from the selected driver; kept read-only
                    // so it always matches the chosen driver's record.
                    // TODO(backend): once driver data has a real editable
                    // phone source, decide whether to allow overrides here.
                    readOnly: true,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: 'Driver number',
                      prefixIcon: const Icon(Icons.call_outlined),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14),
                        vertical: Responsive.h(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(24)),

                  Text('Customer Signature', style: AppTextStyles.bodyBold()),
                  SizedBox(height: Responsive.h(8)),
                  Container(
                    height: Responsive.h(60),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareOnWhatsApp,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share via WhatsApp'),
                    ),
                  ),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!_validateDriverSelected()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a driver first')),
                          );
                          return;
                        }
                        if (!_validateDeliveryAddress()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter the delivery address')),
                          );
                          return;
                        }
                        // TODO(despatch-flow): once the despatch module has
                        // its own status/cubit, mark this estimate as
                        // "Despatched" here and notify Owner + Salesman
                        // dashboards. For now this just confirms locally.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Despatch sheet saved')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.local_shipping_outlined, size: 18),
                      label: const Text('Despatch'),
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

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: AppTextStyles.caption())),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
      ],
    );
  }
}