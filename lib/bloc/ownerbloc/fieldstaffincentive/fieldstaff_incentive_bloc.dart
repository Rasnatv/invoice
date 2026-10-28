// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
// import 'fieldstaff_incentive_event.dart';
// import 'fieldstaff_incentive_state.dart';
//
//
// class FieldStaffIncentiveBloc
//     extends Bloc<FieldStaffIncentiveEvent, FieldStaffIncentiveState> {
//   final IncentiveProvider provider;
//   static const int _perPage = 20;
//
//   FieldStaffIncentiveBloc({required this.provider})
//       : super(FieldStaffIncentiveState.initial()) {
//     on<LoadFieldStaffIncentives>(_onLoad);
//     on<RefreshFieldStaffIncentives>(_onRefresh);
//     on<FilterByFieldStaff>(_onFilterByFieldStaff);
//     on<FilterByStatus>(_onFilterByStatus);
//     on<FilterByDateRange>(_onFilterByDateRange);
//     on<LoadMoreIncentives>(_onLoadMore);
//     on<ClearIncentiveListFeedback>(_onClearFeedback);
//   }
//
//   Future<void> _onLoad(
//       LoadFieldStaffIncentives event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) async {
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loading,
//       dateFrom: event.dateFrom,
//       dateTo: event.dateTo,
//     ));
//
//     final results = await Future.wait([
//       provider.getSummary(
//         dateFrom: event.dateFrom,
//         dateTo: event.dateTo,
//         page: 1,
//         perPage: _perPage,
//       ),
//       provider.getActiveFieldStaff(),
//     ]);
//
//     final summaryResult = results[0] as IncentiveSummaryResult;
//     final staffResult = results[1] as ActiveFieldStaffResult;
//
//     if (!summaryResult.success) {
//       emit(state.copyWith(
//         status: FieldStaffIncentiveStatus.error,
//         errorMessage: summaryResult.errorMessage ?? 'Could not load incentives',
//       ));
//       return;
//     }
//
//     final data = summaryResult.data!;
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loaded,
//       summary: data.summary,
//       fieldStaffOptions: staffResult.success ? staffResult.list : state.fieldStaffOptions,
//       incentives: data.list,
//       page: 1,
//       hasMore: data.list.length >= _perPage,
//     ));
//   }
//
//   Future<void> _onRefresh(
//       RefreshFieldStaffIncentives event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) async {
//     final summaryResult = await provider.getSummary(
//       dateFrom: state.dateFrom,
//       dateTo: state.dateTo,
//       fieldStaffId: state.selectedFieldStaffId,
//       status: state.selectedStatus,
//       page: 1,
//       perPage: _perPage,
//     );
//
//     if (!summaryResult.success) {
//       emit(state.copyWith(errorMessage: summaryResult.errorMessage));
//       return;
//     }
//
//     final data = summaryResult.data!;
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loaded,
//       summary: data.summary,
//       incentives: data.list,
//       page: 1,
//       hasMore: data.list.length >= _perPage,
//     ));
//   }
//
//   Future<void> _onFilterByFieldStaff(
//       FilterByFieldStaff event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) async {
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loading,
//       selectedFieldStaffId: event.fieldStaffId,
//       clearSelectedFieldStaffId: event.fieldStaffId == null,
//     ));
//     await _reloadList(emit);
//   }
//
//   Future<void> _onFilterByStatus(
//       FilterByStatus event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) async {
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loading,
//       selectedStatus: event.status,
//     ));
//     await _reloadList(emit);
//   }
//
//   Future<void> _onFilterByDateRange(
//       FilterByDateRange event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) async {
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loading,
//       dateFrom: event.dateFrom,
//       dateTo: event.dateTo,
//     ));
//     await _reloadList(emit);
//   }
//
//   Future<void> _reloadList(Emitter<FieldStaffIncentiveState> emit) async {
//     final summaryResult = await provider.getSummary(
//       dateFrom: state.dateFrom,
//       dateTo: state.dateTo,
//       fieldStaffId: state.selectedFieldStaffId,
//       status: state.selectedStatus,
//       page: 1,
//       perPage: _perPage,
//     );
//
//     if (!summaryResult.success) {
//       emit(state.copyWith(
//         status: FieldStaffIncentiveStatus.error,
//         errorMessage: summaryResult.errorMessage,
//       ));
//       return;
//     }
//
//     final data = summaryResult.data!;
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loaded,
//       summary: data.summary,
//       incentives: data.list,
//       page: 1,
//       hasMore: data.list.length >= _perPage,
//     ));
//   }
//
//   Future<void> _onLoadMore(
//       LoadMoreIncentives event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) async {
//     if (!state.hasMore || state.status == FieldStaffIncentiveStatus.loadingMore) return;
//
//     emit(state.copyWith(status: FieldStaffIncentiveStatus.loadingMore));
//
//     final summaryResult = await provider.getSummary(
//       dateFrom: state.dateFrom,
//       dateTo: state.dateTo,
//       fieldStaffId: state.selectedFieldStaffId,
//       status: state.selectedStatus,
//       page: state.page + 1,
//       perPage: _perPage,
//     );
//
//     if (!summaryResult.success) {
//       emit(state.copyWith(
//         status: FieldStaffIncentiveStatus.loaded,
//         errorMessage: summaryResult.errorMessage,
//       ));
//       return;
//     }
//
//     final data = summaryResult.data!;
//     emit(state.copyWith(
//       status: FieldStaffIncentiveStatus.loaded,
//       incentives: [...state.incentives, ...data.list],
//       page: state.page + 1,
//       hasMore: data.list.length >= _perPage,
//     ));
//   }
//
//   void _onClearFeedback(
//       ClearIncentiveListFeedback event,
//       Emitter<FieldStaffIncentiveState> emit,
//       ) {
//     emit(state.copyWith(clearFeedback: true));
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
import 'fieldstaff_incentive_event.dart';
import 'fieldstaff_incentive_state.dart';

