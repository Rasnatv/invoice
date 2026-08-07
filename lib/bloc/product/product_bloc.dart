import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Apiprovider/productprovider.dart';
import '../../models/owner_models/deleteproductmodel.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({ProductProvider? productProvider})
      : _productProvider = productProvider ?? ProductProvider(),
        super(const ProductState()) {
    on<LoadProductDropdowns>(_onLoadDropdowns);
    on<LoadProducts>(_onLoadProducts);
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
      emit(state.copyWith(status: ProductStatus.loaded, products: result.products));
    } else {
      emit(state.copyWith(
        status: ProductStatus.error,
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
  /// the product list so the screen reflects the change.
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

    final listResult = await _productProvider.getProducts();
    if (listResult.success) {
      emit(state.copyWith(status: ProductStatus.loaded, products: listResult.products));
    }
  }
}
