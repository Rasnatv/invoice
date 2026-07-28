// //
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:tileshop/features/dashboard/owner/presentation/salesmanincentivesetup.dart';
// // import '../../../../core/constants/app_colors.dart';
// // import '../../../../core/constants/app_text_styles.dart';
// // import '../../../../core/model/product_incentive_model.dart';
// // import '../../../../core/utils/responsive.dart';
// // import 'add_incentiveproduct.dart';
// //
// //
// // /// How the monthly bonus is paid out once a salesman crosses their target.
// // enum BonusType { fixed, percent }
// //
// // /// Simple dummy salesman record. Swap this out for your real model/API
// // /// once you wire this screen up to actual salesman data.
// // class SalesmanModel {
// //   const SalesmanModel({required this.id, required this.name});
// //   final String id;
// //   final String name;
// // }
// //
// // /// One salesman's monthly bonus setup: which month/year it applies to,
// // /// their own target, and whether the bonus is a flat ₹ amount or a %.
// // class SalesmanMonthlyBonus {
// //   const SalesmanMonthlyBonus({
// //     this.enabled = false,
// //     required this.month,
// //     required this.year,
// //     this.target,
// //     this.bonusType = BonusType.percent,
// //     this.bonusValue = 0,
// //   });
// //
// //   final bool enabled;
// //   final int month;
// //   final int year;
// //   final double? target;
// //   final BonusType bonusType;
// //
// //   /// Meaning depends on [bonusType]: a ₹ amount when fixed, a % when percent.
// //   final double bonusValue;
// //
// //   bool get hasTarget => target != null && target! > 0;
// //
// //   SalesmanMonthlyBonus copyWith({
// //     bool? enabled,
// //     int? month,
// //     int? year,
// //     double? target,
// //     bool clearTarget = false,
// //     BonusType? bonusType,
// //     double? bonusValue,
// //   }) {
// //     return SalesmanMonthlyBonus(
// //       enabled: enabled ?? this.enabled,
// //       month: month ?? this.month,
// //       year: year ?? this.year,
// //       target: clearTarget ? null : (target ?? this.target),
// //       bonusType: bonusType ?? this.bonusType,
// //       bonusValue: bonusValue ?? this.bonusValue,
// //     );
// //   }
// // }
// //
// // /// Main Incentive screen — deliberately kept to just two things:
// // /// 1) "Add Monthly Target" -> opens the dedicated salesman incentive
// // ///    setup flow (dropdown + edit/delete), in salesman_incentive_setup_screen.dart.
// // /// 2) Product-wise Incentive -> the product incentive list below.
// // class IncentiveManagementScreen extends StatefulWidget {
// //   const IncentiveManagementScreen({super.key});
// //
// //   @override
// //   State<IncentiveManagementScreen> createState() => _IncentiveManagementScreenState();
// // }
// //
// // class _IncentiveManagementScreenState extends State<IncentiveManagementScreen> {
// //   final _searchCtrl = TextEditingController();
// //
// //   final List<ProductIncentiveModel> _products = [
// //     const ProductIncentiveModel(
// //       id: 'p1',
// //       name: 'Vitrified Tile 600x600',
// //       company: 'Kajaria',
// //       size: '600x600',
// //       unit: 'box',
// //       mrp: 65,
// //       rate: 55,
// //       incentivePercent: 5,
// //     ),
// //     const ProductIncentiveModel(
// //       id: 'p2',
// //       name: 'Wall Tile 300x450',
// //       company: 'Somany',
// //       size: '300x450',
// //       unit: 'box',
// //       mrp: 48,
// //       rate: 40,
// //       incentivePercent: 4,
// //     ),
// //     const ProductIncentiveModel(
// //       id: 'p3',
// //       name: 'PVC Pipe 4"',
// //       company: 'Supreme',
// //       size: '4"',
// //       unit: 'piece',
// //       mrp: 320,
// //       rate: 280,
// //       incentivePercent: 3,
// //     ),
// //   ];
// //
// //   // demo per-product achieved-sales values, keyed by product id
// //   final Map<String, double> _achievedSales = {
// //     'p1': 125000,
// //     'p2': 60000,
// //     'p3': 210000,
// //   };
// //
// //   // ---- Salesman dummy data ----
// //   final List<SalesmanModel> _salesmen = const [
// //     SalesmanModel(id: 's1', name: 'Ramesh Kumar'),
// //     SalesmanModel(id: 's2', name: 'Suresh Patel'),
// //     SalesmanModel(id: 's3', name: 'Anita Sharma'),
// //   ];
// //
// //   // Each salesman gets their own monthly target + bonus setup. Owned here
// //   // and handed (by reference) to the salesman incentive setup flow so
// //   // edits/deletes made there are reflected everywhere.
// //   late final Map<String, SalesmanMonthlyBonus> _monthlyBonusBySalesman = {
// //     's1': SalesmanMonthlyBonus(
// //       enabled: true,
// //       month: DateTime.now().month,
// //       year: DateTime.now().year,
// //       target: 300000,
// //       bonusType: BonusType.percent,
// //       bonusValue: 2,
// //     ),
// //     's2': SalesmanMonthlyBonus(
// //       enabled: true,
// //       month: DateTime.now().month,
// //       year: DateTime.now().year,
// //       target: 200000,
// //       bonusType: BonusType.fixed,
// //       bonusValue: 5000,
// //     ),
// //     's3': SalesmanMonthlyBonus(
// //       enabled: false,
// //       month: DateTime.now().month,
// //       year: DateTime.now().year,
// //     ),
// //   };
// //
// //   final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
// //
// //   String _periodLabelFor(SalesmanMonthlyBonus b) =>
// //       DateFormat('MMMM yyyy').format(DateTime(b.year, b.month));
// //
// //   double _achievedFor(ProductIncentiveModel p) => _achievedSales[p.id] ?? 0;
// //
// //   double _incentiveFor(ProductIncentiveModel p) {
// //     return _achievedFor(p) * (p.incentivePercent / 100);
// //   }
// //
// //   List<ProductIncentiveModel> get _filtered {
// //     final q = _searchCtrl.text.trim().toLowerCase();
// //     if (q.isEmpty) return _products;
// //     return _products
// //         .where((p) =>
// //     p.name.toLowerCase().contains(q) || p.company.toLowerCase().contains(q))
// //         .toList();
// //   }
// //
// //   Future<void> _openAddProduct() async {
// //     final created = await Navigator.of(context).push<ProductIncentiveModel>(
// //       MaterialPageRoute(builder: (_) => const OwnerAddIncentiveProductScreen()),
// //     );
// //     if (created != null) {
// //       setState(() {
// //         _products.add(created);
// //         // New product starts with no recorded sales yet, so it shows
// //         // an explicit ₹0 / "no sales yet" state instead of looking blank.
// //         _achievedSales.putIfAbsent(created.id, () => 0);
// //       });
// //     }
// //   }
// //
// //   Future<void> _openEditProduct(ProductIncentiveModel product) async {
// //     final updated = await Navigator.of(context).push<ProductIncentiveModel>(
// //       MaterialPageRoute(builder: (_) => OwnerAddIncentiveProductScreen(product: product)),
// //     );
// //     if (updated != null) {
// //       setState(() {
// //         final i = _products.indexWhere((p) => p.id == updated.id);
// //         if (i != -1) _products[i] = updated;
// //       });
// //     }
// //   }
// //
// //   Future<void> _confirmDeleteProduct(ProductIncentiveModel product) async {
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (dialogContext) => AlertDialog(
// //         title: Text('Delete Product?', style: AppTextStyles.bodyBold()),
// //         content: Text(
// //           'This will remove "${product.name}" and its incentive setup. This cannot be undone.',
// //           style: AppTextStyles.caption(),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(dialogContext).pop(false),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
// //             onPressed: () => Navigator.of(dialogContext).pop(true),
// //             child: const Text('Delete', style: TextStyle(color: Colors.white)),
// //           ),
// //         ],
// //       ),
// //     );
// //     if (confirmed == true) {
// //       setState(() {
// //         _products.removeWhere((p) => p.id == product.id);
// //         _achievedSales.remove(product.id);
// //       });
// //     }
// //   }
// //
// //   /// "Add Monthly Target" -> opens the salesman incentive setup flow
// //   /// (dropdown to pick a salesman, view/edit/delete their target + bonus).
// //   Future<void> _openIncentiveSetupList() async {
// //     await Navigator.of(context).push(
// //       MaterialPageRoute(
// //         builder: (_) => SalesmanIncentiveListScreen(
// //           salesmen: _salesmen,
// //           bonusBySalesman: _monthlyBonusBySalesman,
// //           currency: _currency,
// //           periodLabelFor: _periodLabelFor,
// //         ),
// //       ),
// //     );
// //     // The setup screen mutates the same map instance directly — nothing
// //     // on this screen currently displays it, but refresh just in case.
// //     if (mounted) setState(() {});
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     Responsive.init(context);
// //     final items = _filtered;
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.background,
// //       appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
// //       floatingActionButton: FloatingActionButton(
// //         backgroundColor: AppColors.primary,
// //         onPressed: _openAddProduct,
// //         child: const Icon(Icons.add, color: Colors.white),
// //       ),
// //       body: SafeArea(
// //         child: ListView(
// //           padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(20)),
// //           children: [
// //             SizedBox(height: Responsive.h(14)),
// //
// //             // Opens the dedicated salesman incentive setup flow.
// //             SizedBox(
// //               width: double.infinity,
// //               child: OutlinedButton.icon(
// //                 onPressed: _openIncentiveSetupList,
// //                 icon: const Icon(Icons.add_chart_outlined, color: AppColors.primary),
// //                 label: Text(
// //                   'Add Monthly Target',
// //                   style: AppTextStyles.bodyBold().copyWith(color: AppColors.primary),
// //                 ),
// //                 style: OutlinedButton.styleFrom(
// //                   side: const BorderSide(color: AppColors.primary),
// //                   padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: Responsive.h(20)),
// //
// //             Text('Product-wise Incentive', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
// //             SizedBox(height: Responsive.h(10)),
// //             TextField(
// //               controller: _searchCtrl,
// //               onChanged: (_) => setState(() {}),
// //               decoration: const InputDecoration(
// //                 hintText: 'Search product or company',
// //                 prefixIcon: Icon(Icons.search_rounded),
// //               ),
// //             ),
// //             SizedBox(height: Responsive.h(12)),
// //             if (items.isEmpty)
// //               Padding(
// //                 padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
// //                 child: Center(child: Text('No products found', style: AppTextStyles.subtitle())),
// //               )
// //             else
// //               Column(
// //                 children: [
// //                   for (int i = 0; i < items.length; i++) ...[
// //                     _ProductIncentiveCard(
// //                       product: items[i],
// //                       achieved: _achievedFor(items[i]),
// //                       incentiveEarned: _incentiveFor(items[i]),
// //                       currency: _currency,
// //                       onEdit: () => _openEditProduct(items[i]),
// //                       onDelete: () => _confirmDeleteProduct(items[i]),
// //                     ),
// //                     if (i != items.length - 1) SizedBox(height: Responsive.h(10)),
// //                   ],
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _ProductIncentiveCard extends StatelessWidget {
// //   const _ProductIncentiveCard({
// //     required this.product,
// //     required this.achieved,
// //     required this.incentiveEarned,
// //     required this.currency,
// //     required this.onEdit,
// //     required this.onDelete,
// //   });
// //
// //   final ProductIncentiveModel product;
// //   final double achieved;
// //   final double incentiveEarned;
// //   final NumberFormat currency;
// //   final VoidCallback onEdit;
// //   final VoidCallback onDelete;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final hasSales = achieved > 0;
// //     final hasSizeOrUnit = (product.size != null && product.size!.isNotEmpty) ||
// //         (product.unit != null && product.unit!.isNotEmpty);
// //
// //     return Container(
// //       padding: EdgeInsets.all(Responsive.w(14)),
// //       decoration: BoxDecoration(
// //         color: AppColors.surface,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: AppColors.border),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Text(product.name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
// //               ),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// //                 decoration: BoxDecoration(
// //                   color: AppColors.primary.withOpacity(0.12),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Text(
// //                   '${product.incentivePercent}% incentive',
// //                   style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
// //                 ),
// //               ),
// //               SizedBox(width: Responsive.w(4)),
// //               PopupMenuButton<String>(
// //                 padding: EdgeInsets.zero,
// //                 icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
// //                 onSelected: (value) {
// //                   if (value == 'edit') onEdit();
// //                   if (value == 'delete') onDelete();
// //                 },
// //                 itemBuilder: (context) => [
// //                   const PopupMenuItem(
// //                     value: 'edit',
// //                     child: Row(
// //                       children: [
// //                         Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
// //                         SizedBox(width: 8),
// //                         Text('Edit'),
// //                       ],
// //                     ),
// //                   ),
// //                   const PopupMenuItem(
// //                     value: 'delete',
// //                     child: Row(
// //                       children: [
// //                         Icon(Icons.delete_outline, size: 18, color: AppColors.error),
// //                         SizedBox(width: 8),
// //                         Text('Delete', style: TextStyle(color: AppColors.error)),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: Responsive.h(3)),
// //           Row(
// //             children: [
// //               Flexible(
// //                 child: Text(
// //                   product.company,
// //                   style: AppTextStyles.caption(),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //               if (hasSizeOrUnit) ...[
// //                 Text('  •  ', style: AppTextStyles.caption()),
// //                 Flexible(
// //                   child: Text(
// //                     [
// //                       if (product.size != null && product.size!.isNotEmpty) product.size,
// //                       if (product.unit != null && product.unit!.isNotEmpty) product.unit,
// //                     ].join(' '),
// //                     style: AppTextStyles.caption(),
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //           SizedBox(height: Responsive.h(6)),
// //           Row(
// //             children: [
// //               Text('MRP ${currency.format(product.mrp)}', style: AppTextStyles.caption()),
// //               SizedBox(width: Responsive.w(10)),
// //               Text('Rate ${currency.format(product.rate)}', style: AppTextStyles.caption()),
// //             ],
// //           ),
// //           SizedBox(height: Responsive.h(10)),
// //           const Divider(height: 1, color: AppColors.border),
// //           SizedBox(height: Responsive.h(10)),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 hasSales ? 'Achieved: ${currency.format(achieved)}' : 'No sales yet',
// //                 style: AppTextStyles.caption(),
// //               ),
// //               Text(
// //                 'Incentive: ${currency.format(incentiveEarned)}',
// //                 style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(13)),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/features/dashboard/owner/presentation/salesmanincentivesetup.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/model/product_incentive_model.dart';
// import '../../../../core/utils/responsive.dart';
// import 'add_incentiveproduct.dart';
// /// How the monthly bonus is paid out once a salesman crosses their target.
// enum BonusType { fixed, percent }
//
// /// Simple dummy salesman record. Swap this out for your real model/API
// /// once you wire this screen up to actual salesman data.
// class SalesmanModel {
//   const SalesmanModel({required this.id, required this.name});
//   final String id;
//   final String name;
// }
//
// /// One salesman's monthly bonus setup: which month/year it applies to,
// /// their own target, and whether the bonus is a flat ₹ amount or a %.
// class SalesmanMonthlyBonus {
//   const SalesmanMonthlyBonus({
//     this.enabled = false,
//     required this.month,
//     required this.year,
//     this.target,
//     this.bonusType = BonusType.percent,
//     this.bonusValue = 0,
//   });
//
//   final bool enabled;
//   final int month;
//   final int year;
//   final double? target;
//   final BonusType bonusType;
//
//   /// Meaning depends on [bonusType]: a ₹ amount when fixed, a % when percent.
//   final double bonusValue;
//
//   bool get hasTarget => target != null && target! > 0;
//
//   SalesmanMonthlyBonus copyWith({
//     bool? enabled,
//     int? month,
//     int? year,
//     double? target,
//     bool clearTarget = false,
//     BonusType? bonusType,
//     double? bonusValue,
//   }) {
//     return SalesmanMonthlyBonus(
//       enabled: enabled ?? this.enabled,
//       month: month ?? this.month,
//       year: year ?? this.year,
//       target: clearTarget ? null : (target ?? this.target),
//       bonusType: bonusType ?? this.bonusType,
//       bonusValue: bonusValue ?? this.bonusValue,
//     );
//   }
// }
//
// /// Main Incentive screen — deliberately kept to just two things:
// /// 1) "Add Monthly Target" -> opens the dedicated salesman incentive
// ///    setup flow (dropdown + edit/delete), in salesman_incentive_setup_screen.dart.
// /// 2) Product-wise Incentive -> the product incentive list below.
// class IncentiveManagementScreen extends StatefulWidget {
//   const IncentiveManagementScreen({super.key});
//
//   @override
//   State<IncentiveManagementScreen> createState() => _IncentiveManagementScreenState();
// }
//
// class _IncentiveManagementScreenState extends State<IncentiveManagementScreen> {
//   final _searchCtrl = TextEditingController();
//
//   final List<ProductIncentiveModel> _products = [
//     const ProductIncentiveModel(
//       id: 'p1',
//       name: 'Vitrified Tile 600x600',
//       company: 'Kajaria',
//       size: '600x600',
//       unit: 'box',
//       mrp: 65,
//       rate: 55,
//       incentivePercent: 5,
//     ),
//     const ProductIncentiveModel(
//       id: 'p2',
//       name: 'Wall Tile 300x450',
//       company: 'Somany',
//       size: '300x450',
//       unit: 'box',
//       mrp: 48,
//       rate: 40,
//       incentivePercent: 4,
//     ),
//     const ProductIncentiveModel(
//       id: 'p3',
//       name: 'PVC Pipe 4"',
//       company: 'Supreme',
//       size: '4"',
//       unit: 'piece',
//       mrp: 320,
//       rate: 280,
//       incentivePercent: 3,
//     ),
//   ];
//
//   // demo per-product achieved-sales values, keyed by product id
//   final Map<String, double> _achievedSales = {
//     'p1': 125000,
//     'p2': 60000,
//     'p3': 210000,
//   };
//
//   // ---- Salesman dummy data ----
//   final List<SalesmanModel> _salesmen = const [
//     SalesmanModel(id: 's1', name: 'Ramesh Kumar'),
//     SalesmanModel(id: 's2', name: 'Suresh Patel'),
//     SalesmanModel(id: 's3', name: 'Anita Sharma'),
//   ];
//
//   // Each salesman gets their own monthly target + bonus setup. Owned here
//   // and handed (by reference) to the salesman incentive setup flow so
//   // edits/deletes made there are reflected everywhere.
//   late final Map<String, SalesmanMonthlyBonus> _monthlyBonusBySalesman = {
//     's1': SalesmanMonthlyBonus(
//       enabled: true,
//       month: DateTime.now().month,
//       year: DateTime.now().year,
//       target: 300000,
//       bonusType: BonusType.percent,
//       bonusValue: 2,
//     ),
//     's2': SalesmanMonthlyBonus(
//       enabled: true,
//       month: DateTime.now().month,
//       year: DateTime.now().year,
//       target: 200000,
//       bonusType: BonusType.fixed,
//       bonusValue: 5000,
//     ),
//     's3': SalesmanMonthlyBonus(
//       enabled: false,
//       month: DateTime.now().month,
//       year: DateTime.now().year,
//     ),
//   };
//
//   final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//
//   String _periodLabelFor(SalesmanMonthlyBonus b) =>
//       DateFormat('MMMM yyyy').format(DateTime(b.year, b.month));
//
//   double _achievedFor(ProductIncentiveModel p) => _achievedSales[p.id] ?? 0;
//
//   double _incentiveFor(ProductIncentiveModel p) {
//     return _achievedFor(p) * (p.incentivePercent / 100);
//   }
//
//   List<ProductIncentiveModel> get _filtered {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     if (q.isEmpty) return _products;
//     return _products
//         .where((p) =>
//     p.name.toLowerCase().contains(q) || p.company.toLowerCase().contains(q))
//         .toList();
//   }
//
//   Future<void> _openAddProduct() async {
//     final created = await Navigator.of(context).push<ProductIncentiveModel>(
//       MaterialPageRoute(builder: (_) => const OwnerAddIncentiveProductScreen()),
//     );
//     if (created != null) {
//       setState(() {
//         _products.add(created);
//         // New product starts with no recorded sales yet, so it shows
//         // an explicit ₹0 / "no sales yet" state instead of looking blank.
//         _achievedSales.putIfAbsent(created.id, () => 0);
//       });
//     }
//   }
//
//   Future<void> _openEditProduct(ProductIncentiveModel product) async {
//     final updated = await Navigator.of(context).push<ProductIncentiveModel>(
//       MaterialPageRoute(builder: (_) => OwnerAddIncentiveProductScreen(product: product)),
//     );
//     if (updated != null) {
//       setState(() {
//         final i = _products.indexWhere((p) => p.id == updated.id);
//         if (i != -1) _products[i] = updated;
//       });
//     }
//   }
//
//   Future<void> _confirmDeleteProduct(ProductIncentiveModel product) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text('Delete Product?', style: AppTextStyles.bodyBold()),
//         content: Text(
//           'This will remove "${product.name}" and its incentive setup. This cannot be undone.',
//           style: AppTextStyles.caption(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       setState(() {
//         _products.removeWhere((p) => p.id == product.id);
//         _achievedSales.remove(product.id);
//       });
//     }
//   }
//
//   /// "Add Incentive" -> opens the salesman-selection screen. Setting the
//   /// actual target/incentive happens on a separate page after that.
//   Future<void> _openIncentiveSetupList() async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => AddIncentiveScreen(
//           salesmen: _salesmen,
//           bonusBySalesman: _monthlyBonusBySalesman,
//           currency: _currency,
//           periodLabelFor: _periodLabelFor,
//         ),
//       ),
//     );
//     // The setup screen mutates the same map instance directly — nothing
//     // on this screen currently displays it, but refresh just in case.
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final items = _filtered;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primary,
//         onPressed: _openAddProduct,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(20)),
//           children: [
//             SizedBox(height: Responsive.h(14)),
//
//             // Opens the dedicated salesman incentive setup flow.
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: _openIncentiveSetupList,
//                 icon: const Icon(Icons.add_chart_outlined, color: AppColors.primary),
//                 label: Text(
//                   'Add Incentive',
//                   style: AppTextStyles.bodyBold().copyWith(color: AppColors.primary),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: AppColors.primary),
//                   padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ),
//             SizedBox(height: Responsive.h(20)),
//
//             Text('Product-wise Incentive', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
//             SizedBox(height: Responsive.h(10)),
//             TextField(
//               controller: _searchCtrl,
//               onChanged: (_) => setState(() {}),
//               decoration: const InputDecoration(
//                 hintText: 'Search product or company',
//                 prefixIcon: Icon(Icons.search_rounded),
//               ),
//             ),
//             SizedBox(height: Responsive.h(12)),
//             if (items.isEmpty)
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
//                 child: Center(child: Text('No products found', style: AppTextStyles.subtitle())),
//               )
//             else
//               Column(
//                 children: [
//                   for (int i = 0; i < items.length; i++) ...[
//                     _ProductIncentiveCard(
//                       product: items[i],
//                       achieved: _achievedFor(items[i]),
//                       incentiveEarned: _incentiveFor(items[i]),
//                       currency: _currency,
//                       onEdit: () => _openEditProduct(items[i]),
//                       onDelete: () => _confirmDeleteProduct(items[i]),
//                     ),
//                     if (i != items.length - 1) SizedBox(height: Responsive.h(10)),
//                   ],
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ProductIncentiveCard extends StatelessWidget {
//   const _ProductIncentiveCard({
//     required this.product,
//     required this.achieved,
//     required this.incentiveEarned,
//     required this.currency,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   final ProductIncentiveModel product;
//   final double achieved;
//   final double incentiveEarned;
//   final NumberFormat currency;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   @override
//   Widget build(BuildContext context) {
//     final hasSales = achieved > 0;
//     final hasSizeOrUnit = (product.size != null && product.size!.isNotEmpty) ||
//         (product.unit != null && product.unit!.isNotEmpty);
//
//     return Container(
//       padding: EdgeInsets.all(Responsive.w(14)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(product.name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '${product.incentivePercent}% incentive',
//                   style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               SizedBox(width: Responsive.w(4)),
//               PopupMenuButton<String>(
//                 padding: EdgeInsets.zero,
//                 icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
//                 onSelected: (value) {
//                   if (value == 'edit') onEdit();
//                   if (value == 'delete') onDelete();
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
//                         SizedBox(width: 8),
//                         Text('Edit'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete_outline, size: 18, color: AppColors.error),
//                         SizedBox(width: 8),
//                         Text('Delete', style: TextStyle(color: AppColors.error)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: Responsive.h(3)),
//           Row(
//             children: [
//               Flexible(
//                 child: Text(
//                   product.company,
//                   style: AppTextStyles.caption(),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               if (hasSizeOrUnit) ...[
//                 Text('  •  ', style: AppTextStyles.caption()),
//                 Flexible(
//                   child: Text(
//                     [
//                       if (product.size != null && product.size!.isNotEmpty) product.size,
//                       if (product.unit != null && product.unit!.isNotEmpty) product.unit,
//                     ].join(' '),
//                     style: AppTextStyles.caption(),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           SizedBox(height: Responsive.h(6)),
//           Row(
//             children: [
//               Text('MRP ${currency.format(product.mrp)}', style: AppTextStyles.caption()),
//               SizedBox(width: Responsive.w(10)),
//               Text('Rate ${currency.format(product.rate)}', style: AppTextStyles.caption()),
//             ],
//           ),
//           SizedBox(height: Responsive.h(10)),
//           const Divider(height: 1, color: AppColors.border),
//           SizedBox(height: Responsive.h(10)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 hasSales ? 'Achieved: ${currency.format(achieved)}' : 'No sales yet',
//                 style: AppTextStyles.caption(),
//               ),
//               Text(
//                 'Incentive: ${currency.format(incentiveEarned)}',
//                 style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(13)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/features/dashboard/owner/presentation/salesmanincentivesetup.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/product_incentive_model.dart';
import '../../../../core/utils/responsive.dart';
import 'add_incentiveproduct.dart';

/// How the monthly bonus is paid out once a salesman crosses their target.
enum BonusType { fixed, percent }

/// Simple dummy salesman record. Swap this out for your real model/API
/// once you wire this screen up to actual salesman data.
class SalesmanModel {
  const SalesmanModel({required this.id, required this.name});
  final String id;
  final String name;
}

/// One salesman's monthly bonus setup: which month/year it applies to,
/// their own target, and whether the bonus is a flat ₹ amount or a %.
class SalesmanMonthlyBonus {
  const SalesmanMonthlyBonus({
    this.enabled = false,
    required this.month,
    required this.year,
    this.target,
    this.bonusType = BonusType.percent,
    this.bonusValue = 0,
  });

  final bool enabled;
  final int month;
  final int year;
  final double? target;
  final BonusType bonusType;

  /// Meaning depends on [bonusType]: a ₹ amount when fixed, a % when percent.
  final double bonusValue;

  bool get hasTarget => target != null && target! > 0;

  SalesmanMonthlyBonus copyWith({
    bool? enabled,
    int? month,
    int? year,
    double? target,
    bool clearTarget = false,
    BonusType? bonusType,
    double? bonusValue,
  }) {
    return SalesmanMonthlyBonus(
      enabled: enabled ?? this.enabled,
      month: month ?? this.month,
      year: year ?? this.year,
      target: clearTarget ? null : (target ?? this.target),
      bonusType: bonusType ?? this.bonusType,
      bonusValue: bonusValue ?? this.bonusValue,
    );
  }
}

/// Main Incentive screen — deliberately kept to just two things:
/// 1) "Add Incentive" -> opens the dedicated salesman incentive
///    setup flow (dropdown + edit/delete), in salesman_incentive_setup_screen.dart.
/// 2) Product-wise Incentive -> the product incentive list below.
class IncentiveManagementScreen extends StatefulWidget {
  const IncentiveManagementScreen({super.key});

  @override
  State<IncentiveManagementScreen> createState() => _IncentiveManagementScreenState();
}

class _IncentiveManagementScreenState extends State<IncentiveManagementScreen> {
  final _searchCtrl = TextEditingController();

  final List<ProductIncentiveModel> _products = [
    const ProductIncentiveModel(
      id: 'p1',
      name: 'Vitrified Tile 600x600',
      company: 'Kajaria',
      size: '600x600',
      unit: 'box',
      mrp: 65,
      rate: 55,
      incentivePercent: 5,
    ),
    const ProductIncentiveModel(
      id: 'p2',
      name: 'Wall Tile 300x450',
      company: 'Somany',
      size: '300x450',
      unit: 'box',
      mrp: 48,
      rate: 40,
      incentivePercent: 4,
    ),
    const ProductIncentiveModel(
      id: 'p3',
      name: 'PVC Pipe 4"',
      company: 'Supreme',
      size: '4"',
      unit: 'piece',
      mrp: 320,
      rate: 280,
      incentivePercent: 3,
    ),
  ];

  // demo per-product achieved-sales values, keyed by product id
  final Map<String, double> _achievedSales = {
    'p1': 125000,
    'p2': 60000,
    'p3': 210000,
  };

  // ---- Salesman dummy data ----
  final List<SalesmanModel> _salesmen = const [
    SalesmanModel(id: 's1', name: 'Ramesh Kumar'),
    SalesmanModel(id: 's2', name: 'Suresh Patel'),
    SalesmanModel(id: 's3', name: 'Anita Sharma'),
  ];

  // Each salesman gets their own monthly target + bonus setup. Owned here
  // and handed (by reference) to the salesman incentive setup flow so
  // edits/deletes made there are reflected everywhere.
  late final Map<String, SalesmanMonthlyBonus> _monthlyBonusBySalesman = {
    's1': SalesmanMonthlyBonus(
      enabled: true,
      month: DateTime.now().month,
      year: DateTime.now().year,
      target: 300000,
      bonusType: BonusType.percent,
      bonusValue: 2,
    ),
    's2': SalesmanMonthlyBonus(
      enabled: true,
      month: DateTime.now().month,
      year: DateTime.now().year,
      target: 200000,
      bonusType: BonusType.fixed,
      bonusValue: 5000,
    ),
    's3': SalesmanMonthlyBonus(
      enabled: false,
      month: DateTime.now().month,
      year: DateTime.now().year,
    ),
  };

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  String _periodLabelFor(SalesmanMonthlyBonus b) =>
      DateFormat('MMMM yyyy').format(DateTime(b.year, b.month));

  double _achievedFor(ProductIncentiveModel p) => _achievedSales[p.id] ?? 0;

  double _incentiveFor(ProductIncentiveModel p) {
    return _achievedFor(p) * (p.incentivePercent / 100);
  }

  List<ProductIncentiveModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products
        .where((p) =>
    p.name.toLowerCase().contains(q) || p.company.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openAddProduct() async {
    final created = await Navigator.of(context).push<ProductIncentiveModel>(
      MaterialPageRoute(builder: (_) => const OwnerAddIncentiveProductScreen()),
    );
    if (created != null) {
      setState(() {
        _products.add(created);
        // New product starts with no recorded sales yet, so it shows
        // an explicit ₹0 / "no sales yet" state instead of looking blank.
        _achievedSales.putIfAbsent(created.id, () => 0);
      });
    }
  }

  Future<void> _openEditProduct(ProductIncentiveModel product) async {
    final updated = await Navigator.of(context).push<ProductIncentiveModel>(
      MaterialPageRoute(builder: (_) => OwnerAddIncentiveProductScreen(product: product)),
    );
    if (updated != null) {
      setState(() {
        final i = _products.indexWhere((p) => p.id == updated.id);
        if (i != -1) _products[i] = updated;
      });
    }
  }

  Future<void> _confirmDeleteProduct(ProductIncentiveModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Product?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will remove "${product.name}" and its incentive setup. This cannot be undone.',
          style: AppTextStyles.caption(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _products.removeWhere((p) => p.id == product.id);
        _achievedSales.remove(product.id);
      });
    }
  }

  /// "Add Incentive" -> opens the salesman-selection screen. Setting the
  /// actual target/incentive happens on a separate page after that.
  Future<void> _openIncentiveSetupList() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddIncentiveScreen(
          salesmen: _salesmen,
          bonusBySalesman: _monthlyBonusBySalesman,
          currency: _currency,
          periodLabelFor: _periodLabelFor,
        ),
      ),
    );
    // The setup screen mutates the same map instance directly — nothing
    // on this screen currently displays it, but refresh just in case.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final items = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(20)),
          children: [
            SizedBox(height: Responsive.h(14)),

            // Opens the dedicated salesman incentive setup flow.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openIncentiveSetupList,
                icon: const Icon(Icons.add_chart_outlined, color: AppColors.primary),
                label: Text(
                  'Add Incentive',
                  style: AppTextStyles.bodyBold().copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(12)),

            // Replaces the old FloatingActionButton for adding a product.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Product',
                  style: AppTextStyles.bodyBold().copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(20)),

            Text('Product-wise Incentive', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
            SizedBox(height: Responsive.h(10)),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search product or company',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                child: Center(child: Text('No products found', style: AppTextStyles.subtitle())),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _ProductIncentiveCard(
                      product: items[i],
                      achieved: _achievedFor(items[i]),
                      incentiveEarned: _incentiveFor(items[i]),
                      currency: _currency,
                      onEdit: () => _openEditProduct(items[i]),
                      onDelete: () => _confirmDeleteProduct(items[i]),
                    ),
                    if (i != items.length - 1) SizedBox(height: Responsive.h(10)),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductIncentiveCard extends StatelessWidget {
  const _ProductIncentiveCard({
    required this.product,
    required this.achieved,
    required this.incentiveEarned,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductIncentiveModel product;
  final double achieved;
  final double incentiveEarned;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasSales = achieved > 0;
    final hasSizeOrUnit = (product.size != null && product.size!.isNotEmpty) ||
        (product.unit != null && product.unit!.isNotEmpty);

    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(product.name, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${product.incentivePercent}% incentive',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: Responsive.w(4)),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.h(3)),
          Row(
            children: [
              Flexible(
                child: Text(
                  product.company,
                  style: AppTextStyles.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasSizeOrUnit) ...[
                Text('  •  ', style: AppTextStyles.caption()),
                Flexible(
                  child: Text(
                    [
                      if (product.size != null && product.size!.isNotEmpty) product.size,
                      if (product.unit != null && product.unit!.isNotEmpty) product.unit,
                    ].join(' '),
                    style: AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: Responsive.h(6)),
          Row(
            children: [
              Text('MRP ${currency.format(product.mrp)}', style: AppTextStyles.caption()),
              SizedBox(width: Responsive.w(10)),
              Text('Rate ${currency.format(product.rate)}', style: AppTextStyles.caption()),
            ],
          ),
          SizedBox(height: Responsive.h(10)),


            ],
          ),

    );
  }
}