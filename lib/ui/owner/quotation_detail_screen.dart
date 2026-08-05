
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/primary_button.dart';
import 'ownerdespatchsheet.dart';

enum _DummyStatus { pending, dispatched, rejected }

extension on _DummyStatus {
  String get label {
    switch (this) {
      case _DummyStatus.pending:
        return 'Pending';
      case _DummyStatus.dispatched:
        return 'Dispatched';
      case _DummyStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case _DummyStatus.pending:
        return Colors.orange;
      case _DummyStatus.dispatched:
        return Colors.blue;
      case _DummyStatus.rejected:
        return Colors.red;
    }
  }
}

class _DummyItem {
  final String name;
  final String company;
  final String size;
  final double quantity;
  final String unit;
  final double mrp;
  final double rate;

  const _DummyItem({
    required this.name,
    required this.company,
    required this.size,
    required this.quantity,
    required this.unit,
    required this.mrp,
    required this.rate,
  });

  double get amount => quantity * rate;
}

class _DummyQuotation {
  final String id;
  // Party Name / Address — the top "Party Name" + "Address" block on
  // the sheet, separate from the Contractor block further down.
  final String partyName;
  final String partyAddress;
  final String contractorName;
  final String siteAddress;
  final String mobno;
  final String phone;
  final String salesmanName;
  final DateTime date;
  final _DummyStatus status;
  final double handlingCharge;
  // Total square footage — shown as "Total Sqrft" on the sheet.
  final double totalSqrft;
  final List<_DummyItem> items;

  const _DummyQuotation({
    required this.id,
    required this.partyName,
    required this.partyAddress,

    required this.contractorName,
    required this.siteAddress,
    required this.mobno,
    required this.phone,
    required this.salesmanName,
    required this.date,
    required this.status,
    required this.handlingCharge,
    required this.totalSqrft,
    required this.items,
  });

  double get mrpTotal => items.fold(0.0, (s, i) => s + i.mrp * i.quantity);
  double get itemsTotal => items.fold(0.0, (s, i) => s + i.amount);
  double get totalQty => items.fold(0.0, (s, i) => s + i.quantity);
  double get totalAmount => itemsTotal + handlingCharge;

  static _DummyQuotation sample() {
    return _DummyQuotation(
      id: 'QUO-2087',
      partyName: 'Ramesh Constructions',
      partyAddress: 'No. 24, Palace Road, Kanhangad',
      contractorName: 'Ramesh Constructions',
      siteAddress: 'No. 24, Palace Road, Kanhangad',
      mobno: '+91 856230000',
      phone: '+91 98765 43210',
      salesmanName: 'Anoop Menon',
      date: DateTime.now(),
      status: _DummyStatus.pending,
      handlingCharge: 250,
      totalSqrft: 1000,
      items: const [
        _DummyItem(
          name: 'PVC Pipe',
          company: 'Supreme',
          size: '1 inch',
          quantity: 40,
          unit: 'Nos',
          mrp: 120,
          rate: 105,
        ),
        _DummyItem(
          name: 'Cement Bag',
          company: 'UltraTech',
          size: '50kg',
          quantity: 20,
          unit: 'Bag',
          mrp: 420,
          rate: 390,
        ),
        _DummyItem(
          name: 'Copper Wire',
          company: 'Havells',
          size: '2.5 sqmm',
          quantity: 8,
          unit: 'Coil',
          mrp: 2100,
          rate: 1950,
        ),
      ],
    );
  }
}

const double _dummyIncentivePercent = 5.0;

double _incentiveAmountFor(_DummyItem item) => item.amount * _dummyIncentivePercent / 100;

const List<String> _dummySalesmen = [
  'Assigned to Me',
  'Anoop Menon',
  'Ravi Kumar',
  'Sunitha Nair',
  'Amit Kumar',
];

class OwnerQuotationDetailsScreen extends StatefulWidget {
  const OwnerQuotationDetailsScreen({
    super.key,
    this.quotationId,
    this.customerName,
    this.customerPhone,
    this.salesmanName,
    this.date,
    this.grandTotal,
  });

  final String? quotationId;
  final String? customerName;
  final String? customerPhone;
  final String? salesmanName;
  final DateTime? date;
  final double? grandTotal;

  @override
  State<OwnerQuotationDetailsScreen> createState() => _OwnerQuotationDetailsScreenState();
}

class _OwnerQuotationDetailsScreenState extends State<OwnerQuotationDetailsScreen> {
  late final _quotation = _buildQuotation();

  // Handling Charge is the only editable field here — starts empty so the
  // owner has to enter it; everything else keeps its previous read-only style.
  late final TextEditingController _handlingChargeCtrl;
  double _handlingCharge = 0;

