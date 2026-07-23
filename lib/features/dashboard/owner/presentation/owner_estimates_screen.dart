
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
import 'ownerdespatchsheet.dart';
import 'ownerestuimatedetailscreen.dart';

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

  // Dummy list of salesmen the owner can choose from when sending an
  // approved estimate to despatch. "Assigned to Me" opens the owner's own
  // despatch sheet instead of just notifying a salesman.
  static const List<String> _dummySalesmen = [
    'Assigned to Me',
    'Anoop Menon',
    'Ravi Kumar',
    'Sunitha Nair',
    'Vishnu Prasad',
  ];

  // ---- DUMMY DATA for UI design purposes only ----
  final List<EstimateModel> _dummyEstimates = [
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

  // Tapping a card:
  // - Approved  -> jump straight to the "send to despatch" bottom sheet.
  // - Anything else -> open the normal details screen.
  void _onCardTap(EstimateModel estimate) {
    if (estimate.status == 'Approved') {
      _showSendToDespatchSheet(estimate);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OwnerEstimateDetailsScreen(),
        ),
      );
    }
  }

  // Bottom sheet listing salesmen to despatch an approved estimate to.
  // "Assigned to Me" hands off to the owner's own despatch sheet
  // (OwnerDespatchSheetScreen). Picking a real salesman just records the
  // intent for now.
  // TODO(despatch-flow): wire the "notify salesman" branch to a real
  // despatch/notification API, and persist the resulting DespatchInfo
  // against `estimate` once the despatch module has its own model/cubit.
  Future<void> _showSendToDespatchSheet(EstimateModel estimate) async {
    final currentSelection = estimate.salesmanName;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: Responsive.h(10)),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: Responsive.h(16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(18)),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                      SizedBox(width: Responsive.w(8)),
                      Text('Send to Despatch Sheet', style: AppTextStyles.h3()),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.h(4)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(18)),
                  child: Text(
                    'Choose who should handle despatch for ${estimate.id}',
                    style: AppTextStyles.caption(),
                  ),
                ),
                SizedBox(height: Responsive.h(10)),
                const Divider(height: 1),
                ..._dummySalesmen.map((name) {
                  final isMe = name == 'Assigned to Me';
                  final isCurrent = name == currentSelection;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe
                          ? AppColors.primary.withOpacity(0.12)
                          : AppColors.surfaceAlt,
                      child: Icon(
                        isMe ? Icons.person_pin_circle_outlined : Icons.person_outline,
                        color: isMe ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(name, style: AppTextStyles.bodyBold()),
                    subtitle: isMe ? const Text('Opens your own despatch sheet') : null,
                    trailing: isCurrent
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(sheetContext).pop(name),
                  );
                }),
                SizedBox(height: Responsive.h(10)),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;

    if (result == 'Assigned to Me') {
      await _openOwnerDespatchSheet(estimate);
      return;
    }

    // TODO(despatch-flow): persist `DespatchInfo(assignedSalesman: result, ...)`
    // against this estimate once despatch state is wired to a real cubit.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent to $result for despatch')),
      );
    }
  }

  // Pushes the owner's own despatch sheet screen, pre-filled with this
  // estimate's data.
  Future<void> _openOwnerDespatchSheet(EstimateModel estimate) async {
    final result = await Navigator.of(context).push<DespatchInfo>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(
          quotationId: estimate.id,
          contractorName: estimate.contractorName,
          phone: estimate.phone,
          siteAddress: estimate.siteAddress,
          items: estimate.items
              .map((i) => OwnerDespatchItem(
            name: i.name,
            company: i.company,
            size: i.size,
            quantity: i.quantity,
            unit: i.unit,
          ))
              .toList(),
        ),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Despatch sheet completed')),
      );
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
  const _OwnerEstimateCard({required this.estimate, required this.currency, required this.onTap});
  final EstimateModel estimate;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasApproval = estimate.approvedBy != null && estimate.approvedBy!.isNotEmpty;

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
                Text('2500', style: AppTextStyles.bodyBold(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}