// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../../../models/dispatch_model.dart';
// import '../../salesman/dispatch/cubit/dispatch_cubit.dart';
//
// class DispatchDetailScreen extends StatelessWidget {
//   const DispatchDetailScreen({super.key, required this.dispatchId});
//
//   final String dispatchId;
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final dateFmt = DateFormat('dd MMM yyyy');
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Dispatch Details', style: AppTextStyles.h6())),
//       body: BlocBuilder<DispatchCubit, List<DispatchModel>>(
//         builder: (context, list) {
//           DispatchModel? dispatch;
//           try {
//             dispatch = list.firstWhere((d) => d.id == dispatchId);
//           } catch (_) {
//             dispatch = null;
//           }
//
//           if (dispatch == null) {
//             return Center(
//               child: Text('This dispatch bill is no longer available', style: AppTextStyles.body()),
//             );
//           }
//
//           final delivered = dispatch.status.toLowerCase() == 'delivered';
//
//           return SafeArea(
//             child: Padding(
//               padding: EdgeInsets.all(Responsive.w(18)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(dispatch.id, style: AppTextStyles.caption()),
//                   SizedBox(height: Responsive.h(4)),
//                   Text(dispatch.contractorName, style: AppTextStyles.h3()),
//                   SizedBox(height: Responsive.h(6)),
//                   Row(
//                     children: [
//                       Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
//                       SizedBox(width: Responsive.w(4)),
//                       Expanded(
//                         child: Text(dispatch.siteAddress, style: AppTextStyles.caption()),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: Responsive.h(16)),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: Responsive.w(14), vertical: Responsive.h(8)),
//                     decoration: BoxDecoration(
//                       color: (delivered ? AppColors.info : AppColors.warning).withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           delivered ? Icons.check_circle_rounded : Icons.local_shipping_outlined,
//                           size: 18,
//                           color: delivered ? AppColors.info : AppColors.warning,
//                         ),
//                         SizedBox(width: Responsive.w(6)),
//                         Text(
//                           delivered ? 'Delivered' : 'On Progress',
//                           style: TextStyle(
//                             color: delivered ? AppColors.info : AppColors.warning,
//                             fontWeight: FontWeight.w600,
//                             fontSize: Responsive.sp(13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: Responsive.h(20)),
//                   Container(
//                     padding: EdgeInsets.all(Responsive.w(14)),
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: Column(
//                       children: [
//                         _infoRow('Date', dateFmt.format(dispatch.date)),
//                         SizedBox(height: Responsive.h(8)),
//                         _infoRow('Amount', currency.format(dispatch.amount)),
//                         SizedBox(height: Responsive.h(8)),
//                         _infoRow('Status', delivered ? 'Delivered' : 'On Progress'),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   SizedBox(
//                     width: double.infinity,
//                     child: delivered
//                         ? OutlinedButton.icon(
//                       onPressed: null,
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape:
//                         RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                       ),
//                       icon: const Icon(Icons.check_circle_rounded, size: 18),
//                       label: const Text('Delivered'),
//                     )
//                         : ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape:
//                         RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                       ),
//                       onPressed: () {
//                       },
//                       icon: const Icon(Icons.local_shipping_rounded, size: 18),
//                       label: const Text('Mark as Delivered'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _infoRow(String label, String value) {
//     return Row(
//       children: [
//         SizedBox(width: 100, child: Text(label, style: AppTextStyles.caption())),
//         Expanded(child: Text(value, style: AppTextStyles.bodyBold())),
//       ],
//     );
//   }
// }