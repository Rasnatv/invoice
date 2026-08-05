
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as xls;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

/// Simple line item passed in from the Owner Quotation Details screen.
/// Kept independent from EstimateModel since this screen is opened
/// directly off quotation data, not off an estimate.
class OwnerDespatchItem {
  final String name;
  final String company;
  final String size;
  final double quantity;
  final String unit;

  const OwnerDespatchItem({
    required this.name,
    required this.company,
    required this.size,
    required this.quantity,
    required this.unit,
  });
}

/// Result handed back to Owner Quotation Details once the owner confirms
/// despatch on this screen.
class DespatchInfo {
  final String driverName;
  final String driverPhone;
  final DateTime despatchDate;
  final String assignedSalesman;
  final String deliveryAddress;

  const DespatchInfo({
    required this.driverName,
    required this.driverPhone,
    required this.despatchDate,
    required this.assignedSalesman,
    required this.deliveryAddress,
  });
}

/// Owner-side Despatch Sheet.
///
/// This is a SEPARATE screen from the salesman's DespatchSheetScreen
/// (which is keyed off EstimateModel and reached from the salesman's own
/// flow). This one is opened when the owner picks "Assigned to Me" while
/// sending a quotation to despatch, and it works directly off the
/// quotation data passed in via the constructor — no EstimateModel needed.
class OwnerDespatchSheetScreen extends StatefulWidget {
  const OwnerDespatchSheetScreen({
    super.key,
    required this.quotationId,
    required this.contractorName,
    required this.phone,
    required this.siteAddress,
    required this.items,
    // Pre-fill the driver_features name/phone when re-opening this screen for an
    // estimate that was already despatched before (e.g. the owner comes
    // back via "Assigned to Me" a second time). Left null on first-ever
    // despatch, in which case the fields start empty as before.
    this.initialDriverName,
    this.initialDriverPhone,
  });

  final String quotationId;
  final String contractorName;
  final String phone;
  final String siteAddress;
  final List<OwnerDespatchItem> items;
  final String? initialDriverName;
  final String? initialDriverPhone;

  @override
  State<OwnerDespatchSheetScreen> createState() => _OwnerDespatchSheetScreenState();
}

class _OwnerDespatchSheetScreenState extends State<OwnerDespatchSheetScreen> {
  late final String _dsNumber;
  late final String _refNo;

  late final TextEditingController _deliveryAddressCtrl;
  bool _deliveryAddressError = false;

  // TODO(backend): replace with real driver_features list from OwnerCubit / repository
  final List<String> _driverOptions = const [
    'Ramesh Kumar',
    'Suresh Nair',
    'Anil Varma',
  ];

  // TODO(backend): replace with real driver_features phone numbers from
  // OwnerCubit / repository, keyed the same way as _driverOptions.
  // Used to auto-fill the phone field the moment a driver_features is picked.
  static const Map<String, String> _dummyDriverPhones = {
    'Ramesh Kumar': '+91 90001 11111',
    'Suresh Nair': '+91 90002 22222',
    'Anil Varma': '+91 90003 33333',
  };
  String? _selectedDriverName;
  final TextEditingController _driverPhoneCtrl = TextEditingController();
  bool _driverError = false;

  late final List<_Row> _rows;

  static const int _minVisibleRows = 20;

  @override
  void initState() {
    super.initState();
    _dsNumber = 'DS-${widget.quotationId}';
    _refNo = widget.quotationId;
    _deliveryAddressCtrl = TextEditingController(text: widget.siteAddress);

    // Auto-fill driver_features name/phone from a previous despatch on this same
    // estimate, if one was passed in. Guard against a saved name that
    // isn't in _driverOptions (e.g. once wired to a real, changing list)
    // since DropdownButtonFormField throws if its value isn't in items.
    if (widget.initialDriverName != null &&
        _driverOptions.contains(widget.initialDriverName)) {
      _selectedDriverName = widget.initialDriverName;
    }
    // Prefer an explicitly passed-in phone (e.g. a previously despatched
    // number); otherwise fall back to the dummy lookup for the selected
    // driver_features so the field isn't left blank.
    _driverPhoneCtrl.text = widget.initialDriverPhone ??
        (_selectedDriverName != null ? _dummyDriverPhones[_selectedDriverName!] ?? '' : '');

    _rows = widget.items
        .map((item) => _Row(
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
    _driverPhoneCtrl.dispose();
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

  void _shareOnWhatsApp() {
    if (!_validateDriverSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a driver_features first')),
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
      ..writeln('Party Name: ${widget.contractorName}')
      ..writeln('Contact Number: ${widget.phone}')
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
      ..writeln('Driver Phone: ${_driverPhoneCtrl.text.isEmpty ? '-' : _driverPhoneCtrl.text}');
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
              pw.Text('Party Name: ${widget.contractorName}'),
              pw.Text('Contact Number: ${widget.phone.isEmpty ? '-' : widget.phone}'),
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
                'Driver Phone: ${_driverPhoneCtrl.text.isEmpty ? '_______________________' : _driverPhoneCtrl.text}',
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
    sheet.appendRow([xls.TextCellValue('Party Name:'), xls.TextCellValue(widget.contractorName)]);
    sheet.appendRow([
      xls.TextCellValue('Contact Number:'),
      xls.TextCellValue(widget.phone.isEmpty ? '-' : widget.phone),
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
      xls.TextCellValue('Driver Phone:'),
      xls.TextCellValue(_driverPhoneCtrl.text.isEmpty ? '-' : _driverPhoneCtrl.text),
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

  // Confirms despatch and pops this screen, returning a DespatchInfo to
  // Owner Quotation Details so it can update its status/UI.
  // TODO(backend): once the despatch module has its own status/cubit,
  // persist this despatch record (driver_features, address, items, timestamps)
  // instead of just returning it locally.
  void _confirmDespatch() {
    if (!_validateDriverSelected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a driver_features first')),
      );
      return;
    }
    if (!_validateDeliveryAddress()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the delivery address')),
      );
      return;
    }
    Navigator.of(context).pop(
      DespatchInfo(
        driverName: _selectedDriverName!,
        driverPhone: _driverPhoneCtrl.text.trim(),
        despatchDate: DateTime.now(),
        assignedSalesman: 'Assigned to Me',
        deliveryAddress: _deliveryAddressCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Despatch Sheet (Owner)', style: AppTextStyles.h6()),
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
                        _infoRow('Party Name', widget.contractorName),
                        SizedBox(height: Responsive.h(6)),
                        _infoRow('Contact Number', widget.phone.isEmpty ? '-' : widget.phone),
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
                                  child:
                                  Text(_rows[i].item, style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
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
                      hintText: 'Select driver_features',
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: _driverError ? 'Please select a driver_features' : null,
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
                        .map((name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(name, style: AppTextStyles.body()),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedDriverName = value;
                      _driverError = false;
                      // Auto-fill the dummy phone number for this driver.
                      // TODO(backend): replace _dummyDriverPhones with a
                      // real lookup once driver phone numbers come from
                      // the API.
                      _driverPhoneCtrl.text =
                      value != null ? (_dummyDriverPhones[value] ?? '') : '';
                    }),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  Text('Driver Phone', style: AppTextStyles.bodyBold()),
                  SizedBox(height: Responsive.h(8)),
                  TextField(
                    controller: _driverPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: 'Enter driver_features phone number',
                      prefixIcon: const Icon(Icons.call_outlined),
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
                      onPressed: _confirmDespatch,
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

class _Row {
  final String item;
  final String company;
  final String size;
  final TextEditingController boxesCtrl;
  final TextEditingController piecesCtrl;

  _Row({
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