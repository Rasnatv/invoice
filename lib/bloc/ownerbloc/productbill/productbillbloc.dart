import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/ownerbloc/productbill/productbillevent.dart';
import 'package:tileshop/bloc/ownerbloc/productbill/productbillstate.dart';

import '../../../Apiprovider/ownerincentiveprovider.dart';

import '../../../models/salesmanmodels/salesmanowner_incentivemodel.dart';


class ProductBillsBloc extends Bloc<ProductBillsEvent, ProductBillsState> {
  final OwnerIncentiveProvider _provider;
  final int? salesmanId; // owner-only
  final int productId;
  final int year;
  final int month;
  final int perPage;

  ProductBillsBloc({
    OwnerIncentiveProvider? provider,
    this.salesmanId,
    required this.productId,
    required this.year,
    required this.month,
    this.perPage = 10,
  })  : _provider = provider ?? OwnerIncentiveProvider(),
        super(ProductBillsState.initial()) {
    on<LoadProductBills>(_onLoad);
    on<LoadMoreProductBills>(_onLoadMore);
  }

  Future<void> _onLoad(LoadProductBills event, Emitter<ProductBillsState> emit) async {
    emit(state.copyWith(status: ProductBillsStatus.loading, clearErrorMessage: true));
    await _fetchPage(page: 1, emit: emit, append: false);
  }

  Future<void> _onLoadMore(LoadMoreProductBills event, Emitter<ProductBillsState> emit) async {
    if (!state.hasMore || state.status == ProductBillsStatus.loadingMore) return;
    emit(state.copyWith(status: ProductBillsStatus.loadingMore));
    await _fetchPage(page: state.page + 1, emit: emit, append: true);
  }

  Future<void> _fetchPage({
    required int page,
    required Emitter<ProductBillsState> emit,
    required bool append,
  }) async {
    final request = ProductBillsRequest(
      salesmanId: salesmanId,
      productId: productId,
      year: year,
      month: month,
      page: page,
      perPage: perPage,
    );

    final result = await _provider.getProductBills(request);

    if (result.success) {
      final combined = append ? [...state.bills, ...result.bills] : result.bills;
      emit(state.copyWith(
        status: ProductBillsStatus.loaded,
        bills: combined,
        page: page,
        total: result.total,
        hasMore: combined.length < result.total,
      ));
    } else {
      emit(state.copyWith(
        status: ProductBillsStatus.error,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }
}