  _DummyQuotation _buildQuotation() {
    final base = _DummyQuotation.sample();
    if (widget.quotationId == null) return base;

    final itemsTotal = base.items.fold(0.0, (s, i) => s + i.amount);
    final targetHandling = widget.grandTotal != null
        ? (widget.grandTotal! - itemsTotal).clamp(0, double.infinity).toDouble()
        : base.handlingCharge;

    return _DummyQuotation(
      id: widget.quotationId!,
      partyName: widget.customerName ?? base.partyName,
      partyAddress: base.partyAddress,
      contractorName: widget.customerName ?? base.contractorName,
      siteAddress: base.siteAddress,
      mobno: base.mobno,
      phone: widget.customerPhone ?? base.phone,
      salesmanName: widget.salesmanName ?? base.salesmanName,
      date: widget.date ?? base.date,
      status: base.status,
      handlingCharge: targetHandling,
      totalSqrft: base.totalSqrft,
      items: base.items,
    );
  }

  @override
  void initState() {
    super.initState();
    // Empty by default — not pre-filled from the dummy quotation.
    _handlingChargeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _handlingChargeCtrl.dispose();
    super.dispose();
  }

  // Set once despatch is confirmed — either by picking a salesman in the
  // dialog below, or by completing the Owner Despatch Sheet after picking
  // "Assigned to Me".
  DespatchInfo? _despatchInfo;

