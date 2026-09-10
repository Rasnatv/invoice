//
//
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_bloc.dart';
// import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_event.dart';
// import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_state.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_styles.dart';
// import '../../core/utils/responsive.dart';
// import '../../models/owner_models/owner_quotationapprovemodel.dart';
// import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
// import '../../widgets/appsnackbar.dart';
// import '../../widgets/primary_button.dart';
// import 'ownerquotationeditscreen.dart';
//
//
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
//   // Cache the bloc reference while context is still safely attached to
//   // the tree. context.read<T>() (an InheritedWidget ancestor lookup)
//   // inside dispose() is unsafe -- by the time dispose() runs the element
//   // may already be deactivated, which throws:
//   // "Looking up a deactivated widget's ancestor is unsafe."
//   // didChangeDependencies() always runs before dispose() can possibly
//   // run, so this is guaranteed to be set in time.
//   late final OwnerQuotationDetailBloc _detailBloc;
//
//   @override
//   void initState() {
//     super.initState();
//     // initState() runs exactly once per State object (unlike
//     // didChangeDependencies(), which can run again later and would throw
//     // a LateInitializationError on the second assignment). The
//     // BlocProvider ancestor is already in the tree by this point, so
//     // context.read() here is safe.
//     _detailBloc = context.read<OwnerQuotationDetailBloc>();
//   }
//
//   @override
//   void dispose() {
//     _detailBloc.add(const OwnerQuotationDetailCleared());
//     super.dispose();
//   }
//
//   /// Whether the quotation's `created_by` is an Owner, derived straight
//   /// from the response (`created_by.role_label` / `role`) rather than any
//   /// local session — no separate auth/role source is used. Incentive
//   /// figures are salesman-facing info, so they're hidden when the creator
//   /// is the Owner.
//   bool _isOwner(QuotationDetailModel q) {
//     final label = q.createdBy.roleLabel.trim().toLowerCase();
//     if (label.isNotEmpty) return label == 'owner';
//     // Fallback to the raw role code if role_label wasn't sent.
//     return q.createdBy.role.trim().toLowerCase() == 'owner';
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
//     return buffer.toString();
//   }
//
//   /// Opens OwnerQuotationEditScreen prefilled with the currently loaded
//   /// detail. On a successful save (screen pops with `true`) the detail is
//   /// re-fetched so this screen reflects the edited customer/contractor/
//   /// items/totals without a manual pull-to-refresh.
//   Future<void> _openEditScreen(QuotationDetailModel q) async {
//     final saved = await Navigator.of(context).push<bool>(
//       MaterialPageRoute(
//         builder: (_) => OwnerQuotationEditScreen(estimate: q),
//       ),
//     );
//
//     if (saved == true && mounted) {
//       context
//           .read<OwnerQuotationDetailBloc>()
//           .add(OwnerQuotationDetailRequested(widget.quotationId));
//     }
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
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return NetworkAwareWrapper(child: Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('Owner Quotation Details', style: AppTextStyles.h6()),
//         actions: [
//           BlocBuilder<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
//             buildWhen: (prev, curr) => prev.detail != curr.detail,
//             builder: (context, state) {
//               final q = state.detail;
//               if (q == null) return const SizedBox.shrink();
//               // Editing stays available regardless of status (approved
//               // quotations can still need a correction) — the update API
//               // itself doesn't gate on status.
//               return IconButton(
//                 icon: const Icon(Icons.edit_outlined),
//                 tooltip: 'Edit Quotation',
//                 onPressed: () => _openEditScreen(q),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: BlocConsumer<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
//           listenWhen: (previous, current) =>
//           previous.approveStatus != current.approveStatus,
//           listener: (context, state) {
//             if (state.approveStatus == OwnerQuotationApproveStatus.success) {
//               AppSnackbar.success(state.approveMessage ?? 'Quotation approved successfully.');
//               context.read<OwnerQuotationDetailBloc>().add(const OwnerQuotationApproveResultConsumed());
//             } else if (state.approveStatus == OwnerQuotationApproveStatus.failure) {
//               AppSnackbar.error(state.approveError ?? 'Failed to approve quotation.');
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
//             // Derived from created_by.role_label / role in the response —
//             // no separate session/role source. Incentive figures are
//             // salesman-facing, so hide them when the creator is the Owner.
//             final isOwner = _isOwner(q);
//             // Does any item actually carry an MRP from the API? Only show
//             // the column when it's worth showing — this endpoint often
//             // sends "mrp": "0" for every line.
//             final hasAnyMrp = q.items.any((i) => i.mrp > 0);
//             final hasAnyCompany = q.items.any((i) => i.companyName.trim().isNotEmpty);
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
//                           if (q.contractor.email.isNotEmpty)
//                             _Row('Email', q.contractor.email, icon: Icons.email),
//
//                           //   if (q.contractor.address.isNotEmpty)
//                           //     _Row('Address', q.contractor.address, icon: Icons.location_on_outlined),
//                         ],
//                       ),
//                       if (q.salesman.employeeCode.isNotEmpty) ...[
//                         SizedBox(height: Responsive.h(14)),
//                         _DetailSection(
//                           title: 'Salesman',
//                           rows: [
//                             _Row('Created By', q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
//                                 icon: Icons.person_outline),
//                           ],
//                         ),
//                       ],
//                       if (q.notes.isNotEmpty) ...[
//                         SizedBox(height: Responsive.h(14)),
//                         _DetailSection(
//                           title: 'Notes',
//                           rows: [_Row('Notes', q.notes, icon: Icons.notes_outlined)],
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
//                               // Straight from totals.items_count.
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
//                             columns: [
//                               const DataColumn(label: Text('Sl.No')),
//                               const DataColumn(label: Text('Item')),
//                               if (hasAnyCompany) const DataColumn(label: Text('Company')),
//                               const DataColumn(label: Text('Size')),
//                               const DataColumn(label: Text('Qty'), numeric: true),
//                               const DataColumn(label: Text('Unit')),
//                               if (hasAnyMrp) const DataColumn(label: Text('MRP'), numeric: true),
//                               const DataColumn(label: Text('Rate'), numeric: true),
//                               const DataColumn(label: Text('Amount'), numeric: true),
//                               if (!isOwner)
//                                 const DataColumn(label: Text('Incentive'), numeric: true),
//                             ],
//                             rows: q.items.asMap().entries.map((entry) {
//                               final i = entry.key;
//                               final item = entry.value;
//                               return DataRow(cells: [
//                                 DataCell(Text('${i + 1}')),
//                                 DataCell(Text(item.productName.isEmpty ? '-' : item.productName)),
//                                 if (hasAnyCompany)
//                                   DataCell(Text(item.companyName.isEmpty ? '-' : item.companyName)),
//                                 DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
//                                 DataCell(Text(number.format(item.quantity))),
//                                 DataCell(Text(item.productUnit)),
//                                 if (hasAnyMrp)
//                                   DataCell(Text(item.mrp > 0 ? number.format(item.mrp) : '-')),
//                                 DataCell(Text(number.format(item.rate))),
//                                 DataCell(Text(
//                                   currency.format(item.amount),
//                                   style: AppTextStyles.bodyBold(),
//                                 )),
//                                 if (!isOwner)
//                                   DataCell(Text(
//                                     item.isIncentiveEligible
//                                         ? currency.format(item.incentiveAmount)
//                                         : '-',
//                                     style: AppTextStyles.body(color: AppColors.success),
//                                   )),
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
//                             // Everything below is read straight off the API
//                             // response — q.itemsCount / q.totalQuantity come
//                             // from totals{}, the rest are top-level fields.
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
//                       // Hidden entirely when the quotation's creator is the
//                       // Owner (derived from created_by.role_label/role).
//                       //
//                       // NOTE: /quotations/show has no total_incentive field
//                       // in its `totals` block (only items_count and
//                       // total_quantity), so this is the one figure on this
//                       // screen that's summed client-side from each item's
//                       // own incentive_amount (which the API does provide
//                       // per line). If the backend ever adds a total, this
//                       // should read from it directly instead.
//                       if (!isOwner)
//                         Container(
//                           padding: EdgeInsets.all(Responsive.w(14)),
//                           decoration: BoxDecoration(
//                             color: AppColors.success.withValues(alpha: 0.08),
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.percent, size: 18, color: AppColors.success),
//                                   SizedBox(width: Responsive.w(8)),
//                                   Text('Total Incentive', style: AppTextStyles.bodyBold(color: AppColors.success)),
//                                 ],
//                               ),
//                               Text(
//                                 currency.format(
//                                   q.items.fold<double>(0, (s, i) => s + i.incentiveAmount),
//                                 ),
//                                 style: AppTextStyles.h3(color: AppColors.success),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (!isOwner) SizedBox(height: Responsive.h(12)),
//                     ],
//                   ),
//                 ),
//
//                 // Bottom action bar. Despatch flow has been removed from
//                 // this screen entirely — once approved, there's simply no
//                 // primary action left to take here, so we show a static
//                 // "Approved" indicator instead of a button.
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
//                             AppSnackbar.success('Quotation summary copied to clipboard');
//
//                           }
//                         },
//                       ),
//                       SizedBox(width: Responsive.w(10)),
//                       Expanded(
//                         child: isApproved
//                             ? Container(
//                           height: 48,
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: AppColors.success.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
//                           ),
//                           child: Text(
//                             'Quotation Approved',
//                             style: AppTextStyles.bodyBold(color: AppColors.success),
//                           ),
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
//     ));
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
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_bloc.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_event.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_state.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_bloc.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_event.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/owner_quotationapprovemodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/primary_button.dart';
import 'ownerquotationeditscreen.dart';


