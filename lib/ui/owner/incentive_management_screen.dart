

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/product_enums.dart';
import '../../bloc/ownerbloc/product/product_bloc.dart';
import '../../bloc/ownerbloc/product/product_event.dart';
import '../../bloc/ownerbloc/product/product_state.dart';
import '../../core/utils/delete_helper.dart';
import '../../models/owner_models/getproductmodel.dart';
import '../../widgets/appsnackbar.dart';
import 'add_incentiveproduct.dart';
import 'company_addscreen.dart';
import 'owner_unitaddscreen.dart';

class IncentiveManagementScreen extends StatefulWidget {
  const IncentiveManagementScreen({super.key});

  @override
  State<IncentiveManagementScreen> createState() => _IncentiveManagementScreenState();
}

class _IncentiveManagementScreenState extends State<IncentiveManagementScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late final ProductBloc _productBloc;

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _productBloc = ProductBloc()..add(const LoadProducts());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _productBloc.close();
    super.dispose();
  }

  /// Requests the next page once the user is within ~200px of the bottom.
  /// The bloc itself guards against duplicate/overlapping requests and
  /// against calling past the last page, so it's safe to call this on
  /// every scroll tick.
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final threshold = _scrollCtrl.position.maxScrollExtent - 200;
    if (_scrollCtrl.position.pixels >= threshold) {
      _productBloc.add(const LoadMoreProducts());
    }
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
    if (_isNavigating) return;
    _isNavigating = true;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddIncentiveProductScreen()),
    );
    _isNavigating = false;
    if (saved == true) _productBloc.add(const LoadProducts());
  }

  Future<void> _openEditProduct(ProductModel product) async {
    if (_isNavigating) return;
    _isNavigating = true;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddIncentiveProductScreen(product: product)),
    );
    _isNavigating = false;
    if (saved == true) _productBloc.add(const LoadProducts());
  }

  Future<void> _confirmDeleteProduct(ProductModel product) async {
    if (_isNavigating) return;
    _isNavigating = true;
    await deleteItem(
      context,
      itemName: product.name,
      onConfirmed: () async {
        _productBloc.add(DeleteProduct(product.id));
      },
    );
    _isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocProvider.value(
        value: _productBloc,
        child: NetworkAwareWrapper(child:Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text('Incentive Setup', style: AppTextStyles.h6())),
          body: SafeArea(
            child: BlocConsumer<ProductBloc, ProductState>(
              listenWhen: (previous, current) =>
              previous.status != current.status || previous.errorMessage != current.errorMessage,
              listener: (context, state) {
                if (state.status == ProductStatus.actionSuccess && state.actionMessage != null) {
                  AppSnackbar.success(state.actionMessage!);
                } else if (state.status == ProductStatus.error && state.errorMessage != null) {
                  AppSnackbar.error(state.errorMessage!);
                }
              },
              builder: (context, state) {
                final loading = state.status == ProductStatus.loading;
                final items = _filtered(state.products);
                final searching = _searchCtrl.text.trim().isNotEmpty;

                return RefreshIndicator(
                  onRefresh: () async => _productBloc.add(const LoadProducts()),
                  child: ListView(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.fromLTRB(
                        Responsive.w(16), Responsive.h(14), Responsive.w(16), Responsive.h(20)),
                    children: [
                      SizedBox(height: Responsive.h(14)),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (_isNavigating) return;
                            _isNavigating = true;
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const UnitSetupScreen()))
                                .then((_) => _isNavigating = false);
                          },
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
                          onPressed: () {
                            if (_isNavigating) return;
                            _isNavigating = true;
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const CompanySetupScreen()))
                                .then((_) => _isNavigating = false);
                          },
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
                        Column(children: [
                          SizedBox(height: 150,),
                        Icon(Icons.inventory_outlined, size: 40, color: AppColors.textSecondary.withOpacity(0.4)),
                         SizedBox(height: Responsive.h(10)),
                      Center(child: Text('No products found', style: AppTextStyles.subtitle())),
                          ])
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

                      if (!searching && state.isLoadingMore)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        ));
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

  String _pct(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  @override
  Widget build(BuildContext context) {
    final hasIncentive = product.incentiveType != ProductIncentiveType.none;

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
          // Name (full, wraps) + menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: AppTextStyles.bodyBold(),
                  softWrap: true,
                ),
              ),
              SizedBox(width: Responsive.w(4)),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                onSelected: (value) {
                  // Deferred so the popup's route finishes closing first
                  // (avoids the 'manifest.fromHero' assertion).
                  Future.delayed(Duration.zero, () {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  });
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

          // Badges (below the name so they never squeeze it)
          if (hasIncentive || !product.isActive) ...[
            SizedBox(height: Responsive.h(4)),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (hasIncentive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.incentiveType == ProductIncentiveType.percentage
                          ? '${_pct(product.incentivePercentage)}% incentive'
                          : '${currency.format(product.incentiveAmount)} incentive',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (!product.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Inactive',
                      style: TextStyle(
                          color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: Responsive.h(4)),

          // Company • size • packing (wraps instead of truncating)
          Text(
            [
              product.company,
              if (product.size.isNotEmpty) product.size,
              if (product.packing.isNotEmpty)
                product.packing
              else if (product.hasBoxPacking && product.piecesPerBox.isNotEmpty)
                '${product.piecesPerBox} pcs/box'
              else if (product.hasMeasurementQty)
                  product.measurementQty,
            ].where((s) => s.isNotEmpty).join('  •  '),
            style: AppTextStyles.caption(),
            softWrap: true,
          ),

          SizedBox(height: Responsive.h(6)),

          // MRP / Rate / Incentive (wraps on narrow screens)
          Wrap(
            spacing: Responsive.w(10),
            runSpacing: 2,
            children: [
              Text('MRP ${currency.format(product.mrp)}', style: AppTextStyles.caption()),
              Text('Rate ${currency.format(product.rate)}', style: AppTextStyles.caption()),
              if (hasIncentive)
                Text(
                  product.incentiveType == ProductIncentiveType.percentage
                      ? 'Incentive ${_pct(product.incentivePercentage)}%'
                      : 'Incentive ${currency.format(product.incentiveAmount)}',
                  style: AppTextStyles.caption(),
                ),
            ],
          ),

          if (product.minQuantity > 0) ...[
            SizedBox(height: Responsive.h(4)),
            Text(
              'Min. Qty: ${_pct(product.minQuantity)}',
              style: AppTextStyles.caption(),
            ),
          ],
        ],
      ),
    );
  }
}