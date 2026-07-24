
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/model/product_incentive_model.dart';
import '../../../../core/utils/responsive.dart';
import 'add_incentiveproduct.dart';


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

  bool _monthlyIncentiveEnabled = true;
  double? _monthlyTarget;
  double _monthlyBonusPercent = 0;

  // NEW: which month + year this bonus setup applies to.
  // Defaults to the current month/year.
  int _monthlyMonth = DateTime.now().month;
  int _monthlyYear = DateTime.now().year;

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  bool get _hasMonthlyTarget => _monthlyTarget != null && _monthlyTarget! > 0;

  String get _monthlyPeriodLabel =>
      DateFormat('MMMM yyyy').format(DateTime(_monthlyYear, _monthlyMonth));

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

  /// One simple flow: first choice is just "does this month have a bonus?".
  /// - If the owner turns it OFF -> save immediately, no other fields shown.
  /// - If ON -> owner picks the month + year it applies to, can optionally
  ///   add a target, and sets the bonus %.
  Future<void> _editMonthlyTarget() async {
    bool enabled = _monthlyIncentiveEnabled;
    bool useTarget = _hasMonthlyTarget;
    int month = _monthlyMonth;
    int year = _monthlyYear;
    final targetCtrl = TextEditingController(
      text: _hasMonthlyTarget ? _monthlyTarget!.toStringAsFixed(0) : '',
    );
    final bonusCtrl = TextEditingController(
      text: _monthlyBonusPercent == 0 ? '' : _monthlyBonusPercent.toString(),
    );
    final formKey = GlobalKey<FormState>();

    // Years available: a couple back, current, and a couple ahead —
    // covers correcting a past month or planning an upcoming one.
    final currentYear = DateTime.now().year;
    final years = [for (int y = currentYear - 1; y <= currentYear + 2; y++) y];

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Monthly Sales Bonus', style: AppTextStyles.bodyBold()),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: simple yes/no.
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    onChanged: (v) => setDialogState(() => enabled = v),
                    title: Text('Bonus for a month?', style: AppTextStyles.bodyBold()),
                    subtitle: Text(
                      enabled
                          ? 'Yes — choose the month below.'
                          : 'No bonus set up. Nothing else to fill in.',
                      style: AppTextStyles.caption(),
                    ),
                  ),
                  // Step 2: only shown once the owner says "yes".
                  if (enabled) ...[
                    const Divider(height: 20, color: AppColors.border),

                    // NEW: month + year picker
                    Text('Applies to', style: AppTextStyles.caption()),
                    SizedBox(height: Responsive.h(6)),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<int>(
                            value: month,
                            isExpanded: true,
                            decoration: const InputDecoration(hintText: 'Month'),
                            items: [
                              for (int m = 1; m <= 12; m++)
                                DropdownMenuItem(
                                  value: m,
                                  child: Text(DateFormat('MMMM').format(DateTime(0, m))),
                                ),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => month = v);
                            },
                          ),
                        ),
                        SizedBox(width: Responsive.w(10)),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            value: year,
                            isExpanded: true,
                            decoration: const InputDecoration(hintText: 'Year'),
                            items: [
                              for (final y in years)
                                DropdownMenuItem(value: y, child: Text('$y')),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => year = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(14)),

                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: useTarget,
                      onChanged: (v) => setDialogState(() => useTarget = v),
                      title: Text('Set a sales target', style: AppTextStyles.bodyBold()),
                      subtitle: Text(
                        useTarget
                            ? 'Bonus is paid only after crossing the target.'
                            : 'Off: bonus % applies to total monthly sales, no target needed.',
                        style: AppTextStyles.caption(),
                      ),
                    ),
                    if (useTarget) ...[
                      SizedBox(height: Responsive.h(10)),
                      Text('Target Amount (₹)', style: AppTextStyles.caption()),
                      SizedBox(height: Responsive.h(6)),
                      TextFormField(
                        controller: targetCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: 'e.g. 300000'),
                        validator: (v) {
                          if (!enabled || !useTarget) return null;
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.h(14)),
                    ],
                    Text(
                      useTarget ? 'Bonus if Target Reached (%)' : 'Bonus on Total Sales (%)',
                      style: AppTextStyles.caption(),
                    ),
                    SizedBox(height: Responsive.h(6)),
                    TextFormField(
                      controller: bonusCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'e.g. 2'),
                      validator: (v) {
                        if (!enabled) return null;
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ],
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                // If disabled, skip validation entirely — nothing to check.
                if (enabled && !formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _monthlyIncentiveEnabled = enabled;
        if (!enabled) {
          // Keep it simple: turning off clears the target so a stale
          // target doesn't silently reappear next time it's turned on.
          _monthlyTarget = null;
        } else {
          _monthlyMonth = month;
          _monthlyYear = year;
          _monthlyTarget = useTarget ? double.parse(targetCtrl.text.trim()) : null;
          _monthlyBonusPercent = double.parse(bonusCtrl.text.trim());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final items = _filtered;

    final totalProductIncentive = _products.fold<double>(0, (s, p) => s + _incentiveFor(p));
    final totalAchievedSales = _products.fold<double>(0, (s, p) => s + _achievedFor(p));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddProduct,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(20)),
          children: [
            SizedBox(height: Responsive.h(14)),
            _MonthlySalesCard(
              enabled: _monthlyIncentiveEnabled,
              hasTarget: _hasMonthlyTarget,
              target: _monthlyTarget,
              bonusPercent: _monthlyBonusPercent,
              periodLabel: _monthlyPeriodLabel,
              currency: _currency,
              onEdit: _editMonthlyTarget,
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


class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(13)),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: Responsive.sp(10.5))),
      ],
    );
  }
}

