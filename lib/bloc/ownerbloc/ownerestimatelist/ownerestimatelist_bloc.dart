
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerestimateprovider.dart';
import '../../../models/salesmanmodels/salesmanownerestimatemodel.dart';
import 'ownerestimatelist_event.dart';
import 'ownerestimatelistevent_state.dart';

class OwnerEstimatesBloc
    extends Bloc<OwnerEstimatesEvent, OwnerEstimatesState> {
  final OwnerEstimateProvider _provider;

  static const int _pageSize = 10;

  OwnerEstimatesBloc({OwnerEstimateProvider? provider})
      : _provider = provider ?? OwnerEstimateProvider(),
        super(const OwnerEstimatesState()) {
    on<OwnerEstimatesLoadRequested>(_onLoadRequested);
    on<OwnerEstimatesRefreshRequested>(_onLoadRequested);
    on<OwnerEstimatesLoadMoreRequested>(_onLoadMore);
    on<OwnerEstimatesSearchQueryChanged>(_onSearchQueryChanged);
    on<OwnerEstimatesFilterChanged>(_onFilterChanged);
  }

  /// Initial load AND pull-to-refresh: always resets to page 1.
  Future<void> _onLoadRequested(
      OwnerEstimatesEvent event, Emitter<OwnerEstimatesState> emit) async {
    emit(state.copyWith(
      status: OwnerEstimatesStatus.loading,
      isLoadingMore: false,
      clearErrorMessage: true,
    ));

    // Without this try/catch, any exception thrown by the provider
    // would leave the state stuck on `loading` forever.
    try {
      final result =
      await _provider.getEstimates(page: 1, perPage: _pageSize);

      if (!result.success) {
        emit(state.copyWith(
          status: OwnerEstimatesStatus.failure,
          errorMessage: result.errorMessage ?? 'Failed to load estimates.',
          hasMore: false,
          isLoadingMore: false,
        ));
        return;
      }

      final filters = _buildFilters(result.estimates);
      final filtered =
      _applyFilters(result.estimates, state.activeFilter, state.query);

      emit(state.copyWith(
        status: OwnerEstimatesStatus.success,
        allEstimates: result.estimates,
        filters: filters,
        filteredEstimates: filtered,
        page: 1,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OwnerEstimatesStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
        hasMore: false,
        isLoadingMore: false,
      ));
    }
  }

  /// Fetch the next page and append it.
  Future<void> _onLoadMore(OwnerEstimatesLoadMoreRequested event,
      Emitter<OwnerEstimatesState> emit) async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status != OwnerEstimatesStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.page + 1;
      final result =
      await _provider.getEstimates(page: nextPage, perPage: _pageSize);

      // A refresh started while we were waiting: drop this stale result.
      if (state.status != OwnerEstimatesStatus.success) return;

      if (!result.success) {
        // Stop auto-loading so a failing request isn't retried in a loop.
        // Pull-to-refresh resets everything.
        emit(state.copyWith(isLoadingMore: false, hasMore: false));
        return;
      }

      // De-duplicate by id in case the list shifted between requests.
      final existingIds = state.allEstimates.map((e) => e.id).toSet();
      final fresh =
      result.estimates.where((e) => !existingIds.contains(e.id)).toList();
      final all = [...state.allEstimates, ...fresh];

      emit(state.copyWith(
        allEstimates: all,
        filters: _buildFilters(all),
        filteredEstimates:
        _applyFilters(all, state.activeFilter, state.query),
        page: nextPage,
        hasMore: result.hasMore && fresh.isNotEmpty,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  void _onSearchQueryChanged(OwnerEstimatesSearchQueryChanged event,
      Emitter<OwnerEstimatesState> emit) {
    final filtered =
    _applyFilters(state.allEstimates, state.activeFilter, event.query);
    emit(state.copyWith(query: event.query, filteredEstimates: filtered));
  }

  void _onFilterChanged(
      OwnerEstimatesFilterChanged event, Emitter<OwnerEstimatesState> emit) {
    final filtered =
    _applyFilters(state.allEstimates, event.filterKey, state.query);
    emit(state.copyWith(
        activeFilter: event.filterKey, filteredEstimates: filtered));
  }

  List<OwnerStatusFilterOption> _buildFilters(
      List<SalesmanowrEstimateModel> estimates) {
    final Map<String, int> counts = {};
    final Map<String, String> labels = {};

    for (final e in estimates) {
      final key = e.statusKey;
      counts[key] = (counts[key] ?? 0) + 1;
      labels[key] = e.statusLabel;
    }

    final options = <OwnerStatusFilterOption>[
      OwnerStatusFilterOption(
          key: 'all', label: 'All', count: estimates.length),
    ];

    final keys = counts.keys.toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    for (final key in keys) {
      options.add(OwnerStatusFilterOption(
        key: key,
        label: labels[key] ?? key,
        count: counts[key] ?? 0,
      ));
    }

    return options;
  }

  List<SalesmanowrEstimateModel> _applyFilters(
      List<SalesmanowrEstimateModel> source, String filterKey, String query) {
    Iterable<SalesmanowrEstimateModel> result = source;

    if (filterKey != 'all') {
      result = result.where((e) => e.statusKey == filterKey);
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((e) =>
      e.estimateNumber.toLowerCase().contains(q) ||
          e.customerName.toLowerCase().contains(q) ||
          e.customerPhone.toLowerCase().contains(q) ||
          e.contractorName.toLowerCase().contains(q) ||
          e.salesmanName.toLowerCase().contains(q));
    }

    return result.toList();
  }
}