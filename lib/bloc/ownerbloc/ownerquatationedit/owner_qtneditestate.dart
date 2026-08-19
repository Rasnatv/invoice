import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../core/dummymodel/product_incentive_model.dart';
import '../../../models/salesmanmodels/estimatesectionproductincentive.dart';

enum OwnerEditLoadStatus { initial, loading, success, failure }

enum OwnerQuotationUpdateStatus { idle, submitting, success, failure }

class OwnerQuotationEditState extends Equatable {
  // ---- active products (GET /products/active) ----
  final OwnerEditLoadStatus productsStatus;
  final List<ActiveProductModel> products;
  final String? productsError;

  // ---- live incentive preview (POST /quotations/product-incentive) ----
  final OwnerEditLoadStatus incentiveStatus;
  final ProductIncentiveModel? incentive;
  final String? incentiveError;

  // ---- update submit (POST /quotations/update) ----
  final OwnerQuotationUpdateStatus updateStatus;
  final String? updateMessage;
  final String? updateError;

  const OwnerQuotationEditState({
    this.productsStatus = OwnerEditLoadStatus.initial,
    this.products = const [],
    this.productsError,
    this.incentiveStatus = OwnerEditLoadStatus.initial,
    this.incentive,
    this.incentiveError,
    this.updateStatus = OwnerQuotationUpdateStatus.idle,
    this.updateMessage,
    this.updateError,
  });

  OwnerQuotationEditState copyWith({
    OwnerEditLoadStatus? productsStatus,
    List<ActiveProductModel>? products,
    String? productsError,
    bool clearProductsError = false,
    OwnerEditLoadStatus? incentiveStatus,
    ProductIncentiveModel? incentive,
    bool clearIncentive = false,
    String? incentiveError,
    bool clearIncentiveError = false,
    OwnerQuotationUpdateStatus? updateStatus,
    String? updateMessage,
    bool clearUpdateMessage = false,
    String? updateError,
    bool clearUpdateError = false,
  }) {
    return OwnerQuotationEditState(
      productsStatus: productsStatus ?? this.productsStatus,
      products: products ?? this.products,
      productsError: clearProductsError ? null : (productsError ?? this.productsError),
      incentiveStatus: incentiveStatus ?? this.incentiveStatus,
      incentive: clearIncentive ? null : (incentive ?? this.incentive),
      incentiveError: clearIncentiveError ? null : (incentiveError ?? this.incentiveError),
      updateStatus: updateStatus ?? this.updateStatus,
      updateMessage: clearUpdateMessage ? null : (updateMessage ?? this.updateMessage),
      updateError: clearUpdateError ? null : (updateError ?? this.updateError),
    );
  }

  @override
  List<Object?> get props => [
    productsStatus,
    products,
    productsError,
    incentiveStatus,
    incentive,
    incentiveError,
    updateStatus,
    updateMessage,
    updateError,
  ];
}