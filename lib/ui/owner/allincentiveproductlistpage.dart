
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/allincentiveproductlist/allincentiveproductlist_bloc.dart';
import '../../bloc/ownerbloc/allincentiveproductlist/allincentiveproductlist_event.dart';
import '../../bloc/ownerbloc/allincentiveproductlist/allincentiveproductlist_state.dart';
import '../../models/salesmanmodels/salesmanowner_incentivemodel.dart';
import 'billpage.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({
    super.key,
    required this.salesmanId,
    required this.salesmanName,
    required this.month,
  });

  final int? salesmanId;
  final String salesmanName;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductListBloc(
        salesmanId: salesmanId,
        year: month.year,
        month: month.month,
        perPage: 10, // use 3 while testing pagination
      )..add(const LoadProductList()),
      child: _AllProductsView(
          salesmanId: salesmanId, salesmanName: salesmanName, month: month),
    );
  }
}

class _AllProductsView extends StatefulWidget {
  const _AllProductsView({
    required this.salesmanId,
    required this.salesmanName,
    required this.month,
  });

  final int? salesmanId;
  final String salesmanName;
  final DateTime month;

  @override
  State<_AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<_AllProductsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() => _loadMoreIfNeeded();

  /// Loads the next page only when the user is near the bottom.
  /// The bloc ignores the event if a page is already loading or there is
  /// nothing left to load, so duplicate calls are safe.
  void _loadMoreIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final bloc = context.read<ProductListBloc>();
    final state = bloc.state;

    if (state.status != ProductListStatus.loaded ||
        !state.hasMore ||
        state.loadMoreFailed) {
      return;
    }

    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 100) {
      bloc.add(const LoadMoreProductList());
    }
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<ProductListBloc>();
    bloc.add(const RefreshProductList());
    // Keep the spinner visible until the reload finishes.
    await bloc.stream.firstWhere((s) => s.status != ProductListStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final monthFmt = DateFormat('MMMM yyyy');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('All Products', style: AppTextStyles.h6())),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Responsive.w(16),
                    Responsive.h(10), Responsive.w(16), Responsive.h(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(monthFmt.format(widget.month),
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),
              Expanded(
                // After each page loads, check whether the list is still too
                // short to scroll (e.g. big screen). If so, fetch the next page.
                child: BlocConsumer<ProductListBloc, ProductListState>(
                  listenWhen: (prev, curr) =>
                  prev.status != curr.status &&
                      curr.status == ProductListStatus.loaded,
                  listener: (context, state) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadMoreIfNeeded();
                    });
                  },
                  builder: (context, state) {
                    if ((state.status == ProductListStatus.loading ||
                        state.status == ProductListStatus.initial) &&
                        state.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == ProductListStatus.error &&
                        state.products.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(24)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage ??
                                    'Failed to load products.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption(
                                    color: AppColors.textSecondary),
                              ),
                              SizedBox(height: Responsive.h(8)),
                              TextButton(
                                onPressed: () => context
                                    .read<ProductListBloc>()
                                    .add(const LoadProductList()),
                                child: Text('Try again',
                                    style: AppTextStyles.link()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state.products.isEmpty) {
                      return Center(
                        child: Text(
                          'No product sales for this period.',
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        ),
                      );
                    }

                    final showFooter = state.hasMore;

                    return RefreshIndicator(
                      onRefresh: () => _refresh(context),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(16),
                            vertical: Responsive.h(10)),
                        itemCount: state.products.length + (showFooter ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Responsive.h(10)),
                        itemBuilder: (context, index) {
                          // Footer: spinner or retry button only.
                          // Loading is triggered by scrolling, not by build.
                          if (index >= state.products.length) {
                            return _PaginationFooter(
                              failed: state.loadMoreFailed,
                              onRetry: () => context
                                  .read<ProductListBloc>()
                                  .add(const LoadMoreProductList()),
                            );
                          }

                          final product = state.products[index];
                          return _ProductCard(
                            product: product,
                            currency: currency,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OwnerProductBillsPage(
                                    product: product,
                                    month: widget.month,
                                    salesmanId: widget.salesmanId?.toString(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.failed,
    required this.onRetry,
  });

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (failed) {
      return Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text('Failed to load more. Tap to retry',
              style: AppTextStyles.link()),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
      {required this.product, required this.currency, required this.onTap});

  final IncentiveProductModel product;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.inventory_2_rounded,
                  color: AppColors.primary, size: 20),
            ),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: Responsive.h(2)),
                  Text('Incentive: ${product.incentiveRate}%',
                      style: AppTextStyles.caption(color: AppColors.success)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(product.totalSalesValue),
                      style: AppTextStyles.body(), textAlign: TextAlign.right),
                  SizedBox(height: Responsive.h(2)),
                  Text('${product.totalUnitsInt} Units',
                      style: AppTextStyles.caption(),
                      textAlign: TextAlign.right),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(4)),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      currency.format(product.incentiveEarnedValue),
                      style: AppTextStyles.bodyBold(color: AppColors.success),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}