class FieldStaffIncentiveBloc
    extends Bloc<FieldStaffIncentiveEvent, FieldStaffIncentiveState> {
  final IncentiveProvider provider;

  // Items per page
  static const int _perPage = 10;

  FieldStaffIncentiveBloc({required this.provider})
      : super(FieldStaffIncentiveState.initial()) {
    on<LoadFieldStaffIncentives>(_onLoad);
    on<RefreshFieldStaffIncentives>(_onRefresh);
    on<FilterByFieldStaff>(_onFilterByFieldStaff);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<LoadMoreIncentives>(_onLoadMore);
    on<ClearIncentiveListFeedback>(_onClearFeedback);
  }

  Future<void> _onLoad(
      LoadFieldStaffIncentives event,
      Emitter<FieldStaffIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loading,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
    ));

    final results = await Future.wait([
      provider.getSummary(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        page: 1,
        perPage: _perPage,
      ),
      provider.getActiveFieldStaff(),
    ]);

    final summaryResult = results[0] as IncentiveSummaryResult;
    final staffResult = results[1] as ActiveFieldStaffResult;

    if (!summaryResult.success) {
      emit(state.copyWith(
        status: FieldStaffIncentiveStatus.error,
        errorMessage: summaryResult.errorMessage ?? 'Could not load incentives',
      ));
      return;
    }

    final data = summaryResult.data!;
    debugPrint('LOAD: got ${data.list.length}, perPage=$_perPage');

    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loaded,
      summary: data.summary,
      fieldStaffOptions:
      staffResult.success ? staffResult.list : state.fieldStaffOptions,
      incentives: data.list,
      page: 1,
      // FIX: a page smaller than perPage is the last page
      hasMore: data.list.length >= _perPage,
    ));
  }

  Future<void> _onRefresh(
      RefreshFieldStaffIncentives event,
      Emitter<FieldStaffIncentiveState> emit,
      ) async {
    await _reloadList(emit, showError: true);
  }

  Future<void> _onFilterByFieldStaff(
      FilterByFieldStaff event,
      Emitter<FieldStaffIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loading,
      selectedFieldStaffId: event.fieldStaffId,
      clearSelectedFieldStaffId: event.fieldStaffId == null,
    ));
    await _reloadList(emit);
  }

  Future<void> _onFilterByStatus(
      FilterByStatus event,
      Emitter<FieldStaffIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loading,
      selectedStatus: event.status,
    ));
    await _reloadList(emit);
  }

  Future<void> _onFilterByDateRange(
      FilterByDateRange event,
      Emitter<FieldStaffIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loading,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
    ));
    await _reloadList(emit);
  }

  Future<void> _reloadList(
      Emitter<FieldStaffIncentiveState> emit, {
        bool showError = false,
      }) async {
    final summaryResult = await provider.getSummary(
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
      fieldStaffId: state.selectedFieldStaffId,
      status: state.selectedStatus,
      page: 1,
      perPage: _perPage,
    );

    if (!summaryResult.success) {
      emit(state.copyWith(
        status: showError ? state.status : FieldStaffIncentiveStatus.error,
        errorMessage: summaryResult.errorMessage,
      ));
      return;
    }

    final data = summaryResult.data!;
    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loaded,
      summary: data.summary,
      incentives: data.list,
      page: 1,
      // FIX: a page smaller than perPage is the last page
      hasMore: data.list.length >= _perPage,
    ));
  }

  Future<void> _onLoadMore(
      LoadMoreIncentives event,
      Emitter<FieldStaffIncentiveState> emit,
      ) async {
    debugPrint(
        'LOADMORE: hasMore=${state.hasMore}, status=${state.status}, page=${state.page}');

    if (!state.hasMore ||
        state.status == FieldStaffIncentiveStatus.loadingMore ||
        state.status == FieldStaffIncentiveStatus.loading) {
      return;
    }

    emit(state.copyWith(status: FieldStaffIncentiveStatus.loadingMore));

    final nextPage = state.page + 1;
    final summaryResult = await provider.getSummary(
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
      fieldStaffId: state.selectedFieldStaffId,
      status: state.selectedStatus,
      page: nextPage,
      perPage: _perPage,
    );

    if (!summaryResult.success) {
      emit(state.copyWith(
        status: FieldStaffIncentiveStatus.loaded,
        errorMessage: summaryResult.errorMessage,
      ));
      return;
    }

    final data = summaryResult.data!;

    // Keep only records we don't already have (safety net if the backend
    // ignores `page` and returns the same rows).
    final existingIds = state.incentives.map((e) => e.id).toSet();
    final fresh =
    data.list.where((e) => !existingIds.contains(e.id)).toList();

    debugPrint(
        'LOADMORE: page=$nextPage got=${data.list.length} new=${fresh.length}');

    emit(state.copyWith(
      status: FieldStaffIncentiveStatus.loaded,
      incentives: [...state.incentives, ...fresh],
      page: nextPage,
      // FIX: more pages only if this page was full AND had new records
      hasMore: data.list.length >= _perPage && fresh.isNotEmpty,
    ));
  }

  void _onClearFeedback(
      ClearIncentiveListFeedback event,
      Emitter<FieldStaffIncentiveState> emit,
      ) {
    emit(state.copyWith(clearFeedback: true));
  }
}