import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/owner_viewquotationprovider.dart';
import 'owner_viewquotation_event.dart';
import 'owner_viewquotations_state.dart';

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  final OwnerviewQuotationProvider _provider;

  QuotationBloc({OwnerviewQuotationProvider? provider})
      : _provider = provider ?? OwnerviewQuotationProvider(),
        super(const QuotationInitial()) {
    on<FetchQuotationsEvent>(_onFetch);
    on<LoadMoreQuotationsEvent>(_onLoadMore);
    on<RefreshQuotationsEvent>(_onRefresh);
    on<SearchQuotationsEvent>(_onSearch);
    on<FilterQuotationsEvent>(_onFilter);
  }

  Future<void> _onFetch(
      FetchQuotationsEvent event,
      Emitter<QuotationState> emit,
      ) async {
    emit(const QuotationLoading());
    final result = await _provider.getQuotations(page: event.page, perPage: event.perPage);

    if (result.success) {
      final total = result.myQuotations.length + result.salesmanQuotations.length;
      emit(QuotationLoaded(
        myQuotations: result.myQuotations,
        salesmanQuotations: result.salesmanQuotations,
        currentPage: event.page,
        perPage: event.perPage,
        hasMore: total >= event.perPage,
      ));
    } else {
      emit(QuotationError(result.errorMessage, isUnauthorized: result.isUnauthorized));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreQuotationsEvent event,
      Emitter<QuotationState> emit,
      ) async {
    final current = state;
    if (current is! QuotationLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _provider.getQuotations(page: nextPage, perPage: current.perPage);

    if (result.success) {
      final total = result.myQuotations.length + result.salesmanQuotations.length;
      emit(current.copyWith(
        myQuotations: [...current.myQuotations, ...result.myQuotations],
        salesmanQuotations: [...current.salesmanQuotations, ...result.salesmanQuotations],
        currentPage: nextPage,
        hasMore: total >= current.perPage,
        isLoadingMore: false,
      ));
    } else {
      // Keep existing data, just stop the loader; don't wipe the list on a failed page.
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(
      RefreshQuotationsEvent event,
      Emitter<QuotationState> emit,
      ) async {
    final current = state;
    final keepFilter = current is QuotationLoaded ? current.filter : QuotationFilterType.mine;
    final keepQuery = current is QuotationLoaded ? current.searchQuery : '';
    final perPage = current is QuotationLoaded ? current.perPage : 10;

    final result = await _provider.getQuotations(page: 1, perPage: perPage);

    if (result.success) {
      final total = result.myQuotations.length + result.salesmanQuotations.length;
      emit(QuotationLoaded(
        myQuotations: result.myQuotations,
        salesmanQuotations: result.salesmanQuotations,
        filter: keepFilter,
        searchQuery: keepQuery,
        currentPage: 1,
        perPage: perPage,
        hasMore: total >= perPage,
      ));
    } else {
      emit(QuotationError(result.errorMessage, isUnauthorized: result.isUnauthorized));
    }
  }

  void _onSearch(SearchQuotationsEvent event, Emitter<QuotationState> emit) {
    final current = state;
    if (current is QuotationLoaded) {
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  void _onFilter(FilterQuotationsEvent event, Emitter<QuotationState> emit) {
    final current = state;
    if (current is QuotationLoaded) {
      emit(current.copyWith(filter: event.filter));
    }
  }
}