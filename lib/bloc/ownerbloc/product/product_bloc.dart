
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/productprovider.dart';
import '../../../models/owner_models/deleteproductmodel.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({ProductProvider? productProvider})
      : _productProvider = productProvider ?? ProductProvider(),
        super(const ProductState()) {
    on<LoadProductDropdowns>(_onLoadDropdowns);
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  final ProductProvider _productProvider;

  Future<void> _onLoadDropdowns(
      LoadProductDropdowns event,
      Emitter<ProductState> emit,
      ) async {
    emit(state.copyWith(dropdownStatus: DropdownStatus.loading, clearMessages: true));

    final results = await Future.wait([
      _productProvider.getActiveCompanies(),
      _productProvider.getActiveUnits(),
    ]);
    final companyResult = results[0] as CompanyActiveListResult;
    final unitResult = results[1] as UnitActiveListResult;

    if (!companyResult.success || !unitResult.success) {
      final unauthorized = companyResult.isUnauthorized || unitResult.isUnauthorized;
      emit(state.copyWith(
        dropdownStatus: DropdownStatus.error,
        errorMessage: companyResult.errorMessage ?? unitResult.errorMessage,
        isUnauthorized: unauthorized,
      ));
      return;
    }

    emit(state.copyWith(
      dropdownStatus: DropdownStatus.loaded,
      companies: companyResult.companies,
      units: unitResult.units,
    ));
  }

  /// Always a full reset to the given page (page 1 by default) — used for
  /// the initial load and pull-to-refresh. Replaces `products` outright and
  /// resets pagination bookkeeping, so it never gets appended to stale data.
  Future<void> _onLoadProducts(
      LoadProducts event,
      Emitter<ProductState> emit,
      ) async {
    emit(state.copyWith(status: ProductStatus.loading, clearMessages: true));

    final result = await _productProvider.getProducts(
      page: event.page,
      perPage: event.perPage,
    );

    if (result.success) {
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: result.products,
        currentPage: event.page,
        // No total/last_page comes back from the API, so infer "more pages
        // exist" from whether this page came back full.
        hasMore: result.products.length >= event.perPage,
        isLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  /// Fetches state.currentPage + 1 and appends it to the existing list.
  /// Guards against duplicate/overlapping requests and against calling past
  /// the last page.
  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event,
      Emitter<ProductState> emit,
      ) async {
    if (state.isLoadingMore || !state.hasMore || state.status == ProductStatus.loading) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _productProvider.getProducts(
      page: nextPage,
      perPage: event.perPage,
    );

    if (result.success) {
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [...state.products, ...result.products],
        currentPage: nextPage,
        hasMore: result.products.length >= event.perPage,
        isLoadingMore: false,
      ));
    } else {
      // Keep the already-loaded products on screen; just surface the error
      // and stop the bottom spinner so the list doesn't hang forever.
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  Future<void> _onCreateProduct(
      CreateProduct event,
      Emitter<ProductState> emit,
      ) async {
    emit(state.copyWith(status: ProductStatus.actionInProgress, clearMessages: true));

    final result = await _productProvider.addProduct(event.request);
    await _emitActionResult(result, emit);
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event,
      Emitter<ProductState> emit,
      ) async {
    emit(state.copyWith(status: ProductStatus.actionInProgress, clearMessages: true));

    final result = await _productProvider.updateProduct(event.request);
    await _emitActionResult(result, emit);
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event,
      Emitter<ProductState> emit,
      ) async {
    emit(state.copyWith(status: ProductStatus.actionInProgress, clearMessages: true));

    final result =
    await _productProvider.deleteProduct(ProductDeleteRequestModel(id: event.id));
    await _emitActionResult(result, emit);
  }

  /// Shared success/error handling for create/update/delete, then refreshes
  /// the product list from page 1 so the screen reflects the change. This
  /// intentionally resets pagination back to page 1 rather than trying to
  /// patch a single item into the already-loaded pages.
  Future<void> _emitActionResult(
      ProductActionResult result,
      Emitter<ProductState> emit,
      ) async {
    if (!result.success) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
      return;
    }

    emit(state.copyWith(status: ProductStatus.actionSuccess, actionMessage: result.message));

    const perPage = 10;
    final listResult = await _productProvider.getProducts(page: 1, perPage: perPage);
    if (listResult.success) {
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: listResult.products,
        currentPage: 1,
        hasMore: listResult.products.length >= perPage,
        isLoadingMore: false,
      ));
    }
  }
}