//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/model/estimate_model.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../../../models/estimate_model.dart';
// import '../widgets/owner_widgets.dart';
// import 'estimate_detail_screen.dart';
// import 'ownercreateesimatescreen.dart';
// import 'ownerestuimatedetailscreen.dart';
//
// class OwnerEstimatesScreen extends StatefulWidget {
//   const OwnerEstimatesScreen({super.key, this.initialFilter = 'All'});
//   final String initialFilter;
//
//   @override
//   State<OwnerEstimatesScreen> createState() => _OwnerEstimatesScreenState();
// }
//
// class _OwnerEstimatesScreenState extends State<OwnerEstimatesScreen> {
//   late String _filter = widget.initialFilter;
//   final _searchCtrl = TextEditingController();
//
//   static const _filters = ['All', 'Pending', 'Approved', 'Rejected', 'Dispatched'];
//
//   // ---- DUMMY DATA for UI design purposes only ----
//   final List<EstimateModel> _dummyEstimates = [
//     EstimateModel(
//       id: 'EST-1001',
//       contractorName: 'Nasser Contractors',
//       siteAddress: 'Plot 14, Industrial Area, Kanhangad',
//       phone: '9944556677',
//       salesmanName: 'Ravi Kumar',
//       salesmanMobile: '9876543210',
//       date: DateTime.now().subtract(const Duration(days: 1)),
//       handlingCharge: 500,
//       billType: EstimateBillType.quotation,
//       status: 'Pending',
//       items: [
//         EstimateItem(id: 'I1', name: 'Vitrified Tile 600x600', company: 'Kajaria', size: '600x600', unit: 'box', quantity: 40, mrp: 950, rate: 850),
//         EstimateItem(id: 'I2', name: 'Wall Tile 300x450', company: 'Somany', size: '300x450', unit: 'box', quantity: 20, mrp: 620, rate: 560),
//       ],
//     ),
//     EstimateModel(
//       id: 'EST-1002',
//       contractorName: 'Balaji Builders',
//       siteAddress: 'MG Road, Kasaragod',
//       phone: '9988776655',
//       salesmanName: 'Anitha S',
//       salesmanMobile: '9123456780',
//       date: DateTime.now().subtract(const Duration(days: 3)),
//       handlingCharge: 1200,
//       billType: EstimateBillType.billed,
//       status: 'Approved',
//       items: [
//         EstimateItem(id: 'I3', name: 'Vitrified Tile 800x800', company: 'Nitco', size: '800x800', unit: 'box', quantity: 60, mrp: 1450, rate: 1320),
//         EstimateItem(id: 'I4', name: 'Anti-skid Tile 300x300', company: 'Orientbell', size: '300x300', unit: 'box', quantity: 35, mrp: 480, rate: 430),
//       ],
//       approvedBy: 'Nitheesh',
//       approvedAt: DateTime.now().subtract(const Duration(days: 2)),
//     ),
//     EstimateModel(
//       id: 'EST-1003',
//       contractorName: 'Sri Vinayaga Constructions',
//       siteAddress: 'Bekal Road, Kanhangad',
//       phone: '9090909090',
//       salesmanName: 'Manoj P',
//       salesmanMobile: '9012345678',
//       date: DateTime.now().subtract(const Duration(days: 5)),
//       handlingCharge: 800,
//       billType: EstimateBillType.quotation,
//       status: 'Rejected',
//       items: [
//         EstimateItem(id: 'I5', name: 'Marble Finish Tile 600x1200', company: 'RAK', size: '600x1200', unit: 'box', quantity: 25, mrp: 1800, rate: 1650),
//       ],
//       rejectionReason: 'Rate mismatch with current price list',
//     ),
//     EstimateModel(
//       id: 'EST-1004',
//       contractorName: 'Modern Interiors',
//       siteAddress: 'Hosdurg, Kasaragod',
//       phone: '9876123450',
//       salesmanName: 'Deepa R',
//       salesmanMobile: '9345612780',
//       date: DateTime.now().subtract(const Duration(days: 7)),
//       handlingCharge: 1500,
//       billType: EstimateBillType.billed,
//       status: 'Dispatched',
//       items: [
//         EstimateItem(id: 'I6', name: 'Vitrified Tile 600x600', company: 'Kajaria', size: '600x600', unit: 'box', quantity: 90, mrp: 950, rate: 870),
//         EstimateItem(id: 'I7', name: 'Wall Tile 250x375', company: 'Johnson', size: '250x375', unit: 'box', quantity: 55, mrp: 540, rate: 495),
//         EstimateItem(id: 'I8', name: 'Border Tile', company: 'Somany', size: '100x300', unit: 'piece', quantity: 200, mrp: 45, rate: 38),
//       ],
//       approvedBy: 'Nitheesh',
//       approvedAt: DateTime.now().subtract(const Duration(days: 6)),
//     ),
//   ];
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   List<EstimateModel> _apply(List<EstimateModel> all) {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     return all.where((e) {
//       final matchesFilter = _filter == 'All' || e.status == _filter;
//       final matchesSearch = q.isEmpty ||
//           e.salesmanName.toLowerCase().contains(q) ||
//           e.contractorName.toLowerCase().contains(q) ||
//           e.phone.contains(q) ||
//           e.salesmanMobile.contains(q) ||
//           e.id.toLowerCase().contains(q);
//       return matchesFilter && matchesSearch;
//     }).toList();
//   }
//
//   // Tapping any card — regardless of status, including Approved — opens
//   // the estimate details screen. "Send to Despatch" for approved estimates
//   // now lives inside OwnerEstimateDetailsScreen's action bar instead of
//   // popping straight to a bottom sheet from here.
//   void _onCardTap(EstimateModel estimate) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => OwnerEstimateDetailsScreen(initialStatus: estimate.status),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final items = _apply(_dummyEstimates);
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: Text('Estimates', style: AppTextStyles.h6())),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
//               child: TextField(
//                 controller: _searchCtrl,
//                 onChanged: (_) => setState(() {}),
//                 decoration: const InputDecoration(
//                   hintText: 'Search salesman, contractor or phone',
//                   prefixIcon: Icon(Icons.search_rounded),
//                 ),
//               ),
//             ),
//             SizedBox(height: Responsive.h(12)),
//             SizedBox(
//               height: 42,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
//                 itemCount: _filters.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (context, i) {
//                   final f = _filters[i];
//                   final selected = f == _filter;
//                   return ChoiceChip(
//                     label: Text(f),
//                     selected: selected,
//                     selectedColor: AppColors.primary,
//                     backgroundColor: AppColors.surface,
//                     labelStyle: AppTextStyles.bodyBold(color: selected ? Colors.white : AppColors.textPrimary),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
//                     ),
//                     onSelected: (_) => setState(() => _filter = f),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: Responsive.h(12)),
//             Expanded(
//               child: items.isEmpty
//                   ? Center(
//                 child: Text('No estimates found', style: AppTextStyles.subtitle()),
//               )
//                   : ListView.separated(
//                 padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
//                 itemCount: items.length,
//                 separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
//                 itemBuilder: (context, i) {
//                   final e = items[i];
//                   return _OwnerEstimateCard(
//                     estimate: e,
//                     currency: currency,
//                     onTap: () => _onCardTap(e),
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
// class _OwnerEstimateCard extends StatelessWidget {
//   const _OwnerEstimateCard({required this.estimate, required this.currency, required this.onTap});
//   final EstimateModel estimate;
//   final NumberFormat currency;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final bool hasApproval = estimate.approvedBy != null && estimate.approvedBy!.isNotEmpty;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: EdgeInsets.all(Responsive.w(14)),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(estimate.contractorName, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
//                 ),
//                 StatusBadge(status: estimate.status),
//               ],
//             ),
//             SizedBox(height: Responsive.h(4)),
//             Text('Estimate No: ${estimate.id}', style: AppTextStyles.caption()),
//             SizedBox(height: Responsive.h(4)),
//             Row(
//               children: [
//                 const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
//                 SizedBox(width: Responsive.w(4)),
//                 Expanded(
//                   child: Text(
//                     '${estimate.salesmanName} · ${estimate.salesmanMobile}',
//                     style: AppTextStyles.caption(),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             if (hasApproval) ...[
//               SizedBox(height: Responsive.h(4)),
//               Row(
//                 children: [
//                   const Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
//                   SizedBox(width: Responsive.w(4)),
//                   Expanded(
//                     child: Text(
//                       'Approved by ${estimate.approvedBy}'
//                           '${estimate.approvedAt != null ? ' · ${DateFormat('dd-MM-yyyy').format(estimate.approvedAt!)}' : ''}',
//                       style: AppTextStyles.caption(color: AppColors.primary),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             SizedBox(height: Responsive.h(8)),
//             const Divider(height: 1, color: AppColors.border),
//             SizedBox(height: Responsive.h(8)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(DateFormat('dd-MM-yyyy').format(estimate.date), style: AppTextStyles.caption()),
//                 Text('2500', style: AppTextStyles.bodyBold(color: AppColors.primary)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/estimate_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/estimate_model.dart';
import '../widgets/owner_widgets.dart';
import 'estimate_detail_screen.dart';
import 'ownercreateesimatescreen.dart';
import 'ownerestuimatedetailscreen.dart';
import 'ownerpaymentscreen.dart';

class OwnerEstimatesScreen extends StatefulWidget {
  const OwnerEstimatesScreen({super.key, this.initialFilter = 'All'});
  final String initialFilter;

  @override
  State<OwnerEstimatesScreen> createState() => _OwnerEstimatesScreenState();
}

class _OwnerEstimatesScreenState extends State<OwnerEstimatesScreen> {
  late String _filter = widget.initialFilter;
  final _searchCtrl = TextEditingController();

  static const _filters = ['All', 'Pending', 'Approved', 'Rejected', 'Dispatched'];

  // ---- DUMMY DATA for UI design purposes only ----
  late final List<EstimateModel> _dummyEstimates = [
    EstimateModel(
      id: 'EST-1001',
      contractorName: 'Nasser Contractors',
      siteAddress: 'Plot 14, Industrial Area, Kanhangad',
      phone: '9944556677',
      salesmanName: 'Ravi Kumar',
      salesmanMobile: '9876543210',
      date: DateTime.now().subtract(const Duration(days: 1)),
      handlingCharge: 500,
      billType: EstimateBillType.quotation,
      status: 'Pending',
      items: [
        EstimateItem(id: 'I1', name: 'Vitrified Tile 600x600', company: 'Kajaria', size: '600x600', unit: 'box', quantity: 40, mrp: 950, rate: 850),
        EstimateItem(id: 'I2', name: 'Wall Tile 300x450', company: 'Somany', size: '300x450', unit: 'box', quantity: 20, mrp: 620, rate: 560),
      ],
    ),
    EstimateModel(
      id: 'EST-1002',
      contractorName: 'Balaji Builders',
      siteAddress: 'MG Road, Kasaragod',
      phone: '9988776655',
      salesmanName: 'Anitha S',
      salesmanMobile: '9123456780',
      date: DateTime.now().subtract(const Duration(days: 3)),
      handlingCharge: 1200,
      billType: EstimateBillType.billed,
      status: 'Approved',
      items: [
        EstimateItem(id: 'I3', name: 'Vitrified Tile 800x800', company: 'Nitco', size: '800x800', unit: 'box', quantity: 60, mrp: 1450, rate: 1320),
        EstimateItem(id: 'I4', name: 'Anti-skid Tile 300x300', company: 'Orientbell', size: '300x300', unit: 'box', quantity: 35, mrp: 480, rate: 430),
      ],
      approvedBy: 'Nitheesh',
      approvedAt: DateTime.now().subtract(const Duration(days: 2)),
      // Partly paid — balance will show, Pay Now button will show.
      amountPaid: 30000,
    ),
    EstimateModel(
      id: 'EST-1003',
      contractorName: 'Sri Vinayaga Constructions',
      siteAddress: 'Bekal Road, Kanhangad',
      phone: '9090909090',
      salesmanName: 'Manoj P',
      salesmanMobile: '9012345678',
      date: DateTime.now().subtract(const Duration(days: 5)),
      handlingCharge: 800,
      billType: EstimateBillType.quotation,
      status: 'Rejected',
      items: [
        EstimateItem(id: 'I5', name: 'Marble Finish Tile 600x1200', company: 'RAK', size: '600x1200', unit: 'box', quantity: 25, mrp: 1800, rate: 1650),
      ],
      rejectionReason: 'Rate mismatch with current price list',
    ),
    EstimateModel(
      id: 'EST-1004',
      contractorName: 'Modern Interiors',
      siteAddress: 'Hosdurg, Kasaragod',
      phone: '9876123450',
      salesmanName: 'Deepa R',
      salesmanMobile: '9345612780',
      date: DateTime.now().subtract(const Duration(days: 7)),
      handlingCharge: 1500,
      billType: EstimateBillType.billed,
      status: 'Dispatched',
      items: [
        EstimateItem(id: 'I6', name: 'Vitrified Tile 600x600', company: 'Kajaria', size: '600x600', unit: 'box', quantity: 90, mrp: 950, rate: 870),
        EstimateItem(id: 'I7', name: 'Wall Tile 250x375', company: 'Johnson', size: '250x375', unit: 'box', quantity: 55, mrp: 540, rate: 495),
        EstimateItem(id: 'I8', name: 'Border Tile', company: 'Somany', size: '100x300', unit: 'piece', quantity: 200, mrp: 45, rate: 38),
      ],
      approvedBy: 'Nitheesh',
      approvedAt: DateTime.now().subtract(const Duration(days: 6)),
      // Fully paid already — balance is 0, Pay Now button stays hidden.
      amountPaid: 90 * 870 + 55 * 495 + 200 * 38 + 1500,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EstimateModel> _apply(List<EstimateModel> all) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return all.where((e) {
      final matchesFilter = _filter == 'All' || e.status == _filter;
      final matchesSearch = q.isEmpty ||
          e.salesmanName.toLowerCase().contains(q) ||
          e.contractorName.toLowerCase().contains(q) ||
          e.phone.contains(q) ||
          e.salesmanMobile.contains(q) ||
          e.id.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  // Tapping any card — regardless of status, including Approved — opens
  // the estimate details screen. "Send to Despatch" for approved estimates
  // now lives inside OwnerEstimateDetailsScreen's action bar instead of
  // popping straight to a bottom sheet from here.
  void _onCardTap(EstimateModel estimate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerEstimateDetailsScreen(initialStatus: estimate.status),
      ),
    );
  }

  Future<void> _onPayNow(EstimateModel estimate) async {
    final updated = await Navigator.of(context).push<EstimateModel>(
      MaterialPageRoute(
        builder: (_) => OwnerPaymentScreen(estimate: estimate),
      ),
    );

    // Payment screen returns the estimate with amountPaid increased.
    // Replace it in the list so the card re-renders with the new balance
    // (or hides the Pay Now button entirely once balance hits 0).
    if (updated != null) {
      setState(() {
        final index = _dummyEstimates.indexWhere((e) => e.id == updated.id);
        if (index != -1) _dummyEstimates[index] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final items = _apply(_dummyEstimates);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Estimates', style: AppTextStyles.h6())),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search salesman, contractor or phone',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.bodyBold(color: selected ? Colors.white : AppColors.textPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    onSelected: (_) => setState(() => _filter = f),
                  );
                },
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: items.isEmpty
                  ? Center(
                child: Text('No estimates found', style: AppTextStyles.subtitle()),
              )
                  : ListView.separated(
                padding: EdgeInsets.fromLTRB(Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                itemBuilder: (context, i) {
                  final e = items[i];
                  return _OwnerEstimateCard(
                    estimate: e,
                    currency: currency,
                    onTap: () => _onCardTap(e),
                    onPayNow: () => _onPayNow(e),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerEstimateCard extends StatelessWidget {
  const _OwnerEstimateCard({
    required this.estimate,
    required this.currency,
    required this.onTap,
    required this.onPayNow,
  });
  final EstimateModel estimate;
  final NumberFormat currency;
  final VoidCallback onTap;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    final bool hasApproval = estimate.approvedBy != null && estimate.approvedBy!.isNotEmpty;
    // Show the balance/Pay Now button for any estimate that has moved past
    // approval (Approved or Dispatched), even if approvedBy wasn't set on
    // the record for some reason — status is the more reliable signal.
    final bool isApprovedOrBeyond = estimate.status == 'Approved' || estimate.status == 'Dispatched';
    final double balance = estimate.balance;
    final bool showBalance = isApprovedOrBeyond && balance > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                  child: Text(estimate.contractorName, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                StatusBadge(status: estimate.status),
              ],
            ),
            SizedBox(height: Responsive.h(4)),
            Text('Estimate No: ${estimate.id}', style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(4)),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Expanded(
                  child: Text(
                    '${estimate.salesmanName} · ${estimate.salesmanMobile}',
                    style: AppTextStyles.caption(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (hasApproval) ...[
              SizedBox(height: Responsive.h(4)),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      'Approved by ${estimate.approvedBy}'
                          '${estimate.approvedAt != null ? ' · ${DateFormat('dd-MM-yyyy').format(estimate.approvedAt!)}' : ''}',
                      style: AppTextStyles.caption(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd-MM-yyyy').format(estimate.date), style: AppTextStyles.caption()),
                Text(currency.format(estimate.totalAmount), style: AppTextStyles.bodyBold(color: AppColors.primary)),
              ],
            ),
            if (showBalance) ...[
              SizedBox(height: Responsive.h(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, size: 14, color: Colors.red),
                      SizedBox(width: Responsive.w(4)),
                      Text(
                        'Balance: ${currency.format(balance)}',
                        style: AppTextStyles.bodyBold(color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onPayNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.infoBg,
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Pay Now',
                        style: AppTextStyles.caption(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}