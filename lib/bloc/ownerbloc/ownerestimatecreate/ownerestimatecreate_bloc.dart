
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';
import 'ownerestimatecreate_event.dart';
import 'ownerestimatecreate_state.dart';

/// Bloc for the Owner Create Estimate screen. Structurally mirrors
/// SalesmanEstimateBloc (products / site visits / live incentive /
/// submit), plus an extra active-salesmen slice used to populate the
/// "Assign to Salesman" dropdown, and a server-preview slice that backs
/// the Preview step's totals/discount/balance.
class OwnerEstimateBloc extends Bloc<OwnerEstimateEvent, OwnerEstimateState> {
  final QuotationProvider _provider;

  OwnerEstimateBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const OwnerEstimateState()) {
    on<OwnerEstimateStarted>(_onStarted);
    on<OwnerActiveProductsRequested>(_onActiveProductsRequested);
    on<OwnerPendingSiteVisitsRequested>(_onPendingSiteVisitsRequested);
    on<ActiveSalesmenRequested>(_onActiveSalesmenRequested);
    on<OwnerSiteVisitSelected>(_onSiteVisitSelected);
    on<OwnerSiteVisitSelectionCleared>(_onSiteVisitSelectionCleared);
    on<SalesmanSelected>(_onSalesmanSelected);
    on<SalesmanSelectionCleared>(_onSalesmanSelectionCleared);
    on<OwnerProductIncentiveRequested>(_onProductIncentiveRequested);
    on<OwnerProductIncentiveCleared>(_onProductIncentiveCleared);
    on<OwnerQuotationPreviewRequested>(_onQuotationPreviewRequested);
    on<OwnerQuotationPreviewCleared>(_onQuotationPreviewCleared);
    on<OwnerQuotationSubmitRequested>(_onQuotationSubmitRequested);
    on<OwnerQuotationSubmitResultConsumed>(_onQuotationSubmitResultConsumed);
  }

  Future<void> _onStarted(
      OwnerEstimateStarted event, Emitter<OwnerEstimateState> emit) async {
    add(const OwnerActiveProductsRequested());
    add(const OwnerPendingSiteVisitsRequested());
    add(const ActiveSalesmenRequested());
  }

  Future<void> _onActiveProductsRequested(
      OwnerActiveProductsRequested event, Emitter<OwnerEstimateState> emit) async {
    emit(state.copyWith(productsStatus: LoadStatus.loading, clearProductsError: true));
    final result = await _provider.getActiveProducts();
    if (result.success) {
      emit(state.copyWith(productsStatus: LoadStatus.success, products: result.list));
    } else {
      emit(state.copyWith(
        productsStatus: LoadStatus.failure,
        productsError: result.errorMessage,
      ));
    }
  }

  Future<void> _onPendingSiteVisitsRequested(
      OwnerPendingSiteVisitsRequested event, Emitter<OwnerEstimateState> emit) async {
    emit(state.copyWith(siteVisitsStatus: LoadStatus.loading, clearSiteVisitsError: true));
    final result = await _provider.getPendingSiteVisits();
    if (result.success) {
      emit(state.copyWith(siteVisitsStatus: LoadStatus.success, siteVisits: result.list));
    } else {
      emit(state.copyWith(
        siteVisitsStatus: LoadStatus.failure,
        siteVisitsError: result.errorMessage,
      ));
    }
  }

  Future<void> _onActiveSalesmenRequested(
      ActiveSalesmenRequested event, Emitter<OwnerEstimateState> emit) async {
    emit(state.copyWith(salesmenStatus: LoadStatus.loading, clearSalesmenError: true));
    final result = await _provider.getActiveSalesmen();
    if (result.success) {
      emit(state.copyWith(salesmenStatus: LoadStatus.success, salesmen: result.list));
    } else {
      emit(state.copyWith(
        salesmenStatus: LoadStatus.failure,
        salesmenError: result.errorMessage,
      ));
    }
  }

  void _onSiteVisitSelected(OwnerSiteVisitSelected event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(selectedSiteVisit: event.visit));
  }

  void _onSiteVisitSelectionCleared(
      OwnerSiteVisitSelectionCleared event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(clearSelectedSiteVisit: true));
  }

  void _onSalesmanSelected(SalesmanSelected event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(selectedSalesman: event.salesman));
  }

  void _onSalesmanSelectionCleared(
      SalesmanSelectionCleared event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(clearSelectedSalesman: true));
  }

  Future<void> _onProductIncentiveRequested(
      OwnerProductIncentiveRequested event, Emitter<OwnerEstimateState> emit) async {
    emit(state.copyWith(incentiveStatus: LoadStatus.loading, clearIncentiveError: true));
    final result = await _provider.getProductIncentive(ProductIncentiveRequest(
      productId: event.productId,
      quantity: event.quantity,
      rate: event.rate,
    ));
    if (result.success) {
      emit(state.copyWith(incentiveStatus: LoadStatus.success, incentive: result.incentive));
    } else {
      emit(state.copyWith(
        incentiveStatus: LoadStatus.failure,
        incentiveError: result.errorMessage,
      ));
    }
  }

  void _onProductIncentiveCleared(
      OwnerProductIncentiveCleared event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(incentiveStatus: LoadStatus.initial, clearIncentive: true));
  }

  /// Calls POST /quotations/preview and stores the server-calculated
  /// totals/discount/balance so the Preview step can render them directly
  /// instead of re-deriving them on-device.
  Future<void> _onQuotationPreviewRequested(
      OwnerQuotationPreviewRequested event, Emitter<OwnerEstimateState> emit) async {
    emit(state.copyWith(previewStatus: LoadStatus.loading, clearPreviewError: true));
    final result = await _provider.previewQuotation(event.request);
    if (result.success) {
      emit(state.copyWith(previewStatus: LoadStatus.success, preview: result.preview));
    } else {
      emit(state.copyWith(
        previewStatus: LoadStatus.failure,
        previewError: result.errorMessage,
      ));
    }
  }

  void _onQuotationPreviewCleared(
      OwnerQuotationPreviewCleared event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(previewStatus: LoadStatus.initial, clearPreview: true));
  }

  Future<void> _onQuotationSubmitRequested(
      OwnerQuotationSubmitRequested event, Emitter<OwnerEstimateState> emit) async {
    emit(state.copyWith(
      submitStatus: SubmitStatus.submitting,
      submitAction: event.request.action,
      clearSubmitMessage: true,
      clearSubmitError: true,
    ));
    final result = await _provider.createQuotation(event.request);
    if (result.success) {
      emit(state.copyWith(submitStatus: SubmitStatus.success, submitMessage: result.message));
    } else {
      emit(state.copyWith(
        submitStatus: SubmitStatus.failure,
        submitError: result.message,
      ));
    }
  }

  void _onQuotationSubmitResultConsumed(
      OwnerQuotationSubmitResultConsumed event, Emitter<OwnerEstimateState> emit) {
    emit(state.copyWith(submitStatus: SubmitStatus.idle, clearSubmitMessage: true, clearSubmitError: true));
  }
}