import '../../../core/dummymodel/product_incentive_model.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../../models/owner_models/get_activedrivermodel.dart';
import '../../models/salesmanmodels/estimatesectionproductincentive.dart';


enum LoadStatus { initial, loading, success, failure }

enum SubmitStatus { idle, submitting, success, failure }

class OwnerEstimateState {
  final LoadStatus productsStatus;
  final List<ActiveProductModel> products;
  final String? productsError;

  final LoadStatus siteVisitsStatus;
  final List<SiteVisitDropdownItem> siteVisits;
  final String? siteVisitsError;

  final SiteVisitDropdownItem? selectedSiteVisit;

  /// Live incentive preview for whatever product/quantity/rate is
  /// currently being entered on the Add Items step (not yet added).
  final LoadStatus incentiveStatus;
  final ProductIncentiveModel? incentive;
  final String? incentiveError;

  /// Active salesmen (GET /salesmen/active) for the "Assign to Salesman"
  /// dropdown shown on the Preview step when approving.
  final LoadStatus salesmenStatus;
  final List<SalesmanActiveModel> salesmen;
  final String? salesmenError;
  final SalesmanActiveModel? selectedSalesman;

  final SubmitStatus submitStatus;
  final String? submitMessage;
  final String? submitError;

  /// Which action ('save_quotation' | 'approve') the in-flight/last submit
  /// used — lets the UI show a spinner on the right button.
  final String? submitAction;

  const OwnerEstimateState({
    this.productsStatus = LoadStatus.initial,
    this.products = const [],
    this.productsError,
    this.siteVisitsStatus = LoadStatus.initial,
    this.siteVisits = const [],
    this.siteVisitsError,
    this.selectedSiteVisit,
    this.incentiveStatus = LoadStatus.initial,
    this.incentive,
    this.incentiveError,
    this.salesmenStatus = LoadStatus.initial,
    this.salesmen = const [],
    this.salesmenError,
    this.selectedSalesman,
    this.submitStatus = SubmitStatus.idle,
    this.submitMessage,
    this.submitError,
    this.submitAction,
  });

  OwnerEstimateState copyWith({
    LoadStatus? productsStatus,
    List<ActiveProductModel>? products,
    String? productsError,
    bool clearProductsError = false,
    LoadStatus? siteVisitsStatus,
    List<SiteVisitDropdownItem>? siteVisits,
    String? siteVisitsError,
    bool clearSiteVisitsError = false,
    SiteVisitDropdownItem? selectedSiteVisit,
    bool clearSelectedSiteVisit = false,
    LoadStatus? incentiveStatus,
    ProductIncentiveModel? incentive,
    bool clearIncentive = false,
    String? incentiveError,
    bool clearIncentiveError = false,
    LoadStatus? salesmenStatus,
    List<SalesmanActiveModel>? salesmen,
    String? salesmenError,
    bool clearSalesmenError = false,
    SalesmanActiveModel? selectedSalesman,
    bool clearSelectedSalesman = false,
    SubmitStatus? submitStatus,
    String? submitMessage,
    bool clearSubmitMessage = false,
    String? submitError,
    bool clearSubmitError = false,
    String? submitAction,
  }) {
    return OwnerEstimateState(
      productsStatus: productsStatus ?? this.productsStatus,
      products: products ?? this.products,
      productsError: clearProductsError ? null : (productsError ?? this.productsError),
      siteVisitsStatus: siteVisitsStatus ?? this.siteVisitsStatus,
      siteVisits: siteVisits ?? this.siteVisits,
      siteVisitsError: clearSiteVisitsError ? null : (siteVisitsError ?? this.siteVisitsError),
      selectedSiteVisit:
      clearSelectedSiteVisit ? null : (selectedSiteVisit ?? this.selectedSiteVisit),
      incentiveStatus: incentiveStatus ?? this.incentiveStatus,
      incentive: clearIncentive ? null : (incentive ?? this.incentive),
      incentiveError: clearIncentiveError ? null : (incentiveError ?? this.incentiveError),
      salesmenStatus: salesmenStatus ?? this.salesmenStatus,
      salesmen: salesmen ?? this.salesmen,
      salesmenError: clearSalesmenError ? null : (salesmenError ?? this.salesmenError),
      selectedSalesman:
      clearSelectedSalesman ? null : (selectedSalesman ?? this.selectedSalesman),
      submitStatus: submitStatus ?? this.submitStatus,
      submitMessage: clearSubmitMessage ? null : (submitMessage ?? this.submitMessage),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitAction: submitAction ?? this.submitAction,
    );
  }
}
