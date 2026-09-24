//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../bloc/salemanbloc/estimatedetail/estimate_detail_event.dart';
// import '../../bloc/salemanbloc/estimatedetail/estimate_detail_state.dart';
// import '../../bloc/salemanbloc/estimatedetail/estimatedetail_bloc.dart';
// import '../../models/salesmanmodels/estimatedetail.model.dart';
// import '../owner/ownerdespatchsheet.dart';
//
// class SalesmanEstimateDetailsScreen extends StatefulWidget {
//   const SalesmanEstimateDetailsScreen({super.key, required this.id});
//
//   final String id;
//
//   @override
//   State<SalesmanEstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
// }
//
// class _EstimateDetailsScreenState extends State<SalesmanEstimateDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => EstimateDetailBloc()..add(EstimateDetailRequested(widget.id)),
//       child: _EstimateDetailsView(id: widget.id),
//     );
//   }
// }
//
// class _EstimateDetailsView extends StatelessWidget {
//   const _EstimateDetailsView({required this.id});
//
//   final String id;
//
//   /// Derived straight from the API response's `created_by_details.role_label`
//   /// (e.g. "Owner" vs "Salesman") — no manual flag needed. When the estimate
//   /// was created by an Owner, the Incentive column is hidden; for a
//   /// Salesman-created estimate, it stays visible.
//   bool _isOwner(EstimateDetailModel estimate) {
//     return estimate.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
//   }
//
//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return AppColors.success;
//       case 'pending_approval':
//         return Colors.orange;
//       case 'rejected':
//         return AppColors.error;
//       default:
//         return AppColors.textHint;
//     }
//   }
//
//   IconData _statusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return Icons.check_circle_rounded;
//       case 'pending_approval':
//         return Icons.hourglass_top_rounded;
//       case 'rejected':
//         return Icons.cancel_rounded;
//       default:
//         return Icons.info_outline_rounded;
//     }
//   }
//
//   String _statusLabel(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending_approval':
//         return 'Pending Approval';
//       case 'approved':
//         return 'Approved';
//       case 'rejected':
//         return 'Rejected';
//       default:
//         return status.isEmpty ? '-' : status;
//     }
//   }
//
//   void _openDespatchSheet(BuildContext context, EstimateDetailModel estimate) async {
//     final despatched = await Navigator.of(context).push<bool>(
//       MaterialPageRoute(
//         builder: (_) => OwnerDespatchSheetScreen(estimateId: estimate.id),
//       ),
//     );
//
//     if (despatched == true && context.mounted) {
//       // Pop this Estimate Detail screen too, returning to the screen
//       // that opened it (e.g. Approved Bills) instead of the dashboard.
//       Navigator.of(context).pop(true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return NetworkAwareWrapper(
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: Text('Estimate Detail', style: AppTextStyles.h6()),
//         ),
//         body: SafeArea(
//           child: BlocBuilder<EstimateDetailBloc, EstimateDetailState>(
//             builder: (context, state) {
//               if (state.status == EstimateDetailStatus.loading && state.detail == null) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state.status == EstimateDetailStatus.failure && state.detail == null) {
//                 return Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.error_outline, size: 40, color: AppColors.error),
//                       SizedBox(height: Responsive.h(10)),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
//                         child: Text(
//                           state.error ?? 'Failed to load estimate.',
//                           textAlign: TextAlign.center,
//                           style: AppTextStyles.body(color: AppColors.error),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(10)),
//                       TextButton(
//                         onPressed: () =>
//                             context.read<EstimateDetailBloc>().add(EstimateDetailRequested(id)),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               final estimate = state.detail;
//               if (estimate == null) return const SizedBox.shrink();
//
//               final statusColor = _statusColor(estimate.status);
//               final isOwner = _isOwner(estimate);
//
//               return Column(
//                 children: [
//                   Expanded(
//                     child: ListView(
//                       padding: EdgeInsets.all(Responsive.w(18)),
//                       children: [
//                         // ---- Header card ----
//                         Container(
//                           padding: EdgeInsets.all(Responsive.w(16)),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 AppColors.primary.withOpacity(0.07),
//                                 AppColors.primary.withOpacity(0.02),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: AppColors.primary.withOpacity(0.14)),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text('Reference NO.',
//                                             style: AppTextStyles.captionnew()
//                                                 .copyWith(letterSpacing: 0.6)),
//                                         SizedBox(height: Responsive.h(4)),
//                                         Text(
//                                           estimate.estimateNumber.isEmpty
//                                               ? '#${estimate.id}'
//                                               : estimate.estimateNumber,
//                                           style: AppTextStyles.bodyBold(),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: Responsive.w(12)),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text('DATE',
//                                           style: AppTextStyles.caption()
//                                               .copyWith(letterSpacing: 0.6)),
//                                       SizedBox(height: Responsive.h(4)),
//                                       Text(
//                                         estimate.date != null
//                                             ? DateFormat('dd-MM-yyyy').format(estimate.date!)
//                                             : estimate.dateRaw,
//                                         style: AppTextStyles.bodyBold(),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: Responsive.h(14)),
//                               Container(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: statusColor.withOpacity(0.14),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(_statusIcon(estimate.status),
//                                         size: 14, color: statusColor),
//                                     SizedBox(width: Responsive.w(6)),
//                                     Text(
//                                       _statusLabel(estimate.status),
//                                       style: AppTextStyles.bodyBold(color: statusColor)
//                                           .copyWith(fontSize: Responsive.sp(12)),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: Responsive.h(16)),
//
//                         _DetailSection(
//                           title: 'Customer Details',
//                           icon: Icons.groups_2_outlined,
//                           rows: [
//                             _Row(' Name', estimate.customerName, icon: Icons.groups_2_outlined),
//                             _Row('Address', estimate.customerAddress,
//                                 icon: Icons.location_on_outlined),
//                             _Row('Contact No.', estimate.customerPhone,
//                                 icon: Icons.phone_outlined),
//                             _Row('Email', estimate.customerEmail, icon: Icons.alternate_email),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(14)),
//                         _DetailSection(
//                           title: 'Contractor Details',
//                           icon: Icons.person_outline,
//                           rows: [
//                             _Row(' Name', estimate.customer.name, icon: Icons.groups_2_outlined),
//                             _Row('Contact No.', estimate.customer.phone,
//                                 icon: Icons.phone_outlined),
//                             _Row('Email', estimate.customer.email, icon: Icons.alternate_email),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(14)),
//                         // Salesman section — always shown, including for owners.
//                         _DetailSection(
//                           title: 'Salesman',
//                           icon: Icons.badge_outlined,
//                           rows: [
//                             _Row('Name', estimate.salesman.name, icon: Icons.badge_outlined),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(14)),
//
//                         if (estimate.siteVisit.id.isNotEmpty)
//                           _DetailSection(
//                             title: 'Site Visit',
//                             icon: Icons.location_history_outlined,
//                             rows: [
//                               _Row('Visit Date', estimate.siteVisit.visitDate,
//                                   icon: Icons.event_outlined),
//                               _Row('Status', estimate.siteVisit.statusLabel,
//                                   icon: Icons.flag_outlined),
//                               _Row('Field Staff', estimate.siteVisit.fieldStaffName,
//                                   icon: Icons.engineering_outlined),
//                             ],
//                           ),
//                         SizedBox(height: Responsive.h(20)),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.primary.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Icon(Icons.list_alt_rounded,
//                                       size: 15, color: AppColors.primary),
//                                 ),
//                                 SizedBox(width: Responsive.w(8)),
//                                 Text('Items', style: AppTextStyles.h3()),
//                               ],
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: Responsive.w(10), vertical: Responsive.h(4)),
//                               decoration: BoxDecoration(
//                                 color: AppColors.surfaceAlt,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 'Total Items: ${estimate.itemsCount}',
//                                 style: AppTextStyles.bodyBold(color: AppColors.primary),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(12)),
//
//                         _buildItemsTable(estimate, number, isOwner),
//                         SizedBox(height: Responsive.h(16)),
//
//                         if (estimate.notes.isNotEmpty) ...[
//                           _DetailSection(
//                             title: 'Notes',
//                             icon: Icons.sticky_note_2_outlined,
//                             rows: [_Row('', estimate.notes)],
//                           ),
//                           SizedBox(height: Responsive.h(14)),
//                         ],
//
//                         _buildSummaryCard(estimate, number),
//                         SizedBox(height: Responsive.h(12)),
//
//                         if (estimate.isApproved) _buildPaymentStatus(estimate),
//                       ],
//                     ),
//                   ),
//                   if (estimate.isApproved) _buildBottomBar(context, estimate),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Items table (bill-style)
//   // ---------------------------------------------------------------------
//
//   Widget _buildItemsTable(EstimateDetailModel estimate, NumberFormat number, bool isOwner) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final totalQty = estimate.items.fold<double>(0, (sum, i) => sum + i.quantity);
//     final totalAmount = estimate.items.fold<double>(0, (sum, i) => sum + i.amount);
//     final totalIncentive =
//     estimate.items.fold<double>(0, (sum, i) => sum + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));
//
//     if (estimate.items.isEmpty) {
//       return Container(
//         padding: EdgeInsets.all(Responsive.w(14)),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Text('No items on this estimate.', style: AppTextStyles.caption()),
//       );
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Table(
//           border: TableBorder(
//             horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
//             verticalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
//             bottom: BorderSide(color: AppColors.border),
//           ),
//           columnWidths: {
//             0: const FixedColumnWidth(36), // Sl.No
//             1: const FixedColumnWidth(160), // Item
//             2: const FixedColumnWidth(130), // Company
//             3: const FixedColumnWidth(90), // Size
//             4: const FixedColumnWidth(60), // Qty
//             5: const FixedColumnWidth(70), // Unit
//             6: const FixedColumnWidth(80), // MRP
//             7: const FixedColumnWidth(80), // Rate
//             8: const FixedColumnWidth(100), // Amount
//             if (!isOwner) 9: const FixedColumnWidth(100), // Incentive
//           },
//           children: [
//             // ---- Header row ----
//             TableRow(
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.08),
//                 border: Border(
//                   bottom: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.4),
//                 ),
//               ),
//               children: [
//                 _headerCell('Sl.No', align: TextAlign.center),
//                 _headerCell('Item'),
//                 _headerCell('Company'),
//                 _headerCell('Size'),
//                 _headerCell('Qty', align: TextAlign.right),
//                 _headerCell('Unit'),
//                 _headerCell('MRP', align: TextAlign.right),
//                 _headerCell('Rate', align: TextAlign.right),
//                 _headerCell('Amount', align: TextAlign.right),
//                 if (!isOwner) _headerCell('Incentive', align: TextAlign.right),
//               ],
//             ),
//             // ---- Data rows ----
//             for (var i = 0; i < estimate.items.length; i++)
//               TableRow(
//                 decoration: BoxDecoration(
//                   color: i.isEven ? AppColors.surface : AppColors.surfaceAlt.withOpacity(0.4),
//                 ),
//                 children: [
//                   _dataCell('${i + 1}', align: TextAlign.center),
//                   _dataCell(estimate.items[i].productName),
//                   _dataCell(estimate.items[i].companyName.isEmpty
//                       ? '-'
//                       : estimate.items[i].companyName),
//                   _dataCell(estimate.items[i].productSize.isEmpty
//                       ? '-'
//                       : estimate.items[i].productSize),
//                   _dataCell(number.format(estimate.items[i].quantity), align: TextAlign.right),
//                   _dataCell(
//                       estimate.items[i].unitName.isEmpty ? '-' : estimate.items[i].unitName),
//                   _dataCell(
//                       estimate.items[i].mrp > 0 ? currency.format(estimate.items[i].mrp) : '-',
//                       align: TextAlign.right),
//                   _dataCell(number.format(estimate.items[i].rate), align: TextAlign.right),
//                   _dataCell(currency.format(estimate.items[i].amount),
//                       align: TextAlign.right, bold: true),
//                   if (!isOwner)
//                     _dataCell(
//                       estimate.items[i].incentiveAmount > 0
//                           ? currency.format(estimate.items[i].incentiveAmount)
//                           : '-',
//                       align: TextAlign.right,
//                       bold: true,
//                       color: AppColors.success,
//                     ),
//                 ],
//               ),
//             // ---- Totals footer row ----
//             TableRow(
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.06),
//                 border: Border(
//                   top: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.2),
//                 ),
//               ),
//               children: [
//                 _dataCell(''),
//                 _dataCell('Total', bold: true),
//                 _dataCell(''),
//                 _dataCell(''),
//                 _dataCell(number.format(totalQty), align: TextAlign.right, bold: true),
//                 _dataCell(''),
//                 _dataCell(''),
//                 _dataCell(''),
//                 _dataCell(currency.format(totalAmount),
//                     align: TextAlign.right, bold: true, color: AppColors.primary),
//                 if (!isOwner)
//                   _dataCell(currency.format(totalIncentive),
//                       align: TextAlign.right, bold: true, color: AppColors.success),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(11)),
//       child: Text(
//         text,
//         textAlign: align,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: AppTextStyles.captionnew().copyWith(
//           fontWeight: FontWeight.w700,
//           color: AppColors.primary,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
//
//   Widget _dataCell(
//       String text, {
//         TextAlign align = TextAlign.left,
//         bool bold = false,
//         Color? color,
//       }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(9)),
//       child: Text(
//         text,
//         textAlign: align,
//         maxLines: 1,
//         softWrap: false,
//         overflow: TextOverflow.visible,
//         style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(color: color),
//       ),
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Summary card
//   // ---------------------------------------------------------------------
//
//   Widget _buildSummaryCard(EstimateDetailModel estimate, NumberFormat number) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(Responsive.w(16)),
//             child: Column(
//               children: [
//
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Total Sq.Ft', number.format(estimate.totalSquareFeet)),
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Subtotal', currency.format(estimate.subtotal)),
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Total Before Discount', currency.format(estimate.grandTotal)),
//
//                 // Discount, payment, and balance are only meaningful once
//                 // the estimate is approved — while pending, these fields
//                 // are still zero/unset on the server, so showing them
//                 // would just display misleading zeros.
//                 if (estimate.isApproved && estimate.hasDiscount) ...[
//                   SizedBox(height: Responsive.h(8)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text('Discount (${estimate.discountTypeLabel})',
//                             style: AppTextStyles.body()),
//                       ),
//                       Text('- ${currency.format(estimate.discountAmount)}',
//                           style: AppTextStyles.bodyBold(color: Colors.red)),
//                     ],
//                   ),
//                 ],
//
//                 if (estimate.isApproved) ...[
//                   SizedBox(height: Responsive.h(8)),
//                   _totalRow(
//                     large: true,
//                       'Grand Total', currency.format(estimate.amountAfterDiscount),
//                   ),
//                   SizedBox(height: Responsive.h(8)),
//                   _totalRow('Total Paid', currency.format(estimate.totalPaid),
//                       valueColor: AppColors.success),
//                 ],
//               ],
//             ),
//           ),
//           // Grand Total strip
//           // Balance strip — only meaningful once approved.
//           if (estimate.isApproved)
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(
//                   horizontal: Responsive.w(16), vertical: Responsive.h(14)),
//               decoration: BoxDecoration(
//                 color: estimate.balanceAmount > 0
//                     ? Colors.red.withOpacity(0.06)
//
//                     : AppColors.success.withOpacity(0.08),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Balance Due', style: AppTextStyles.h3()),
//                   Text(
//                     currency.format(estimate.balanceAmount),
//                     style: AppTextStyles.h2(
//                         color: estimate.balanceAmount > 0 ? Colors.red : AppColors.success),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _totalRow(String label, String value, {Color? valueColor, bool large = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: large
//               ? AppTextStyles.h3().copyWith(fontWeight: FontWeight.w700)
//               : AppTextStyles.body(),
//         ),
//         Text(
//           value,
//           style: large
//               ? AppTextStyles.h2(color: valueColor ?? AppColors.primary)
//               .copyWith(fontWeight: FontWeight.w800)
//               : AppTextStyles.bodyBold(color: valueColor ?? Colors.black),
//         ),
//       ],
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Payment status banner
//   // ---------------------------------------------------------------------
//
//   Widget _buildPaymentStatus(EstimateDetailModel estimate) {
//     final color = estimate.isFullyPaid ? AppColors.success : Colors.orange;
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 estimate.isFullyPaid
//                     ? Icons.check_circle_outline
//                     : Icons.hourglass_bottom_outlined,
//                 size: 18,
//                 color: color,
//               ),
//               SizedBox(width: Responsive.w(8)),
//               Text('Payment Status', style: AppTextStyles.bodyBold(color: color)),
//             ],
//           ),
//           Text(estimate.balanceStatusLabel, style: AppTextStyles.h3(color: color)),
//         ],
//       ),
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Bottom bar
//   // ---------------------------------------------------------------------
//
//   Widget _buildBottomBar(BuildContext context, EstimateDetailModel estimate) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(
//             Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
//         child: ElevatedButton.icon(
//           onPressed: () => _openDespatchSheet(context, estimate),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           ),
//           icon: const Icon(Icons.local_shipping_outlined, size: 18),
//           label: const Text('Create Despatch Sheet'),
//         ),
//       ),
//     );
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
//   const _DetailSection({required this.title, required this.rows, this.icon});
//   final String title;
//   final List<_Row> rows;
//   final IconData? icon;
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
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               if (icon != null) ...[
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 15, color: AppColors.primary),
//                 ),
//                 SizedBox(width: Responsive.w(8)),
//               ],
//               Text(title,
//                   style: AppTextStyles.bodyBold(color: AppColors.primary)
//                       .copyWith(fontSize: Responsive.sp(13.5))),
//             ],
//           ),
//           SizedBox(height: Responsive.h(12)),
//           ...rows.map((r) => Padding(
//             padding: EdgeInsets.only(bottom: Responsive.h(10)),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (r.icon != null) ...[
//                   Icon(r.icon, size: 15, color: AppColors.textHint),
//                   SizedBox(width: Responsive.w(8)),
//                 ],
//                 if (r.label.isNotEmpty)
//                   SizedBox(
//                     width: r.icon != null ? 86 : 100,
//                     child: Text(r.label, style: AppTextStyles.caption()),
//                   ),
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
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../bloc/salemanbloc/estimatedetail/estimate_detail_event.dart';
// import '../../bloc/salemanbloc/estimatedetail/estimate_detail_state.dart';
// import '../../bloc/salemanbloc/estimatedetail/estimatedetail_bloc.dart';
// import '../../models/salesmanmodels/estimatedetail.model.dart';
// import '../owner/ownerdespatchsheet.dart';
//
// class SalesmanEstimateDetailsScreen extends StatefulWidget {
//   const SalesmanEstimateDetailsScreen({super.key, required this.id});
//
//   final String id;
//
//   @override
//   State<SalesmanEstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
// }
//
// class _EstimateDetailsScreenState extends State<SalesmanEstimateDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => EstimateDetailBloc()..add(EstimateDetailRequested(widget.id)),
//       child: _EstimateDetailsView(id: widget.id),
//     );
//   }
// }
//
// class _EstimateDetailsView extends StatelessWidget {
//   const _EstimateDetailsView({required this.id});
//
//   final String id;
//
//   /// Derived straight from the API response's `created_by_details.role_label`
//   /// (e.g. "Owner" vs "Salesman") — no manual flag needed. When the estimate
//   /// was created by an Owner, the Incentive column is hidden; for a
//   /// Salesman-created estimate, it stays visible.
//   bool _isOwner(EstimateDetailModel estimate) {
//     return estimate.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
//   }
//
//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return AppColors.success;
//       case 'pending_approval':
//         return Colors.orange;
//       case 'rejected':
//         return AppColors.error;
//       default:
//         return AppColors.textHint;
//     }
//   }
//
//   IconData _statusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return Icons.check_circle_rounded;
//       case 'pending_approval':
//         return Icons.hourglass_top_rounded;
//       case 'rejected':
//         return Icons.cancel_rounded;
//       default:
//         return Icons.info_outline_rounded;
//     }
//   }
//
//   String _statusLabel(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending_approval':
//         return 'Pending Approval';
//       case 'approved':
//         return 'Approved';
//       case 'rejected':
//         return 'Rejected';
//       default:
//         return status.isEmpty ? '-' : status;
//     }
//   }
//
//   void _openDespatchSheet(BuildContext context, EstimateDetailModel estimate) async {
//     final despatched = await Navigator.of(context).push<bool>(
//       MaterialPageRoute(
//         builder: (_) => OwnerDespatchSheetScreen(estimateId: estimate.id),
//       ),
//     );
//
//     if (despatched == true && context.mounted) {
//       // Pop this Estimate Detail screen too, returning to the screen
//       // that opened it (e.g. Approved Bills) instead of the dashboard.
//       Navigator.of(context).pop(true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final number = NumberFormat.decimalPattern('en_IN');
//
//     return NetworkAwareWrapper(
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: Text('Estimate Detail', style: AppTextStyles.h6()),
//         ),
//         body: SafeArea(
//           child: BlocBuilder<EstimateDetailBloc, EstimateDetailState>(
//             builder: (context, state) {
//               if (state.status == EstimateDetailStatus.loading && state.detail == null) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state.status == EstimateDetailStatus.failure && state.detail == null) {
//                 return Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.error_outline, size: 40, color: AppColors.error),
//                       SizedBox(height: Responsive.h(10)),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
//                         child: Text(
//                           state.error ?? 'Failed to load estimate.',
//                           textAlign: TextAlign.center,
//                           style: AppTextStyles.body(color: AppColors.error),
//                         ),
//                       ),
//                       SizedBox(height: Responsive.h(10)),
//                       TextButton(
//                         onPressed: () =>
//                             context.read<EstimateDetailBloc>().add(EstimateDetailRequested(id)),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               final estimate = state.detail;
//               if (estimate == null) return const SizedBox.shrink();
//
//               final statusColor = _statusColor(estimate.status);
//               final isOwner = _isOwner(estimate);
//
//               return Column(
//                 children: [
//                   Expanded(
//                     child: ListView(
//                       padding: EdgeInsets.all(Responsive.w(18)),
//                       children: [
//                         // ---- Header card ----
//                         Container(
//                           padding: EdgeInsets.all(Responsive.w(16)),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 AppColors.primary.withOpacity(0.07),
//                                 AppColors.primary.withOpacity(0.02),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: AppColors.primary.withOpacity(0.14)),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text('Reference NO.',
//                                             style: AppTextStyles.captionnew()
//                                                 .copyWith(letterSpacing: 0.6)),
//                                         SizedBox(height: Responsive.h(4)),
//                                         Text(
//                                           estimate.estimateNumber.isEmpty
//                                               ? '#${estimate.id}'
//                                               : estimate.estimateNumber,
//                                           style: AppTextStyles.bodyBold(),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: Responsive.w(12)),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text('DATE',
//                                           style: AppTextStyles.caption()
//                                               .copyWith(letterSpacing: 0.6)),
//                                       SizedBox(height: Responsive.h(4)),
//                                       Text(
//                                         estimate.date != null
//                                             ? DateFormat('dd-MM-yyyy').format(estimate.date!)
//                                             : estimate.dateRaw,
//                                         style: AppTextStyles.bodyBold(),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: Responsive.h(14)),
//                               Container(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: statusColor.withOpacity(0.14),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(_statusIcon(estimate.status),
//                                         size: 14, color: statusColor),
//                                     SizedBox(width: Responsive.w(6)),
//                                     Text(
//                                       _statusLabel(estimate.status),
//                                       style: AppTextStyles.bodyBold(color: statusColor)
//                                           .copyWith(fontSize: Responsive.sp(12)),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: Responsive.h(16)),
//
//                         _DetailSection(
//                           title: 'Customer Details',
//                           icon: Icons.groups_2_outlined,
//                           rows: [
//                             _Row(' Name', estimate.customerName, icon: Icons.groups_2_outlined),
//                             _Row('Address', estimate.customerAddress,
//                                 icon: Icons.location_on_outlined),
//                             _Row('Contact No.', estimate.customerPhone,
//                                 icon: Icons.phone_outlined),
//                             _Row('Email', estimate.customerEmail, icon: Icons.alternate_email),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(14)),
//                         _DetailSection(
//                           title: 'Contractor Details',
//                           icon: Icons.person_outline,
//                           rows: [
//                             _Row(' Name', estimate.customer.name, icon: Icons.groups_2_outlined),
//                             _Row('Contact No.', estimate.customer.phone,
//                                 icon: Icons.phone_outlined),
//                             _Row('Email', estimate.customer.email, icon: Icons.alternate_email),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(14)),
//                         // Salesman section — always shown, including for owners.
//                         _DetailSection(
//                           title: 'Salesman',
//                           icon: Icons.badge_outlined,
//                           rows: [
//                             _Row('Name', estimate.salesman.name, icon: Icons.badge_outlined),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(14)),
//
//                         if (estimate.siteVisit.id.isNotEmpty)
//                           _DetailSection(
//                             title: 'Site Visit',
//                             icon: Icons.location_history_outlined,
//                             rows: [
//                               _Row('Visit Date', estimate.siteVisit.visitDate,
//                                   icon: Icons.event_outlined),
//                               _Row('Status', estimate.siteVisit.statusLabel,
//                                   icon: Icons.flag_outlined),
//                               _Row('Field Staff', estimate.siteVisit.fieldStaffName,
//                                   icon: Icons.engineering_outlined),
//                             ],
//                           ),
//                         SizedBox(height: Responsive.h(20)),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.primary.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Icon(Icons.list_alt_rounded,
//                                       size: 15, color: AppColors.primary),
//                                 ),
//                                 SizedBox(width: Responsive.w(8)),
//                                 Text('Items', style: AppTextStyles.h3()),
//                               ],
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: Responsive.w(10), vertical: Responsive.h(4)),
//                               decoration: BoxDecoration(
//                                 color: AppColors.surfaceAlt,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 'Total Items: ${estimate.itemsCount}',
//                                 style: AppTextStyles.bodyBold(color: AppColors.primary),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: Responsive.h(12)),
//
//                         _buildItemsTable(estimate, number, isOwner),
//                         SizedBox(height: Responsive.h(16)),
//
//                         if (estimate.notes.isNotEmpty) ...[
//                           _DetailSection(
//                             title: 'Notes',
//                             icon: Icons.sticky_note_2_outlined,
//                             rows: [_Row('', estimate.notes)],
//                           ),
//                           SizedBox(height: Responsive.h(14)),
//                         ],
//
//                         _buildSummaryCard(estimate, number),
//                         SizedBox(height: Responsive.h(12)),
//
//                         if (estimate.isApproved) _buildPaymentStatus(estimate),
//                       ],
//                     ),
//                   ),
//                   if (estimate.isApproved) _buildBottomBar(context, estimate),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Items table (bill-style)
//   // ---------------------------------------------------------------------
//
//   Widget _buildItemsTable(EstimateDetailModel estimate, NumberFormat number, bool isOwner) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final totalQty = estimate.items.fold<double>(0, (sum, i) => sum + i.quantity);
//     final totalAmount = estimate.items.fold<double>(0, (sum, i) => sum + i.amount);
//     final totalIncentive =
//     estimate.items.fold<double>(0, (sum, i) => sum + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));
//
//     // Only show these columns if at least one item across the whole
//     // estimate actually has a value for them — otherwise the column
//     // would just be a strip of dashes. Rows without a value still show
//     // '-' in that column once it's visible.
//     final hasBoxQty = estimate.items.any((i) => i.boxQuantity > 0);
//     final hasPieceQty = estimate.items.any((i) => i.pieceQuantity > 0);
//
//     if (estimate.items.isEmpty) {
//       return Container(
//         padding: EdgeInsets.all(Responsive.w(14)),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Text('No items on this estimate.', style: AppTextStyles.caption()),
//       );
//     }
//
//     // Column widths are keyed by index, so build the map dynamically —
//     // the index of every column after Unit shifts depending on which of
//     // Box Qty / Piece Qty / Incentive are actually shown.
//     final columnWidths = <int, TableColumnWidth>{};
//     var col = 0;
//     columnWidths[col++] = const FixedColumnWidth(36); // Sl.No
//     columnWidths[col++] = const FixedColumnWidth(160); // Item
//     columnWidths[col++] = const FixedColumnWidth(130); // Company
//     columnWidths[col++] = const FixedColumnWidth(90); // Size
//     columnWidths[col++] = const FixedColumnWidth(60); // Qty
//     columnWidths[col++] = const FixedColumnWidth(70); // Unit
//     if (hasBoxQty) columnWidths[col++] = const FixedColumnWidth(80); // Box Qty
//     if (hasPieceQty) columnWidths[col++] = const FixedColumnWidth(80); // Piece Qty
//     columnWidths[col++] = const FixedColumnWidth(80); // MRP
//     columnWidths[col++] = const FixedColumnWidth(80); // Rate
//     columnWidths[col++] = const FixedColumnWidth(100); // Amount
//     if (!isOwner) columnWidths[col++] = const FixedColumnWidth(100); // Incentive
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Table(
//           border: TableBorder(
//             horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
//             verticalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
//             bottom: BorderSide(color: AppColors.border),
//           ),
//           columnWidths: columnWidths,
//           children: [
//             // ---- Header row ----
//             TableRow(
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.08),
//                 border: Border(
//                   bottom: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.4),
//                 ),
//               ),
//               children: [
//                 _headerCell('Sl.No', align: TextAlign.center),
//                 _headerCell('Item'),
//                 _headerCell('Company'),
//                 _headerCell('Size'),
//                 _headerCell('Qty', align: TextAlign.right),
//                 _headerCell('Unit'),
//                 if (hasBoxQty) _headerCell('Box Qty', align: TextAlign.right),
//                 if (hasPieceQty) _headerCell('Piece Qty', align: TextAlign.right),
//                 _headerCell('MRP', align: TextAlign.right),
//                 _headerCell('Rate', align: TextAlign.right),
//                 _headerCell('Amount', align: TextAlign.right),
//                 if (!isOwner) _headerCell('Incentive', align: TextAlign.right),
//               ],
//             ),
//             // ---- Data rows ----
//             for (var i = 0; i < estimate.items.length; i++)
//               TableRow(
//                 decoration: BoxDecoration(
//                   color: i.isEven ? AppColors.surface : AppColors.surfaceAlt.withOpacity(0.4),
//                 ),
//                 children: [
//                   _dataCell('${i + 1}', align: TextAlign.center),
//                   _dataCell(estimate.items[i].productName),
//                   _dataCell(estimate.items[i].companyName.isEmpty
//                       ? '-'
//                       : estimate.items[i].companyName),
//                   _dataCell(estimate.items[i].productSize.isEmpty
//                       ? '-'
//                       : estimate.items[i].productSize),
//                   _dataCell(number.format(estimate.items[i].quantity), align: TextAlign.right),
//                   _dataCell(
//                       estimate.items[i].unitName.isEmpty ? '-' : estimate.items[i].unitName),
//                   if (hasBoxQty)
//                     _dataCell(
//                       estimate.items[i].boxQuantity > 0
//                           ? number.format(estimate.items[i].boxQuantity)
//                           : '-',
//                       align: TextAlign.right,
//                     ),
//                   if (hasPieceQty)
//                     _dataCell(
//                       estimate.items[i].pieceQuantity > 0
//                           ? number.format(estimate.items[i].pieceQuantity)
//                           : '-',
//                       align: TextAlign.right,
//                     ),
//                   _dataCell(
//                       estimate.items[i].mrp > 0 ? currency.format(estimate.items[i].mrp) : '-',
//                       align: TextAlign.right),
//                   _dataCell(number.format(estimate.items[i].rate), align: TextAlign.right),
//                   _dataCell(currency.format(estimate.items[i].amount),
//                       align: TextAlign.right, bold: true),
//                   if (!isOwner)
//                     _dataCell(
//                       estimate.items[i].incentiveAmount > 0
//                           ? currency.format(estimate.items[i].incentiveAmount)
//                           : '-',
//                       align: TextAlign.right,
//                       bold: true,
//                       color: AppColors.success,
//                     ),
//                 ],
//               ),
//             // ---- Totals footer row ----
//             TableRow(
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.06),
//                 border: Border(
//                   top: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.2),
//                 ),
//               ),
//               children: [
//                 _dataCell(''),
//                 _dataCell('Total', bold: true),
//                 _dataCell(''),
//                 _dataCell(''),
//                 _dataCell(number.format(totalQty), align: TextAlign.right, bold: true),
//                 _dataCell(''),
//                 if (hasBoxQty) _dataCell(''),
//                 if (hasPieceQty) _dataCell(''),
//                 _dataCell(''),
//                 _dataCell(''),
//                 _dataCell(currency.format(totalAmount),
//                     align: TextAlign.right, bold: true, color: AppColors.primary),
//                 if (!isOwner)
//                   _dataCell(currency.format(totalIncentive),
//                       align: TextAlign.right, bold: true, color: AppColors.success),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(11)),
//       child: Text(
//         text,
//         textAlign: align,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: AppTextStyles.captionnew().copyWith(
//           fontWeight: FontWeight.w700,
//           color: AppColors.primary,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
//
//   Widget _dataCell(
//       String text, {
//         TextAlign align = TextAlign.left,
//         bool bold = false,
//         Color? color,
//       }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(9)),
//       child: Text(
//         text,
//         textAlign: align,
//         maxLines: 1,
//         softWrap: false,
//         overflow: TextOverflow.visible,
//         style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(color: color),
//       ),
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Summary card
//   // ---------------------------------------------------------------------
//
//   Widget _buildSummaryCard(EstimateDetailModel estimate, NumberFormat number) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(Responsive.w(16)),
//             child: Column(
//               children: [
//
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Total Sq.Ft', number.format(estimate.totalSquareFeet)),
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Subtotal', currency.format(estimate.subtotal)),
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),
//                 SizedBox(height: Responsive.h(8)),
//                 _totalRow('Total Before Discount', currency.format(estimate.grandTotal)),
//
//                 // Discount, payment, and balance are only meaningful once
//                 // the estimate is approved — while pending, these fields
//                 // are still zero/unset on the server, so showing them
//                 // would just display misleading zeros.
//                 if (estimate.isApproved && estimate.hasDiscount) ...[
//                   SizedBox(height: Responsive.h(8)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text('Discount (${estimate.discountTypeLabel})',
//                             style: AppTextStyles.body()),
//                       ),
//                       Text('- ${currency.format(estimate.discountAmount)}',
//                           style: AppTextStyles.bodyBold(color: Colors.red)),
//                     ],
//                   ),
//                 ],
//
//                 if (estimate.isApproved) ...[
//                   SizedBox(height: Responsive.h(8)),
//                   _totalRow(
//                     large: true,
//                     'Grand Total', currency.format(estimate.amountAfterDiscount),
//                   ),
//                   SizedBox(height: Responsive.h(8)),
//                   _totalRow('Total Paid', currency.format(estimate.totalPaid),
//                       valueColor: AppColors.success),
//                 ],
//               ],
//             ),
//           ),
//           // Grand Total strip
//           // Balance strip — only meaningful once approved.
//           if (estimate.isApproved)
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(
//                   horizontal: Responsive.w(16), vertical: Responsive.h(14)),
//               decoration: BoxDecoration(
//                 color: estimate.balanceAmount > 0
//                     ? Colors.red.withOpacity(0.06)
//
//                     : AppColors.success.withOpacity(0.08),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Balance Due', style: AppTextStyles.h3()),
//                   Text(
//                     currency.format(estimate.balanceAmount),
//                     style: AppTextStyles.h2(
//                         color: estimate.balanceAmount > 0 ? Colors.red : AppColors.success),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _totalRow(String label, String value, {Color? valueColor, bool large = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: large
//               ? AppTextStyles.h3().copyWith(fontWeight: FontWeight.w700)
//               : AppTextStyles.body(),
//         ),
//         Text(
//           value,
//           style: large
//               ? AppTextStyles.h2(color: valueColor ?? AppColors.primary)
//               .copyWith(fontWeight: FontWeight.w800)
//               : AppTextStyles.bodyBold(color: valueColor ?? Colors.black),
//         ),
//       ],
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Payment status banner
//   // ---------------------------------------------------------------------
//
//   Widget _buildPaymentStatus(EstimateDetailModel estimate) {
//     final color = estimate.isFullyPaid ? AppColors.success : Colors.orange;
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 estimate.isFullyPaid
//                     ? Icons.check_circle_outline
//                     : Icons.hourglass_bottom_outlined,
//                 size: 18,
//                 color: color,
//               ),
//               SizedBox(width: Responsive.w(8)),
//               Text('Payment Status', style: AppTextStyles.bodyBold(color: color)),
//             ],
//           ),
//           Text(estimate.balanceStatusLabel, style: AppTextStyles.h3(color: color)),
//         ],
//       ),
//     );
//   }
//
//   // ---------------------------------------------------------------------
//   // Bottom bar
//   // ---------------------------------------------------------------------
//
//   Widget _buildBottomBar(BuildContext context, EstimateDetailModel estimate) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(
//             Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
//         child: ElevatedButton.icon(
//           onPressed: () => _openDespatchSheet(context, estimate),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           ),
//           icon: const Icon(Icons.local_shipping_outlined, size: 18),
//           label: const Text('Create Despatch Sheet'),
//         ),
//       ),
//     );
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
//   const _DetailSection({required this.title, required this.rows, this.icon});
//   final String title;
//   final List<_Row> rows;
//   final IconData? icon;
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
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               if (icon != null) ...[
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 15, color: AppColors.primary),
//                 ),
//                 SizedBox(width: Responsive.w(8)),
//               ],
//               Text(title,
//                   style: AppTextStyles.bodyBold(color: AppColors.primary)
//                       .copyWith(fontSize: Responsive.sp(13.5))),
//             ],
//           ),
//           SizedBox(height: Responsive.h(12)),
//           ...rows.map((r) => Padding(
//             padding: EdgeInsets.only(bottom: Responsive.h(10)),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (r.icon != null) ...[
//                   Icon(r.icon, size: 15, color: AppColors.textHint),
//                   SizedBox(width: Responsive.w(8)),
//                 ],
//                 if (r.label.isNotEmpty)
//                   SizedBox(
//                     width: r.icon != null ? 86 : 100,
//                     child: Text(r.label, style: AppTextStyles.caption()),
//                   ),
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimatedetail/estimate_detail_event.dart';
import '../../bloc/salemanbloc/estimatedetail/estimate_detail_state.dart';
import '../../bloc/salemanbloc/estimatedetail/estimatedetail_bloc.dart';
import '../../models/salesmanmodels/estimatedetail.model.dart';
import '../owner/ownerdespatchsheet.dart';

class SalesmanEstimateDetailsScreen extends StatefulWidget {
  const SalesmanEstimateDetailsScreen({super.key, required this.id});

  final String id;

  @override
  State<SalesmanEstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
}

class _EstimateDetailsScreenState extends State<SalesmanEstimateDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstimateDetailBloc()..add(EstimateDetailRequested(widget.id)),
      child: _EstimateDetailsView(id: widget.id),
    );
  }
}

