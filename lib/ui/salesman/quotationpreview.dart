// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:intl/intl.dart';
// // import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// // import 'package:tileshop/ui/salesman/quotation_editscreen.dart';
// // import '../../../core/constants/app_colors.dart';
// // import '../../../core/constants/app_text_styles.dart';
// // import '../../../core/utils/responsive.dart';
// // import '../../../widgets/primary_button.dart';
// // import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
// // import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
// // import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
// // import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
// // import '../../widgets/appsnackbar.dart';
// //
// // class QuotationPreviewScreen extends StatefulWidget {
// //   const QuotationPreviewScreen({super.key, required this.id});
// //
// //   final String id;
// //
// //   @override
// //   State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
// // }
// //
// // class _QuotationPreviewScreenState extends State<QuotationPreviewScreen> {
// //   late final SalesmanQuotationBloc _bloc;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _bloc = context.read<SalesmanQuotationBloc>();
// //     _bloc.add(QuotationDetailRequested(widget.id));
// //   }
// //
// //   @override
// //   void dispose() {
// //     _bloc.add(const QuotationDetailCleared());
// //     super.dispose();
// //   }
// //
// //   /// Whether the quotation's `created_by` is an Owner, derived straight
// //   /// from the response (`created_by.role_label` / `role`) — same check
// //   /// as OwnerQuotationDetailsScreen, since both screens share
// //   /// QuotationDetailModel. Incentive figures are salesman-facing, so
// //   /// they're hidden when the creator is the Owner.
// //   bool _isOwner(QuotationDetailModel q) {
// //     final label = q.createdBy.roleLabel.trim().toLowerCase();
// //     if (label.isNotEmpty) return label == 'owner';
// //     // Fallback to the raw role code if role_label wasn't sent.
// //     return q.createdBy.role.trim().toLowerCase() == 'owner';
// //   }
// //
// //   bool _isApproved(QuotationDetailModel q) =>
// //       q.status.trim().toLowerCase() == 'approved';
// //
// //   Color _statusColor(String status) {
// //     switch (status.toLowerCase()) {
// //       case 'approved':
// //         return AppColors.success;
// //       case 'rejected':
// //       case 'cancelled':
// //         return Colors.red;
// //       case 'draft':
// //         return Colors.blueGrey;
// //       default:
// //         return Colors.orange; // send / submitted / pending
// //     }
// //   }
// //
// //   /// paid -> green, partial -> orange, unpaid -> red.
// //   Color _balanceStatusColor(String status) {
// //     switch (status.toLowerCase()) {
// //       case 'paid':
// //         return AppColors.success;
// //       case 'partial':
// //         return Colors.orange;
// //       case 'unpaid':
// //         return Colors.red;
// //       default:
// //         return AppColors.primary;
// //     }
// //   }
// //
// //   String _capitalize(String s) =>
// //       s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
// //
// //   void _showError(String msg) {
// //     AppSnackbar.error(msg);
// //   }
// //
// //   void _editQuotation(QuotationDetailModel estimate) {
// //     final bloc = context.read<SalesmanQuotationBloc>();
// //     Navigator.of(context).push(
// //       MaterialPageRoute(
// //         builder: (_) =>
// //             BlocProvider.value(
// //               value: bloc,
// //               child: QuotationEditScreen(estimate: estimate),
// //             ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _confirmDelete(QuotationDetailModel estimate) async {
// //     final bloc = context.read<SalesmanQuotationBloc>();
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (dialogContext) =>
// //           AlertDialog(
// //             title: const Text('Delete quotation?'),
// //             content: Text(
// //               'This will permanently delete ${estimate.quotationNumber
// //                   .isNotEmpty
// //                   ? estimate.quotationNumber
// //                   : 'this quotation'}. This action cannot be undone.',
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.of(dialogContext).pop(false),
// //                 child: const Text('Cancel'),
// //               ),
// //               TextButton(
// //                 onPressed: () => Navigator.of(dialogContext).pop(true),
// //                 child: Text('Delete', style: TextStyle(color: AppColors.error)),
// //               ),
// //             ],
// //           ),
// //     );
// //     if (confirmed == true) {
// //       bloc.add(QuotationDeleteRequested(estimate.id));
// //     }
// //   }
// //
// //   void _sendForApproval(QuotationDetailModel estimate) {
// //     context.read<SalesmanQuotationBloc>().add(
// //         QuotationSubmitForApprovalRequested(estimate.id));
// //   }
// //
// //   /// Sum of (mrp × quantity) across every item. `mrp` and `company_name`
// //   /// now come straight from /quotations/show on QuotationDetailItem, so
// //   /// this no longer needs a second catalog lookup — mirrors
// //   /// CreateEstimateScreen's `_mrpTotal` getter using the values already
// //   /// on the item.
// //   double _mrpTotal(List<QuotationDetailItem> items) {
// //     return items.fold(0.0, (sum, item) => sum + (item.mrp * item.quantity));
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     Responsive.init(context);
// //     final currency = NumberFormat.currency(
// //         locale: 'en_IN', symbol: '₹', decimalDigits: 0);
// //     // Approved bills show paise in the totals, like the owner screens.
// //     final money = NumberFormat.currency(
// //         locale: 'en_IN', symbol: '₹', decimalDigits: 2);
// //     final number = NumberFormat.decimalPattern('en_IN');
// //
// //     return NetworkAwareWrapper(child: Scaffold(
// //       backgroundColor: AppColors.background,
// //       appBar: AppBar(
// //         title: Text('Quotation Preview', style: AppTextStyles.h6()),
// //       ),
// //       body: SafeArea(
// //         child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
// //           listenWhen: (prev, curr) =>
// //           prev.deleteStatus != curr.deleteStatus ||
// //               prev.submitStatus != curr.submitStatus,
// //           listener: (context, state) {
// //             if (state.deleteStatus == QuotationActionStatus.success) {
// //               AppSnackbar.success('Quotation deleted.');
// //               context.read<SalesmanQuotationBloc>().add(
// //                   const QuotationActionResultConsumed());
// //               Navigator.of(context).pop();
// //             } else if (state.deleteStatus == QuotationActionStatus.failure) {
// //               _showError(state.deleteError ?? 'Failed to delete quotation.');
// //               context.read<SalesmanQuotationBloc>().add(
// //                   const QuotationActionResultConsumed());
// //             } else if (state.submitStatus == QuotationActionStatus.success) {
// //               AppSnackbar.success(
// //                   state.submitMessage ?? 'Submitted for approval.');
// //               context.read<SalesmanQuotationBloc>().add(
// //                   const QuotationActionResultConsumed());
// //             } else if (state.submitStatus == QuotationActionStatus.failure) {
// //               _showError(state.submitError ?? 'Failed to submit for approval.');
// //               context.read<SalesmanQuotationBloc>().add(
// //                   const QuotationActionResultConsumed());
// //             }
// //           },
// //           child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
// //             buildWhen: (prev, curr) =>
// //             prev.detailStatus != curr.detailStatus ||
// //                 prev.detail != curr.detail,
// //             builder: (context, state) {
// //               if (state.detailStatus == QuotationLoadStatus.loading &&
// //                   state.detail == null) {
// //                 return const Center(child: CircularProgressIndicator());
// //               }
// //
// //               if (state.detailStatus == QuotationLoadStatus.failure &&
// //                   state.detail == null) {
// //                 return Center(
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(Icons.error_outline, size: 40, color: AppColors
// //                           .error),
// //                       SizedBox(height: Responsive.h(10)),
// //                       Padding(
// //                         padding: EdgeInsets.symmetric(
// //                             horizontal: Responsive.w(24)),
// //                         child: Text(
// //                           state.detailError ?? 'Failed to load quotation.',
// //                           textAlign: TextAlign.center,
// //                           style: AppTextStyles.body(color: AppColors.error),
// //                         ),
// //                       ),
// //                       SizedBox(height: Responsive.h(10)),
// //                       TextButton(
// //                         onPressed: () =>
// //                             context
// //                                 .read<SalesmanQuotationBloc>()
// //                                 .add(QuotationDetailRequested(widget.id)),
// //                         child: const Text('Retry'),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }
// //
// //               final estimate = state.detail;
// //               if (estimate == null) return const SizedBox.shrink();
// //
// //               final mrpTotal = _mrpTotal(estimate.items);
// //               // Derived from created_by.role_label / role in the
// //               // response — same source as OwnerQuotationDetailsScreen.
// //               final isOwner = _isOwner(estimate);
// //               final isApproved = _isApproved(estimate);
// //               final statusColor = _statusColor(estimate.status);
// //               // Only show these columns if at least one item actually has
// //               // a value for them — otherwise the whole column is just a
// //               // column of dashes and clutters the table.
// //               final hasBoxQty = estimate.items.any((i) => i.boxQuantity > 0);
// //               final hasPieceQty =
// //               estimate.items.any((i) => i.pieceQuantity > 0);
// //
// //               return Column(
// //                 children: [
// //                   Expanded(
// //                     child: ListView(
// //                       padding: EdgeInsets.all(Responsive.w(18)),
// //                       children: [
// //                         Container(
// //                           padding: EdgeInsets.all(Responsive.w(14)),
// //                           decoration: BoxDecoration(
// //                             color: AppColors.surfaceAlt,
// //                             borderRadius: BorderRadius.circular(14),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text('Quotation No.',
// //                                       style: AppTextStyles.caption()),
// //                                   Text(
// //                                     estimate.quotationNumber.isEmpty
// //                                         ? '#${estimate.id}'
// //                                         : estimate.quotationNumber,
// //                                     style: AppTextStyles.h3(),
// //                                   ),
// //                                 ],
// //                               ),
// //                               Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.end,
// //                                 children: [
// //                                   Text('Date', style: AppTextStyles.caption()),
// //                                   Text(
// //                                     estimate.date != null
// //                                         ? DateFormat('dd-MM-yyyy').format(
// //                                         estimate.date!)
// //                                         : estimate.dateRaw,
// //                                     style: AppTextStyles.h3(),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         SizedBox(height: Responsive.h(10)),
// //                         Align(
// //                           alignment: Alignment.centerLeft,
// //                           child: Container(
// //                             padding: const EdgeInsets.symmetric(
// //                                 horizontal: 10, vertical: 4),
// //                             decoration: BoxDecoration(
// //                               color: statusColor.withOpacity(0.12),
// //                               borderRadius: BorderRadius.circular(20),
// //                             ),
// //                             child: Text(
// //                               estimate.status.isEmpty ? '-' : estimate.status,
// //                               style: AppTextStyles.bodyBold(color: statusColor),
// //                             ),
// //                           ),
// //                         ),
// //                         SizedBox(height: Responsive.h(16)),
// //
// //                         _PreviewSection(
// //                           title: 'Customer Details',
// //                           rows: [
// //                             _PreviewRow('Name', estimate.customer.name,
// //                                 icon: Icons.groups_2_outlined),
// //                             _PreviewRow('Address', estimate.customer.address,
// //                                 icon: Icons.location_on_outlined),
// //                             _PreviewRow('Contact No.', estimate.customer.phone,
// //                                 icon: Icons.phone_outlined),
// //                             _PreviewRow('Email', estimate.customer.email,
// //                                 icon: Icons.alternate_email),
// //                           ],
// //                         ),
// //                         SizedBox(height: Responsive.h(14)),
// //
// //                         _PreviewSection(
// //                           title: 'Contractor Details',
// //                           rows: [
// //                             _PreviewRow('Name', estimate.contractor.name,
// //                                 icon: Icons.engineering_outlined),
// //                             _PreviewRow(
// //                                 'Contact No.', estimate.contractor.mobile,
// //                                 icon: Icons.phone_outlined),
// //                             _PreviewRow('Email', estimate.contractor.email,
// //                                 icon: Icons.alternate_email),
// //                           ],
// //                         ),
// //                         SizedBox(height: Responsive.h(14)),
// //
// //                         _PreviewSection(
// //                           title: 'Salesman',
// //                           rows: [
// //                             _PreviewRow('Name', estimate.salesman.name,
// //                                 icon: Icons.badge_outlined),
// //                           ],
// //                         ),
// //                         SizedBox(height: Responsive.h(20)),
// //
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text('Items', style: AppTextStyles.h3()),
// //                             Container(
// //                               padding: EdgeInsets.symmetric(
// //                                   horizontal: Responsive.w(10),
// //                                   vertical: Responsive.h(4)),
// //                               decoration: BoxDecoration(
// //                                 color: AppColors.surfaceAlt,
// //                                 borderRadius: BorderRadius.circular(20),
// //                               ),
// //                               child: Text(
// //                                 'Total Items: ${estimate.itemsCount}',
// //                                 style: AppTextStyles.bodyBold(
// //                                     color: AppColors.primary),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         SizedBox(height: Responsive.h(10)),
// //
// //                         Container(
// //                             decoration: BoxDecoration(
// //                               color: AppColors.surface,
// //                               borderRadius: BorderRadius.circular(14),
// //                               border: Border.all(color: AppColors.border),
// //                             ),
// //                             clipBehavior: Clip.antiAlias,
// //                             child: SingleChildScrollView(
// //                                 scrollDirection: Axis.horizontal,
// //                                 child: DataTable(
// //                                   headingRowColor: MaterialStateProperty.all(
// //                                       AppColors.surfaceAlt),
// //                                   headingTextStyle: AppTextStyles.bodyBold(),
// //                                   dataTextStyle: AppTextStyles.body(),
// //                                   columnSpacing: 18,
// //                                   columns: [
// //                                     const DataColumn(label: Text('Sl.No')),
// //                                     const DataColumn(label: Text('Item')),
// //                                     const DataColumn(label: Text('Company')),
// //                                     const DataColumn(label: Text('Size')),
// //                                     const DataColumn(label: Text('Qty'), numeric: true),
// //                                     const DataColumn(label: Text('Unit')),
// //                                     if (hasBoxQty)
// //                                       const DataColumn(label: Text('Box Qty'), numeric: true),
// //                                     if (hasPieceQty)
// //                                       const DataColumn(label: Text('Piece Qty'), numeric: true),
// //                                     const DataColumn(label: Text('MRP'), numeric: true),
// //                                     const DataColumn(label: Text('Rate'), numeric: true),
// //                                     const DataColumn(label: Text('Amount'), numeric: true),
// //                                     if (!isOwner)
// //                                       const DataColumn(label: Text('Incentive'), numeric: true),
// //                                   ],
// //                                   rows: estimate.items.asMap().entries.map((entry) {
// //                                     final i = entry.key;
// //                                     final item = entry.value;
// //                                     return DataRow(cells: [
// //                                       DataCell(Text('${i + 1}')),
// //                                       DataCell(Text(item.productName)),
// //                                       DataCell(Text(item.companyName.isNotEmpty ? item.companyName : '-')),
// //                                       DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
// //                                       DataCell(Text(number.format(item.quantity))),
// //                                       DataCell(Text(item.productUnit)),
// //                                       if (hasBoxQty)
// //                                         DataCell(Text(item.boxQuantity > 0
// //                                             ? number.format(item.boxQuantity) : '-')),
// //                                       if (hasPieceQty)
// //                                         DataCell(Text(item.pieceQuantity > 0
// //                                             ? number.format(item.pieceQuantity) : '-')),
// //                                       DataCell(Text(item.mrp > 0 ? number.format(item.mrp) : '-')),
// //                                       DataCell(Text(number.format(item.rate))),
// //                                       DataCell(Text(
// //                                         currency.format(item.amount),
// //                                         style: AppTextStyles.bodyBold(),
// //                                       )),
// //                                       if (!isOwner)
// //                                         DataCell(Text(
// //                                           item.incentiveAmount > 0 ? currency.format(item.incentiveAmount) : '-',
// //                                           style: AppTextStyles.bodyBold(color: AppColors.success),
// //                                         )),
// //                                     ]);
// //                                   }).toList(),
// //                                 ))),
// //                         SizedBox(height: Responsive.h(16)),
// //
// //                         if (estimate.notes.isNotEmpty) ...[
// //                           _PreviewSection(
// //                             title: 'Notes',
// //                             rows: [_PreviewRow('', estimate.notes)],
// //                           ),
// //                           SizedBox(height: Responsive.h(14)),
// //                         ],
// //
// //                         // Totals. For approved quotations this also shows the
// //                         // discount, amount after discount, total paid and balance.
// //                         _buildTotalsCard(
// //                           estimate,
// //                           isApproved ? money : currency,
// //                           number,
// //                           mrpTotal,
// //                           isApproved,
// //                         ),
// //                         SizedBox(height: Responsive.h(12)),
// //
// //                         // Payment status banner + payments list — approved only.
// //                         if (isApproved && estimate.showPaymentSummary) ...[
// //                           _buildPaymentStatus(estimate),
// //                           SizedBox(height: Responsive.h(12)),
// //                         ],
// //                         if (isApproved && estimate.payments.isNotEmpty) ...[
// //                           _PreviewSection(
// //                             title: 'Payments',
// //                             rows: estimate.payments.map((p) {
// //                               final parsed = DateTime.tryParse(p.date);
// //                               final dateText = parsed != null
// //                                   ? DateFormat('yyyy-MM-dd').format(parsed)
// //                                   : p.date;
// //                               final parts = <String>[
// //                                 money.format(p.amount),
// //                                 if (dateText.isNotEmpty) dateText,
// //                                 if (p.reference.isNotEmpty) 'Ref: ${p
// //                                     .reference}',
// //                               ];
// //                               return _PreviewRow(
// //                                 p.methodLabel,
// //                                 parts.join(' · '),
// //                                 icon: Icons.receipt_long_outlined,
// //                               );
// //                             }).toList(),
// //                           ),
// //                           SizedBox(height: Responsive.h(12)),
// //                         ],
// //
// //                         if (!isOwner &&
// //                             estimate.items.any((i) => i.incentiveAmount > 0))
// //                           Container(
// //                             padding: EdgeInsets.all(Responsive.w(14)),
// //                             decoration: BoxDecoration(
// //                               color: AppColors.success.withOpacity(0.08),
// //                               borderRadius: BorderRadius.circular(14),
// //                               border: Border.all(
// //                                   color: AppColors.success.withOpacity(0.3)),
// //                             ),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Row(
// //                                   children: [
// //                                     Icon(Icons.percent, size: 18,
// //                                         color: AppColors.success),
// //                                     SizedBox(width: Responsive.w(8)),
// //                                     Text('Incentive Total',
// //                                         style: AppTextStyles.bodyBold(
// //                                             color: AppColors.success)),
// //                                   ],
// //                                 ),
// //                                 Text(
// //                                   currency.format(
// //                                     estimate.items.fold(
// //                                         0.0, (s, r) => s + r.incentiveAmount),
// //                                   ),
// //                                   style: AppTextStyles.h3(
// //                                       color: AppColors.success),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         SizedBox(height: Responsive.h(12)),
// //                       ],
// //                     ),
// //                   ),
// //                   Container(
// //                     padding: EdgeInsets.fromLTRB(
// //                         Responsive.w(18), Responsive.h(10), Responsive.w(18),
// //                         Responsive.h(14)),
// //                     decoration: BoxDecoration(
// //                       color: AppColors.background,
// //                       border: Border(top: BorderSide(color: AppColors.border)),
// //                     ),
// //                     child: BlocBuilder<
// //                         SalesmanQuotationBloc,
// //                         SalesmanQuotationState>(
// //                       buildWhen: (prev, curr) =>
// //                       prev.deleteStatus != curr.deleteStatus ||
// //                           prev.submitStatus != curr.submitStatus,
// //                       builder: (context, state) {
// //                         final deleting = state.deleteStatus ==
// //                             QuotationActionStatus.inProgress;
// //                         final submitting = state.submitStatus ==
// //                             QuotationActionStatus.inProgress;
// //                         final busy = deleting || submitting;
// //
// //                         return Row(
// //                           children: [
// //                             if (estimate.isDraft) ...[
// //                               Expanded(
// //                                 child: OutlinedButton.icon(
// //                                   onPressed: busy ? null : () =>
// //                                       _editQuotation(estimate),
// //                                   style: OutlinedButton.styleFrom(
// //                                     padding: const EdgeInsets.symmetric(
// //                                         vertical: 14),
// //                                     shape: RoundedRectangleBorder(
// //                                         borderRadius: BorderRadius.circular(
// //                                             14)),
// //                                   ),
// //                                   icon: const Icon(
// //                                       Icons.edit_outlined, size: 18),
// //                                   label: const Text('Edit'),
// //                                 ),
// //                               ),
// //                               SizedBox(width: Responsive.w(10)),
// //                               IconButton(
// //                                 onPressed: busy ? null : () =>
// //                                     _confirmDelete(estimate),
// //                                 icon: deleting
// //                                     ? const SizedBox(
// //                                   width: 18,
// //                                   height: 18,
// //                                   child: CircularProgressIndicator(
// //                                       strokeWidth: 2),
// //                                 )
// //                                     : Icon(Icons.delete_outline,
// //                                     color: AppColors.error),
// //                                 tooltip: 'Delete',
// //                               ),
// //                               SizedBox(width: Responsive.w(10)),
// //                               Expanded(
// //                                 flex: 2,
// //                                 child: PrimaryButton(
// //                                   label: submitting
// //                                       ? 'Submitting…'
// //                                       : 'Submit for Approval',
// //                                   height: 48,
// //                                   onPressed: busy ? null : () =>
// //                                       _sendForApproval(estimate),
// //                                 ),
// //                               ),
// //                             ] else
// //                             // Not a draft anymore (e.g. already sent for
// //                             // approval, or approved) — nothing left to edit,
// //                             // delete, or resubmit here, so the action bar is
// //                             // just an informational status pill instead
// //                             // of buttons that would no longer apply.
// //                               Expanded(
// //                                 child: Container(
// //                                   padding: EdgeInsets.symmetric(
// //                                       vertical: Responsive.h(12),
// //                                       horizontal: Responsive.w(14)),
// //                                   decoration: BoxDecoration(
// //                                     color: isApproved
// //                                         ? AppColors.success.withOpacity(0.08)
// //                                         : AppColors.surfaceAlt,
// //                                     borderRadius: BorderRadius.circular(14),
// //                                   ),
// //                                   child: Row(
// //                                     mainAxisAlignment: MainAxisAlignment.center,
// //                                     children: [
// //                                       Icon(
// //                                         isApproved
// //                                             ? Icons.check_circle_outline
// //                                             : Icons.lock_outline,
// //                                         size: 16,
// //                                         color: isApproved
// //                                             ? AppColors.success
// //                                             : AppColors.textHint,
// //                                       ),
// //                                       SizedBox(width: Responsive.w(8)),
// //                                       Expanded(
// //                                         child: Text(
// //                                           isApproved
// //                                               ? 'This quotation has been approved.'
// //                                               : 'This quotation has already been submitted and can no longer be edited or deleted.',
// //                                           textAlign: TextAlign.center,
// //                                           style: isApproved
// //                                               ? AppTextStyles.bodyBold(
// //                                               color: AppColors.success)
// //                                               : AppTextStyles.caption(),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                           ],
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               );
// //             },
// //           ),
// //         ),
// //       ),
// //     ));
// //   }
// //
// //   // ---------------------------------------------------------------------
// //   // Totals card
// //   // ---------------------------------------------------------------------
// //
// //   /// Not approved: Sq.Ft / MRP / Sub Total / Handling Charge / Grand Total
// //   /// (same as before).
// //   ///
// //   /// Approved: additionally shows
// //   ///   Total Before Discount, Discount, Amount After Discount   (only if a discount exists)
// //   ///   Grand Total (= amount after discount, large + bold)
// //   ///   Total Paid, and a Balance Due strip                      (once payments are tracked)
// //   Widget _buildTotalsCard(QuotationDetailModel q,
// //       NumberFormat fmt,
// //       NumberFormat number,
// //       double mrpTotal,
// //       bool isApproved,) {
// //     final gap = SizedBox(height: Responsive.h(6));
// //     final showDiscount = isApproved && q.hasDiscount;
// //     final showPayment = isApproved && q.showPaymentSummary;
// //     final payable = isApproved ? q.amountAfterDiscount : q.grandTotal;
// //     final balanceColor = q.balanceAmount > 0 ? Colors.red : AppColors.success;
// //
// //     return Container(
// //       width: double.infinity,
// //       decoration: BoxDecoration(
// //         color: AppColors.surfaceAlt,
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       clipBehavior: Clip.antiAlias,
// //       child: Column(
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.all(Responsive.w(14)),
// //             child: Column(
// //               children: [
// //                 _totalRow('Total Sq.Ft', number.format(q.totalSquareFeet)),
// //                 gap,
// //                 _totalRow('Sub Total', fmt.format(q.subtotal)),
// //                 gap,
// //                 _totalRow('Handling Charge', fmt.format(q.handlingCharge)),
// //                 if (showDiscount) ...[
// //                   gap,
// //                   _totalRow('Total Before Discount', fmt.format(q.grandTotal)),
// //                   gap,
// //                   _totalRow(
// //                     q.discountLabel,
// //                     '- ${fmt.format(q.discountAmount)}',
// //                     bold: true,
// //                     valueColor: Colors.red,
// //                   ),
// //                   gap,
// //                   // _totalRow('Amount After Discount',
// //                   //     fmt.format(q.amountAfterDiscount), bold: true),
// //                 ],
// //                 const Divider(height: 20),
// //                 _totalRow('Grand Total', fmt.format(payable), large: true),
// //                 if (showPayment) ...[
// //                   SizedBox(height: Responsive.h(10)),
// //                   _totalRow(
// //                     'Total Paid',
// //                     fmt.format(q.totalPaid),
// //                     bold: true,
// //                     valueColor: AppColors.success,
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //           // Balance strip — red while money is due, green once fully paid.
// //           if (showPayment)
// //             Container(
// //               width: double.infinity,
// //               color: balanceColor.withOpacity(0.08),
// //               padding: EdgeInsets.symmetric(
// //                   horizontal: Responsive.w(14), vertical: Responsive.h(14)),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text('Balance Due', style: AppTextStyles.h3()),
// //                   Text(
// //                     fmt.format(q.balanceAmount),
// //                     style: AppTextStyles.h2(color: balanceColor),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPaymentStatus(QuotationDetailModel q) {
// //     final color = _balanceStatusColor(q.balanceStatus);
// //     final isPaid = q.balanceStatus == 'paid';
// //     return Container(
// //       padding: EdgeInsets.all(Responsive.w(14)),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.08),
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(
// //                 isPaid ? Icons.check_circle_outline : Icons
// //                     .hourglass_bottom_outlined,
// //                 size: 18,
// //                 color: color,
// //               ),
// //               SizedBox(width: Responsive.w(8)),
// //               Text('Payment Status',
// //                   style: AppTextStyles.bodyBold(color: color)),
// //             ],
// //           ),
// //           Text(
// //             q.balanceStatus.isEmpty ? '-' : _capitalize(q.balanceStatus),
// //             style: AppTextStyles.h3(color: color),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _totalRow(String label,
// //       String value, {
// //         Color? valueColor,
// //         bool bold = false,
// //         bool large = false,
// //       }) {
// //     final labelStyle = large
// //         ? AppTextStyles.h3().copyWith(fontWeight: FontWeight.w700)
// //         : AppTextStyles.body();
// //
// //     final valueStyle = large
// //         ? AppTextStyles.h2(color: valueColor ?? AppColors.primary)
// //         .copyWith(fontWeight: FontWeight.w800)
// //         : (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
// //         .copyWith(
// //         color: valueColor); // copyWith accepts null (keeps default color)
// //
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(label, style: labelStyle),
// //         Text(value, style: valueStyle),
// //       ],
// //     );
// //   }
// // }
// // class _PreviewRow {
// //   final String label;
// //   final String value;
// //   final IconData? icon;
// //   _PreviewRow(this.label, this.value, {this.icon});
// // }
// //
// // class _PreviewSection extends StatelessWidget {
// //   const _PreviewSection({required this.title, required this.rows});
// //   final String title;
// //   final List<_PreviewRow> rows;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.all(Responsive.w(14)),
// //       decoration: BoxDecoration(
// //         color: AppColors.surface,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: AppColors.border),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
// //           SizedBox(height: Responsive.h(10)),
// //           ...rows.map((r) => Padding(
// //             padding: EdgeInsets.only(bottom: Responsive.h(10)),
// //             child: Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 if (r.icon != null) ...[
// //                   Icon(r.icon, size: 16, color: AppColors.textHint),
// //                   SizedBox(width: Responsive.w(8)),
// //                 ],
// //                 if (r.label.isNotEmpty)
// //                   SizedBox(
// //                     width: r.icon != null ? 88 : 100,
// //                     child: Text(r.label, style: AppTextStyles.caption()),
// //                   ),
// //                 Expanded(
// //                   child: Text(
// //                     r.value.isEmpty ? '-' : r.value,
// //                     style: AppTextStyles.bodyBold(),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/salesman/quotation_editscreen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../widgets/primary_button.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/appsnackbar.dart';

class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key, required this.id});

  final String id;

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen> {
  late final SalesmanQuotationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SalesmanQuotationBloc>();
    _bloc.add(QuotationDetailRequested(widget.id));
  }

  @override
  void dispose() {
    _bloc.add(const QuotationDetailCleared());
    super.dispose();
  }

  /// Whether the quotation's `created_by` is an Owner, derived straight
  /// from the response (`created_by.role_label` / `role`) — same check
  /// as OwnerQuotationDetailsScreen, since both screens share
  /// QuotationDetailModel. Incentive figures are salesman-facing, so
  /// they're hidden when the creator is the Owner.
  bool _isOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    // Fallback to the raw role code if role_label wasn't sent.
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  bool _isApproved(QuotationDetailModel q) =>
      q.status.trim().toLowerCase() == 'approved';

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'draft':
        return Colors.blueGrey;
      default:
        return Colors.orange; // send / submitted / pending
    }
  }

  /// paid -> green, partial -> orange, unpaid -> red.
  Color _balanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  void _showError(String msg) {
    AppSnackbar.error(msg);
  }

  void _editQuotation(QuotationDetailModel estimate) {
    final bloc = context.read<SalesmanQuotationBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(
              value: bloc,
              child: QuotationEditScreen(estimate: estimate),
            ),
      ),
    );
  }

  Future<void> _confirmDelete(QuotationDetailModel estimate) async {
    final bloc = context.read<SalesmanQuotationBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            title: const Text('Delete quotation?'),
            content: Text(
              'This will permanently delete ${estimate.quotationNumber
                  .isNotEmpty
                  ? estimate.quotationNumber
                  : 'this quotation'}. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      bloc.add(QuotationDeleteRequested(estimate.id));
    }
  }

  void _sendForApproval(QuotationDetailModel estimate) {
    context.read<SalesmanQuotationBloc>().add(
        QuotationSubmitForApprovalRequested(estimate.id));
  }

  /// Sum of (mrp × quantity) across every item. `mrp` and `company_name`
  /// now come straight from /quotations/show on QuotationDetailItem, so
  /// this no longer needs a second catalog lookup — mirrors
  /// CreateEstimateScreen's `_mrpTotal` getter using the values already
  /// on the item.
  double _mrpTotal(List<QuotationDetailItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.mrp * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    // Approved bills show paise in the totals, like the owner screens.
    final money = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quotation Preview', style: AppTextStyles.h6()),
      ),
      body: SafeArea(
        child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
          // CHANGED: this screen shares SalesmanQuotationBloc with
          // QuotationEditScreen, which also reports its own save result via
          // submitStatus. Without the isCurrent check, a successful edit
          // fired BOTH screens' listeners, so the snackbar showed twice.
          // Now the preview only reacts while it is the visible route.
          listenWhen: (prev, curr) =>
          prev.deleteStatus != curr.deleteStatus ||
              (prev.submitStatus != curr.submitStatus &&
                  curr.submitStatus != QuotationActionStatus.idle &&
                  ModalRoute.of(context)?.isCurrent == true),
          listener: (context, state) {
            if (state.deleteStatus == QuotationActionStatus.success) {
              AppSnackbar.success('Quotation deleted.');
              context.read<SalesmanQuotationBloc>().add(
                  const QuotationActionResultConsumed());
              Navigator.of(context).pop();
            } else if (state.deleteStatus == QuotationActionStatus.failure) {
              _showError(state.deleteError ?? 'Failed to delete quotation.');
              context.read<SalesmanQuotationBloc>().add(
                  const QuotationActionResultConsumed());
            } else if (state.submitStatus == QuotationActionStatus.success) {
              AppSnackbar.success(
                  state.submitMessage ?? 'Submitted for approval.');
              context.read<SalesmanQuotationBloc>().add(
                  const QuotationActionResultConsumed());
            } else if (state.submitStatus == QuotationActionStatus.failure) {
              _showError(state.submitError ?? 'Failed to submit for approval.');
              context.read<SalesmanQuotationBloc>().add(
                  const QuotationActionResultConsumed());
            }
          },
          child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
            buildWhen: (prev, curr) =>
            prev.detailStatus != curr.detailStatus ||
                prev.detail != curr.detail,
            builder: (context, state) {
              if (state.detailStatus == QuotationLoadStatus.loading &&
                  state.detail == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.detailStatus == QuotationLoadStatus.failure &&
                  state.detail == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: AppColors
                          .error),
                      SizedBox(height: Responsive.h(10)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(24)),
                        child: Text(
                          state.detailError ?? 'Failed to load quotation.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.error),
                        ),
                      ),
                      SizedBox(height: Responsive.h(10)),
                      TextButton(
                        onPressed: () =>
                            context
                                .read<SalesmanQuotationBloc>()
                                .add(QuotationDetailRequested(widget.id)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final estimate = state.detail;
              if (estimate == null) return const SizedBox.shrink();

              final mrpTotal = _mrpTotal(estimate.items);
              // Derived from created_by.role_label / role in the
              // response — same source as OwnerQuotationDetailsScreen.
              final isOwner = _isOwner(estimate);
              final isApproved = _isApproved(estimate);
              final statusColor = _statusColor(estimate.status);
              // Only show these columns if at least one item actually has
              // a value for them — otherwise the whole column is just a
              // column of dashes and clutters the table.
              final hasBoxQty = estimate.items.any((i) => i.boxQuantity > 0);
              final hasPieceQty =
              estimate.items.any((i) => i.pieceQuantity > 0);

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
                                  Text('Quotation No.',
                                      style: AppTextStyles.caption()),
                                  Text(
                                    estimate.quotationNumber.isEmpty
                                        ? '#${estimate.id}'
                                        : estimate.quotationNumber,
                                    style: AppTextStyles.h3(),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Date', style: AppTextStyles.caption()),
                                  Text(
                                    estimate.date != null
                                        ? DateFormat('dd-MM-yyyy').format(
                                        estimate.date!)
                                        : estimate.dateRaw,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              estimate.status.isEmpty ? '-' : estimate.status,
                              style: AppTextStyles.bodyBold(color: statusColor),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(16)),

                        _PreviewSection(
                          title: 'Customer Details',
                          rows: [
                            _PreviewRow('Name', estimate.customer.name,
                                icon: Icons.groups_2_outlined),
                            _PreviewRow('Address', estimate.customer.address,
                                icon: Icons.location_on_outlined),
                            _PreviewRow('Contact No.', estimate.customer.phone,
                                icon: Icons.phone_outlined),
                            _PreviewRow('Email', estimate.customer.email,
                                icon: Icons.alternate_email),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),

                        _PreviewSection(
                          title: 'Contractor Details',
                          rows: [
                            _PreviewRow('Name', estimate.contractor.name,
                                icon: Icons.engineering_outlined),
                            _PreviewRow(
                                'Contact No.', estimate.contractor.mobile,
                                icon: Icons.phone_outlined),
                            _PreviewRow('Email', estimate.contractor.email,
                                icon: Icons.alternate_email),
                            // NEW: shows the saved contractor address so you
                            // can verify it was stored after an edit.
                            _PreviewRow('Address', estimate.contractor.address,
                                icon: Icons.location_on_outlined),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),

                        _PreviewSection(
                          title: 'Salesman',
                          rows: [
                            _PreviewRow('Name', estimate.salesman.name,
                                icon: Icons.badge_outlined),
                          ],
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items', style: AppTextStyles.h3()),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.w(10),
                                  vertical: Responsive.h(4)),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Total Items: ${estimate.itemsCount}',
                                style: AppTextStyles.bodyBold(
                                    color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(10)),

                        // ---- ONLY CHANGE: Excel-style bordered table ----
                        _InvoiceTable(
                          items: estimate.items,
                          showBox: hasBoxQty,
                          showPiece: hasPieceQty,
                          showIncentive: !isOwner,
                          currency: currency,
                          number: number,
                        ),
                        SizedBox(height: Responsive.h(16)),

                        if (estimate.notes.isNotEmpty) ...[
                          _PreviewSection(
                            title: 'Notes',
                            rows: [_PreviewRow('', estimate.notes)],
                          ),
                          SizedBox(height: Responsive.h(14)),
                        ],

                        // Totals. For approved quotations this also shows the
                        // discount, amount after discount, total paid and balance.
                        _buildTotalsCard(
                          estimate,
                          isApproved ? money : currency,
                          number,
                          mrpTotal,
                          isApproved,
                        ),
                        SizedBox(height: Responsive.h(12)),

                        // Payment status banner + payments list — approved only.
                        if (isApproved && estimate.showPaymentSummary) ...[
                          _buildPaymentStatus(estimate),
                          SizedBox(height: Responsive.h(12)),
                        ],
                        if (isApproved && estimate.payments.isNotEmpty) ...[
                          _PreviewSection(
                            title: 'Payments',
                            rows: estimate.payments.map((p) {
                              final parsed = DateTime.tryParse(p.date);
                              final dateText = parsed != null
                                  ? DateFormat('yyyy-MM-dd').format(parsed)
                                  : p.date;
                              final parts = <String>[
                                money.format(p.amount),
                                if (dateText.isNotEmpty) dateText,
                                if (p.reference.isNotEmpty) 'Ref: ${p
                                    .reference}',
                              ];
                              return _PreviewRow(
                                p.methodLabel,
                                parts.join(' · '),
                                icon: Icons.receipt_long_outlined,
                              );
                            }).toList(),
                          ),
                          SizedBox(height: Responsive.h(12)),
                        ],

                        if (!isOwner &&
                            estimate.items.any((i) => i.incentiveAmount > 0))
                          Container(
                            padding: EdgeInsets.all(Responsive.w(14)),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.percent, size: 18,
                                        color: AppColors.success),
                                    SizedBox(width: Responsive.w(8)),
                                    Text('Incentive Total',
                                        style: AppTextStyles.bodyBold(
                                            color: AppColors.success)),
                                  ],
                                ),
                                Text(
                                  currency.format(
                                    estimate.items.fold(
                                        0.0, (s, r) => s + r.incentiveAmount),
                                  ),
                                  style: AppTextStyles.h3(
                                      color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: Responsive.h(12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(18), Responsive.h(10), Responsive.w(18),
                        Responsive.h(14)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: BlocBuilder<
                        SalesmanQuotationBloc,
                        SalesmanQuotationState>(
                      buildWhen: (prev, curr) =>
                      prev.deleteStatus != curr.deleteStatus ||
                          prev.submitStatus != curr.submitStatus,
                      builder: (context, state) {
                        final deleting = state.deleteStatus ==
                            QuotationActionStatus.inProgress;
                        final submitting = state.submitStatus ==
                            QuotationActionStatus.inProgress;
                        final busy = deleting || submitting;

                        return Row(
                          children: [
                            if (estimate.isDraft) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: busy ? null : () =>
                                      _editQuotation(estimate),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            14)),
                                  ),
                                  icon: const Icon(
                                      Icons.edit_outlined, size: 18),
                                  label: const Text('Edit'),
                                ),
                              ),
                              SizedBox(width: Responsive.w(10)),
                              IconButton(
                                onPressed: busy ? null : () =>
                                    _confirmDelete(estimate),
                                icon: deleting
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                                    : Icon(Icons.delete_outline,
                                    color: AppColors.error),
                                tooltip: 'Delete',
                              ),
                              SizedBox(width: Responsive.w(10)),
                              Expanded(
                                flex: 2,
                                child: PrimaryButton(
                                  label: submitting
                                      ? 'Submitting…'
                                      : 'Submit for Approval',
                                  height: 48,
                                  onPressed: busy ? null : () =>
                                      _sendForApproval(estimate),
                                ),
                              ),
                            ] else
                            // Not a draft anymore (e.g. already sent for
                            // approval, or approved) — nothing left to edit,
                            // delete, or resubmit here, so the action bar is
                            // just an informational status pill instead
                            // of buttons that would no longer apply.
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Responsive.h(12),
                                      horizontal: Responsive.w(14)),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? AppColors.success.withOpacity(0.08)
                                        : AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isApproved
                                            ? Icons.check_circle_outline
                                            : Icons.lock_outline,
                                        size: 16,
                                        color: isApproved
                                            ? AppColors.success
                                            : AppColors.textHint,
                                      ),
                                      SizedBox(width: Responsive.w(8)),
                                      Expanded(
                                        child: Text(
                                          isApproved
                                              ? 'This quotation has been approved.'
                                              : 'This quotation has already been submitted and can no longer be edited or deleted.',
                                          textAlign: TextAlign.center,
                                          style: isApproved
                                              ? AppTextStyles.bodyBold(
                                              color: AppColors.success)
                                              : AppTextStyles.caption(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

  // ---------------------------------------------------------------------
  // Totals card
  // ---------------------------------------------------------------------

  /// Not approved: Sq.Ft / MRP / Sub Total / Handling Charge / Grand Total
  /// (same as before).
  ///
  /// Approved: additionally shows
  ///   Total Before Discount, Discount, Amount After Discount   (only if a discount exists)
  ///   Grand Total (= amount after discount, large + bold)
  ///   Total Paid, and a Balance Due strip                      (once payments are tracked)
  Widget _buildTotalsCard(QuotationDetailModel q,
      NumberFormat fmt,
      NumberFormat number,
      double mrpTotal,
      bool isApproved,) {
    final gap = SizedBox(height: Responsive.h(6));
    final showDiscount = isApproved && q.hasDiscount;
    final showPayment = isApproved && q.showPaymentSummary;
    final payable = isApproved ? q.amountAfterDiscount : q.grandTotal;
    final balanceColor = q.balanceAmount > 0 ? Colors.red : AppColors.success;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                _totalRow('Total Sq.Ft', number.format(q.totalSquareFeet)),
                gap,
                _totalRow('Sub Total', fmt.format(q.subtotal)),
                gap,
                _totalRow('Handling Charge', fmt.format(q.handlingCharge)),
                if (showDiscount) ...[
                  gap,
                  _totalRow('Total Before Discount', fmt.format(q.grandTotal)),
                  gap,
                  _totalRow(
                    q.discountLabel,
                    '- ${fmt.format(q.discountAmount)}',
                    bold: true,
                    valueColor: Colors.red,
                  ),
                  gap,
                  // _totalRow('Amount After Discount',
                  //     fmt.format(q.amountAfterDiscount), bold: true),
                ],
                const Divider(height: 20),
                _totalRow('Grand Total', fmt.format(payable), large: true),
                if (showPayment) ...[
                  SizedBox(height: Responsive.h(10)),
                  _totalRow(
                    'Total Paid',
                    fmt.format(q.totalPaid),
                    bold: true,
                    valueColor: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
          // Balance strip — red while money is due, green once fully paid.
          if (showPayment)
            Container(
              width: double.infinity,
              color: balanceColor.withOpacity(0.08),
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Balance Due', style: AppTextStyles.h3()),
                  Text(
                    fmt.format(q.balanceAmount),
                    style: AppTextStyles.h2(color: balanceColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(QuotationDetailModel q) {
    final color = _balanceStatusColor(q.balanceStatus);
    final isPaid = q.balanceStatus == 'paid';
    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle_outline : Icons
                    .hourglass_bottom_outlined,
                size: 18,
                color: color,
              ),
              SizedBox(width: Responsive.w(8)),
              Text('Payment Status',
                  style: AppTextStyles.bodyBold(color: color)),
            ],
          ),
          Text(
            q.balanceStatus.isEmpty ? '-' : _capitalize(q.balanceStatus),
            style: AppTextStyles.h3(color: color),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label,
      String value, {
        Color? valueColor,
        bool bold = false,
        bool large = false,
      }) {
    final labelStyle = large
        ? AppTextStyles.h3().copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.body();

    final valueStyle = large
        ? AppTextStyles.h2(color: valueColor ?? AppColors.primary)
        .copyWith(fontWeight: FontWeight.w800)
        : (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
        .copyWith(
        color: valueColor); // copyWith accepts null (keeps default color)

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _PreviewRow {
  final String label;
  final String value;
  final IconData? icon;
  _PreviewRow(this.label, this.value, {this.icon});
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.rows});
  final String title;
  final List<_PreviewRow> rows;

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
                if (r.label.isNotEmpty)
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

// =======================================================================
// NEW: Excel-style bordered items table with a Total row
// =======================================================================
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
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('No items on this quotation.',
            style: AppTextStyles.caption()),
      );
    }

    // label, width, alignment
    final cols = <(String, double, TextAlign)>[
      ('Sl.No', 50, TextAlign.center),
      ('Item', 170, TextAlign.left),
      ('Company', 110, TextAlign.left),
      ('Size', 90, TextAlign.center),
      ('Qty', 70, TextAlign.right),
      ('Unit', 60, TextAlign.center),
      if (showBox) ('Box Qty', 70, TextAlign.right),
      if (showPiece) ('Piece Qty', 80, TextAlign.right),
      ('MRP', 80, TextAlign.right),
      ('Rate', 80, TextAlign.right),
      ('Amount', 100, TextAlign.right),
      if (showIncentive) ('Incentive', 90, TextAlign.right),
    ];

    final amountCol = cols.indexWhere((c) => c.$1 == 'Amount');
    final qtyCol = cols.indexWhere((c) => c.$1 == 'Qty');
    final incentiveCol = cols.indexWhere((c) => c.$1 == 'Incentive');

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(
        0, (s, i) => s + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));

    Alignment alignOf(int c) => switch (cols[c].$3) {
      TextAlign.right => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      _ => Alignment.centerLeft,
    };

    Widget headerCell(int c) => Container(
      alignment: alignOf(c),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(8), vertical: Responsive.h(11)),
      child: Text(
        cols[c].$1,
        textAlign: cols[c].$3,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.captionnew().copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );

    Widget dataCell(String text, int c, {bool bold = false, Color? color}) =>
        Container(
          alignment: alignOf(c),
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(8), vertical: Responsive.h(9)),
          child: Text(
            text,
            textAlign: cols[c].$3,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
                .copyWith(color: color),
          ),
        );

    TableRow itemRow(int i, QuotationDetailItem it) {
      final values = <String>[
        '${i + 1}',
        it.productName,
        it.companyName.isNotEmpty ? it.companyName : '-',
        it.productSize.isEmpty ? '-' : it.productSize,
        number.format(it.quantity),
        it.productUnit,
        if (showBox) it.boxQuantity > 0 ? number.format(it.boxQuantity) : '-',
        if (showPiece)
          it.pieceQuantity > 0 ? number.format(it.pieceQuantity) : '-',
        it.mrp > 0 ? number.format(it.mrp) : '-',
        number.format(it.rate),
        currency.format(it.amount),
        if (showIncentive)
          it.incentiveAmount > 0 ? currency.format(it.incentiveAmount) : '-',
      ];
      return TableRow(
        decoration: BoxDecoration(
          color: i.isEven
              ? AppColors.surface
              : AppColors.surfaceAlt.withOpacity(0.4),
        ),
        children: [
          for (var c = 0; c < values.length; c++)
            dataCell(
              values[c],
              c,
              bold: c == amountCol || (showIncentive && c == incentiveCol),
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
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          border: Border(
            top: BorderSide(
                color: AppColors.primary.withOpacity(0.3), width: 1.2),
          ),
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: AppColors.border, width: 0.8),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            for (var c = 0; c < cols.length; c++)
              c: FixedColumnWidth(cols[c].$2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.3), width: 1.4),
                ),
              ),
              children: [for (var c = 0; c < cols.length; c++) headerCell(c)],
            ),
            for (var i = 0; i < items.length; i++) itemRow(i, items[i]),
            totalRow(),
          ],
        ),
      ),
    );
  }
}