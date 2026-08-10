import '../../../core/dummymodel/product_incentive_model.dart';
import '../../../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';


enum LoadStatus { initial, loading, success, failure }

enum SubmitStatus { idle, submitting, success, failure }

class SalesmanEstimateState {
  final LoadStatus productsStatus;
  final List<ActiveProductModel> products;
  final String? productsError;

  final LoadStatus siteVisitsStatus;
  final List<SiteVisitDropdownItem> siteVisits;
  final String? siteVisitsError;

  final SiteVisitDropdownItem? selectedSiteVisit;

  /// Live incentive preview for whatever product/quantity/rate is
  /// currently being entered on the Add Items step (not yet added to the
  /// list). Cleared whenever the product, quantity, or rate changes to
  /// something that no longer matches.
  final LoadStatus incentiveStatus;
  final ProductIncentiveModel? incentive;
  final String? incentiveError;

  final SubmitStatus submitStatus;
  final String? submitMessage;
  final String? submitError;

  /// Which action ('save_quotation' | 'submit') the in-flight/last submit
  /// used — lets the UI show a spinner on the right button.
  final String? submitAction;

  const SalesmanEstimateState({
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
    this.submitStatus = SubmitStatus.idle,
    this.submitMessage,
    this.submitError,
    this.submitAction,
  });

  SalesmanEstimateState copyWith({
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
    SubmitStatus? submitStatus,
    String? submitMessage,
    bool clearSubmitMessage = false,
    String? submitError,
    bool clearSubmitError = false,
    String? submitAction,
  }) {
    return SalesmanEstimateState(
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
      submitStatus: submitStatus ?? this.submitStatus,
      submitMessage: clearSubmitMessage ? null : (submitMessage ?? this.submitMessage),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitAction: submitAction ?? this.submitAction,
    );
  }
}