class _MonthlySalesCard extends StatelessWidget {
  const _MonthlySalesCard({
    required this.enabled,
    required this.hasTarget,
    required this.target,
    required this.bonusPercent,
    required this.periodLabel,
    required this.currency,
    required this.onEdit,
  });

  final bool enabled;
  final bool hasTarget;
  final double? target;
  final double bonusPercent;
  final String periodLabel;
  final NumberFormat currency;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return _EmptyMonthlyBonusCard(onAdd: onEdit);
    }

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
              Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 18, color: Colors.black),
                  SizedBox(width: Responsive.w(6)),
                  Text('Monthly Sales Bonus', style: AppTextStyles.bodyBold()),
                ],
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(4)),

          // NEW: shows exactly which month + year this bonus is for.
          Container(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(4)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.primary),
                SizedBox(width: Responsive.w(4)),
                Text(
                  periodLabel,
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(8)),

          Text(
            hasTarget
                ? 'Applies once, on top of product incentives — only if total sales this period cross the target.'
                : 'No target set — bonus % applies directly to total sales this period.',
            style: AppTextStyles.caption(),
          ),
          SizedBox(height: Responsive.h(12)),
          if (hasTarget) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target: ${currency.format(target)}', style: AppTextStyles.caption()),
              ],
            ),
            SizedBox(height: Responsive.h(8)),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Bonus rate: $bonusPercent%', style: AppTextStyles.caption()),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
        ],
      ),
    );
  }
}

/// Shown when the owner has not set up a bonus.
/// Deliberately minimal — one line + one button, no fields, no confusion.
class _EmptyMonthlyBonusCard extends StatelessWidget {
  const _EmptyMonthlyBonusCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.textSecondary),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No incentive set up', style: AppTextStyles.bodyBold()),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Turn it on and pick the month + year you want to give a bonus for.',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(10)),
            ),
            onPressed: onAdd,
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
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
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasSales ? 'Achieved: ${currency.format(achieved)}' : 'No sales yet',
                style: AppTextStyles.caption(),
              ),
              Text(
                'Incentive: ${currency.format(incentiveEarned)}',
                style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}