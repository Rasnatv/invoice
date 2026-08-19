//
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../bloc/ownerbloc/ownerviewqtndetail_bloc.dart';
// import '../../bloc/ownerbloc/ownerviewqtndetail_event.dart';
// import '../../bloc/ownerbloc/ownerviewqtndetail_state.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_styles.dart';
// import '../../core/utils/responsive.dart';
// import '../../models/owner_models/owner_quotationapprovemodel.dart';
// import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
// import '../../widgets/primary_button.dart';
// import 'ownerdespatchsheet.dart';
//
//
//
// /// Owner's view of a single quotation/estimate.
// ///
// /// Loads real data from POST /quotations/show and, when the quotation
// /// isn't approved yet, lets the owner approve it via POST /quotations/approve
// /// (optionally overriding the handling charge and capturing a discount /
// /// initial payment in the same call). Once approved, the bottom action
// /// switches to "Send to Despatch", which opens the real despatch-sheet
// /// flow (POST /despatches/suggest -> GET /drivers/active -> POST
// /// /despatches/create) instead of a dummy salesman-picker dialog.
// class OwnerQuotationDetailsScreen extends StatelessWidget {
//   const OwnerQuotationDetailsScreen({super.key, required this.quotationId});
//
//   final String quotationId;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => OwnerQuotationDetailBloc()
//         ..add(OwnerQuotationDetailRequested(quotationId)),
//       child: _OwnerQuotationDetailsView(quotationId: quotationId),
//     );
//   }
// }
//
// class _OwnerQuotationDetailsView extends StatefulWidget {
//   const _OwnerQuotationDetailsView({required this.quotationId});
//   final String quotationId;
//
//   @override
//   State<_OwnerQuotationDetailsView> createState() => _OwnerQuotationDetailsViewState();
// }
//
// class _OwnerQuotationDetailsViewState extends State<_OwnerQuotationDetailsView> {
//   // Flips once a despatch sheet has been successfully created via
//   // OwnerDespatchSheetScreen -> POST /despatches/create, just to relabel
//   // the bottom button. The estimate can still be despatched again for
//   // partial/remaining quantities, so this never disables the button.
//   bool _despatchCreated = false;
//
//   @override
//   void dispose() {
//     context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationDetailCleared());
//     super.dispose();
//   }
//
//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return Colors.green;
//       case 'submitted':
//       case 'pending':
//         return Colors.orange;
//       case 'rejected':
//         return Colors.red;
//       case 'draft':
//         return Colors.blueGrey;
//       default:
//         return AppColors.primary;
//     }
//   }
//
//   String _buildShareText(
//       QuotationDetailModel q,
//       NumberFormat currency,
//       NumberFormat number,
//       ) {
//     final buffer = StringBuffer()
//       ..writeln('Quotation ${q.quotationNumber}')
//       ..writeln('Customer: ${q.customer.name}')
//       ..writeln('Address: ${q.customer.address}')
//       ..writeln('Contractor: ${q.contractor.name}')
//       ..writeln(
//           'Date: ${q.date != null ? DateFormat('dd MMM yyyy').format(q.date!) : q.dateRaw}')
//       ..writeln('---');
//     for (final item in q.items) {
//       buffer.writeln(
//         '${item.productName} (${item.productSize}) x ${number.format(item.quantity)} ${item.productUnit} = ${currency.format(item.amount)}',
//       );
//     }
//     buffer
//       ..writeln('---')
//       ..writeln('Handling Charge: ${currency.format(q.handlingCharge)}')
//       ..writeln('Grand Total: ${currency.format(q.grandTotal)}');
//     if (q.salesman.name.isNotEmpty) {
//       buffer.writeln('Salesman: ${q.salesman.name}');
//     }
//     buffer.writeln('Total Sqft: ${number.format(q.totalSquareFeet)}');
//     if (_despatchCreated) {
//       buffer.writeln('Despatch: Created');
//     }
//     return buffer.toString();
//   }
//
//   Future<void> _showApproveDialog(QuotationDetailModel q) async {
//     final formKey = GlobalKey<FormState>();
//     final handlingCtrl = TextEditingController(
//       text: q.handlingCharge > 0 ? q.handlingCharge.toStringAsFixed(2) : '',
//     );
//     final approvalNotesCtrl = TextEditingController();
//
//     String? discountType; // null | 'percentage' | 'flat'
//     final discountValueCtrl = TextEditingController();
//     final discountNotesCtrl = TextEditingController();
//
//     final paymentAmountCtrl = TextEditingController();
//     String? paymentMethod; // 'cash' | 'online' | 'cheque'
//     final paymentReferenceCtrl = TextEditingController();
//     DateTime? paymentDate;
//     final paymentNotesCtrl = TextEditingController();
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text('Approve Quotation'),
//               content: SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: handlingCtrl,
//                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         decoration: const InputDecoration(
//                           labelText: 'Handling Charge (optional)',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: approvalNotesCtrl,
//                         decoration: const InputDecoration(
//                           labelText: 'Approval Notes (optional)',
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLines: 2,
//                       ),
//                       const Divider(height: 28),
//                       Text('Discount (optional)', style: AppTextStyles.bodyBold()),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         value: discountType,
//                         decoration: const InputDecoration(
//                           labelText: 'Discount Type',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: null, child: Text('None')),
//                           DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
//                           DropdownMenuItem(value: 'flat', child: Text('Flat Amount')),
//                         ],
//                         onChanged: (v) => setDialogState(() => discountType = v),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: discountValueCtrl,
//                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         enabled: discountType != null,
//                         decoration: const InputDecoration(
//                           labelText: 'Discount Value',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: discountNotesCtrl,
//                         enabled: discountType != null,
//                         decoration: const InputDecoration(
//                           labelText: 'Discount Notes',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const Divider(height: 28),
//                       Text('Initial Payment (optional)', style: AppTextStyles.bodyBold()),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: paymentAmountCtrl,
//                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                         decoration: const InputDecoration(
//                           labelText: 'Payment Amount',
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (_) => setDialogState(() {}),
//                       ),
//                       const SizedBox(height: 12),
//                       DropdownButtonFormField<String>(
//                         value: paymentMethod,
//                         decoration: const InputDecoration(
//                           labelText: 'Payment Method',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: null, child: Text('Select')),
//                           DropdownMenuItem(value: 'cash', child: Text('Cash')),
//                           DropdownMenuItem(value: 'online', child: Text('Online')),
//                           DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
//                         ],
//                         onChanged: paymentAmountCtrl.text.trim().isEmpty
//                             ? null
//                             : (v) => setDialogState(() => paymentMethod = v),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: paymentReferenceCtrl,
//                         enabled: paymentAmountCtrl.text.trim().isNotEmpty,
//                         decoration: const InputDecoration(
//                           labelText: 'Payment Reference (e.g. TXN No.)',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       InkWell(
//                         onTap: paymentAmountCtrl.text.trim().isEmpty
//                             ? null
//                             : () async {
//                           final picked = await showDatePicker(
//                             context: context,
//                             initialDate: paymentDate ?? DateTime.now(),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2100),
//                           );
//                           if (picked != null) {
//                             setDialogState(() => paymentDate = picked);
//                           }
//                         },
//                         child: InputDecorator(
//                           decoration: const InputDecoration(
//                             labelText: 'Payment Date',
//                             border: OutlineInputBorder(),
//                           ),
//                           child: Text(
//                             paymentDate == null
//                                 ? 'Select date'
//                                 : DateFormat('dd-MM-yyyy').format(paymentDate!),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: paymentNotesCtrl,
//                         enabled: paymentAmountCtrl.text.trim().isNotEmpty,
//                         decoration: const InputDecoration(
//                           labelText: 'Payment Notes',
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLines: 2,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(dialogContext).pop(false),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.of(dialogContext).pop(true),
//                   child: const Text('Approve'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//
//     if (confirmed != true || !mounted) return;
//
//     final handlingCharge = double.tryParse(handlingCtrl.text.trim());
//     final discountValue = double.tryParse(discountValueCtrl.text.trim());
//     final paymentAmount = double.tryParse(paymentAmountCtrl.text.trim());
//
//     final request = QuotationApproveRequest(
//       id: widget.quotationId,
//       handlingCharge: handlingCharge,
//       approvalNotes: approvalNotesCtrl.text,
//       discountType: discountType,
//       discountValue: discountType != null ? discountValue : null,
//       discountNotes: discountType != null ? discountNotesCtrl.text : null,
//       paymentAmount: paymentAmount,
//       paymentMethod: paymentAmount != null ? paymentMethod : null,
//       paymentReference: paymentAmount != null ? paymentReferenceCtrl.text : null,
//       paymentDate: paymentAmount != null && paymentDate != null
//           ? DateFormat('yyyy-MM-dd').format(paymentDate!)
//           : null,
//       paymentNotes: paymentAmount != null ? paymentNotesCtrl.text : null,
//     );
//
//     context.read<OwnerQuotationDetailBloc>().add(OwnerQuotationApproveRequested(request));
//   }
//
//   /// Opens the real despatch-sheet screen (suggest -> assign driver ->
//   /// create), keyed off this quotation/estimate's id.
//   Future<void> _openDespatchSheet(QuotationDetailModel q) async {
//     final created = await Navigator.of(context).push<bool>(
//       MaterialPageRoute(
//         builder: (_) => OwnerDespatchSheetScreen(estimateId: q.id),
//       ),
//     );
//
//     if (created == true && mounted) {
//       setState(() => _despatchCreated = true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Owner Quotation Details', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: BlocConsumer<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
//           listenWhen: (previous, current) =>
//           previous.approveStatus != current.approveStatus,
//           listener: (context, state) {
//             if (state.approveStatus == OwnerQuotationApproveStatus.success) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.approveMessage ?? 'Quotation approved successfully.')),
//               );
//               context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationApproveResultConsumed());
//             } else if (state.approveStatus == OwnerQuotationApproveStatus.failure) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.approveError ?? 'Failed to approve quotation.')),
//               );
//               context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationApproveResultConsumed());
//             }
//           },
//           builder: (context, state) {
//             if (state.detailStatus == OwnerQuotationDetailStatus.loading ||
//                 state.detailStatus == OwnerQuotationDetailStatus.initial) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (state.detailStatus == OwnerQuotationDetailStatus.failure) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.error_outline, size: 40, color: AppColors.textHint),
//                       const SizedBox(height: 12),
//                       Text(
//                         state.detailError ?? 'Failed to load quotation.',
//                         textAlign: TextAlign.center,
//                         style: AppTextStyles.body(),
//                       ),
//                       const SizedBox(height: 16),
//                       PrimaryButton(
//                         label: 'Retry',
//                         height: 44,
//                         onPressed: () => context
//                             .read<OwnerQuotationDetailBloc>()
//                             .add(OwnerQuotationDetailRequested(widget.quotationId)),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//
//             final q = state.detail;
//             if (q == null) {
//               return const Center(child: Text('No data found.'));
//             }
//
//             final isApproved = q.status.toLowerCase() == 'approved';
//             final isApproving = state.approveStatus == OwnerQuotationApproveStatus.inProgress;
//
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView(
//                     padding: EdgeInsets.all(Responsive.w(18)),
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(Responsive.w(14)),
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceAlt,
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Quotation No.', style: AppTextStyles.caption()),
//                                 Text(q.quotationNumber, style: AppTextStyles.h3()),
//                               ],
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text('Date', style: AppTextStyles.caption()),
//                                 Text(
//                                   q.date != null
//                                       ? DateFormat('dd-MM-yyyy').format(q.date!)
//                                       : q.dateRaw,
//                                   style: AppTextStyles.h3(),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(10)),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: _statusColor(q.status).withValues(alpha: 0.12),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             q.status.isEmpty ? '-' : q.status,
//                             style: AppTextStyles.bodyBold(color: _statusColor(q.status)),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(16)),
//
//                       _DetailSection(
//                         title: 'Customer Details',
//                         rows: [
//                           _Row('Name', q.customer.name, icon: Icons.groups_2_outlined),
//                           _Row('Address', q.customer.address, icon: Icons.location_on_outlined),
//                           _Row('Phone', q.customer.phone, icon: Icons.phone_outlined),
//                           if (q.customer.email.isNotEmpty)
//                             _Row('Email', q.customer.email, icon: Icons.email_outlined),
//                         ],
//                       ),
//                       SizedBox(height: Responsive.h(14)),
//                       _DetailSection(
//                         title: 'Contractor Details',
//                         rows: [
//                           _Row('Name', q.contractor.name, icon: Icons.engineering_outlined),
//                           _Row('Mobile', q.contractor.mobile, icon: Icons.phone_outlined),
//                           if (q.contractor.address.isNotEmpty)
//                             _Row('Address', q.contractor.address, icon: Icons.location_on_outlined),
//                         ],
//                       ),
//                       SizedBox(height: Responsive.h(14)),
//                       _DetailSection(
//                         title: 'Salesman',
//                         rows: [
//                           _Row('Name', q.salesman.name, icon: Icons.badge_outlined),
//                           if (q.salesman.employeeCode.isNotEmpty)
//                             _Row('Employee Code', q.salesman.employeeCode, icon: Icons.badge_outlined),
//                           _Row('Created By', q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
//                               icon: Icons.person_outline),
//                         ],
//                       ),
//                       if (q.notes.isNotEmpty) ...[
//                         SizedBox(height: Responsive.h(14)),
//                         _DetailSection(
//                           title: 'Notes',
//                           rows: [_Row('Notes', q.notes, icon: Icons.notes_outlined)],
//                         ),
//                       ],
//                       if (_despatchCreated) ...[
//                         SizedBox(height: Responsive.h(14)),
//                         _DetailSection(
//                           title: 'Despatch',
//                           rows: [
//                             _Row('Status', 'Despatch sheet created',
//                                 icon: Icons.local_shipping_outlined),
//                           ],
//                         ),
//                       ],
//                       SizedBox(height: Responsive.h(20)),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Items', style: AppTextStyles.h3()),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: Responsive.w(10), vertical: Responsive.h(4)),
//                             decoration: BoxDecoration(
//                               color: AppColors.surfaceAlt,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               'Total Items: ${q.itemsCount}',
//                               style: AppTextStyles.bodyBold(color: AppColors.primary),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: Responsive.h(10)),
//
//                       Container(
//                         decoration: BoxDecoration(
//                           color: AppColors.surface,
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(color: AppColors.border),
//                         ),
//                         clipBehavior: Clip.antiAlias,
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: DataTable(
//                             headingRowColor: WidgetStateProperty.all(AppColors.surfaceAlt),
//                             headingTextStyle: AppTextStyles.bodyBold(),
//                             dataTextStyle: AppTextStyles.body(),
//                             columnSpacing: 18,
//                             columns: const [
//                               DataColumn(label: Text('Sl.No')),
//                               DataColumn(label: Text('Item')),
//                               DataColumn(label: Text('Size')),
//                               DataColumn(label: Text('Qty'), numeric: true),
//                               DataColumn(label: Text('Unit')),
//                               DataColumn(label: Text('Rate'), numeric: true),
//                               DataColumn(label: Text('Amount'), numeric: true),
//                               DataColumn(label: Text('Incentive'), numeric: true),
//                             ],
//                             rows: q.items.asMap().entries.map((entry) {
//                               final i = entry.key;
//                               final item = entry.value;
//                               return DataRow(cells: [
//                                 DataCell(Text('${i + 1}')),
//                                 DataCell(Text(item.productName)),
//                                 DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
//                                 DataCell(Text(number.format(item.quantity))),
//                                 DataCell(Text(item.productUnit)),
//                                 DataCell(Text(number.format(item.rate))),
//                                 DataCell(Text(
//                                   currency.format(item.amount),
//                                   style: AppTextStyles.bodyBold(),
//                                 )),
//                                 DataCell(Text(
//                                   item.isIncentiveEligible
//                                       ? currency.format(item.incentiveAmount)
//                                       : '-',
//                                   style: AppTextStyles.body(color: AppColors.success),
//                                 )),
//                               ]);
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(16)),
//
//                       Container(
//                         padding: EdgeInsets.all(Responsive.w(14)),
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceAlt,
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Column(
//                           children: [
//                             _totalRow('Total Items', '${q.itemsCount}'),
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Total Qty', number.format(q.totalQuantity)),
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Subtotal', currency.format(q.subtotal)),
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Handling Charge', currency.format(q.handlingCharge)),
//                             SizedBox(height: Responsive.h(6)),
//                             _totalRow('Total Sqft', number.format(q.totalSquareFeet)),
//                             const Divider(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('Grand Total', style: AppTextStyles.h3()),
//                                 Text(currency.format(q.grandTotal),
//                                     style: AppTextStyles.h2(color: AppColors.primary)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(12)),
//
//                       // Total incentive across items — internal/salesman
//                       // info, kept visually separate from the customer bill.
//                       Container(
//                         padding: EdgeInsets.all(Responsive.w(14)),
//                         decoration: BoxDecoration(
//                           color: AppColors.success.withValues(alpha: 0.08),
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(Icons.percent, size: 18, color: AppColors.success),
//                                 SizedBox(width: Responsive.w(8)),
//                                 Text('Total Incentive', style: AppTextStyles.bodyBold(color: AppColors.success)),
//                               ],
//                             ),
//                             Text(
//                               currency.format(
//                                 q.items.fold<double>(0, (s, i) => s + i.incentiveAmount),
//                               ),
//                               style: AppTextStyles.h3(color: AppColors.success),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(12)),
//                     ],
//                   ),
//                 ),
//
//                 // Bottom action bar.
//                 Container(
//                   padding: EdgeInsets.fromLTRB(
//                       Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
//                   decoration: BoxDecoration(
//                     color: AppColors.background,
//                     border: Border(top: BorderSide(color: AppColors.border)),
//                   ),
//                   child: Row(
//                     children: [
//                       _RoundIconButton(
//                         icon: Icons.share_outlined,
//                         tooltip: 'Share',
//                         onPressed: () async {
//                           await Clipboard.setData(
//                             ClipboardData(text: _buildShareText(q, currency, number)),
//                           );
//                           if (context.mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Quotation summary copied to clipboard')),
//                             );
//                           }
//                         },
//                       ),
//                       SizedBox(width: Responsive.w(10)),
//                       Expanded(
//                         child: isApproved
//                             ? PrimaryButton(
//                           label: _despatchCreated
//                               ? 'Create Another Despatch'
//                               : 'Send to Despatch',
//                           height: 48,
//                           onPressed: () => _openDespatchSheet(q),
//                         )
//                             : PrimaryButton(
//                           label: isApproving ? 'Approving...' : 'Approve Quotation',
//                           height: 48,
//                           onPressed: isApproving ? null : () => _showApproveDialog(q),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _totalRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: AppTextStyles.body()),
//         Text(value, style: AppTextStyles.body()),
//       ],
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
// class _Row {
//   final String label;
//   final String value;
//   final IconData? icon;
//   _Row(this.label, this.value, {this.icon});
// }
//
// class _DetailSection extends StatelessWidget {
//   const _DetailSection({required this.title, required this.rows});
//   final String title;
//   final List<_Row> rows;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
//           SizedBox(height: Responsive.h(10)),
//           ...rows.map((r) => Padding(
//             padding: EdgeInsets.only(bottom: Responsive.h(10)),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (r.icon != null) ...[
//                   Icon(r.icon, size: 16, color: AppColors.textHint),
//                   SizedBox(width: Responsive.w(8)),
//                 ],
//                 SizedBox(
//                   width: r.icon != null ? 88 : 100,
//                   child: Text(r.label, style: AppTextStyles.caption()),
//                 ),
//                 Expanded(
//                   child: Text(
//                     r.value.isEmpty ? '-' : r.value,
//                     style: AppTextStyles.bodyBold(),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }
// }
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_bloc.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_event.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/owner_quotationapprovemodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/primary_button.dart';
import 'ownerdespatchsheet.dart';
import 'ownerquotationeditscreen.dart';



/// Owner's view of a single quotation/estimate.
///
/// Loads real data from POST /quotations/show and, when the quotation
/// isn't approved yet, lets the owner approve it via POST /quotations/approve
/// (optionally overriding the handling charge and capturing a discount /
/// initial payment in the same call). Once approved, the bottom action
/// switches to "Send to Despatch", which opens the real despatch-sheet
/// flow (POST /despatches/suggest -> GET /drivers/active -> POST
/// /despatches/create) instead of a dummy salesman-picker dialog.
///
/// An Edit action (top-right icon) opens OwnerQuotationEditScreen, prefilled
/// from this already-loaded detail, and saves via POST /quotations/update.
/// On a successful edit the detail is re-fetched so the screen reflects the
/// new customer/contractor/items/totals immediately.
class OwnerQuotationDetailsScreen extends StatelessWidget {
  const OwnerQuotationDetailsScreen({super.key, required this.quotationId});

  final String quotationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerQuotationDetailBloc()
        ..add(OwnerQuotationDetailRequested(quotationId)),
      child: _OwnerQuotationDetailsView(quotationId: quotationId),
    );
  }
}

