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

  Future<void> _load(Emitter<DispatchListState> emit) async {
    final result = await provider.getMyDispatches();

    if (result.success) {
      emit(state.copyWith(
        status: DispatchListStatus.success,
        allDispatches: result.dispatches,
        filteredDispatches: _filter(result.dispatches, state.searchQuery),
        clearError: true,
      ));
      return;
    }

    // On a real 401 with a valid token, ApiErrorHandler has already
    // cleared it and redirected to LoginScreen — this screen will be
    // popped shortly. If there was no token to clear, no redirect
    // happens, so we still show the message instead of a blank state.
    emit(state.copyWith(
      status: DispatchListStatus.failure,
      errorMessage: result.errorMessage,
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
