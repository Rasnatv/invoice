
import 'package:equatable/equatable.dart';
import '../../../models/owner_models/activecompanymodel.dart';
import '../../../models/owner_models/activeuintmodel.dart';
import '../../../models/owner_models/getproductmodel.dart';

enum ProductStatus { initial, loading, loaded, actionInProgress, actionSuccess, error }

enum DropdownStatus { initial, loading, loaded, error }

/// Single state class rather than a state-per-subclass hierarchy. Products,
/// companies, and units are loaded somewhat independently (dropdowns load
/// once on screen open, the list can reload separately, an action can run
/// on top of an already-loaded list) — copyWith lets each of those update
/// without wiping the others out, which a sealed-class-per-status shape
/// would make awkward.
class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.dropdownStatus = DropdownStatus.initial,
    this.companies = const [],
    this.units = const [],
    this.errorMessage,
    this.actionMessage,
    this.isUnauthorized = false,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final ProductStatus status;
  final List<ProductModel> products;

  final DropdownStatus dropdownStatus;
  final List<CompanyActiveModel> companies;
  final List<UnitActiveModel> units;

  final String? errorMessage;
  final String? actionMessage;
  final bool isUnauthorized;

  /// Pagination bookkeeping. `currentPage` is the last page successfully
  /// loaded into `products`. `hasMore` is inferred client-side: a page that
  /// comes back with fewer than `perPage` items is treated as the last
  /// page, since the API response carries no total/last_page metadata.
  /// `isLoadingMore` drives a small bottom-of-list spinner, kept separate
  /// from `status` so loading page 2 doesn't blank the already-loaded list.
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductModel>? products,
    DropdownStatus? dropdownStatus,
    List<CompanyActiveModel>? companies,
    List<UnitActiveModel>? units,
    String? errorMessage,
    String? actionMessage,
    bool? isUnauthorized,
    bool clearMessages = false,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      dropdownStatus: dropdownStatus ?? this.dropdownStatus,
      companies: companies ?? this.companies,
      units: units ?? this.units,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearMessages ? null : (actionMessage ?? this.actionMessage),
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    dropdownStatus,
    companies,
    units,
    errorMessage,
    actionMessage,
    isUnauthorized,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}