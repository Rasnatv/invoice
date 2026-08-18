//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import 'cubit/dummymodel.dart';
//
// class OwnerDispatchDetailScreen extends StatelessWidget {
//   const OwnerDispatchDetailScreen({super.key, required this.dispatchId});
//
//   final String dispatchId;
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     final dispatch = DispatchDummyData.billById(dispatchId);
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('Dispatch Details', style: AppTextStyles.h6()),
//       ),
//       body: dispatch == null
//           ? Center(
//         child: Text('This dispatch bill is no longer available', style: AppTextStyles.body()),
//       )
//           : _buildBody(dispatch),
//     );
//   }
//
//   Widget _buildBody(dispatch) {
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
//     final delivered = dispatch.status.toLowerCase() == 'delivered';
//
//     return SafeArea(
//       child: ListView(
//         padding: EdgeInsets.all(Responsive.w(18)),
//         children: [
//           _StatusBanner(delivered: delivered, deliveredAt: dispatch.deliveredAt, dateFmt: dateFmt),
//           SizedBox(height: Responsive.h(16)),
//           Container(
//             padding: EdgeInsets.all(Responsive.w(14)),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: AppColors.border),
//             ),
//             child: Column(
//               children: [
//                 _infoRow('DS Number', dispatch.dsNumber),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Ref. No.', dispatch.refNo),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Party Name', dispatch.contractorName),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Contact Number', dispatch.phone),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Delivery Address', dispatch.siteAddress),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Despatched By', dispatch.despatchedBy),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Despatched At', dateFmt.format(dispatch.date)),
//                 SizedBox(height: Responsive.h(6)),
//                 _infoRow('Driver Name', dispatch.driverName),
//                 _infoRow('Driver ContactNo.', "+91 9633215632"),
//               ],
//             ),
//           ),
//           SizedBox(height: Responsive.h(18)),
//           Text('Items', style: AppTextStyles.h3()),
//           SizedBox(height: Responsive.h(10)),
//           Container(
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: AppColors.border),
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Column(
//               children: [
//                 Container(
//                   color: AppColors.surfaceAlt,
//                   padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
//                   child: Row(
//                     children: [
//                       SizedBox(width: 24, child: Text('#', style: AppTextStyles.captionnew())),
//                       Expanded(flex: 3, child: Text('Item', style: AppTextStyles.captionnew())),
//                       Expanded(flex: 2, child: Text('Company', style: AppTextStyles.captionnew())),
//                       Expanded(flex: 2, child: Text('Size', style: AppTextStyles.captionnew())),
//                       SizedBox(width: 44, child: Text('Box', style: AppTextStyles.captionnew())),
//                       SizedBox(width: 44, child: Text('Pcs', style: AppTextStyles.captionnew())),
//                     ],
//                   ),
//                 ),
//                 for (var i = 0; i < dispatch.items.length; i++)
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
//                     decoration: const BoxDecoration(
//                       border: Border(top: BorderSide(color: AppColors.border)),
//                     ),
//                     child: Row(
//                       children: [
//                         SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.body())),
//                         Expanded(
//                           flex: 3,
//                           child: Text(dispatch.items[i].name,
//                               style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(dispatch.items[i].company,
//                               style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(dispatch.items[i].size,
//                               style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
//                         ),
//                         SizedBox(width: 44, child: Text(dispatch.items[i].boxes, style: AppTextStyles.body())),
//                         SizedBox(width: 44, child: Text(dispatch.items[i].pieces, style: AppTextStyles.body())),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           SizedBox(height: Responsive.h(16)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Grand Total', style: AppTextStyles.bodyBold()),
//               Text(
//                 currency.format(dispatch.amount),
//                 style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
//               ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(20)),
//           const _SignatureBlock(),
//           SizedBox(height: Responsive.h(12)),
//         ],
//       ),
//     );
//   }
//
//   Widget _infoRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption())),
//         Expanded(child: Text(value.isEmpty ? '-' : value, style: AppTextStyles.bodyBold())),
//       ],
//     );
//   }
// }
//
// class _StatusBanner extends StatelessWidget {
//   const _StatusBanner({required this.delivered, required this.deliveredAt, required this.dateFmt});
//   final bool delivered;
//   final DateTime? deliveredAt;
//   final DateFormat dateFmt;
//
//   @override
//   Widget build(BuildContext context) {
//     final color = delivered ? AppColors.info : AppColors.warning;
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(delivered ? Icons.check_circle_rounded : Icons.local_shipping_outlined, color: color, size: 20),
//           SizedBox(width: Responsive.w(8)),
//           Expanded(
//             child: Text(
//               delivered
//                   ? 'Delivered on ${deliveredAt != null ? dateFmt.format(deliveredAt!) : '-'}'
//                   : 'Pending delivery',
//               style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: Responsive.sp(12.5)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SignatureBlock extends StatelessWidget {
//   const _SignatureBlock();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           height: 60,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.border),
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         SizedBox(height: Responsive.h(6)),
//         Text('Customer Signature', style: AppTextStyles.caption()),
//       ],
//     );
//   }
// }