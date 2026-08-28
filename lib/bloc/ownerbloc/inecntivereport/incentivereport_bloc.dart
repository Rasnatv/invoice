import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerreportprovider.dart';

import 'incentivereport_event.dart';
import 'incentivereport_state.dart';

class IncentiveReportBloc
    extends Bloc<IncentiveReportEvent, IncentiveReportState> {
  final OwnerReportsProvider _provider;

  // Remembers the last-used filters so LoadMoreIncentiveReport can ask for
  // the next page without the UI having to resend them.
  String? _type;
  String? _personId;
  String? _fromDate;
  String? _toDate;
  String? _status;
  int _perPage = 10;

  IncentiveReportBloc({OwnerReportsProvider? provider})
      : _provider = provider ?? OwnerReportsProvider(),
        super(const IncentiveReportInitial()) {
    on<FetchIncentiveReport>(_onFetch);
    on<LoadMoreIncentiveReport>(_onLoadMore);
    on<ResetIncentiveReport>(
            (event, emit) => emit(const IncentiveReportInitial()));
  }

  Future<void> _onFetch(
      FetchIncentiveReport event,
      Emitter<IncentiveReportState> emit,
      ) async {
    _type = event.type;
    _personId = event.personId;
    _fromDate = event.fromDate;
    _toDate = event.toDate;
    _status = event.status;
    _perPage = event.perPage;

    emit(const IncentiveReportLoading(isFirstLoad: true));

    final result = await _provider.getIncentiveReport(
      type: event.type,
      personId: event.personId,
      fromDate: event.fromDate,
      toDate: event.toDate,
      status: event.status,
      page: event.page,
      perPage: event.perPage,
    );

    if (result.success && result.data != null) {
      final data = result.data!;
      emit(IncentiveReportLoaded(
        summary: data.summary,
        items: data.list,
        currentPage: event.page,
        hasReachedMax: data.list.length < event.perPage,
      ));
    } else {
      emit(IncentiveReportError(
        result.errorMessage ?? 'Failed to load incentive report.',
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreIncentiveReport event,
      Emitter<IncentiveReportState> emit,
      ) async {
    final current = state;
    if (current is! IncentiveReportLoaded) return;
    if (current.hasReachedMax || current.isLoadingMore) return;
    if (_type == null ||
        _personId == null ||
        _fromDate == null ||
        _toDate == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _provider.getIncentiveReport(
      type: _type!,
      personId: _personId!,
      fromDate: _fromDate!,
      toDate: _toDate!,
      status: _status,
      page: nextPage,
      perPage: _perPage,
    );

    if (result.success && result.data != null) {
      final data = result.data!;
      emit(current.copyWith(
        summary: data.summary,
        items: [...current.items, ...data.list],
        currentPage: nextPage,
        hasReachedMax: data.list.length < _perPage,
        isLoadingMore: false,
      ));
    } else {
      // Keep the existing list on screen; just drop the loading-more spinner.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}