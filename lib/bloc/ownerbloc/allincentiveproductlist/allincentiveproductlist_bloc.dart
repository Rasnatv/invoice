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
  })  : _provider = provider ?? OwnerIncentiveProvider(),
        super(ProductListState.initial()) {
    on<LoadProductList>(_onLoad);
    on<RefreshProductList>(_onRefresh);
    on<LoadMoreProductList>(_onLoadMore);
  }

  Future<void> _fetchPage(Emitter<ProductListState> emit, int page, {required bool append}) async {
    final request = IncentiveProductsRequest(
      salesmanId: salesmanId,
      year: year,
      month: month,
      page: page,
      perPage: state.perPage,
    );

    final result = await _provider.getProducts(request);

    if (result.success) {
      final updated = append ? [...state.products, ...result.products] : result.products;
      emit(state.copyWith(
        status: ProductListStatus.loaded,
        products: updated,
        total: result.total,
        page: page,
        clearErrorMessage: true,
      ));
    } else {
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: result.errorMessage ?? 'Failed to load products.',
      ));
    }
  }

  Future<void> _onLoad(LoadProductList event, Emitter<ProductListState> emit) async {
    emit(state.copyWith(status: ProductListStatus.loading, clearErrorMessage: true));
    await _fetchPage(emit, 1, append: false);
  }

  Future<void> _onRefresh(RefreshProductList event, Emitter<ProductListState> emit) async {
    emit(state.copyWith(status: ProductListStatus.loading, clearErrorMessage: true));
    await _fetchPage(emit, 1, append: false);
  }

  Future<void> _onLoadMore(LoadMoreProductList event, Emitter<ProductListState> emit) async {
    if (state.status == ProductListStatus.loadingMore || !state.hasMore) return;
    emit(state.copyWith(status: ProductListStatus.loadingMore));
    await _fetchPage(emit, state.page + 1, append: true);
  }
}