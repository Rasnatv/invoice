import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/approvedbills/salesman_approvedevent.dart';
import 'package:tileshop/bloc/salemanbloc/approvedbills/salesman_approvedsate.dart';
import '../../../Apiprovider/salesman_approvedestimateprovider.dart';

class ApprovedEstimatesBloc
    extends Bloc<ApprovedEstimatesEvent, ApprovedEstimatesState> {
  static const int _perPage = 10;

  final ApprovedEstimateProvider _provider;

  ApprovedEstimatesBloc({ApprovedEstimateProvider? provider})
      : _provider = provider ?? ApprovedEstimateProvider(),
        super(const ApprovedEstimatesState()) {
    on<ApprovedEstimatesRequested>(_onFetch);
    on<ApprovedEstimatesRefreshed>(_onFetch);
    on<ApprovedEstimatesLoadMore>(_onLoadMore);
    on<ApprovedEstimatesSearchChanged>(_onSearchChanged);
  }

  /// First page (initial load or pull-to-refresh) — replaces the list.
  Future<void> _onFetch(
      ApprovedEstimatesEvent event, Emitter<ApprovedEstimatesState> emit) async {
    final isRefresh = event is ApprovedEstimatesRefreshed;
    emit(state.copyWith(
      status: isRefresh
          ? ApprovedEstimatesStatus.refreshing
          : ApprovedEstimatesStatus.loading,
      loadMoreFailed: false,
    ));

    final result =
    await _provider.getMyApprovedEstimates(page: 1, perPage: _perPage);

    if (result.success) {
      emit(state.copyWith(
        status: ApprovedEstimatesStatus.success,
        list: result.list,
        page: 1,
        hasMore: result.list.length >= _perPage,
        loadMoreFailed: false,
      ));
    } else {
      emit(state.copyWith(
        status: ApprovedEstimatesStatus.failure,
        errorMessage:
        result.errorMessage ?? 'Failed to load approved estimates.',
      ));
    }
  }

  /// Next page — appends to the existing list.
  Future<void> _onLoadMore(ApprovedEstimatesLoadMore event,
      Emitter<ApprovedEstimatesState> emit) async {
    // Only load more when idle on a successful list that still has pages.
    if (state.status != ApprovedEstimatesStatus.success || !state.hasMore) {
      return;
    }

    emit(state.copyWith(
      status: ApprovedEstimatesStatus.loadingMore,
      loadMoreFailed: false,
    ));

    final nextPage = state.page + 1;
    final result =
    await _provider.getMyApprovedEstimates(page: nextPage, perPage: _perPage);

    // A refresh started while we were loading -> drop this stale response.
    if (state.status != ApprovedEstimatesStatus.loadingMore) return;

    if (result.success) {
      final existingIds = state.list.map((e) => e.id).toSet();
      final fresh =
      result.list.where((e) => !existingIds.contains(e.id)).toList();

      emit(state.copyWith(
        status: ApprovedEstimatesStatus.success,
        list: [...state.list, ...fresh],
        page: nextPage,
        // Stop if the page was short or brought nothing new (avoids endless loop).
        hasMore: result.list.length >= _perPage && fresh.isNotEmpty,
      ));
    } else {
      emit(state.copyWith(
        status: ApprovedEstimatesStatus.success,
        loadMoreFailed: true,
      ));
    }
  }

  void _onSearchChanged(ApprovedEstimatesSearchChanged event,
      Emitter<ApprovedEstimatesState> emit) {
    emit(state.copyWith(query: event.query));
  }
}