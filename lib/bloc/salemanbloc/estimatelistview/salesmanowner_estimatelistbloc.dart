
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistevent.dart';
import 'package:tileshop/bloc/salemanbloc/estimatelistview/salesmanownerestimatestate.dart';
import '../../../Apiprovider/salesman_ownerestimatelistprovider.dart';
import '../../../models/salesmanmodels/salesmanownerestimatemodel.dart';

class EstimatesBloc
    extends Bloc<SalesmanowrEstimatesEvent, SalesmanownerEstimatesState> {
  final SalesmanOwnerEstimateProvider _provider;

  static const int _perPage = 10;

  /// Incremented on every (re)load so a slow in-flight load-more can't
  /// append stale data after a refresh.
  int _generation = 0;

  EstimatesBloc({SalesmanOwnerEstimateProvider? provider})
      : _provider = provider ?? SalesmanOwnerEstimateProvider(),
        super(const SalesmanownerEstimatesState()) {
    on<EstimatesLoadRequested>(_onLoadRequested);
    on<EstimatesRefreshRequested>(_onLoadRequested);
    on<EstimatesLoadMoreRequested>(_onLoadMore);
    on<EstimatesSearchQueryChanged>(_onSearchQueryChanged);
    on<EstimatesFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
      SalesmanowrEstimatesEvent event,
      Emitter<SalesmanownerEstimatesState> emit,
      ) async {
    final gen = ++_generation;

    emit(state.copyWith(
      status: EstimatesStatus.loading,
      errorMessage: null,
      isLoadingMore: false,
      loadMoreFailed: false,
    ));

    final result = await _provider.getEstimates(page: 1, perPage: _perPage);
    if (gen != _generation) return;

    if (!result.success) {
      emit(state.copyWith(
        status: EstimatesStatus.failure,
        errorMessage: result.errorMessage ?? 'Failed to load estimates.',
      ));
      return;
    }

    emit(state.copyWith(
      status: EstimatesStatus.success,
      allEstimates: result.estimates,
      filters: _buildFilters(result.estimates),
      filteredEstimates:
      _applyFilters(result.estimates, state.activeFilter, state.query),
      page: 1,
      hasMore: result.estimates.length >= _perPage,
    ));
  }

  Future<void> _onLoadMore(
      EstimatesLoadMoreRequested event,
      Emitter<SalesmanownerEstimatesState> emit,
      ) async {
    if (state.status != EstimatesStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }

    final gen = _generation;
    final nextPage = state.page + 1;

    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));

    final result =
    await _provider.getEstimates(page: nextPage, perPage: _perPage);
    if (gen != _generation) return; // a refresh happened meanwhile

    if (!result.success) {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
      return;
    }

    // De-duplicate in case the server list shifted between pages.
    final existingIds = state.allEstimates.map((e) => e.id).toSet();
    final fresh =
    result.estimates.where((e) => !existingIds.contains(e.id)).toList();
    final all = [...state.allEstimates, ...fresh];

    emit(state.copyWith(
      allEstimates: all,
      filters: _buildFilters(all),
      filteredEstimates: _applyFilters(all, state.activeFilter, state.query),
      page: nextPage,
      hasMore: result.estimates.length >= _perPage,
      isLoadingMore: false,
    ));
  }

  void _onSearchQueryChanged(
      EstimatesSearchQueryChanged event,
      Emitter<SalesmanownerEstimatesState> emit,
      ) {
    final filtered =
    _applyFilters(state.allEstimates, state.activeFilter, event.query);
    emit(state.copyWith(query: event.query, filteredEstimates: filtered));
  }

  void _onFilterChanged(
      EstimatesFilterChanged event,
      Emitter<SalesmanownerEstimatesState> emit,
      ) {
    final filtered =
    _applyFilters(state.allEstimates, event.filterKey, state.query);
    emit(state.copyWith(
        activeFilter: event.filterKey, filteredEstimates: filtered));
  }

  List<StatusFilterOption> _buildFilters(
      List<SalesmanowrEstimateModel> estimates) {
    final Map<String, int> counts = {};
    final Map<String, String> labels = {};

    for (final e in estimates) {
      final key = e.statusKey;
      counts[key] = (counts[key] ?? 0) + 1;
      labels[key] = e.statusLabel;
    }

    final options = <StatusFilterOption>[
      StatusFilterOption(key: 'all', label: 'All', count: estimates.length),
    ];

    // Most common status first.
    final keys = counts.keys.toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    for (final key in keys) {
      options.add(StatusFilterOption(
          key: key, label: labels[key] ?? key, count: counts[key] ?? 0));
    }

    return options;
  }

  List<SalesmanowrEstimateModel> _applyFilters(
      List<SalesmanowrEstimateModel> source,
      String filterKey,
      String query,
      ) {
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
          e.contractorName.toLowerCase().contains(q));
    }

    return result.toList();
  }
}