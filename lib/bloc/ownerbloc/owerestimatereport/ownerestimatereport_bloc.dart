// // Adjust the provider import path below to match where owner_reports_provider.dart
// // actually lives in your project (this assumes lib/Apiprovider/).
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
//     if (result.isUnauthorized) {
//       emit(const EstimateReportUnauthorized());
//       return;
//     }
//
//     emit(EstimateReportError(result.errorMessage ?? 'Failed to load estimate report.'));
//   }
//
//   String _formatDate(DateTime date) {
//     final y = date.year.toString().padLeft(4, '0');
//     final m = date.month.toString().padLeft(2, '0');
//     final d = date.day.toString().padLeft(2, '0');
//     return '$y-$m-$d';
//   }
// }
// Adjust the provider import path below to match where owner_reports_provider.dart
// actually lives in your project (this assumes lib/Apiprovider/).

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import 'ownerestimatereport_event.dart';
import 'ownerestimatereport_state.dart';


class EstimateReportBloc extends Bloc<EstimateReportEvent, EstimateReportState> {
  EstimateReportBloc({OwnerReportsProvider? reportsProvider})
      : _reportsProvider = reportsProvider ?? OwnerReportsProvider(),
        super(const EstimateReportInitial()) {
    on<FetchEstimateReport>(_onFetchEstimateReport);
  }

  final OwnerReportsProvider _reportsProvider;

  Future<void> _onFetchEstimateReport(
      FetchEstimateReport event,
      Emitter<EstimateReportState> emit,
      ) async {
    emit(const EstimateReportLoading());

    final result = await _reportsProvider.getEstimateReport(
      type: event.type,
      personId: event.personId,
      fromDate: _formatDate(event.fromDate),
      toDate: _formatDate(event.toDate),
      status: event.status,
    );

    if (result.success && result.data != null) {
      emit(EstimateReportLoaded(
        data: result.data!,
        type: event.type,
        personName: event.personName,
        fromDate: event.fromDate,
        toDate: event.toDate,
        status: event.status,
      ));
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