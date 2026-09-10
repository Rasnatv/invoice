import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/fieldstaffviewincentiveprovider.dart';
import '../../../models/fieldstaffmodels/fieldstaffincentiveviewingmodel.dart';
import 'fieldstaffview_incentive_event.dart';
import 'fieldstaffview_incentive_state.dart';

class FieldStaffIncentivesListBloc
    extends Bloc<FieldStaffIncentivesListEvent, FieldStaffIncentivesListState> {
  final FieldStaffIncentivesProvider _provider;

  FieldStaffIncentivesListBloc({FieldStaffIncentivesProvider? provider})
      : _provider = provider ?? FieldStaffIncentivesProvider(),
        super(const FieldStaffIncentivesListState()) {
    on<FetchFieldStaffIncentivesEvent>(_onFetch);
    on<RefreshFieldStaffIncentivesEvent>(_onRefresh);
    on<FetchMoreFieldStaffIncentivesEvent>(_onFetchMore);
    on<SelectFieldStaffIncentiveStatusEvent>(_onSelectStatus);
  }

  Future<void> _onFetch(
      FetchFieldStaffIncentivesEvent event,
      Emitter<FieldStaffIncentivesListState> emit,
      ) async {
    emit(state.copyWith(
      status: FieldStaffIncentivesListStatus.loading,
      list: [],
      page: 1,
      hasReachedMax: false,
      filters: event.filters,
      errorMessage: null,
    ));

    final result = await _provider.getIncentives(
      page: 1,
      perPage: state.perPage,
      filters: event.filters,
    );

    if (result.success && result.response != null) {
      final incoming = result.response!.list;
      emit(state.copyWith(
        status: FieldStaffIncentivesListStatus.loaded,
        list: incoming,
        page: 1,
        hasReachedMax: incoming.length < state.perPage,
        statusOptions: _mergeStatusOptions(state.statusOptions, incoming),
      ));
    } else {
      emit(state.copyWith(
        status: FieldStaffIncentivesListStatus.error,
        errorMessage: result.errorMessage ?? 'Something went wrong',
      ));
    }
  }

  Future<void> _onRefresh(
      RefreshFieldStaffIncentivesEvent event,
      Emitter<FieldStaffIncentivesListState> emit,
      ) =>
      _onFetch(FetchFieldStaffIncentivesEvent(filters: state.filters), emit);

  Future<void> _onFetchMore(
      FetchMoreFieldStaffIncentivesEvent event,
      Emitter<FieldStaffIncentivesListState> emit,
      ) async {
    if (state.hasReachedMax ||
        state.status == FieldStaffIncentivesListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: FieldStaffIncentivesListStatus.loadingMore));

    final nextPage = state.page + 1;
    final result = await _provider.getIncentives(
      page: nextPage,
      perPage: state.perPage,
      filters: state.filters,
    );

    if (result.success && result.response != null) {
      final incoming = result.response!.list;
      emit(state.copyWith(
        status: FieldStaffIncentivesListStatus.loaded,
        list: [...state.list, ...incoming],
        page: nextPage,
        hasReachedMax: incoming.length < state.perPage,
        statusOptions: _mergeStatusOptions(state.statusOptions, incoming),
      ));
    } else {
      emit(state.copyWith(
        status: FieldStaffIncentivesListStatus.loaded,
        errorMessage: result.errorMessage ?? 'Could not load more',
      ));
    }
  }

  /// Tapping a chip re-fetches page 1 with (or without) a status filter,
  /// while keeping every status option discovered so far so the chip row
  /// doesn't lose entries just because the current filter narrows the list.
  Future<void> _onSelectStatus(
      SelectFieldStaffIncentiveStatusEvent event,
      Emitter<FieldStaffIncentivesListState> emit,
      ) async {
    if (event.status == state.selectedStatus) return;

    final newFilters = Map<String, dynamic>.from(state.filters);
    if (event.status == kAllStatusFilter) {
      newFilters.remove('status');
    } else {
      newFilters['status'] = event.status;
    }

    emit(state.copyWith(selectedStatus: event.status));
    await _onFetch(FetchFieldStaffIncentivesEvent(filters: newFilters), emit);
  }

  /// Builds the union of previously-seen statuses and any new ones found
  /// in [incoming], preserving first-seen order. Prefers statusLabel
  /// (display text) but falls back to status (raw key).
  List<String> _mergeStatusOptions(
      List<String> existing,
      List<FieldStaffIncentive> incoming,
      ) {
    final seen = {...existing};
    final merged = [...existing];
    for (final item in incoming) {
      final label = item.statusLabel.isNotEmpty ? item.statusLabel : item.status;
      if (label.isNotEmpty && !seen.contains(label)) {
        seen.add(label);
        merged.add(label);
      }
    }
    return merged;
  }
}