//
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../../../core/widgets/primary_button.dart';
// import 'ownerdespatchsheet.dart';
//
// enum _DummyStatus { pending, dispatched, rejected }
//
// extension on _DummyStatus {
//   String get label {
//     switch (this) {
//       case _DummyStatus.pending:
//         return 'Pending';
//       case _DummyStatus.dispatched:
//         return 'Dispatched';
//       case _DummyStatus.rejected:
//         return 'Rejected';
//     }
//   }
//
//   Color get color {
//     switch (this) {
//       case _DummyStatus.pending:
//         return Colors.orange;
//       case _DummyStatus.dispatched:
//         return Colors.blue;
//       case _DummyStatus.rejected:
//         return Colors.red;
//     }
//   }
// }
//
// class _DummyItem {
//   final String name;
//   final String company;
//   final String size;
//   final double quantity;
//   final String unit;
//   final double mrp;
//   final double rate;
//
//   const _DummyItem({
//     required this.name,
//     required this.company,
//     required this.size,
//     required this.quantity,
//     required this.unit,
//     required this.mrp,
//     required this.rate,
//   });
//
//   double get amount => quantity * rate;
// }
//
// class _DummyQuotation {
//   final String id;
//   final String contractorName;
//   final String siteAddress;
//   final String phone;
//   final String salesmanName;
//   final DateTime date;
//   final _DummyStatus status;
//   final double handlingCharge;
//   final List<_DummyItem> items;
//
//   const _DummyQuotation({
//     required this.id,
//     required this.contractorName,
//     required this.siteAddress,
//     required this.phone,
//     required this.salesmanName,
//     required this.date,
//     required this.status,
//     required this.handlingCharge,
//     required this.items,
//   });
//
//   double get mrpTotal => items.fold(0.0, (s, i) => s + i.mrp * i.quantity);
//   double get itemsTotal => items.fold(0.0, (s, i) => s + i.amount);
//   double get totalAmount => itemsTotal + handlingCharge;
//
//   static _DummyQuotation sample() {
//     return _DummyQuotation(
//       id: 'QUO-2087',
//       contractorName: 'Ramesh Constructions',
//       siteAddress: 'No. 24, Palace Road, Kanhangad',
//       phone: '+91 98765 43210',
//       salesmanName: 'Anoop Menon',
//       date: DateTime.now(),
//       status: _DummyStatus.pending,
//       handlingCharge: 250,
//       items: const [
//         _DummyItem(
//           name: 'PVC Pipe',
//           company: 'Supreme',
//           size: '1 inch',
//           quantity: 40,
//           unit: 'Nos',
//           mrp: 120,
//           rate: 105,
//         ),
//         _DummyItem(
//           name: 'Cement Bag',
//           company: 'UltraTech',
//           size: '50kg',
//           quantity: 20,
//           unit: 'Bag',
//           mrp: 420,
//           rate: 390,
//         ),
//         _DummyItem(
//           name: 'Copper Wire',
//           company: 'Havells',
//           size: '2.5 sqmm',
//           quantity: 8,
//           unit: 'Coil',
//           mrp: 2100,
//           rate: 1950,
//         ),
//       ],
//     );
//   }
// }
//
// // Placeholder incentive % — same dummy pattern used elsewhere in the app.
// const double _dummyIncentivePercent = 5.0;
//
// double _incentiveAmountFor(_DummyItem item) => item.amount * _dummyIncentivePercent / 100;
//
// // Dummy list of salesmen the owner can choose from when sending a
// // quotation to the despatch sheet. "Assigned to Me" lets the owner handle
// // despatch themselves via OwnerDespatchSheetScreen instead of notifying a
// // salesman. Replace with a real API/cubit call (e.g. fetch active
// // salesmen for the branch) once available.
// const List<String> _dummySalesmen = [
//   'Assigned to Me',
//   'Anoop Menon',
//   'Ravi Kumar',
//   'Sunitha Nair',
//   'Vishnu Prasad',
// ];
//
// class OwnerQuotationDetailsScreen extends StatefulWidget {
//   const OwnerQuotationDetailsScreen({
//     super.key,
//     this.quotationId,
//     this.customerName,
//     this.customerPhone,
//     this.salesmanName,
//     this.date,
//     this.grandTotal,
//   });
//
//   final String? quotationId;
//   final String? customerName;
//   final String? customerPhone;
//   final String? salesmanName;
//   final DateTime? date;
//   final double? grandTotal;
//
//   @override
//   State<OwnerQuotationDetailsScreen> createState() => _OwnerQuotationDetailsScreenState();
// }
//
// class _OwnerQuotationDetailsScreenState extends State<OwnerQuotationDetailsScreen> {
//   late final _quotation = _buildQuotation();
//
//   // Merges whatever was passed in from the list screen on top of the
//   // sample data. Once a real "get quotation by id" call exists, replace
//   // this whole method with that API/cubit call keyed on widget.quotationId.
//   _DummyQuotation _buildQuotation() {
//     final base = _DummyQuotation.sample();
//     if (widget.quotationId == null) return base;
//
//     final itemsTotal = base.items.fold(0.0, (s, i) => s + i.amount);
//     final targetHandling = widget.grandTotal != null
//         ? (widget.grandTotal! - itemsTotal).clamp(0, double.infinity).toDouble()
//         : base.handlingCharge;
//
//     return _DummyQuotation(
//       id: widget.quotationId!,
//       contractorName: widget.customerName ?? base.contractorName,
//       siteAddress: base.siteAddress,
//       phone: widget.customerPhone ?? base.phone,
//       salesmanName: widget.salesmanName ?? base.salesmanName,
//       date: widget.date ?? base.date,
//       status: base.status,
//       handlingCharge: targetHandling,
//       items: base.items,
//     );
//   }
//
//   // Set once despatch is confirmed — either by picking a salesman in the
//   // dialog below, or by completing the Owner Despatch Sheet after picking
//   // "Assigned to Me".
//   DespatchInfo? _despatchInfo;
//
//   double get _incentiveTotal =>
//       _quotation.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));
//
//   String _buildShareText(NumberFormat currency) {
//     final buffer = StringBuffer()
//       ..writeln('Quotation ${_quotation.id}')
//       ..writeln('Party: ${_quotation.contractorName}')
//       ..writeln('Address: ${_quotation.siteAddress}')
//       ..writeln('Date: ${DateFormat('dd MMM yyyy').format(_quotation.date)}')
//       ..writeln('---');
//     for (final item in _quotation.items) {
//       buffer.writeln(
//         '${item.name} (${item.company}) x ${item.quantity.toStringAsFixed(0)} ${item.unit} = ${currency.format(item.amount)}',
//       );
//     }
//     buffer
//       ..writeln('---')
//       ..writeln('Total: ${currency.format(_quotation.totalAmount)}');
//     if (_despatchInfo != null) {
//       buffer
//         ..writeln('Despatched: ${DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate)}')
//         ..writeln('Sent to Salesman: ${_despatchInfo!.assignedSalesman}');
//       if (_despatchInfo!.driverName.isNotEmpty) {
//         buffer.writeln('Driver: ${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})');
//       }
//     }
//     return buffer.toString();
//   }
//
//   // Opens a dialog letting the owner pick who the quotation is sent to for
//   // despatch. Picking "Assigned to Me" hands off straight to the Owner
//   // Despatch Sheet (see _openOwnerDespatchSheet). Picking a real salesman
//   // just records the intent for now — TODO(backend): wire this to a real
//   // despatch/notification API once the despatch module has its own
//   // model/cubit, so the chosen salesman actually gets notified and fills
//   // in their own despatch sheet from their side.
//   Future<void> _showSendToDespatchDialog() async {
//     String? selectedSalesman = _despatchInfo?.assignedSalesman ?? widget.salesmanName ?? _quotation.salesmanName;
//     if (!_dummySalesmen.contains(selectedSalesman)) {
//       selectedSalesman = null;
//     }
//     final formKey = GlobalKey<FormState>();
//
//     final result = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text('Send to Despatch Sheet'),
//               content: SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(height: 12),
//                       DropdownButtonFormField<String>(
//                         value: selectedSalesman,
//                         decoration: const InputDecoration(
//                           labelText: 'Send To (Salesman)',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: _dummySalesmen
//                             .map(
//                               (name) => DropdownMenuItem<String>(
//                             value: name,
//                             child: Text(name),
//                           ),
//                         )
//                             .toList(),
//                         onChanged: (value) {
//                           setDialogState(() => selectedSalesman = value);
//                         },
//                         validator: (value) =>
//                         (value == null || value.isEmpty) ? 'Please select a salesman' : null,
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(dialogContext).pop(),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (formKey.currentState!.validate()) {
//                       Navigator.of(dialogContext).pop(selectedSalesman);
//                     }
//                   },
//                   child: const Text('Send'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//
//     if (result == null) return;
//
//     if (result == 'Assigned to Me') {
//       await _openOwnerDespatchSheet();
//       return;
//     }
//
//     // Sent to an actual salesman — just notify locally for now.
//     setState(() {
//       _despatchInfo =
//
//           DespatchInfo(
//         driverName: '',
//         driverPhone: '',
//         despatchDate: DateTime.now(),
//         assignedSalesman: result,
//         deliveryAddress: _quotation.siteAddress,
//       );
//     });
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sent to $result for despatch')),
//       );
//     }
//   }
//
//   // Pushes the owner's own, separate despatch sheet screen — distinct from
//   // the salesman's DespatchSheetScreen (which is keyed off EstimateModel).
//   // Passes the quotation's own data straight in, so no EstimateModel is
//   // needed here.
//   Future<void> _openOwnerDespatchSheet() async {
//     final result = await Navigator.of(context).push<DespatchInfo>(
//       MaterialPageRoute(
//         builder: (_) => OwnerDespatchSheetScreen(
//           quotationId: _quotation.id,
//           contractorName: _quotation.contractorName,
//           phone: _quotation.phone,
//           siteAddress: _quotation.siteAddress,
//           items: _quotation.items
//               .map((i) => OwnerDespatchItem(
//             name: i.name,
//             company: i.company,
//             size: i.size,
//             quantity: i.quantity,
//             unit: i.unit,
//           ))
//               .toList(),
//         ),
//       ),
//     );
//
//     if (result != null) {
//       setState(() => _despatchInfo = result);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Despatch sheet completed')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//     final date = DateFormat('dd MMM yyyy').format(_quotation.date);
//     final status = _despatchInfo != null ? _DummyStatus.dispatched : _quotation.status;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Owner Quotation Details', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.all(Responsive.w(18)),
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(16)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(_quotation.id, style: AppTextStyles.h2()),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: status.color.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: status.color.withOpacity(0.4)),
//                               ),
//                               child: Text(
//                                 status.label,
//                                 style: AppTextStyles.caption(color: status.color),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(4)),
//                         Text(date, style: AppTextStyles.caption()),
//                         const Divider(height: 28),
//                         _InfoRow(label: 'Contractor', value: _quotation.contractorName),
//                         _InfoRow(label: 'Site Address', value: _quotation.siteAddress),
//                         _InfoRow(label: 'Phone', value: _quotation.phone),
//                         if (_quotation.salesmanName.isNotEmpty)
//                           _InfoRow(label: 'Salesman', value: _quotation.salesmanName),
//                         if (_despatchInfo != null) ...[
//                           _InfoRow(label: 'Sent To', value: _despatchInfo!.assignedSalesman),
//                           if (_despatchInfo!.driverName.isNotEmpty)
//                             _InfoRow(
//                               label: 'Driver',
//                               value: _despatchInfo!.driverPhone.isEmpty
//                                   ? _despatchInfo!.driverName
//                                   : '${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})',
//                             ),
//                           if (_despatchInfo!.deliveryAddress.isNotEmpty)
//                             _InfoRow(label: 'Delivery Address', value: _despatchInfo!.deliveryAddress),
//                           _InfoRow(
//                             label: 'Despatch Date',
//                             value: DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Items', style: AppTextStyles.h3()),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceAlt,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           'Total Items: ${_quotation.items.length}',
//                           style: AppTextStyles.bodyBold(color: AppColors.primary),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(12)),
//
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
//                         headingTextStyle: AppTextStyles.bodyBold(),
//                         dataTextStyle: AppTextStyles.body(),
//                         columnSpacing: 18,
//                         columns: const [
//                           DataColumn(label: Text('Sl.No')),
//                           DataColumn(label: Text('Item')),
//                           DataColumn(label: Text('Company')),
//                           DataColumn(label: Text('Size')),
//                           DataColumn(label: Text('Qty'), numeric: true),
//                           DataColumn(label: Text('Unit')),
//                           DataColumn(label: Text('MRP'), numeric: true),
//                           DataColumn(label: Text('Rate'), numeric: true),
//                           DataColumn(label: Text('Amount'), numeric: true),
//                           DataColumn(label: Text('Incentive'), numeric: true),
//                         ],
//                         rows: _quotation.items.asMap().entries.map((entry) {
//                           final i = entry.key;
//                           final item = entry.value;
//                           return DataRow(cells: [
//                             DataCell(Text('${i + 1}')),
//                             DataCell(Text(item.name)),
//                             DataCell(Text(item.company.isEmpty ? '-' : item.company)),
//                             DataCell(Text(item.size.isEmpty ? '-' : item.size)),
//                             DataCell(Text(number.format(item.quantity))),
//                             DataCell(Text(item.unit)),
//                             DataCell(Text(number.format(item.mrp))),
//                             DataCell(Text(number.format(item.rate))),
//                             DataCell(Text(
//                               currency.format(item.amount),
//                               style: AppTextStyles.bodyBold(),
//                             )),
//                             DataCell(Text(
//                               currency.format(_incentiveAmountFor(item)),
//                               style: AppTextStyles.bodyBold(color: AppColors.success),
//                             )),
//                           ]);
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(16)),
//
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceAlt,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total Items', style: AppTextStyles.body()),
//                             Text('${_quotation.items.length}', style: AppTextStyles.body()),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(6)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('MRP Total', style: AppTextStyles.body()),
//                             Text(currency.format(_quotation.mrpTotal), style: AppTextStyles.body()),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(6)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Handling Charge', style: AppTextStyles.body()),
//                             Text(currency.format(_quotation.handlingCharge), style: AppTextStyles.body()),
//                           ],
//                         ),
//                         const Divider(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total Amount', style: AppTextStyles.h3()),
//                             Text(currency.format(_quotation.totalAmount), style: AppTextStyles.h2(color: AppColors.primary)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(12)),
//
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.success.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.success.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.percent, size: 18, color: AppColors.success),
//                             SizedBox(width: Responsive.w(8)),
//                             Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
//                             SizedBox(width: Responsive.w(6)),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
//                               decoration: BoxDecoration(
//                                 color: AppColors.success.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 '${_dummyIncentivePercent.toStringAsFixed(0)}% · dummy',
//                                 style: AppTextStyles.caption(color: AppColors.success),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           currency.format(_incentiveTotal),
//                           style: AppTextStyles.h3(color: AppColors.success),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
//               child: Row(
//                 children: [
//                   _RoundIconButton(
//                     icon: Icons.edit_outlined,
//                     tooltip: 'Edit',
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Wire this up to your edit flow')),
//                       );
//                     },
//                   ),
//                   SizedBox(width: Responsive.w(10)),
//                   _RoundIconButton(
//                     icon: Icons.share_outlined,
//                     tooltip: 'Share',
//                     onPressed: () async {
//                       await Clipboard.setData(ClipboardData(text: _buildShareText(currency)));
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Quotation summary copied to clipboard')),
//                         );
//                       }
//                     },
//                   ),
//                   SizedBox(width: Responsive.w(10)),
//                   Expanded(
//                     child: PrimaryButton(
//                       label: _despatchInfo == null
//                           ? 'Approve & Send to Despatch '
//                           : 'Sent to ${_despatchInfo!.assignedSalesman}',
//                       height: 48,
//                       onPressed: _showSendToDespatchDialog,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _RoundIconButton extends StatelessWidget {
//   const _RoundIconButton({
//     required this.icon,
//     required this.onPressed,
//     this.tooltip,
//   });
//
//   final IconData icon;
//   final VoidCallback? onPressed;
//   final String? tooltip;
//
//   @override
//   Widget build(BuildContext context) {
//     final button = InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Icon(icon, size: 20, color: AppColors.primary),
//       ),
//     );
//     if (tooltip == null) return button;
//     return Tooltip(message: tooltip!, child: button);
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//   const _InfoRow({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption())),
//           Expanded(child: Text(value, style: AppTextStyles.bodyBold())),
//         ],
//       ),
//     );
//   }
// }
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/primary_button.dart';
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
  // NEW: Party Name / Address — the top "Party Name" + "Address" block on
  // the sheet, separate from the Contractor block further down.
  final String partyName;
  final String partyAddress;
  final String contractorName;
  final String siteAddress;
  final String phone;
  final String salesmanName;
  final DateTime date;
  final _DummyStatus status;
  final double handlingCharge;
  // NEW: total square footage — shown as "Total Sqrft" on the sheet.
  final double totalSqrft;
  final List<_DummyItem> items;

  const _DummyQuotation({
    required this.id,
    required this.partyName,
    required this.partyAddress,
    required this.contractorName,
    required this.siteAddress,
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
  double get totalAmount => itemsTotal + handlingCharge;

  static _DummyQuotation sample() {
    return _DummyQuotation(
      id: 'QUO-2087',
      partyName: 'Ramesh Constructions',
      partyAddress: 'No. 24, Palace Road, Kanhangad',
      contractorName: 'Ramesh Constructions',
      siteAddress: 'No. 24, Palace Road, Kanhangad',
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
  'Vishnu Prasad',
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
      phone: widget.customerPhone ?? base.phone,
      salesmanName: widget.salesmanName ?? base.salesmanName,
      date: widget.date ?? base.date,
      status: base.status,
      handlingCharge: targetHandling,
      totalSqrft: base.totalSqrft,
      items: base.items,
    );
  }

  // Set once despatch is confirmed — either by picking a salesman in the
  // dialog below, or by completing the Owner Despatch Sheet after picking
  // "Assigned to Me".
  DespatchInfo? _despatchInfo;

  double get _incentiveTotal =>
      _quotation.items.fold(0.0, (s, item) => s + _incentiveAmountFor(item));

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
      ..writeln('Total: ${currency.format(_quotation.totalAmount)}');
    if (_quotation.salesmanName.isNotEmpty) {
      buffer.writeln('Salesman: ${_quotation.salesmanName}');
    }
    // NEW: total sqrft in the shared summary.
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
      _despatchInfo =

          DespatchInfo(
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
    final date = DateFormat('dd MMM yyyy').format(_quotation.date);
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
                  Container(
                    padding: EdgeInsets.all(Responsive.w(16)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_quotation.id, style: AppTextStyles.h2()),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: status.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: status.color.withOpacity(0.4)),
                              ),
                              child: Text(
                                status.label,
                                style: AppTextStyles.caption(color: status.color),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(4)),
                        Text(date, style: AppTextStyles.caption()),
                        const Divider(height: 28),
                        // NEW: Party Name / Address block.
                        _InfoRow(label: 'Party Name', value: _quotation.partyName),
                        _InfoRow(label: 'Party Address', value: _quotation.partyAddress),
                        _InfoRow(label: 'Contractor', value: _quotation.contractorName),
                        _InfoRow(label: 'Site Address', value: _quotation.siteAddress),
                        _InfoRow(label: 'Contractor Phone', value: _quotation.phone),
                        if (_quotation.salesmanName.isNotEmpty)
                          _InfoRow(label: 'Salesman', value: _quotation.salesmanName),
                        // NEW: total square footage ("Total Sqrft" on the sheet).
                        // _InfoRow(label: 'Total Sqrft', value: number.format(_quotation.totalSqrft)),
                        if (_despatchInfo != null) ...[
                          _InfoRow(label: 'Sent To', value: _despatchInfo!.assignedSalesman),
                          if (_despatchInfo!.driverName.isNotEmpty)
                            _InfoRow(
                              label: 'Driver',
                              value: _despatchInfo!.driverPhone.isEmpty
                                  ? _despatchInfo!.driverName
                                  : '${_despatchInfo!.driverName} (${_despatchInfo!.driverPhone})',
                            ),
                          if (_despatchInfo!.deliveryAddress.isNotEmpty)
                            _InfoRow(label: 'Delivery Address', value: _despatchInfo!.deliveryAddress),
                          _InfoRow(
                            label: 'Despatch Date',
                            value: DateFormat('dd MMM yyyy').format(_despatchInfo!.despatchDate),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                  SizedBox(height: Responsive.h(12)),

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
                          DataColumn(label: Text('Incentive'), numeric: true),
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
                            DataCell(Text(
                              currency.format(_incentiveAmountFor(item)),
                              style: AppTextStyles.bodyBold(color: AppColors.success),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Items', style: AppTextStyles.body()),
                            Text('${_quotation.items.length}', style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MRP Total', style: AppTextStyles.body()),
                            Text(currency.format(_quotation.mrpTotal), style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Handling Charge', style: AppTextStyles.body()),
                            Text(currency.format(_quotation.handlingCharge), style: AppTextStyles.body()),
                          ],
                        ),
                        SizedBox(height: Responsive.h(6)),
                        // NEW: Total Sqrft also shown in the bottom summary.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Sqrft', style: AppTextStyles.body()),
                            Text(number.format(_quotation.totalSqrft), style: AppTextStyles.body()),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTextStyles.h3()),
                            Text(currency.format(_quotation.totalAmount), style: AppTextStyles.h2(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),

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
                            Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
                            SizedBox(width: Responsive.w(6)),
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
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
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
                          ? 'Approve & Send to Despatch '
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption())),
          Expanded(child: Text(value, style: AppTextStyles.bodyBold())),
        ],
      ),
    );
  }
}