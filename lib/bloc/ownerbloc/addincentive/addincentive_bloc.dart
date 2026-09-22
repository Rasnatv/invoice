
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';
import '../../../Apiprovider/salesmanincentivesetupprovider.dart';
import '../../../models/owner_models/owner_incentivesetupmodel.dart';
import 'addincentive_event.dart';
import 'addincentive_state.dart';

class SalesmanIncentiveBloc extends Bloc<SalesmanIncentiveEvent, SalesmanIncentiveState> {
  final SalesmanIncentiveSetupProvider _provider;
  final QuotationProvider _quotationProvider;

  SalesmanIncentiveBloc({
    SalesmanIncentiveSetupProvider? provider,
    QuotationProvider? quotationProvider,
  })  : _provider = provider ?? SalesmanIncentiveSetupProvider(),
        _quotationProvider = quotationProvider ?? QuotationProvider(),
        super(const SalesmanIncentiveState()) {
    on<LoadSalesmanIncentiveList>(_onLoadList);
    on<LoadSalesmanIncentiveSetup>(_onLoadSetup);
    on<SaveSalesmanIncentiveSetup>(_onSave);
    on<DeleteSalesmanIncentiveSetup>(_onDelete);
    on<ClearSalesmanIncentiveSetupDetail>(_onClearDetail);
  }

  /// Loads the dropdown list. Source of truth for WHO shows up is now
  /// GET /salesmen/active (QuotationProvider.getActiveSalesmen) so every
  /// active salesman appears, not just ones with an existing incentive
  /// record. We separately call the incentive-setup list endpoint to
  /// annotate each salesman with this month's hasSetup/displayText/
  /// monthYear, and merge the two by salesman id.
  Future<void> _onLoadList(
      LoadSalesmanIncentiveList event,
      Emitter<SalesmanIncentiveState> emit,
      ) async {
    emit(state.copyWith(listStatus: SalesmanIncentiveListStatus.loading));

    final results = await Future.wait([
      _quotationProvider.getActiveSalesmen(),
      _provider.getList(),
    ]);
    final activeResult = results[0] as SalesmanListResult;
    final statusResult = results[1] as dynamic; // SalesmanIncentiveListResult from _provider.getList()

    if (!activeResult.success) {
      emit(state.copyWith(
        listStatus: SalesmanIncentiveListStatus.failure,
        listError: activeResult.errorMessage,
      ));
      return;
    }

    // Index incentive-status rows by salesman id for O(1) lookup while
    // merging. If the status call failed, we still show the active
    // salesmen with "no setup yet" rather than blocking the whole screen.
    final statusById = <String, SalesmanIncentiveListItem>{
      if (statusResult.success)
        for (final item in statusResult.list) item.id: item,
    };

    final merged = <SalesmanIncentiveListItem>[
      for (final salesman in activeResult.list)
        statusById[salesman.id] ??
            SalesmanIncentiveListItem(
              id: salesman.id,
              name: salesman.name,
              hasSetup: false,
              displayText: '',
              monthYear: '',
            ),
    ];

    emit(state.copyWith(
      listStatus: SalesmanIncentiveListStatus.success,
      list: merged,
      clearListError: true,
    ));
  }

  Future<void> _onLoadSetup(
      LoadSalesmanIncentiveSetup event,
      Emitter<SalesmanIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      detailStatus: SalesmanIncentiveDetailStatus.loading,
      clearDetail: true,
    ));
    final result = await _provider.getSetup(SalesmanIncentiveSetupQueryRequest(
      salesmanId: event.salesmanId,
      year: event.year,
      month: event.month,
    ));
    if (result.success) {
      // result.detail == null just means nothing has been set up for this
      // period yet — the form should start blank, not show an error.
      emit(state.copyWith(
        detailStatus: SalesmanIncentiveDetailStatus.success,
        detail: result.detail,
        clearDetail: result.detail == null,
        clearDetailError: true,
      ));
    } else {
      emit(state.copyWith(
        detailStatus: SalesmanIncentiveDetailStatus.failure,
        detailError: result.errorMessage,
      ));
    }
  }

  Future<void> _onSave(
      SaveSalesmanIncentiveSetup event,
      Emitter<SalesmanIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      actionStatus: SalesmanIncentiveActionStatus.submitting,
      clearActionError: true,
      clearActionMessage: true,
    ));
    try {
      final result = await _provider.saveSetup(event.request);
      if (result.success) {
        emit(state.copyWith(
          actionStatus: SalesmanIncentiveActionStatus.success,
          actionMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          actionStatus: SalesmanIncentiveActionStatus.failure,
          actionError: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        actionStatus: SalesmanIncentiveActionStatus.failure,
        actionError: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onDelete(
      DeleteSalesmanIncentiveSetup event,
      Emitter<SalesmanIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      actionStatus: SalesmanIncentiveActionStatus.submitting,
      clearActionError: true,
      clearActionMessage: true,
    ));
    final result = await _provider.deleteSetup(event.request);
    if (result.success) {
      emit(state.copyWith(
        actionStatus: SalesmanIncentiveActionStatus.success,
        actionMessage: result.message,
        clearDetail: true,
        detailStatus: SalesmanIncentiveDetailStatus.success,
      ));
    } else {
      emit(state.copyWith(
        actionStatus: SalesmanIncentiveActionStatus.failure,
        actionError: result.message,
      ));
    }
  }

  void _onClearDetail(
      ClearSalesmanIncentiveSetupDetail event,
      Emitter<SalesmanIncentiveState> emit,
      ) {
    emit(state.copyWith(
      detailStatus: SalesmanIncentiveDetailStatus.initial,
      clearDetail: true,
      clearDetailError: true,
      actionStatus: SalesmanIncentiveActionStatus.initial,
      clearActionMessage: true,
      clearActionError: true,
    ));
  }
}