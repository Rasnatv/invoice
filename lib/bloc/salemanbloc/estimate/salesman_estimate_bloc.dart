import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/estimate/salesmanestimate_event.dart';
import 'package:tileshop/bloc/salemanbloc/estimate/salesmanestimate_state.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';
import '../../../models/salesmanmodels/estimatesectionproductincentive.dart';


/// No repository layer, by request — this bloc talks to QuotationProvider
/// directly, the same way EstimatesCubit talks to its data source today.
class SalesmanEstimateBloc extends Bloc<SalesmanEstimateEvent, SalesmanEstimateState> {
  final QuotationProvider _provider;

  SalesmanEstimateBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const SalesmanEstimateState()) {
    on<SalesmanEstimateStarted>(_onStarted);
    on<ActiveProductsRequested>(_onProductsRequested);
    on<PendingSiteVisitsRequested>(_onSiteVisitsRequested);
    on<SiteVisitSelected>(_onSiteVisitSelected);
    on<SiteVisitSelectionCleared>(_onSiteVisitSelectionCleared);
    on<ProductIncentiveRequested>(
      _onIncentiveRequested,
      // Cancel any incentive call still in flight when a newer one comes
      // in (e.g. the salesman is still typing the quantity) so a slow,
      // older response can't overwrite a newer preview.
      transformer: restartable(),
    );
    on<ProductIncentiveCleared>(_onIncentiveCleared);
    on<QuotationSubmitRequested>(_onSubmitRequested);
    on<QuotationSubmitResultConsumed>(_onSubmitResultConsumed);
  }

  Future<void> _onStarted(
      SalesmanEstimateStarted event,
      Emitter<SalesmanEstimateState> emit,
      ) async {
    await Future.wait([
      _loadProducts(emit),
      _loadSiteVisits(emit),
    ]);
  }

  Future<void> _onProductsRequested(
      ActiveProductsRequested event,
      Emitter<SalesmanEstimateState> emit,
      ) =>
      _loadProducts(emit);

  Future<void> _onSiteVisitsRequested(
      PendingSiteVisitsRequested event,
      Emitter<SalesmanEstimateState> emit,
      ) =>
      _loadSiteVisits(emit);

  Future<void> _loadProducts(Emitter<SalesmanEstimateState> emit) async {
    emit(state.copyWith(productsStatus: LoadStatus.loading, clearProductsError: true));
    final result = await _provider.getActiveProducts();
    if (result.success) {
      emit(state.copyWith(productsStatus: LoadStatus.success, products: result.list));
    } else {
      emit(state.copyWith(
        productsStatus: LoadStatus.failure,
        productsError: result.errorMessage ?? 'Failed to load products.',
      ));
    }
  }

  Future<void> _loadSiteVisits(Emitter<SalesmanEstimateState> emit) async {
    emit(state.copyWith(siteVisitsStatus: LoadStatus.loading, clearSiteVisitsError: true));
    final result = await _provider.getPendingSiteVisits();
    if (result.success) {
      emit(state.copyWith(siteVisitsStatus: LoadStatus.success, siteVisits: result.list));
    } else {
      emit(state.copyWith(
        siteVisitsStatus: LoadStatus.failure,
        siteVisitsError: result.errorMessage ?? 'Failed to load site visits.',
      ));
    }
  }

  void _onSiteVisitSelected(
      SiteVisitSelected event,
      Emitter<SalesmanEstimateState> emit,
      ) {
    emit(state.copyWith(selectedSiteVisit: event.visit));
  }

  void _onSiteVisitSelectionCleared(
      SiteVisitSelectionCleared event,
      Emitter<SalesmanEstimateState> emit,
      ) {
    emit(state.copyWith(clearSelectedSiteVisit: true));
  }

  Future<void> _onIncentiveRequested(
      ProductIncentiveRequested event,
      Emitter<SalesmanEstimateState> emit,
      ) async {
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
        incentiveError: result.errorMessage ?? 'Failed to fetch incentive.',
      ));
    }
  }

  void _onIncentiveCleared(
      ProductIncentiveCleared event,
      Emitter<SalesmanEstimateState> emit,
      ) {
    emit(state.copyWith(
      incentiveStatus: LoadStatus.initial,
      clearIncentive: true,
      clearIncentiveError: true,
    ));
  }

  Future<void> _onSubmitRequested(
      QuotationSubmitRequested event,
      Emitter<SalesmanEstimateState> emit,
      ) async {
    emit(state.copyWith(
      submitStatus: SubmitStatus.submitting,
      submitAction: event.request.action,
      clearSubmitError: true,
      clearSubmitMessage: true,
    ));
    final result = await _provider.createQuotation(event.request);
    if (result.success) {
      emit(state.copyWith(
        submitStatus: SubmitStatus.success,
        submitMessage: result.message ?? 'Saved successfully.',
      ));
    } else {
      emit(state.copyWith(
        submitStatus: SubmitStatus.failure,
        submitError: result.errorMessage ?? 'Something went wrong. Please try again.',
      ));
    }
  }

  void _onSubmitResultConsumed(
      QuotationSubmitResultConsumed event,
      Emitter<SalesmanEstimateState> emit,
      ) {
    emit(state.copyWith(
      submitStatus: SubmitStatus.idle,
      clearSubmitError: true,
      clearSubmitMessage: true,
    ));
  }
}