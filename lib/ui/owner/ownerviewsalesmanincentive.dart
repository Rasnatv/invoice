// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import '../salesman/incentive/salesmanincentivescreen.dart';
//
//
//
//
// class OwnerViewSalesmanScreen extends StatelessWidget {
//   const OwnerViewSalesmanScreen({super.key});
//
//   // Demo salesman list — replace with real data source when available.
//   static const _salesmen = [
//     _SalesmanOption('Rahul Kumar', '9123456780', 'Sales Executive'),
//     _SalesmanOption('Anoop Menon', '9123456781', 'Sales Executive'),
//     _SalesmanOption('Divya Prasad', '9123456782', 'Senior Sales Executive'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Salesman Incentives', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: ListView.separated(
//           padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(24)),
//           itemCount: _salesmen.length,
//           separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
//           itemBuilder: (context, index) {
//             final s = _salesmen[index];
//             return _SalesmanTile(
//               option: s,
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => SalesmanIncentiveScreen(
//                     salesmanName: s.name,
//                     role: s.role,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class _SalesmanOption {
//   const _SalesmanOption(this.name, this.mobile, this.role);
//   final String name;
//   final String mobile;
//   final String role;
// }
//
// class _SalesmanTile extends StatelessWidget {
//   const _SalesmanTile({required this.option, required this.onTap});
//   final _SalesmanOption option;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           padding: EdgeInsets.all(Responsive.w(14)),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   option.name.isNotEmpty ? option.name[0].toUpperCase() : '?',
//                   style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(16)),
//                 ),
//               ),
//               SizedBox(width: Responsive.w(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(option.name, style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14))),
//                     SizedBox(height: Responsive.h(2)),
//                     Text('${option.role} · ${option.mobile}', style: AppTextStyles.caption()),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }