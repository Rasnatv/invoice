import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/ownerreportprovider.dart';
import '../../../models/owner_reportmodel/reportentrymodel.dart';
import 'ownerreport_event.dart';
import 'ownerreport_state.dart';

class OwnerReportsBloc extends Bloc<OwnerReportsEvent, OwnerReportsState> {
  OwnerReportsBloc({OwnerReportsProvider? provider})
      : _provider = provider ?? OwnerReportsProvider(),
        super(OwnerReportsState.initial()) {
    on<newLoadActiveSalesmen>(_onLoadActiveSalesmen);
    on<LoadActiveContractors>(_onLoadActiveContractors);
    on<LoadSalesmanReport>(_onLoadSalesmanReport);
    on<LoadContractorReport>(_onLoadContractorReport);
    on<LoadMoreSalesmanReport>(_onLoadMoreSalesmanReport);
    on<LoadMoreContractorReport>(_onLoadMoreContractorReport);
  }

  final OwnerReportsProvider _provider;

  /// Rows requested per page. Matches the provider's default for these
  /// two report endpoints.
  static const int _perPage = 15;

  // Filters of the report currently on screen, remembered so a load-more
  // can ask for the next page without the UI resending them.
  String? _salesmanId;
  String? _salesmanFrom;
  String? _salesmanTo;

  String? _contractorId;
  String? _contractorFrom;
  String? _contractorTo;

  // ------------------------------------------------------------------
  // Dropdown lists
  // ------------------------------------------------------------------

  Future<void> _onLoadActiveSalesmen(
      newLoadActiveSalesmen event,
      Emitter<OwnerReportsState> emit,
      ) async {
    emit(state.copyWith(
      activeSalesmenStatus: LoadStatus.loading,
      clearActiveSalesmenError: true,
    ));
    final result = await _provider.getActiveSalesmen();
    if (result.success) {
      emit(state.copyWith(
        activeSalesmenStatus: LoadStatus.success,
        activeSalesmen: result.salesmen,
      ));
    } else {
      emit(state.copyWith(
        activeSalesmenStatus: LoadStatus.failure,
        activeSalesmenError: result.errorMessage,
      ));
    }
  }

  Future<void> _onLoadActiveContractors(
      LoadActiveContractors event,
      Emitter<OwnerReportsState> emit,
      ) async {
    emit(state.copyWith(
      activeContractorsStatus: LoadStatus.loading,
      clearActiveContractorsError: true,
    ));
    final result = await _provider.getActiveContractors();
    if (result.success) {
      emit(state.copyWith(
        activeContractorsStatus: LoadStatus.success,
        activeContractors: result.contractors,
      ));
    } else {
      emit(state.copyWith(
        activeContractorsStatus: LoadStatus.failure,
        activeContractorsError: result.errorMessage,
      ));
    }
  }

  // ------------------------------------------------------------------
  // Salesman report
  // ------------------------------------------------------------------