class _EstimateDetailsView extends StatelessWidget {
  const _EstimateDetailsView({required this.id});

  final String id;

  /// Derived straight from the API response's `created_by_details.role_label`
  /// (e.g. "Owner" vs "Salesman") — no manual flag needed. When the estimate
  /// was created by an Owner, the Incentive column is hidden; for a
  /// Salesman-created estimate, it stays visible.
  bool _isOwner(EstimateDetailModel estimate) {
    return estimate.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending_approval':
        return Colors.orange;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending_approval':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  void _openDespatchSheet(BuildContext context, EstimateDetailModel estimate) async {
    final despatched = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(estimateId: estimate.id),
      ),
    );

    if (despatched == true && context.mounted) {
      // Pop this Estimate Detail screen too, returning to the screen
      // that opened it (e.g. Approved Bills) instead of the dashboard.
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Estimate Detail', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: BlocBuilder<EstimateDetailBloc, EstimateDetailState>(
            builder: (context, state) {
              if (state.status == EstimateDetailStatus.loading && state.detail == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == EstimateDetailStatus.failure && state.detail == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: AppColors.error),
                      SizedBox(height: Responsive.h(10)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                        child: Text(
                          state.error ?? 'Failed to load estimate.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.error),
                        ),
                      ),
                      SizedBox(height: Responsive.h(10)),
                      TextButton(
                        onPressed: () =>
                            context.read<EstimateDetailBloc>().add(EstimateDetailRequested(id)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final estimate = state.detail;
              if (estimate == null) return const SizedBox.shrink();

              final statusColor = _statusColor(estimate.status);
              final isOwner = _isOwner(estimate);

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        // ---- Header card ----
                        Container(
                          padding: EdgeInsets.all(Responsive.w(16)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.07),
                                AppColors.primary.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.14)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Reference NO.',
                                            style: AppTextStyles.captionnew()
                                                .copyWith(letterSpacing: 0.6)),
                                        SizedBox(height: Responsive.h(4)),
                                        Text(
                                          estimate.estimateNumber.isEmpty
                                              ? '#${estimate.id}'
                                              : estimate.estimateNumber,
                                          style: AppTextStyles.bodyBold(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: Responsive.w(12)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('DATE',
                                          style: AppTextStyles.caption()
                                              .copyWith(letterSpacing: 0.6)),
                                      SizedBox(height: Responsive.h(4)),
                                      Text(
                                        estimate.date != null
                                            ? DateFormat('dd-MM-yyyy').format(estimate.date!)
                                            : estimate.dateRaw,
                                        style: AppTextStyles.bodyBold(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.h(14)),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(estimate.status),
                                        size: 14, color: statusColor),
                                    SizedBox(width: Responsive.w(6)),
                                    Text(
                                      _statusLabel(estimate.status),
                                      style: AppTextStyles.bodyBold(color: statusColor)
                                          .copyWith(fontSize: Responsive.sp(12)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(16)),

                        _DetailSection(
                          title: 'Customer Details',
                          icon: Icons.groups_2_outlined,
                          rows: [
                            _Row(' Name', estimate.customerName, icon: Icons.groups_2_outlined),
                            _Row('Address', estimate.customerAddress,
                                icon: Icons.location_on_outlined),
                            _Row('Contact No.', estimate.customerPhone,
                                icon: Icons.phone_outlined),
                            _Row('Email', estimate.customerEmail, icon: Icons.alternate_email),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),
                        _DetailSection(
                          title: 'Contractor Details',
                          icon: Icons.person_outline,
                          rows: [
                            _Row(' Name', estimate.customer.name, icon: Icons.groups_2_outlined),
                            _Row('Contact No.', estimate.customer.phone,
                                icon: Icons.phone_outlined),
                            _Row('Email', estimate.customer.email, icon: Icons.alternate_email),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),
                        // Salesman section — always shown, including for owners.
                        _DetailSection(
                          title: 'Salesman',
                          icon: Icons.badge_outlined,
                          rows: [
                            _Row('Name', estimate.salesman.name, icon: Icons.badge_outlined),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),

                        if (estimate.siteVisit.id.isNotEmpty)
                          _DetailSection(
                            title: 'Site Visit',
                            icon: Icons.location_history_outlined,
                            rows: [
                              _Row('Visit Date', estimate.siteVisit.visitDate,
                                  icon: Icons.event_outlined),
                              _Row('Status', estimate.siteVisit.statusLabel,
                                  icon: Icons.flag_outlined),
                              _Row('Field Staff', estimate.siteVisit.fieldStaffName,
                                  icon: Icons.engineering_outlined),
                            ],
                          ),
                        SizedBox(height: Responsive.h(20)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.list_alt_rounded,
                                      size: 15, color: AppColors.primary),
                                ),
                                SizedBox(width: Responsive.w(8)),
                                Text('Items', style: AppTextStyles.h3()),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Total Items: ${estimate.itemsCount}',
                                style: AppTextStyles.bodyBold(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(12)),

                        _buildItemsTable(estimate, number, isOwner),
                        SizedBox(height: Responsive.h(16)),

                        if (estimate.notes.isNotEmpty) ...[
                          _DetailSection(
                            title: 'Notes',
                            icon: Icons.sticky_note_2_outlined,
                            rows: [_Row('', estimate.notes)],
                          ),
                          SizedBox(height: Responsive.h(14)),
                        ],

                        _buildSummaryCard(estimate, number),
                        SizedBox(height: Responsive.h(12)),

                        if (estimate.isApproved) _buildPaymentStatus(estimate),
                      ],
                    ),
                  ),
                  if (estimate.isApproved) _buildBottomBar(context, estimate),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Items table — Excel-style bordered grid with Total row
  // ---------------------------------------------------------------------

  Widget _buildItemsTable(EstimateDetailModel estimate, NumberFormat number, bool isOwner) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final items = estimate.items;

    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('No items on this estimate.', style: AppTextStyles.caption()),
      );
    }

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(
        0, (s, i) => s + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));

    final hasBoxQty = items.any((i) => i.boxQuantity > 0);
    final hasPieceQty = items.any((i) => i.pieceQuantity > 0);
    final showIncentive = !isOwner;

    // label, width, alignment
    final cols = <(String, double, TextAlign)>[
      ('Sl.No', 50, TextAlign.center),
      ('Item', 170, TextAlign.left),
      ('Company', 110, TextAlign.left),
      ('Size', 90, TextAlign.center),
      ('Qty', 70, TextAlign.right),
      ('Unit', 60, TextAlign.center),
      if (hasBoxQty) ('Box Qty', 70, TextAlign.right),
      if (hasPieceQty) ('Piece Qty', 80, TextAlign.right),
      ('MRP', 80, TextAlign.right),
      ('Rate', 80, TextAlign.right),
      ('Amount', 100, TextAlign.right),
      if (showIncentive) ('Incentive', 90, TextAlign.right),
    ];

    final amountCol = cols.indexWhere((c) => c.$1 == 'Amount');
    final qtyCol = cols.indexWhere((c) => c.$1 == 'Qty');
    final incentiveCol = cols.indexWhere((c) => c.$1 == 'Incentive');

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

    TableRow itemRow(int i, EstimateDetailItem it) {
      final values = <String>[
        '${i + 1}',
        it.productName,
        it.companyName.isEmpty ? '-' : it.companyName,
        it.productSize.isEmpty ? '-' : it.productSize,
        number.format(it.quantity),
        it.unitName.isEmpty ? '-' : it.unitName,
        if (hasBoxQty) it.boxQuantity > 0 ? number.format(it.boxQuantity) : '-',
        if (hasPieceQty) it.pieceQuantity > 0 ? number.format(it.pieceQuantity) : '-',
        it.mrp > 0 ? currency.format(it.mrp) : '-',
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
              color: (showIncentive && c == incentiveCol) ? AppColors.success : null,
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
            top: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.2),
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
          // Full grid lines (Excel style) in your theme border color.
          border: TableBorder.all(color: AppColors.border, width: 0.8),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            for (var c = 0; c < cols.length; c++) c: FixedColumnWidth(cols[c].$2),
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
  // ---------------------------------------------------------------------
  // Summary card
  // ---------------------------------------------------------------------

  Widget _buildSummaryCard(EstimateDetailModel estimate, NumberFormat number) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Column(
              children: [

                SizedBox(height: Responsive.h(8)),
                _totalRow('Total Sq.Ft', number.format(estimate.totalSquareFeet)),
                SizedBox(height: Responsive.h(8)),
                _totalRow('Subtotal', currency.format(estimate.subtotal)),
                SizedBox(height: Responsive.h(8)),
                _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),
                SizedBox(height: Responsive.h(8)),
                _totalRow('Total Before Discount', currency.format(estimate.grandTotal)),

                // Discount, payment, and balance are only meaningful once
                // the estimate is approved — while pending, these fields
                // are still zero/unset on the server, so showing them
                // would just display misleading zeros.
                if (estimate.isApproved && estimate.hasDiscount) ...[
                  SizedBox(height: Responsive.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Discount (${estimate.discountTypeLabel})',
                            style: AppTextStyles.body()),
                      ),
                      Text('- ${currency.format(estimate.discountAmount)}',
                          style: AppTextStyles.bodyBold(color: Colors.red)),
                    ],
                  ),
                ],

                if (estimate.isApproved) ...[
                  SizedBox(height: Responsive.h(8)),
                  _totalRow(
                    large: true,
                    'Grand Total', currency.format(estimate.amountAfterDiscount),
                  ),
                  SizedBox(height: Responsive.h(8)),
                  _totalRow('Total Paid', currency.format(estimate.totalPaid),
                      valueColor: AppColors.success),
                ],
              ],
            ),
          ),
          // Grand Total strip
          // Balance strip — only meaningful once approved.
          if (estimate.isApproved)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(16), vertical: Responsive.h(14)),
              decoration: BoxDecoration(
                color: estimate.balanceAmount > 0
                    ? Colors.red.withOpacity(0.06)

                    : AppColors.success.withOpacity(0.08),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Balance Due', style: AppTextStyles.h3()),
                  Text(
                    currency.format(estimate.balanceAmount),
                    style: AppTextStyles.h2(
                        color: estimate.balanceAmount > 0 ? Colors.red : AppColors.success),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  Widget _totalRow(String label, String value, {Color? valueColor, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: large
              ? AppTextStyles.h3().copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.body(),
        ),
        Text(
          value,
          style: large
              ? AppTextStyles.h2(color: valueColor ?? AppColors.primary)
              .copyWith(fontWeight: FontWeight.w800)
              : AppTextStyles.bodyBold(color: valueColor ?? Colors.black),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Payment status banner
  // ---------------------------------------------------------------------

  Widget _buildPaymentStatus(EstimateDetailModel estimate) {
    final color = estimate.isFullyPaid ? AppColors.success : Colors.orange;
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
                estimate.isFullyPaid
                    ? Icons.check_circle_outline
                    : Icons.hourglass_bottom_outlined,
                size: 18,
                color: color,
              ),
              SizedBox(width: Responsive.w(8)),
              Text('Payment Status', style: AppTextStyles.bodyBold(color: color)),
            ],
          ),
          Text(estimate.balanceStatusLabel, style: AppTextStyles.h3(color: color)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------

  Widget _buildBottomBar(BuildContext context, EstimateDetailModel estimate) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
        child: ElevatedButton.icon(
          onPressed: () => _openDespatchSheet(context, estimate),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: const Text('Create Despatch Sheet'),
        ),
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  final IconData? icon;
  _Row(this.label, this.value, {this.icon});
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows, this.icon});
  final String title;
  final List<_Row> rows;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(8)),
              ],
              Text(title,
                  style: AppTextStyles.bodyBold(color: AppColors.primary)
                      .copyWith(fontSize: Responsive.sp(13.5))),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 15, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                if (r.label.isNotEmpty)
                  SizedBox(
                    width: r.icon != null ? 86 : 100,
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