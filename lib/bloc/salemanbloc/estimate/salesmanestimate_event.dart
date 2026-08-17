
import '../../../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../../models/salesmanmodels/salesman_qtnpreviewmodel.dart';

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

/// Asks for a server-calculated full estimate preview (POST
/// /quotations/preview) — fired when the salesman reaches the Preview
/// step, and again (debounced) whenever handling charge or notes change
/// there.
class QuotationPreviewRequested extends SalesmanEstimateEvent {
  final QuotationPreviewRequest request;
  const QuotationPreviewRequested(this.request);
}

/// Clears the current full-estimate preview — e.g. the salesman navigated
/// away from the Preview step back to Add Items.
class QuotationPreviewCleared extends SalesmanEstimateEvent {
  const QuotationPreviewCleared();
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
