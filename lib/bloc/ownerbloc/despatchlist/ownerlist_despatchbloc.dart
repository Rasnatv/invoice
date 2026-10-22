
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/ownerdespatchprovider.dart';
import '../../../models/owner_models/owner_despatchmodellist.dart';
import 'ownerlist_despatchevent.dart';
import 'ownerlist_despatchstate.dart';

class DispatchListBloc extends Bloc<DispatchListEvent, DispatchListState> {
  final DispatchProvider provider;

  DispatchListBloc(this.provider) : super(const DispatchListState()) {
    on<FetchDispatchList>(_onFetch);
    on<RefreshDispatchList>(_onRefresh);
    on<LoadMoreDispatchList>(_onLoadMore);
    on<SearchDispatchQueryChanged>(_onSearch);
  }

  Future<void> _onFetch(FetchDispatchList event, Emitter<DispatchListState> emit) async {
    emit(state.copyWith(status: DispatchListStatus.loading, clearError: true));
    await _load(emit);
  }

  Future<void> _onRefresh(RefreshDispatchList event, Emitter<DispatchListState> emit) async {
    emit(state.copyWith(status: DispatchListStatus.refreshing, clearError: true));
    await _load(emit);
  }

  /// Always loads page 1 and resets paging.
  Future<void> _load(Emitter<DispatchListState> emit) async {
    final result = await provider.getMyDispatches(page: 1);

    if (result.success) {
      emit(state.copyWith(
        status: DispatchListStatus.success,
        allDispatches: result.dispatches,
        filteredDispatches: _filter(result.dispatches, state.searchQuery),
        page: 1,
        hasMore: result.hasMore,
        isLoadingMore: false,
        clearError: true,
      ));
      return;
    }

    emit(state.copyWith(
      status: DispatchListStatus.failure,
      errorMessage: result.errorMessage,
      isLoadingMore: false,
    ));
  }

  Future<void> _onLoadMore(
      LoadMoreDispatchList event, Emitter<DispatchListState> emit) async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != DispatchListStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.page + 1;
    final result = await provider.getMyDispatches(page: nextPage);

    if (!result.success) {
      emit(state.copyWith(isLoadingMore: false));
      return;
    }

    // skip duplicates in case a record moved between pages
    final existingIds = state.allDispatches.map((d) => d.id).toSet();
    final merged = [
      ...state.allDispatches,
      ...result.dispatches.where((d) => !existingIds.contains(d.id)),
    ];

    emit(state.copyWith(
      allDispatches: merged,
      filteredDispatches: _filter(merged, state.searchQuery),
      page: nextPage,
      hasMore: result.hasMore,
      isLoadingMore: false,
    ));
  }

  void _onSearch(SearchDispatchQueryChanged event, Emitter<DispatchListState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      filteredDispatches: _filter(state.allDispatches, event.query),
    ));
  }

  List<DispatchListItem> _filter(List<DispatchListItem> list, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where((d) =>
    d.dsNumber.toLowerCase().contains(q) ||
        d.partyName.toLowerCase().contains(q) ||
        d.estimateNumber.toLowerCase().contains(q))
        .toList();
  }
}