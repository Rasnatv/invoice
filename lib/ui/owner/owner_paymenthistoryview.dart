// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../../../dummymodels/estimate_model.dart';
//
//
// class PaymentHistoryScreen extends StatelessWidget {
//   const PaymentHistoryScreen({super.key, required this.estimate});
//   final EstimateModel estimate;
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final history = estimate.paymentHistory;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('Payment History', style: AppTextStyles.h6()),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         actions: [
//           // Optional: Add summary info in AppBar
//           Padding(
//             padding: EdgeInsets.only(right: Responsive.w(16)),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'Total Paid: ${currency.format(estimate.amountPaid)}',
//                   style: AppTextStyles.caption(color: Colors.white),
//                 ),
//                 Text(
//                   '${history.length} payments',
//                   //style: AppTextStyles.caption(fontSize: 10, color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Summary Card
//             Container(
//               margin: EdgeInsets.all(Responsive.w(16)),
//               padding: EdgeInsets.all(Responsive.w(14)),
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Estimate #${estimate.id}', style: AppTextStyles.bodyBold()),
//                       Text(
//                         estimate.contractorName,
//                         style: AppTextStyles.bodyBold(color: AppColors.primary),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(8)),
//                   const Divider(height: 1, color: AppColors.border),
//                   SizedBox(height: Responsive.h(8)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _SummaryChip(
//                         label: 'Total Amount',
//                         value: currency.format(estimate.totalAmount),
//                       ),
//                       _SummaryChip(
//                         label: 'Paid Amount',
//                         value: currency.format(estimate.amountPaid),
//                         color: AppColors.primary,
//                       ),
//                       _SummaryChip(
//                         label: 'Balance',
//                         value: currency.format(estimate.balance),
//                         color: Colors.red,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Payment History List
//             Expanded(
//               child: history.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.history,
//                       size: Responsive.w(60),
//                       color: AppColors.textSecondary.withOpacity(0.3),
//                     ),
//                     SizedBox(height: Responsive.h(16)),
//                     Text(
//                       'No payment records yet',
//                       style: AppTextStyles.subtitle(color: AppColors.textSecondary),
//                     ),
//                   ],
//                 ),
//               )
//                   : ListView.separated(
//                 padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
//                 itemCount: history.length,
//                 separatorBuilder: (_, __) => SizedBox(height: Responsive.h(8)),
//                 itemBuilder: (context, index) {
//                   final payment = history.reversed.toList()[index]; // Show newest first
//                   return _PaymentHistoryCard(
//                     payment: payment,
//                     currency: currency,
//                     index: history.length - index,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SummaryChip extends StatelessWidget {
//   const _SummaryChip({
//     required this.label,
//     required this.value,
//     this.color,
//   });
//
//   final String label;
//   final String value;
//   final Color? color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(label, style: AppTextStyles.caption()),
//         SizedBox(height: Responsive.h(4)),
//         Text(
//           value,
//           style: AppTextStyles.bodyBold(color: color ?? AppColors.textPrimary),
//         ),
//       ],
//     );
//   }
// }
//
// class _PaymentHistoryCard extends StatelessWidget {
//   const _PaymentHistoryCard({
//     required this.payment,
//     required this.currency,
//     required this.index,
//   });
//
//   final PaymentRecord payment;
//   final NumberFormat currency;
//   final int index;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           // Payment Number/Icon
//           Container(
//             width: Responsive.w(40),
//             height: Responsive.w(40),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 '#$index',
//                 style: AppTextStyles.bodyBold(
//                   color: AppColors.primary,
//                   //fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: Responsive.w(12)),
//
//           // Payment Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       _getPaymentIcon(payment.paymentMethod),
//                       size: Responsive.w(14),
//                       color: AppColors.textSecondary,
//                     ),
//                     SizedBox(width: Responsive.w(4)),
//                     Text(
//                       payment.paymentMethod ?? 'Unknown Method',
//                       //style: AppTextStyles.bodyBold(fontSize: 13),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: Responsive.h(2)),
//                 Text(
//                   DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(payment.date),
//                   //style: AppTextStyles.caption(fontSize: 11),
//                 ),
//                 if (payment.note != null) ...[
//                   SizedBox(height: Responsive.h(2)),
//                   Text(
//                     payment.note!,
//                     style: AppTextStyles.caption(
//                       //fontSize: 11,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           // Amount
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 currency.format(payment.amount),
//                 style: AppTextStyles.bodyBold(
//                   color: AppColors.primary,
//                   //fontSize: 15,
//                 ),
//               ),
//               if (payment.paymentMethod != null)
//                 Container(
//                   margin: EdgeInsets.only(top: Responsive.h(4)),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: Responsive.w(8),
//                     vertical: Responsive.h(2),
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getMethodColor(payment.paymentMethod!).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     payment.paymentMethod!,
//                     style: AppTextStyles.caption(
//                       //fontSize: 9,
//                       color: _getMethodColor(payment.paymentMethod!),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getPaymentIcon(String? method) {
//     switch (method) {
//       case 'Cash':
//         return Icons.attach_money;
//       case 'UPI':
//         return Icons.qr_code_scanner;
//       case 'Bank Transfer':
//         return Icons.account_balance;
//       case 'Cheque':
//         return Icons.description;
//       case 'Card':
//         return Icons.credit_card;
//       default:
//         return Icons.payment;
//     }
//   }
//
//   Color _getMethodColor(String method) {
//     switch (method) {
//       case 'Cash':
//         return Colors.green;
//       case 'UPI':
//         return Colors.blue;
//       case 'Bank Transfer':
//         return Colors.purple;
//       case 'Cheque':
//         return Colors.orange;
//       case 'Card':
//         return Colors.red;
//       default:
//         return AppColors.textSecondary;
//     }
//   }
// }