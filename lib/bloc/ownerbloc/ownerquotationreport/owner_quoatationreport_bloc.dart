
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
import 'owner_quoatationreport_event.dart';
import 'owner_quoatationreport_state.dart';

class QuotationReportBloc
    extends Bloc<QuotationReportEvent, QuotationReportState> {
  QuotationReportBloc({OwnerReportsProvider? reportsProvider})
      : _reportsProvider = reportsProvider ?? OwnerReportsProvider(),
        super(const QuotationReportInitial()) {
    on<FetchQuotationReport>(_onFetchQuotationReport);
    on<LoadMoreQuotationReport>(_onLoadMore);
  }

  final OwnerReportsProvider _reportsProvider;

  /// Rows requested per page. Must match what the API honours.
  static const int _perPage = 10;

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
      page: 1,
      perPage: _perPage,
    );

    if (result.success && result.data != null) {
      final rows = result.data!.list;
      emit(QuotationReportLoaded(
        data: result.data!,
        rows: rows,
        type: event.type,
        personId: event.personId,
        personName: event.personName,
        fromDate: event.fromDate,
        toDate: event.toDate,
        status: event.status,
        page: 1,
        hasMore: rows.length >= _perPage,
      ));
      return;
    }

    emit(QuotationReportError(result.errorMessage));
  }

  Future<void> _onLoadMore(
      LoadMoreQuotationReport event,
      Emitter<QuotationReportState> emit,
      ) async {
    final current = state;
    if (current is! QuotationReportLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;
    final result = await _reportsProvider.getQuotationReport(
      type: current.type,
      personId: current.personId,
      fromDate: _formatDate(current.fromDate),
      toDate: _formatDate(current.toDate),
      status: current.status,
      page: nextPage,
      perPage: _perPage,
    );

    if (result.success && result.data != null) {
      final newRows = result.data!.list;

      // Guard against the server repeating rows (e.g. when it ignores
      // `page`), so the list can never duplicate or loop forever.
      final existing = current.rows.map((r) => r.quotationNumber).toSet();
      final fresh =
      newRows.where((r) => !existing.contains(r.quotationNumber)).toList();

      emit(current.copyWith(
        rows: [...current.rows, ...fresh],
        page: nextPage,
        hasMore: fresh.isNotEmpty && newRows.length >= _perPage,
        isLoadingMore: false,
      ));
    } else {
      // Keep what we have; the next scroll will retry this page.
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}