  /// Page 1 — replaces everything on screen.
  Future<void> _onLoadSalesmanReport(
      LoadSalesmanReport event,
      Emitter<OwnerReportsState> emit,
      ) async {
    _salesmanId = event.salesmanId;
    _salesmanFrom = event.fromDate;
    _salesmanTo = event.toDate;

    emit(state.copyWith(
      salesmanReportStatus: LoadStatus.loading,
      clearSalesmanReportError: true,
    ));

    final result = await _provider.getSalesmanPerformanceReport(
      salesmanId: event.salesmanId,
      fromDate: event.fromDate,
      toDate: event.toDate,
      page: 1,
      perPage: _perPage,
    );

    if (result.success && result.report != null) {
      final report = result.report!;
      emit(state.copyWith(
        salesmanReportStatus: LoadStatus.success,
        salesmanReport: report, // summary / header come from page 1
        salesmanQuotations: report.quotations,
        salesmanEstimates: report.estimates,
        salesmanPage: 1,
        salesmanHasMore: _hasFullPage(report.quotations, report.estimates),
        salesmanLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(
        salesmanReportStatus: LoadStatus.failure,
        salesmanReportError: result.errorMessage,
      ));
    }
  }

  /// Page N+1 — appends to the quotation and estimate lists.
  Future<void> _onLoadMoreSalesmanReport(
      LoadMoreSalesmanReport event,
      Emitter<OwnerReportsState> emit,
      ) async {
    if (state.salesmanReportStatus != LoadStatus.success) return;
    if (!state.salesmanHasMore || state.salesmanLoadingMore) return;

    final id = _salesmanId;
    final from = _salesmanFrom;
    final to = _salesmanTo;
    if (id == null || from == null || to == null) return;

    emit(state.copyWith(salesmanLoadingMore: true));

    final nextPage = state.salesmanPage + 1;
    final result = await _provider.getSalesmanPerformanceReport(
      salesmanId: id,
      fromDate: from,
      toDate: to,
      page: nextPage,
      perPage: _perPage,
    );

    // A different report was loaded while this request was running:
    // drop the stale response.
    if (id != _salesmanId || from != _salesmanFrom || to != _salesmanTo) {
      return;
    }

    if (result.success && result.report != null) {
      final report = result.report!;
      final newQuotations =
      _freshOnly(state.salesmanQuotations, report.quotations);
      final newEstimates =
      _freshOnly(state.salesmanEstimates, report.estimates);

      emit(state.copyWith(
        salesmanQuotations: [...state.salesmanQuotations, ...newQuotations],
        salesmanEstimates: [...state.salesmanEstimates, ...newEstimates],
        salesmanPage: nextPage,
        // Stop when the page was short, or when the server sent nothing
        // new (e.g. it ignored `page` and repeated page 1).
        salesmanHasMore:
        _hasFullPage(report.quotations, report.estimates) &&
            (newQuotations.isNotEmpty || newEstimates.isNotEmpty),
        salesmanLoadingMore: false,
      ));
    } else {
      // Keep the list on screen; the next scroll retries this page.
      emit(state.copyWith(salesmanLoadingMore: false));
    }
  }

  // ------------------------------------------------------------------
  // Contractor report
  // ------------------------------------------------------------------

  /// Page 1 — replaces everything on screen.
  Future<void> _onLoadContractorReport(
      LoadContractorReport event,
      Emitter<OwnerReportsState> emit,
      ) async {
    _contractorId = event.contractorId;
    _contractorFrom = event.fromDate;
    _contractorTo = event.toDate;

    emit(state.copyWith(
      contractorReportStatus: LoadStatus.loading,
      clearContractorReportError: true,
    ));

    final result = await _provider.getContractorPerformanceReport(
      contractorId: event.contractorId,
      fromDate: event.fromDate,
      toDate: event.toDate,
      page: 1,
      perPage: _perPage,
    );

    if (result.success && result.report != null) {
      final report = result.report!;
      emit(state.copyWith(
        contractorReportStatus: LoadStatus.success,
        contractorReport: report, // summary / header come from page 1
        contractorQuotations: report.quotations,
        contractorEstimates: report.estimates,
        contractorPage: 1,
        contractorHasMore: _hasFullPage(report.quotations, report.estimates),
        contractorLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(
        contractorReportStatus: LoadStatus.failure,
        contractorReportError: result.errorMessage,
      ));
    }
  }

  /// Page N+1 — appends to the quotation and estimate lists.
  Future<void> _onLoadMoreContractorReport(
      LoadMoreContractorReport event,
      Emitter<OwnerReportsState> emit,
      ) async {
    if (state.contractorReportStatus != LoadStatus.success) return;
    if (!state.contractorHasMore || state.contractorLoadingMore) return;

    final id = _contractorId;
    final from = _contractorFrom;
    final to = _contractorTo;
    if (id == null || from == null || to == null) return;

    emit(state.copyWith(contractorLoadingMore: true));

    final nextPage = state.contractorPage + 1;
    final result = await _provider.getContractorPerformanceReport(
      contractorId: id,
      fromDate: from,
      toDate: to,
      page: nextPage,
      perPage: _perPage,
    );

    // A different report was loaded while this request was running:
    // drop the stale response.
    if (id != _contractorId || from != _contractorFrom || to != _contractorTo) {
      return;
    }

    if (result.success && result.report != null) {
      final report = result.report!;
      final newQuotations =
      _freshOnly(state.contractorQuotations, report.quotations);
      final newEstimates =
      _freshOnly(state.contractorEstimates, report.estimates);

      emit(state.copyWith(
        contractorQuotations: [...state.contractorQuotations, ...newQuotations],
        contractorEstimates: [...state.contractorEstimates, ...newEstimates],
        contractorPage: nextPage,
        contractorHasMore:
        _hasFullPage(report.quotations, report.estimates) &&
            (newQuotations.isNotEmpty || newEstimates.isNotEmpty),
        contractorLoadingMore: false,
      ));
    } else {
      // Keep the list on screen; the next scroll retries this page.
      emit(state.copyWith(contractorLoadingMore: false));
    }
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------

  /// Both lists share one `page` parameter, so more pages may exist as
  /// long as EITHER list came back full.
  bool _hasFullPage(
      List<ReportEntryModel> quotations,
      List<ReportEntryModel> estimates,
      ) =>
      quotations.length >= _perPage || estimates.length >= _perPage;

  /// Rows from [incoming] that are not already in [existing] (by id).
  List<ReportEntryModel> _freshOnly(
      List<ReportEntryModel> existing,
      List<ReportEntryModel> incoming,
      ) {
    final seen = existing.map((r) => r.id).toSet();
    return incoming.where((r) => !seen.contains(r.id)).toList();
  }
}