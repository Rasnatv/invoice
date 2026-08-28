// Adjust the provider import path below to match where owner_reports_provider.dart
// actually lives in your project (this assumes lib/providers/).

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import 'owner_quoatationreport_event.dart';
import 'owner_quoatationreport_state.dart';


class QuotationReportBloc extends Bloc<QuotationReportEvent, QuotationReportState> {
  QuotationReportBloc({OwnerReportsProvider? reportsProvider})
      : _reportsProvider = reportsProvider ?? OwnerReportsProvider(),
        super(const QuotationReportInitial()) {
    on<FetchQuotationReport>(_onFetchQuotationReport);
  }

  final OwnerReportsProvider _reportsProvider;

  Future<void> _onFetchQuotationReport(
      FetchQuotationReport event,
      Emitter<QuotationReportState> emit,
      ) async {
    emit(const QuotationReportLoading());

    final result = await _reportsProvider.getQuotationReport(
      type: event.type,
      personId: event.personId,
      fromDate: _formatDate(event.fromDate),
      toDate: _formatDate(event.toDate),
      status: event.status,
    );

    if (result.success && result.data != null) {
      emit(QuotationReportLoaded(
        data: result.data!,
        type: event.type,
        personName: event.personName,
        fromDate: event.fromDate,
        toDate: event.toDate,
        status: event.status,
      ));
      return;
    }

    if (result.isUnauthorized) {
      emit(const QuotationReportUnauthorized());
      return;
    }

    emit(QuotationReportError(result.errorMessage ?? 'Failed to load quotation report.'));
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}