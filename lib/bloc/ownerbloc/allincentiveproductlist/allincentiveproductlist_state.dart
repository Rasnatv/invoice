import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/salesmanowner_incentivemodel.dart';

enum ProductListStatus { initial, loading, loadingMore, loaded, error }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<IncentiveProductModel> products;
  final int total;
  final int page;
  final int perPage;
  final String? errorMessage;

  const ProductListState({
    required this.status,
    required this.products,
    required this.total,
    required this.page,
    required this.perPage,
    required this.errorMessage,
  });

  factory ProductListState.initial({int perPage = 10}) => ProductListState(
    status: ProductListStatus.initial,
    products: const [],
    total: 0,
    page: 1,
    perPage: perPage,
    errorMessage: null,
  );

  /// True while more pages remain to be fetched.
  bool get hasMore => products.length < total;

  ProductListState copyWith({
    ProductListStatus? status,
    List<IncentiveProductModel>? products,
    int? total,
    int? page,
    int? perPage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      total: total ?? this.total,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, products, total, page, perPage, errorMessage];
}