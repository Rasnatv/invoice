import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/salesmanowner_incentivemodel.dart';

enum ProductBillsStatus { initial, loading, loadingMore, loaded, error }

class ProductBillsState extends Equatable {
  final ProductBillsStatus status;
  final List<ProductBillModel> bills;
  final int page;
  final int total;
  final bool hasMore;
  final String? errorMessage;
  final bool isUnauthorized;

  const ProductBillsState({
    required this.status,
    required this.bills,
    required this.page,
    required this.total,
    required this.hasMore,
    required this.errorMessage,
    required this.isUnauthorized,
  });

  factory ProductBillsState.initial() => const ProductBillsState(
    status: ProductBillsStatus.initial,
    bills: [],
    page: 0,
    total: 0,
    hasMore: true,
    errorMessage: null,
    isUnauthorized: false,
  );

  ProductBillsState copyWith({
    ProductBillsStatus? status,
    List<ProductBillModel>? bills,
    int? page,
    int? total,
    bool? hasMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isUnauthorized,
  }) {
    return ProductBillsState(
      status: status ?? this.status,
      bills: bills ?? this.bills,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }

  @override
  List<Object?> get props => [status, bills, page, total, hasMore, errorMessage, isUnauthorized];
}