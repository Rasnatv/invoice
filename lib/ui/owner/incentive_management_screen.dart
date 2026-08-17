
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/owner/salesmanincentivesetup.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../models/owner_models/getproductmodel.dart';
import 'add_incentiveproduct.dart';
import 'company_addscreen.dart';
import 'owner_unitaddscreen.dart';

/// How the monthly bonus is paid out once a salesman crosses their target.
enum BonusType { fixed, percent }

/// Simple dummy salesman record. Swap this out for your real dummymodel/API
/// once you wire this screen up to actual salesman data.
class SalesmanModel {
  const SalesmanModel({required this.id, required this.name});
  final String id;
  final String name;
}

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

class IncentiveManagementScreen extends StatefulWidget {
  const IncentiveManagementScreen({super.key});

  @override
  State<IncentiveManagementScreen> createState() => _IncentiveManagementScreenState();
}

class _IncentiveManagementScreenState extends State<IncentiveManagementScreen> {
  final _searchCtrl = TextEditingController();

  // Owns the bloc for this screen so the list survives navigating to
  // company/unit setup and back, and so we can trigger a refresh after
  // returning from add/edit without re-parsing a popped result.
  late final ProductBloc _productBloc;

  // ---- Salesman dummy data (unrelated to the product API; left as-is) ----
  final List<SalesmanModel> _salesmen = const [
    SalesmanModel(id: 's1', name: 'Ramesh Kumar'),
    SalesmanModel(id: 's2', name: 'Suresh Patel'),
    SalesmanModel(id: 's3', name: 'Anita Sharma'),
  ];

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

  @override
  void initState() {
    super.initState();
    _productBloc = ProductBloc()..add(const LoadProducts());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _productBloc.close();
    super.dispose();
  }

  List<ProductModel> _filtered(List<ProductModel> products) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where((p) =>
    p.name.toLowerCase().contains(q) || p.company.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openAddProduct() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddIncentiveProductScreen()),
    );
    if (saved == true) _productBloc.add(const LoadProducts());
  }

  Future<void> _openEditProduct(ProductModel product) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddIncentiveProductScreen(product: product)),
    );
    if (saved == true) _productBloc.add(const LoadProducts());
  }

  Future<void> _confirmDeleteProduct(ProductModel product) async {
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
      _productBloc.add(DeleteProduct(product.id));
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocProvider.value(
      value: _productBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
        body: SafeArea(
          child: BlocConsumer<ProductBloc, ProductState>(
            listenWhen: (previous, current) =>
            previous.status != current.status || previous.errorMessage != current.errorMessage,
            listener: (context, state) {
              if (state.status == ProductStatus.actionSuccess && state.actionMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.actionMessage!)),
                );
              } else if (state.status == ProductStatus.error && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              final loading = state.status == ProductStatus.loading;
              final items = _filtered(state.products);

              return RefreshIndicator(
                onRefresh: () async => _productBloc.add(const LoadProducts()),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(20)),
                  children: [
                    SizedBox(height: Responsive.h(14)),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openIncentiveSetupList,
                        icon: const Icon(Icons.add_chart_outlined, color: AppColors.primary),
                        label: Text(
                          'Add Monthly Target',
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
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UnitSetupScreen()),
                        ),
                        icon: const Icon(Icons.inventory_outlined, color: AppColors.primary),
                        label: Text(
                          'Unit Set Up',
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
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CompanySetupScreen()),
                        ),
                        icon: const Icon(Icons.business, color: AppColors.primary),
                        label: Text(
                          '+ Add Company',
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

                    Text('Products',
                        style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(15))),
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

                    if (loading && state.products.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(40)),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (state.status == ProductStatus.error && state.products.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                        child: Column(
                          children: [
                            Text(
                              state.errorMessage ?? 'Failed to load products.',
                              style: AppTextStyles.subtitle(),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: Responsive.h(10)),
                            OutlinedButton(
                              onPressed: () => _productBloc.add(const LoadProducts()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (items.isEmpty)
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductIncentiveCard extends StatelessWidget {
  const _ProductIncentiveCard({
    required this.product,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                child: Text(product.name,
                    style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${product.incentivePercentage.toStringAsFixed(product.incentivePercentage % 1 == 0 ? 0 : 2)}% incentive',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              if (!product.isActive) ...[
                SizedBox(width: Responsive.w(6)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
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
              if (product.size.isNotEmpty) ...[
                Text('  •  ', style: AppTextStyles.caption()),
                Flexible(
                  child: Text(
                    product.size,
                    style: AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (product.hasBoxPacking) ...[
                Text('  •  ', style: AppTextStyles.caption()),
                Flexible(
                  child: Text(
                    product.packing.isNotEmpty
                        ? product.packing
                        : '${product.piecesPerBox} pcs/box',
                    style: AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else if (product.hasMeasurementQty) ...[
                Text('  •  ', style: AppTextStyles.caption()),
                Flexible(
                  child: Text(
                    product.measurementQty,
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
              SizedBox(width: Responsive.w(10)),
              Text('Incentive ${currency.format(product.incentiveAmount)}',
                  style: AppTextStyles.caption()),
            ],
          ),
          if (product.minQuantity > 0) ...[
            SizedBox(height: Responsive.h(4)),
            Text(
              'Min. Qty: ${product.minQuantity.toStringAsFixed(product.minQuantity % 1 == 0 ? 0 : 2)}',
              style: AppTextStyles.caption(),
            ),
          ],
        ],
      ),
    );
  }
}