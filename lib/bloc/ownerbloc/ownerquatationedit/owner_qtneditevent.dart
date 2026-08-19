import 'package:equatable/equatable.dart';
import '../../../models/salesmanmodels/quotationupdatemodel.dart';

abstract class OwnerQuotationEditEvent extends Equatable {
  const OwnerQuotationEditEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the owner edit screen opens — loads GET /products/active
/// for the "Select Product" dropdown and to backfill company/MRP on
/// pre-existing items (mirrors SalesmanEstimateBloc's
/// ActiveProductsRequested, kept as its own event so this bloc doesn't
/// depend on the salesman bloc at all).
class OwnerEditActiveProductsRequested extends OwnerQuotationEditEvent {
  const OwnerEditActiveProductsRequested();
}

/// Live incentive preview (POST /quotations/product-incentive) for the
/// product/quantity/rate currently entered on the add/edit-item form.
class OwnerEditProductIncentiveRequested extends OwnerQuotationEditEvent {
  final int productId;
  final double quantity;
  final double rate;

  const OwnerEditProductIncentiveRequested({
    required this.productId,
    required this.quantity,
    required this.rate,
  });

  @override
  List<Object?> get props => [productId, quantity, rate];
}

/// Clears the current incentive preview (product deselected, or
/// quantity/rate no longer valid).
class OwnerEditProductIncentiveCleared extends OwnerQuotationEditEvent {
  const OwnerEditProductIncentiveCleared();
}

/// Submits the edited quotation via POST /quotations/update. Uses the
/// SAME QuotationUpdateRequest/QuotationUpdateItemRequest models already
/// shared with the salesman edit flow — only the id + whatever fields
/// actually changed need to be set on the request.
class OwnerQuotationUpdateSubmitted extends OwnerQuotationEditEvent {
  final QuotationUpdateRequest request;
  const OwnerQuotationUpdateSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

/// Resets updateStatus back to idle after the screen has already reacted
/// to a success/failure, so re-opening the screen doesn't replay it.
class OwnerQuotationUpdateResultConsumed extends OwnerQuotationEditEvent {
  const OwnerQuotationUpdateResultConsumed();
}