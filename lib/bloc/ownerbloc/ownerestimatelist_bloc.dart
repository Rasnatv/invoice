import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/ownerestimateprovider.dart';
import '../../models/salesmanmodels/salesmanownerestimatemodel.dart';
import 'ownerestimatelist_event.dart';
import 'ownerestimatelistevent_state.dart';

class OwnerEstimatesBloc extends Bloc<OwnerEstimatesEvent, OwnerEstimatesState> {
  final OwnerEstimateProvider _provider;

  OwnerEstimatesBloc({OwnerEstimateProvider? provider})
      : _provider = provider ?? OwnerEstimateProvider(),
        super(const OwnerEstimatesState()) {
    on<OwnerEstimatesLoadRequested>(_onLoadRequested);
    on<OwnerEstimatesRefreshRequested>(_onLoadRequested);
    on<OwnerEstimatesSearchQueryChanged>(_onSearchQueryChanged);
    on<OwnerEstimatesFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
      OwnerEstimatesEvent event, Emitter<OwnerEstimatesState> emit) async {
    emit(state.copyWith(status: OwnerEstimatesStatus.loading, errorMessage: null));

    final result = await _provider.getEstimates();

    if (!result.success) {
      emit(state.copyWith(
        status: OwnerEstimatesStatus.failure,
        errorMessage: result.errorMessage ?? 'Failed to load estimates.',
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
    ));
  }

  void _onSearchQueryChanged(
      OwnerEstimatesSearchQueryChanged event, Emitter<OwnerEstimatesState> emit) {
    final filtered =
    _applyFilters(state.allEstimates, state.activeFilter, event.query);
    emit(state.copyWith(query: event.query, filteredEstimates: filtered));
  }

  void _onFilterChanged(
      OwnerEstimatesFilterChanged event, Emitter<OwnerEstimatesState> emit) {
    final filtered =
    _applyFilters(state.allEstimates, event.filterKey, state.query);
    emit(state.copyWith(activeFilter: event.filterKey, filteredEstimates: filtered));
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
      OwnerStatusFilterOption(key: 'all', label: 'All', count: estimates.length),
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