  double get _incentiveTotal =>
      _quotation.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));

  double get _totalAmount => _quotation.itemsTotal + _handlingCharge;

  Color _statusColor(_DummyStatus status) => status.color;

  String _buildShareText(NumberFormat currency, NumberFormat number) {
    final buffer = StringBuffer()
      ..writeln('Quotation ${_quotation.id}')
      ..writeln('Party Name: ${_quotation.partyName}')
      ..writeln('Party Address: ${_quotation.partyAddress}')
      ..writeln('Contractor: ${_quotation.contractorName}')
      ..writeln('Site Address: ${_quotation.siteAddress}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(_quotation.date)}')
      ..writeln('---');
    for (final item in _quotation.items) {
      buffer.writeln(
        '${item.name} (${item.company}) x ${item.quantity.toStringAsFixed(0)} ${item.unit} = ${currency.format(item.amount)}',
      );
    }
    buffer
      ..writeln('---')
      ..writeln('Handling Charge: ${currency.format(_handlingCharge)}')
      ..writeln('Total: ${currency.format(_totalAmount)}');
    if (_quotation.salesmanName.isNotEmpty) {
      buffer.writeln('Salesman: ${_quotation.salesmanName}');
    }
    // Total sqrft in the shared summary.
    buffer.writeln('Total Sqrft: ${number.format(_quotation.totalSqrft)}');
    if (_despatchInfo != null) {
      buffer
        ..writeln('Despatched: ${DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate)}')
        ..writeln('Sent to Salesman: ${_despatchInfo!.assignedSalesman}');
      if (_despatchInfo!.driverName.isNotEmpty) {
        buffer.writeln('Driver: ${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})');
      }
    }
    return buffer.toString();
  }

  Future<void> _showSendToDespatchDialog() async {
    String? selectedSalesman = _despatchInfo?.assignedSalesman ?? widget.salesmanName ?? _quotation.salesmanName;
    if (!_dummySalesmen.contains(selectedSalesman)) {
      selectedSalesman = null;
    }
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Send to Despatch Sheet'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedSalesman,
                        decoration: const InputDecoration(
                          labelText: 'Send To (Salesman)',
                          border: OutlineInputBorder(),
                        ),
                        items: _dummySalesmen
                            .map(
                              (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedSalesman = value);
                        },
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select a salesman' : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop(selectedSalesman);
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    if (result == 'Assigned to Me') {
      await _openOwnerDespatchSheet();
      return;
    }

    // Sent to an actual salesman — just notify locally for now.
    setState(() {
      _despatchInfo = DespatchInfo(
        driverName: '',
        driverPhone: '',
        despatchDate: DateTime.now(),
        assignedSalesman: result,
        deliveryAddress: _quotation.siteAddress,
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent to $result for despatch')),
      );
    }
  }

  Future<void> _openOwnerDespatchSheet() async {
    final result = await Navigator.of(context).push<DespatchInfo>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(
          quotationId: _quotation.id,
          contractorName: _quotation.contractorName,
          phone: _quotation.phone,
          siteAddress: _quotation.siteAddress,
          items: _quotation.items
              .map((i) => OwnerDespatchItem(
            name: i.name,
            company: i.company,
            size: i.size,
            quantity: i.quantity,
            unit: i.unit,
          ))
              .toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() => _despatchInfo = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despatch sheet completed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');
    final status = _despatchInfo != null ? _DummyStatus.dispatched : _quotation.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Owner Quotation Details', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Responsive.w(18)),
                children: [
                  // Top summary card — Quotation No. / Date.
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quotation No.', style: AppTextStyles.caption()),
                            Text(_quotation.id, style: AppTextStyles.h3()),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Date', style: AppTextStyles.caption()),
                            Text(DateFormat('dd-MM-yyyy').format(_quotation.date), style: AppTextStyles.h3()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: AppTextStyles.bodyBold(color: _statusColor(status)),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  _DetailSection(
                    title: 'Party Details',
                    rows: [
                      _Row('Party Name', _quotation.partyName, icon: Icons.groups_2_outlined),
                      _Row('Party Address', _quotation.partyAddress, icon: Icons.location_on_outlined),
                      _Row('Mobile no.', _quotation.mobno, icon: Icons.location_on_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: 'Contractor Details',
                    rows: [
                      _Row('Contractor Name', _quotation.contractorName, icon: Icons.engineering_outlined),
                      _Row('Contact No.', _quotation.phone.isEmpty ? '-' : _quotation.phone, icon: Icons.phone_outlined),
                    ],
                  ),
                  SizedBox(height: Responsive.h(14)),
                  _DetailSection(
                    title: ' Owner',
                    rows: [
                      _Row('Name', _quotation.salesmanName.isEmpty ? '-' : _quotation.salesmanName, icon: Icons.badge_outlined),
                    ],
                  ),
                  if (_despatchInfo != null) ...[
                    SizedBox(height: Responsive.h(14)),
                    _DetailSection(
                      title: 'Despatch',
                      rows: [
                        _Row('Sent To', _despatchInfo!.assignedSalesman, icon: Icons.local_shipping_outlined),
                        if (_despatchInfo!.driverName.isNotEmpty)
                          _Row(
                            'Driver',
                            _despatchInfo!.driverPhone.isEmpty
                                ? _despatchInfo!.driverName
                                : '${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})',
                            icon: Icons.badge_outlined,
                          ),
                        if (_despatchInfo!.deliveryAddress.isNotEmpty)
                          _Row('Delivery Address', _despatchInfo!.deliveryAddress, icon: Icons.location_on_outlined),
                        _Row(
                          'Despatch Date',
                          DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate),
                          icon: Icons.event_outlined,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: Responsive.h(20)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items', style: AppTextStyles.h3()),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Items: ${_quotation.items.length}',
                          style: AppTextStyles.bodyBold(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(10)),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
                        headingTextStyle: AppTextStyles.bodyBold(),
                        dataTextStyle: AppTextStyles.body(),
                        columnSpacing: 18,
                        columns: const [
                          DataColumn(label: Text('Sl.No')),
                          DataColumn(label: Text('Item')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Size')),
                          DataColumn(label: Text('Qty'), numeric: true),
                          DataColumn(label: Text('Unit')),
                          DataColumn(label: Text('MRP'), numeric: true),
                          DataColumn(label: Text('Rate'), numeric: true),
                          DataColumn(label: Text('Amount'), numeric: true),
                        ],
                        rows: _quotation.items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(item.name)),
                            DataCell(Text(item.company.isEmpty ? '-' : item.company)),
                            DataCell(Text(item.size.isEmpty ? '-' : item.size)),
                            DataCell(Text(number.format(item.quantity))),
                            DataCell(Text(item.unit)),
                            DataCell(Text(number.format(item.mrp))),
                            DataCell(Text(number.format(item.rate))),
                            DataCell(Text(
                              currency.format(item.amount),
                              style: AppTextStyles.bodyBold(),
                            )),

                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _totalRow('Total Items', '${_quotation.items.length}'),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Total Qty', number.format(_quotation.totalQty)),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('MRP Total', currency.format(_quotation.mrpTotal)),
                        SizedBox(height: Responsive.h(6)),
                        // Handling Charge — the one editable field, starts
                        // empty. Total Amount below updates as it's typed.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Handling Charge', style: AppTextStyles.body()),
                            SizedBox(
                              width: 130,
                              child: TextField(
                                controller: _handlingChargeCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.right,
                                style: AppTextStyles.bodyBold(),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: '0',
                                  prefixText: '₹ ',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (v) => setState(() => _handlingCharge = double.tryParse(v) ?? 0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        _totalRow('Total Sqrft', number.format(_quotation.totalSqrft)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTextStyles.h3()),
                            Text(currency.format(_totalAmount), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

                  // Separate, visually distinct box for incentive so it's
                  // clear this is internal/salesman info, not part of the
                  // customer's bill total above. Values are dummy (5%)
                  // until admin-configured incentive data is wired up.
                  Container(
                    padding: EdgeInsets.all(Responsive.w(14)),
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
                            Icon(Icons.percent, size: 18, color: AppColors.success),
                            SizedBox(width: Responsive.w(8)),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_dummyIncentivePercent.toStringAsFixed(0)}% · dummy',
                                style: AppTextStyles.caption(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currency.format(_incentiveTotal),
                          style: AppTextStyles.h3(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                ],
              ),
            ),

            // Bottom action bar.
            Container(
              padding: EdgeInsets.fromLTRB(Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wire this up to your edit flow')),
                      );
                    },
                  ),
                  SizedBox(width: Responsive.w(10)),
                  _RoundIconButton(
                    icon: Icons.share_outlined,
                    tooltip: 'Share',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _buildShareText(currency, number)));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quotation summary copied to clipboard')),
                        );
                      }
                    },
                  ),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: PrimaryButton(
                      label: _despatchInfo == null
                          ? 'Approve & Send to Despatch'
                          : 'Sent to ${_despatchInfo!.assignedSalesman}',
                      height: 48,
                      onPressed: _showSendToDespatchDialog,
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

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: AppTextStyles.body()),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
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

class _Row {
  final String label;
  final String value;
  final IconData? icon;
  _Row(this.label, this.value, {this.icon});
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

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