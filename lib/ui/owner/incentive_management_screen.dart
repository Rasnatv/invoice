
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
import '../../widgets/owner_estimateshimmer.dart';
import 'add_incentiveproduct.dart';
import 'company_addscreen.dart';
import 'owner_unitaddscreen.dart';

class IncentiveManagementScreen extends StatefulWidget {
  const IncentiveManagementScreen({super.key});

  @override
  State<IncentiveManagementScreen> createState() =>
      _IncentiveManagementScreenState();
}

class _IncentiveManagementScreenState extends State<IncentiveManagementScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late final ProductBloc _productBloc;

  // Whole numbers show as ₹450, decimals show as ₹22.50
  final _currencyWhole =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _currencyDecimal =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  String _money(double v) => v == v.truncateToDouble()
      ? _currencyWhole.format(v)
      : _currencyDecimal.format(v);

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

  void _refresh() => _productBloc.add(const LoadProducts());

  /// Requests the next page once the user is within ~200px of the bottom.
  /// The bloc guards against duplicate requests and calls past the last
  /// page, so it is safe to call this on every scroll tick.
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
    p.name.toLowerCase().contains(q) ||
        p.company.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openAddProduct() async {
    if (_isNavigating) return;
    _isNavigating = true;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddIncentiveProductScreen()),
    );
    _isNavigating = false;
    if (saved == true) _refresh();
  }

  Future<void> _openEditProduct(ProductModel product) async {
    if (_isNavigating) return;
    _isNavigating = true;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => AddIncentiveProductScreen(product: product)),
    );
    _isNavigating = false;
    if (saved == true) _refresh();
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

  Future<void> _openUnitSetup() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const UnitSetupScreen()));
    _isNavigating = false;
  }

  Future<void> _openBrandSetup() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CompanySetupScreen()));
    _isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocProvider.value(
      value: _productBloc,
      child: NetworkAwareWrapper(
        child: Scaffold(
          backgroundColor: AppColors.background,

          // ---------- APPBAR (same as Estimates) ----------
          appBar: AppBar(
            title: Text('Products', style: AppTextStyles.h6()),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: Responsive.w(12)),
                child: TextButton.icon(
                  onPressed: _openAddProduct,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Add Product',
                    style: AppTextStyles.bodyBold(color: AppColors.primary),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding:
                    EdgeInsets.symmetric(horizontal: Responsive.w(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),

          body: SafeArea(
            child: BlocConsumer<ProductBloc, ProductState>(
              listenWhen: (previous, current) =>
              previous.status != current.status ||
                  previous.errorMessage != current.errorMessage,
              listener: (context, state) {
                if (state.status == ProductStatus.actionSuccess &&
                    state.actionMessage != null) {
                  AppSnackbar.success(state.actionMessage!);
                } else if (state.status == ProductStatus.error &&
                    state.errorMessage != null) {
                  AppSnackbar.error(state.errorMessage!);
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Responsive.w(20),
                          Responsive.h(14), Responsive.w(20), 0),
                      child: _SearchField(
                        controller: _searchCtrl,
                        hint: 'Search product or company',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(height: Responsive.h(12)),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionChip(
                              icon: Icons.inventory_outlined,
                              label: 'Unit Set Up',
                              onTap: _openUnitSetup,
                            ),
                          ),
                          SizedBox(width: Responsive.w(10)),
                          Expanded(
                            child: _ActionChip(
                              icon: Icons.business_outlined,
                              label: 'Add Brand',
                              onTap: _openBrandSetup,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(12)),
                    Expanded(child: _buildBody(context, state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductState state) {
    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));

    final loading = state.status == ProductStatus.loading;
    final items = _filtered(state.products);
    final searching = _searchCtrl.text.trim().isNotEmpty;

    // ---- loading skeleton ----
    if (loading && state.products.isEmpty) {
      return ShimmerListPlaceholder(
        itemCount: 6,
        padding: listPadding,
        separatorHeight: Responsive.h(10),
        itemBuilder: (context, i) => const _ProductCardSkeleton(),
      );
    }

    // ---- error ----
    if (state.status == ProductStatus.error && state.products.isEmpty) {
      return _ErrorView(
        message: state.errorMessage ?? 'Failed to load products.',
        onRetry: _refresh,
      );
    }

    // ---- empty ----
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 44,
                      color: AppColors.textSecondary.withOpacity(0.4),
                    ),
                    SizedBox(height: Responsive.h(10)),
                    Text('No products found', style: AppTextStyles.subtitle()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ---- list ----
    final showLoader = !searching && state.isLoadingMore;

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: listPadding,
        itemCount: items.length + (showLoader ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, i) {
          if (i >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final p = items[i];
          return _ProductIncentiveCard(
            key: ValueKey(p.id),
            product: p,
            money: _money,
            onEdit: () => _openEditProduct(p),
            onDelete: () => _confirmDeleteProduct(p),
          );
        },
      ),
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        prefixIcon: Icon(Icons.search_rounded,
            size: 20, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(13)),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(11)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              SizedBox(width: Responsive.w(6)),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: Responsive.sp(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =====================================================================
// ERROR / SKELETON
// =====================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: Responsive.w(12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 100, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PRODUCT CARD
// =====================================================================

class _ProductIncentiveCard extends StatelessWidget {
  const _ProductIncentiveCard({
    super.key,
    required this.product,
    required this.money,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;

  /// Formats a rupee amount: no decimals for whole numbers, 2 for others.
  final String Function(double) money;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Percentage: 5 -> "5", 2.5 -> "2.50"
  String _pct(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  /// Quantity: 5 -> "5", 2.5 -> "2.5"
  String _qty(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  String get _subtitle => [
    product.company,
    if (product.size.isNotEmpty) product.size,
    if (product.packing.isNotEmpty)
      product.packing
    else if (product.hasBoxPacking && product.piecesPerBox.isNotEmpty)
      '${product.piecesPerBox} pcs/box'
    else if (product.hasMeasurementQty)
        product.measurementQty,
  ].where((s) => s.isNotEmpty).join('  •  ');

  @override
  Widget build(BuildContext context) {
    final hasIncentive = product.incentiveType != ProductIncentiveType.none;

    return _ListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: icon, name + company/size, menu ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.inventory_2_outlined),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyBold(),
                      softWrap: true,
                    ),
                    if (_subtitle.isNotEmpty) ...[
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        _subtitle,
                        style: AppTextStyles.caption(
                            color: AppColors.textSecondary),
                        softWrap: true,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(4)),
              SizedBox(
                width: 30,
                height: 30,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert,
                      size: 20, color: AppColors.textSecondary),
                  onSelected: (value) {
                    // Deferred so the popup's route finishes closing first
                    // (avoids the 'manifest.fromHero' assertion).
                    Future.delayed(Duration.zero, () {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text('Edit', style: AppTextStyles.body()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Delete',
                              style:
                              AppTextStyles.body(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ---- badges ----
          if (hasIncentive || !product.isActive) ...[
            SizedBox(height: Responsive.h(10)),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (hasIncentive)
                  _StatusPill(
                    label: product.incentiveType ==
                        ProductIncentiveType.percentage
                        ? '${_pct(product.incentivePercentage)}% incentive'
                        : '${money(product.incentiveAmount)} incentive',
                    color: AppColors.primary,
                  ),
                if (!product.isActive)
                  const _StatusPill(
                    label: 'Inactive',
                    color: AppColors.error,
                  ),
              ],
            ),
          ],

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: MRP, min qty, rate ----
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: Responsive.w(10),
                  runSpacing: 2,
                  children: [
                    Text(
                      'MRP ${money(product.mrp)}',
                      style:
                      AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                    if (product.minQuantity > 0)
                      Text(
                        'Min. Qty: ${_qty(product.minQuantity)}',
                        style: AppTextStyles.caption(
                            color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              Text(
                'Rate ${money(product.rate)}',
                style: AppTextStyles.amount(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}