class _OwnerQuotationDetailsView extends StatefulWidget {
  const _OwnerQuotationDetailsView({required this.quotationId});
  final String quotationId;

  @override
  State<_OwnerQuotationDetailsView> createState() => _OwnerQuotationDetailsViewState();
}

class _OwnerQuotationDetailsViewState extends State<_OwnerQuotationDetailsView> {
  // Flips once a despatch sheet has been successfully created via
  // OwnerDespatchSheetScreen -> POST /despatches/create, just to relabel
  // the bottom button. The estimate can still be despatched again for
  // partial/remaining quantities, so this never disables the button.
  bool _despatchCreated = false;

  @override
  void dispose() {
    context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationDetailCleared());
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'submitted':
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'draft':
        return Colors.blueGrey;
      default:
        return AppColors.primary;
    }
  }

  String _buildShareText(
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
      ..writeln('Handling Charge: ${currency.format(q.handlingCharge)}')
      ..writeln('Grand Total: ${currency.format(q.grandTotal)}');
    if (q.salesman.name.isNotEmpty) {
      buffer.writeln('Salesman: ${q.salesman.name}');
    }
    buffer.writeln('Total Sqft: ${number.format(q.totalSquareFeet)}');
    if (_despatchCreated) {
      buffer.writeln('Despatch: Created');
    }
    return buffer.toString();
  }

  /// Opens OwnerQuotationEditScreen prefilled with the currently loaded
  /// detail. On a successful save (screen pops with `true`) the detail is
  /// re-fetched so this screen reflects the edited customer/contractor/
  /// items/totals without a manual pull-to-refresh.
  Future<void> _openEditScreen(QuotationDetailModel q) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationEditScreen(estimate: q),
      ),
    );

    if (saved == true && mounted) {
      context
          .read<OwnerQuotationDetailBloc>()
          .add(OwnerQuotationDetailRequested(widget.quotationId));
    }
  }

  Future<void> _showApproveDialog(QuotationDetailModel q) async {
    final formKey = GlobalKey<FormState>();
    final handlingCtrl = TextEditingController(
      text: q.handlingCharge > 0 ? q.handlingCharge.toStringAsFixed(2) : '',
    );
    final approvalNotesCtrl = TextEditingController();

    String? discountType; // null | 'percentage' | 'flat'
    final discountValueCtrl = TextEditingController();
    final discountNotesCtrl = TextEditingController();

    final paymentAmountCtrl = TextEditingController();
    String? paymentMethod; // 'cash' | 'online' | 'cheque'
    final paymentReferenceCtrl = TextEditingController();
    DateTime? paymentDate;
    final paymentNotesCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Approve Quotation'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: handlingCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Handling Charge (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: approvalNotesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Approval Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const Divider(height: 28),
                      Text('Discount (optional)', style: AppTextStyles.bodyBold()),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: discountType,
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('None')),
                          DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                          DropdownMenuItem(value: 'flat', child: Text('Flat Amount')),
                        ],
                        onChanged: (v) => setDialogState(() => discountType = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: discountValueCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        enabled: discountType != null,
                        decoration: const InputDecoration(
                          labelText: 'Discount Value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: discountNotesCtrl,
                        enabled: discountType != null,
                        decoration: const InputDecoration(
                          labelText: 'Discount Notes',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const Divider(height: 28),
                      Text('Initial Payment (optional)', style: AppTextStyles.bodyBold()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: paymentAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Payment Amount',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Select')),
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'online', child: Text('Online')),
                          DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                        ],
                        onChanged: paymentAmountCtrl.text.trim().isEmpty
                            ? null
                            : (v) => setDialogState(() => paymentMethod = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentReferenceCtrl,
                        enabled: paymentAmountCtrl.text.trim().isNotEmpty,
                        decoration: const InputDecoration(
                          labelText: 'Payment Reference (e.g. TXN No.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: paymentAmountCtrl.text.trim().isEmpty
                            ? null
                            : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: paymentDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() => paymentDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Payment Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            paymentDate == null
                                ? 'Select date'
                                : DateFormat('dd-MM-yyyy').format(paymentDate!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentNotesCtrl,
                        enabled: paymentAmountCtrl.text.trim().isNotEmpty,
                        decoration: const InputDecoration(
                          labelText: 'Payment Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final handlingCharge = double.tryParse(handlingCtrl.text.trim());
    final discountValue = double.tryParse(discountValueCtrl.text.trim());
    final paymentAmount = double.tryParse(paymentAmountCtrl.text.trim());

    final request = QuotationApproveRequest(
      id: widget.quotationId,
      handlingCharge: handlingCharge,
      approvalNotes: approvalNotesCtrl.text,
      discountType: discountType,
      discountValue: discountType != null ? discountValue : null,
      discountNotes: discountType != null ? discountNotesCtrl.text : null,
      paymentAmount: paymentAmount,
      paymentMethod: paymentAmount != null ? paymentMethod : null,
      paymentReference: paymentAmount != null ? paymentReferenceCtrl.text : null,
      paymentDate: paymentAmount != null && paymentDate != null
          ? DateFormat('yyyy-MM-dd').format(paymentDate!)
          : null,
      paymentNotes: paymentAmount != null ? paymentNotesCtrl.text : null,
    );

    context.read<OwnerQuotationDetailBloc>().add(OwnerQuotationApproveRequested(request));
  }

  /// Opens the real despatch-sheet screen (suggest -> assign driver ->
  /// create), keyed off this quotation/estimate's id.
  Future<void> _openDespatchSheet(QuotationDetailModel q) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(estimateId: q.id),
      ),
    );

    if (created == true && mounted) {
      setState(() => _despatchCreated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Owner Quotation Details', style: AppTextStyles.h6()),
        actions: [
          BlocBuilder<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
            buildWhen: (prev, curr) => prev.detail != curr.detail,
            builder: (context, state) {
              final q = state.detail;
              if (q == null) return const SizedBox.shrink();
              // Editing stays available regardless of status (approved
              // quotations can still need a correction) — the update API
              // itself doesn't gate on status.
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Quotation',
                onPressed: () => _openEditScreen(q),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
          listenWhen: (previous, current) =>
          previous.approveStatus != current.approveStatus,
          listener: (context, state) {
            if (state.approveStatus == OwnerQuotationApproveStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.approveMessage ?? 'Quotation approved successfully.')),
              );
              context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationApproveResultConsumed());
            } else if (state.approveStatus == OwnerQuotationApproveStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.approveError ?? 'Failed to approve quotation.')),
              );
              context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationApproveResultConsumed());
            }
          },
          builder: (context, state) {
            if (state.detailStatus == OwnerQuotationDetailStatus.loading ||
                state.detailStatus == OwnerQuotationDetailStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.detailStatus == OwnerQuotationDetailStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        state.detailError ?? 'Failed to load quotation.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Retry',
                        height: 44,
                        onPressed: () => context
                            .read<OwnerQuotationDetailBloc>()
                            .add(OwnerQuotationDetailRequested(widget.quotationId)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final q = state.detail;
            if (q == null) {
              return const Center(child: Text('No data found.'));
            }

            final isApproved = q.status.toLowerCase() == 'approved';
            final isApproving = state.approveStatus == OwnerQuotationApproveStatus.inProgress;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(18)),
                    children: [
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
                                Text(q.quotationNumber, style: AppTextStyles.h3()),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Date', style: AppTextStyles.caption()),
                                Text(
                                  q.date != null
                                      ? DateFormat('dd-MM-yyyy').format(q.date!)
                                      : q.dateRaw,
                                  style: AppTextStyles.h3(),
                                ),
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
                            color: _statusColor(q.status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            q.status.isEmpty ? '-' : q.status,
                            style: AppTextStyles.bodyBold(color: _statusColor(q.status)),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(16)),

                      _DetailSection(
                        title: 'Customer Details',
                        rows: [
                          _Row('Name', q.customer.name, icon: Icons.groups_2_outlined),
                          _Row('Address', q.customer.address, icon: Icons.location_on_outlined),
                          _Row('Phone', q.customer.phone, icon: Icons.phone_outlined),
                          if (q.customer.email.isNotEmpty)
                            _Row('Email', q.customer.email, icon: Icons.email_outlined),
                        ],
                      ),
                      SizedBox(height: Responsive.h(14)),
                      _DetailSection(
                        title: 'Contractor Details',
                        rows: [
                          _Row('Name', q.contractor.name, icon: Icons.engineering_outlined),
                          _Row('Mobile', q.contractor.mobile, icon: Icons.phone_outlined),
                          if (q.contractor.address.isNotEmpty)
                            _Row('Address', q.contractor.address, icon: Icons.location_on_outlined),
                        ],
                      ),
                      SizedBox(height: Responsive.h(14)),
                      _DetailSection(
                        title: 'Salesman',
                        rows: [
                          _Row('Name', q.salesman.name, icon: Icons.badge_outlined),
                          if (q.salesman.employeeCode.isNotEmpty)
                            _Row('Employee Code', q.salesman.employeeCode, icon: Icons.badge_outlined),
                          _Row('Created By', q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
                              icon: Icons.person_outline),
                        ],
                      ),
                      if (q.notes.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(14)),
                        _DetailSection(
                          title: 'Notes',
                          rows: [_Row('Notes', q.notes, icon: Icons.notes_outlined)],
                        ),
                      ],
                      if (_despatchCreated) ...[
                        SizedBox(height: Responsive.h(14)),
                        _DetailSection(
                          title: 'Despatch',
                          rows: [
                            _Row('Status', 'Despatch sheet created',
                                icon: Icons.local_shipping_outlined),
                          ],
                        ),
                      ],
                      SizedBox(height: Responsive.h(20)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items', style: AppTextStyles.h3()),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Total Items: ${q.itemsCount}',
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
                            headingRowColor: WidgetStateProperty.all(AppColors.surfaceAlt),
                            headingTextStyle: AppTextStyles.bodyBold(),
                            dataTextStyle: AppTextStyles.body(),
                            columnSpacing: 18,
                            columns: const [
                              DataColumn(label: Text('Sl.No')),
                              DataColumn(label: Text('Item')),
                              DataColumn(label: Text('Size')),
                              DataColumn(label: Text('Qty'), numeric: true),
                              DataColumn(label: Text('Unit')),
                              DataColumn(label: Text('Rate'), numeric: true),
                              DataColumn(label: Text('Amount'), numeric: true),
                              DataColumn(label: Text('Incentive'), numeric: true),
                            ],
                            rows: q.items.asMap().entries.map((entry) {
                              final i = entry.key;
                              final item = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${i + 1}')),
                                DataCell(Text(item.productName)),
                                DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                                DataCell(Text(number.format(item.quantity))),
                                DataCell(Text(item.productUnit)),
                                DataCell(Text(number.format(item.rate))),
                                DataCell(Text(
                                  currency.format(item.amount),
                                  style: AppTextStyles.bodyBold(),
                                )),
                                DataCell(Text(
                                  item.isIncentiveEligible
                                      ? currency.format(item.incentiveAmount)
                                      : '-',
                                  style: AppTextStyles.body(color: AppColors.success),
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
                            _totalRow('Total Items', '${q.itemsCount}'),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Total Qty', number.format(q.totalQuantity)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Subtotal', currency.format(q.subtotal)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Handling Charge', currency.format(q.handlingCharge)),
                            SizedBox(height: Responsive.h(6)),
                            _totalRow('Total Sqft', number.format(q.totalSquareFeet)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Grand Total', style: AppTextStyles.h3()),
                                Text(currency.format(q.grandTotal),
                                    style: AppTextStyles.h2(color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(12)),

                      // Total incentive across items — internal/salesman
                      // info, kept visually separate from the customer bill.
                      Container(
                        padding: EdgeInsets.all(Responsive.w(14)),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.percent, size: 18, color: AppColors.success),
                                SizedBox(width: Responsive.w(8)),
                                Text('Total Incentive', style: AppTextStyles.bodyBold(color: AppColors.success)),
                              ],
                            ),
                            Text(
                              currency.format(
                                q.items.fold<double>(0, (s, i) => s + i.incentiveAmount),
                              ),
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
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.share_outlined,
                        tooltip: 'Share',
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _buildShareText(q, currency, number)),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Quotation summary copied to clipboard')),
                            );
                          }
                        },
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: isApproved
                            ? PrimaryButton(
                          label: _despatchCreated
                              ? 'Create Another Despatch'
                              : 'Send to Despatch',
                          height: 48,
                          onPressed: () => _openDespatchSheet(q),
                        )
                            : PrimaryButton(
                          label: isApproving ? 'Approving...' : 'Approve Quotation',
                          height: 48,
                          onPressed: isApproving ? null : () => _showApproveDialog(q),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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