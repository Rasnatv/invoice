
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/ownerincentiveprovider.dart';
import '../../../models/salesmanmodels/salesmanowner_incentivemodel.dart';
import 'allincentiveproductlist_event.dart';
import 'allincentiveproductlist_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final OwnerIncentiveProvider _provider;

  /// Owner-only. Leave null when a salesman is viewing their own product
  /// list — matches the same owner/salesman toggle used everywhere else
  /// in the incentive flow.
  final int? salesmanId;
  final int year;
  final int month;

  ProductListBloc({
    OwnerIncentiveProvider? provider,
    required this.salesmanId,
    required this.year,
    required this.month,
    int perPage = 10,
  })  : _provider = provider ?? OwnerIncentiveProvider(),
        super(ProductListState.initial(perPage: perPage)) {
    on<LoadProductList>(_onLoad);
    on<RefreshProductList>(_onRefresh);
    on<LoadMoreProductList>(_onLoadMore);
  }

  Future<void> _fetchPage(
      Emitter<ProductListState> emit,
      int page, {
        required bool append,
      }) async {
    final request = IncentiveProductsRequest(
      salesmanId: salesmanId,
      year: year,
      month: month,
      page: page,
      perPage: state.perPage,
    );

    final result = await _provider.getProducts(request);

    // A refresh started while this "load more" was in flight -> drop it.
    if (append && state.status != ProductListStatus.loadingMore) return;

    if (result.success) {
      final updated =
      append ? [...state.products, ...result.products] : result.products;

      // FIX: trust `total` when the API sends it. Only guess from a full
      // page when `total` is missing (0). An empty page always means "no more".
      final hasMore = result.products.isNotEmpty &&
          (result.total > 0
              ? updated.length < result.total
              : result.products.length >= state.perPage);

      emit(state.copyWith(
        status: ProductListStatus.loaded,
        products: updated,
        total: result.total,
        page: page,
        hasMore: hasMore,
        loadMoreFailed: false,
        clearErrorMessage: true,
      ));
    } else {
      final message = result.errorMessage ?? 'Failed to load products.';

      if (state.products.isEmpty) {
        // Nothing to show -> full-screen error.
        emit(state.copyWith(
          status: ProductListStatus.error,
          errorMessage: message,
        ));
      } else {
        // Keep the existing list; footer shows a Retry button.
        emit(state.copyWith(
          status: ProductListStatus.loaded,
          loadMoreFailed: append,
          errorMessage: message,
        ));
      }
    }
  }

  Future<void> _onLoad(
      LoadProductList event, Emitter<ProductListState> emit) async {
    emit(state.copyWith(
      status: ProductListStatus.loading,
      loadMoreFailed: false,
      clearErrorMessage: true,
    ));
    await _fetchPage(emit, 1, append: false);
  }

  Future<void> _onRefresh(
      RefreshProductList event, Emitter<ProductListState> emit) async {
    emit(state.copyWith(
      status: ProductListStatus.loading,
      loadMoreFailed: false,
      clearErrorMessage: true,
    ));
    await _fetchPage(emit, 1, append: false);
  }

  Future<void> _onLoadMore(
      LoadMoreProductList event, Emitter<ProductListState> emit) async {
    // Only when idle on a loaded list that still has pages.
    if (state.status != ProductListStatus.loaded || !state.hasMore) return;

    emit(state.copyWith(
      status: ProductListStatus.loadingMore,
      loadMoreFailed: false,
    ));
    await _fetchPage(emit, state.page + 1, append: true);
  }
}