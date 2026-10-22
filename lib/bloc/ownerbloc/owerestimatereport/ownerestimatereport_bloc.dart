//
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../Apiprovider/ownerreportprovider.dart';
// import 'ownerestimatereport_event.dart';
// import 'ownerestimatereport_state.dart';
//
//
// class EstimateReportBloc extends Bloc<EstimateReportEvent, EstimateReportState> {
//   EstimateReportBloc({OwnerReportsProvider? reportsProvider})
//       : _reportsProvider = reportsProvider ?? OwnerReportsProvider(),
//         super(const EstimateReportInitial()) {
//     on<FetchEstimateReport>(_onFetchEstimateReport);
//   }
//
//   final OwnerReportsProvider _reportsProvider;
//
//   Future<void> _onFetchEstimateReport(
//       FetchEstimateReport event,
//       Emitter<EstimateReportState> emit,
//       ) async {
//     emit(const EstimateReportLoading());
//
//     final result = await _reportsProvider.getEstimateReport(
//       type: event.type,
//       personId: event.personId,
//       fromDate: _formatDate(event.fromDate),
//       toDate: _formatDate(event.toDate),
//       status: event.status,
//     );
//
//     if (result.success && result.data != null) {
//       emit(EstimateReportLoaded(
//         data: result.data!,
//         type: event.type,
//         personName: event.personName,
//         fromDate: event.fromDate,
//         toDate: event.toDate,
//         status: event.status,
//       ));
//       return;
//     }
//
//     emit(EstimateReportError(result.errorMessage));
//   }
//
//   String _formatDate(DateTime date) {
//     final y = date.year.toString().padLeft(4, '0');
//     final m = date.month.toString().padLeft(2, '0');
//     final d = date.day.toString().padLeft(2, '0');
//     return '$y-$m-$d';
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import '../../../models/owner_reportmodel/estimatereportmodel.dart';
import 'ownerestimatereport_event.dart';
import 'ownerestimatereport_state.dart';

class EstimateReportBloc
    extends Bloc<EstimateReportEvent, EstimateReportState> {
  EstimateReportBloc({OwnerReportsProvider? reportsProvider})
      : _reportsProvider = reportsProvider ?? OwnerReportsProvider(),
        super(const EstimateReportInitial()) {
    on<FetchEstimateReport>(_onFetchEstimateReport);
  }

  final OwnerReportsProvider _reportsProvider;
  static const int _perPage = 10;

  Future<void> _onFetchEstimateReport(
      FetchEstimateReport event,
      Emitter<EstimateReportState> emit,
      ) async {
    final current = state;
    final isLoadMore = event.page > 1 && current is EstimateReportLoaded;

    if (isLoadMore) {
      if (current.loadingMore || !current.hasMore) return;
      emit(current.copyWith(loadingMore: true)); // keep the list visible
    } else {
      emit(const EstimateReportLoading());
    }

    final result = await _reportsProvider.getEstimateReport(
      type: event.type,
      personId: event.personId,
      fromDate: _formatDate(event.fromDate),
      toDate: _formatDate(event.toDate),
      status: event.status,
      page: event.page,
      perPage: _perPage,
    );

    // A chip was tapped / refresh happened while this load-more was running:
    // drop the stale response.
    if (isLoadMore) {
      final now = state;
      if (now is! EstimateReportLoaded || now.status != event.status) return;
    }

    if (result.success && result.data != null) {
      final fresh = result.data!;

      final data = isLoadMore
          ? EstimateReportDataModel(
        summary: current.data.summary, // summary from page 1
        list: [...current.data.list, ...fresh.list],
      )
          : fresh;

      emit(EstimateReportLoaded(
        data: data,
        type: event.type,
        personName: event.personName,
        fromDate: event.fromDate,
        toDate: event.toDate,
        status: event.status,
        page: event.page,
        hasMore: fresh.list.length >= _perPage,
      ));
      return;
    }

    if (isLoadMore) {
      emit(current.copyWith(loadingMore: false)); // keep list, allow retry
      return;
    }
    emit(EstimateReportError(result.errorMessage));
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}