class OwnerQuotationDetailsScreen extends StatelessWidget {
  const OwnerQuotationDetailsScreen({super.key, required this.quotationId});

  final String quotationId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OwnerQuotationDetailBloc()
            ..add(OwnerQuotationDetailRequested(quotationId)),
        ),
        BlocProvider(create: (_) => OwnerCancelQuotationBloc()),
      ],
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
  // Cache the bloc reference while context is still safely attached to
  // the tree. context.read<T>() (an InheritedWidget ancestor lookup)
  // inside dispose() is unsafe -- by the time dispose() runs the element
  // may already be deactivated, which throws:
  // "Looking up a deactivated widget's ancestor is unsafe."
  // didChangeDependencies() always runs before dispose() can possibly
  // run, so this is guaranteed to be set in time.
  late final OwnerQuotationDetailBloc _detailBloc;

  @override
  void initState() {
    super.initState();
    _detailBloc = context.read<OwnerQuotationDetailBloc>();
  }

  @override
  void dispose() {
    _detailBloc.add(const OwnerQuotationDetailCleared());
    super.dispose();
  }

  bool _isOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'send':
      case 'submitted':
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
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
    return buffer.toString();
  }

  /// Shows whatever message the backend sent — success or error — in a
  /// plain dialog. No frontend-authored copy, no SnackBar.
  Future<void> _showBackendMessage(String? message, {bool isError = false}) async {
    if (message == null || message.trim().isEmpty) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isError ? 'Error' : 'Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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

  // =====================================================================
  // CANCEL — dispatches to the separate OwnerCancelQuotationBloc, which
  // calls OwnerviewQuotationProvider().cancelQuotation(id) internally.
  // =====================================================================

  Future<void> _confirmAndCancel(QuotationDetailModel q) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Quotation'),
        content: const Text(
          'Are you sure you want to cancel this quotation? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<OwnerCancelQuotationBloc>().add(
        OwnerCancelQuotationRequested(widget.quotationId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Owner Quotation Details', style: AppTextStyles.h6()),
        actions: [
          BlocBuilder<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
            buildWhen: (prev, curr) => prev.detail != curr.detail,
            builder: (context, state) {
              final q = state.detail;
              if (q == null) return const SizedBox.shrink();

              final status = q.status.toLowerCase();
              // Edit icon hidden once a quotation is approved or
              // cancelled — both are final states. Shown for 'draft',
              // 'send', and any other in-progress status.
              final hideEditIcon = status == 'approved' || status == 'cancelled';
              if (hideEditIcon) return const SizedBox.shrink();

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
        child: BlocListener<OwnerCancelQuotationBloc, OwnerCancelQuotationState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, cancelState) async {
            if (cancelState.status == OwnerCancelQuotationStatus.success) {
              await _showBackendMessage(cancelState.message);
              if (mounted) Navigator.of(context).pop(true);
            } else if (cancelState.status == OwnerCancelQuotationStatus.failure) {
              await _showBackendMessage(cancelState.errorMessage, isError: true);
              if (mounted) {
                context
                    .read<OwnerCancelQuotationBloc>()
                    .add(const OwnerCancelQuotationResultConsumed());
              }
            }
          },
          child: BlocConsumer<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
            listenWhen: (previous, current) =>
            previous.approveStatus != current.approveStatus,
            listener: (context, state) async {
              if (state.approveStatus == OwnerQuotationApproveStatus.success) {
                await _showBackendMessage(state.approveMessage);
                if (mounted) {
                  context
                      .read<OwnerQuotationDetailBloc>()
                      .add(const OwnerQuotationApproveResultConsumed());
                }
              } else if (state.approveStatus == OwnerQuotationApproveStatus.failure) {
                await _showBackendMessage(state.approveError, isError: true);
                if (mounted) {
                  context
                      .read<OwnerQuotationDetailBloc>()
                      .add(const OwnerQuotationApproveResultConsumed());
                }
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

              final status = q.status.toLowerCase();
              final isApproved = status == 'approved';
              final isCancelled = status == 'cancelled';
              // Approve + Cancel are only meaningful actions for 'draft'
              // and 'send'.
              final showActionButtons = status == 'draft' || status == 'send';
              final isApproving = state.approveStatus == OwnerQuotationApproveStatus.inProgress;
              // Derived from created_by.role_label / role in the response —
              // no separate session/role source. Incentive figures are
              // salesman-facing, so hide them when the creator is the Owner.
              final isOwner = _isOwner(q);
              // Does any item actually carry an MRP from the API? Only show
              // the column when it's worth showing — this endpoint often
              // sends "mrp": "0" for every line.
              final hasAnyMrp = q.items.any((i) => i.mrp > 0);
              final hasAnyCompany = q.items.any((i) => i.companyName.trim().isNotEmpty);

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
                            if (q.contractor.email.isNotEmpty)
                              _Row('Email', q.contractor.email, icon: Icons.email),
                          ],
                        ),
                        if (q.salesman.employeeCode.isNotEmpty) ...[
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Salesman',
                            rows: [
                              _Row('Created By', q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
                                  icon: Icons.person_outline),
                            ],
                          ),
                        ],
                        if (q.notes.isNotEmpty) ...[
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Notes',
                            rows: [_Row('Notes', q.notes, icon: Icons.notes_outlined)],
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
                              columns: [
                                const DataColumn(label: Text('Sl.No')),
                                const DataColumn(label: Text('Item')),
                                if (hasAnyCompany) const DataColumn(label: Text('Company')),
                                const DataColumn(label: Text('Size')),
                                const DataColumn(label: Text('Qty'), numeric: true),
                                const DataColumn(label: Text('Unit')),
                                if (hasAnyMrp) const DataColumn(label: Text('MRP'), numeric: true),
                                const DataColumn(label: Text('Rate'), numeric: true),
                                const DataColumn(label: Text('Amount'), numeric: true),
                                if (!isOwner)
                                  const DataColumn(label: Text('Incentive'), numeric: true),
                              ],
                              rows: q.items.asMap().entries.map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text('${i + 1}')),
                                  DataCell(Text(item.productName.isEmpty ? '-' : item.productName)),
                                  if (hasAnyCompany)
                                    DataCell(Text(item.companyName.isEmpty ? '-' : item.companyName)),
                                  DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                                  DataCell(Text(number.format(item.quantity))),
                                  DataCell(Text(item.productUnit)),
                                  if (hasAnyMrp)
                                    DataCell(Text(item.mrp > 0 ? number.format(item.mrp) : '-')),
                                  DataCell(Text(number.format(item.rate))),
                                  DataCell(Text(
                                    currency.format(item.amount),
                                    style: AppTextStyles.bodyBold(),
                                  )),
                                  if (!isOwner)
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
                        // Hidden entirely when the quotation's creator is the
                        // Owner.
                        if (!isOwner)
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
                        if (!isOwner) SizedBox(height: Responsive.h(12)),
                      ],
                    ),
                  ),

                  // Bottom action bar. Approve + Cancel are shown only for
                  // 'draft'/'send' statuses; approved/cancelled show a
                  // static status indicator instead.
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: BlocBuilder<OwnerCancelQuotationBloc, OwnerCancelQuotationState>(
                      builder: (context, cancelState) {
                        final isCancelling =
                            cancelState.status == OwnerCancelQuotationStatus.inProgress;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                _RoundIconButton(
                                  icon: Icons.share_outlined,
                                  tooltip: 'Share',
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: _buildShareText(q, currency, number)),
                                    );
                                  },
                                ),
                                SizedBox(width: Responsive.w(10)),
                                Expanded(
                                  child: isApproved
                                      ? Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.success.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'Quotation Approved',
                                      style: AppTextStyles.bodyBold(color: AppColors.success),
                                    ),
                                  )
                                      : isCancelled
                                      ? Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.red.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'Quotation Cancelled',
                                      style: AppTextStyles.bodyBold(color: Colors.red),
                                    ),
                                  )
                                      : showActionButtons
                                      ? PrimaryButton(
                                    label: isApproving
                                        ? 'Approving...'
                                        : 'Approve Quotation',
                                    height: 48,
                                    onPressed: (isApproving || isCancelling)
                                        ? null
                                        : () => _showApproveDialog(q),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            if (showActionButtons) ...[
                              SizedBox(height: Responsive.h(10)),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: (isApproving || isCancelling)
                                      ? null
                                      : () => _confirmAndCancel(q),
                                  icon: const Icon(Icons.cancel_outlined, size: 18),
                                  label: Text(isCancelling ? 'Cancelling...' : 'Cancel Quotation'),
                                ),
                              ),
                            ],
                          ],
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
    ));
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