import '../../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';

abstract class SalesmanEstimateEvent {
  const SalesmanEstimateEvent();
}

/// Fired once when the screen opens — kicks off both the products fetch
/// and the pending-site-visits fetch.
class SalesmanEstimateStarted extends SalesmanEstimateEvent {
  const SalesmanEstimateStarted();
}

/// Re-fetches GET /products/active (e.g. retry after a failure).
class ActiveProductsRequested extends SalesmanEstimateEvent {
  const ActiveProductsRequested();
}

/// Re-fetches GET /site-visits/pending-dropdown.
class PendingSiteVisitsRequested extends SalesmanEstimateEvent {
  const PendingSiteVisitsRequested();
}

/// A site visit was picked from the phone-number suggestion list. The
/// screen fills Party Name / Address locally; the bloc just remembers
/// which one is selected so its id can ride along on submit.
class SiteVisitSelected extends SalesmanEstimateEvent {
  final SiteVisitDropdownItem visit;
  const SiteVisitSelected(this.visit);
}

/// Clears a previously selected site visit (e.g. the phone number was
/// edited by hand after a selection was made).
class SiteVisitSelectionCleared extends SalesmanEstimateEvent {
  const SiteVisitSelectionCleared();
}

/// Asks for a live incentive preview (POST /quotations/product-incentive)
/// for the product/quantity/rate currently being entered on the Add Items
/// step — fired (debounced) whenever those fields change while a product
/// is selected.
class ProductIncentiveRequested extends SalesmanEstimateEvent {
  final int productId;
  final double quantity;
  final double rate;
  const ProductIncentiveRequested({
    required this.productId,
    required this.quantity,
    required this.rate,
  });
}

/// Clears the current incentive preview — e.g. the product was
/// deselected, or quantity/rate became invalid (0 or empty).
class ProductIncentiveCleared extends SalesmanEstimateEvent {
  const ProductIncentiveCleared();
}

/// Submits the estimate. request.action must be 'save_quotation' or
/// 'submit' — nothing else is valid from this screen.
class QuotationSubmitRequested extends SalesmanEstimateEvent {
  final QuotationCreateRequest request;
  const QuotationSubmitRequested(this.request);
}

/// Resets submitStatus back to idle after the screen has already reacted
/// to a success/failure (shown a SnackBar, popped, etc.) so it doesn't
/// fire again on the next rebuild.
class QuotationSubmitResultConsumed extends SalesmanEstimateEvent {
  const QuotationSubmitResultConsumed();
}