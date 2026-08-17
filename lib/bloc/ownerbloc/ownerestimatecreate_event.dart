import '../../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../models/owner_models/get_activedrivermodel.dart';

abstract class OwnerEstimateEvent {
  const OwnerEstimateEvent();
}

/// Fired once when the screen opens — kicks off the products fetch, the
/// pending-site-visits fetch, and the active-salesmen fetch.
class OwnerEstimateStarted extends OwnerEstimateEvent {
  const OwnerEstimateStarted();
}

/// Re-fetches GET /products/active (e.g. retry after a failure).
class OwnerActiveProductsRequested extends OwnerEstimateEvent {
  const OwnerActiveProductsRequested();
}

/// Re-fetches GET /site-visits/pending-dropdown.
class OwnerPendingSiteVisitsRequested extends OwnerEstimateEvent {
  const OwnerPendingSiteVisitsRequested();
}

/// Re-fetches GET /salesmen/active (e.g. retry after a failure, or a
/// pull-to-refresh on the Preview step's Assign Salesman dropdown).
class ActiveSalesmenRequested extends OwnerEstimateEvent {
  const ActiveSalesmenRequested();
}

/// A site visit was picked from the phone-number suggestion list.
class OwnerSiteVisitSelected extends OwnerEstimateEvent {
  final SiteVisitDropdownItem visit;
  const OwnerSiteVisitSelected(this.visit);
}

/// Clears a previously selected site visit.
class OwnerSiteVisitSelectionCleared extends OwnerEstimateEvent {
  const OwnerSiteVisitSelectionCleared();
}

/// A salesman was picked from the "Assign to Salesman" dropdown on the
/// Preview step.
class SalesmanSelected extends OwnerEstimateEvent {
  final SalesmanActiveModel salesman;
  const SalesmanSelected(this.salesman);
}

/// Clears the currently assigned salesman.
class SalesmanSelectionCleared extends OwnerEstimateEvent {
  const SalesmanSelectionCleared();
}

/// Asks for a live incentive preview (POST /quotations/product-incentive)
/// for the product/quantity/rate currently being entered on the Add Items
/// step.
class OwnerProductIncentiveRequested extends OwnerEstimateEvent {
  final int productId;
  final double quantity;
  final double rate;
  const OwnerProductIncentiveRequested({
    required this.productId,
    required this.quantity,
    required this.rate,
  });
}

/// Clears the current incentive preview.
class OwnerProductIncentiveCleared extends OwnerEstimateEvent {
  const OwnerProductIncentiveCleared();
}

/// Submits the estimate. request.action must be 'save_quotation' or
/// 'approve' from this screen.
class OwnerQuotationSubmitRequested extends OwnerEstimateEvent {
  final QuotationCreateRequest request;
  const OwnerQuotationSubmitRequested(this.request);
}

/// Resets submitStatus back to idle after the screen has already reacted
/// to a success/failure so it doesn't fire again on the next rebuild.
class OwnerQuotationSubmitResultConsumed extends OwnerEstimateEvent {
  const OwnerQuotationSubmitResultConsumed();
}
