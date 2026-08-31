import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/salesmanincentivesetupprovider.dart';
import '../../../models/owner_models/owner_incentivesetupmodel.dart';
import 'addincentive_event.dart';
import 'addincentive_state.dart';


class SalesmanIncentiveBloc extends Bloc<SalesmanIncentiveEvent, SalesmanIncentiveState> {
  final SalesmanIncentiveSetupProvider _provider;

  SalesmanIncentiveBloc({SalesmanIncentiveSetupProvider? provider})
      : _provider = provider ?? SalesmanIncentiveSetupProvider(),
        super(const SalesmanIncentiveState()) {
    on<LoadSalesmanIncentiveList>(_onLoadList);
    on<LoadSalesmanIncentiveSetup>(_onLoadSetup);
    on<SaveSalesmanIncentiveSetup>(_onSave);
    on<DeleteSalesmanIncentiveSetup>(_onDelete);
    on<ClearSalesmanIncentiveSetupDetail>(_onClearDetail);
  }

  Future<void> _onLoadList(
      LoadSalesmanIncentiveList event,
      Emitter<SalesmanIncentiveState> emit,
      ) async {
    emit(state.copyWith(listStatus: SalesmanIncentiveListStatus.loading, isUnauthorized: false));
    final result = await _provider.getList();
    if (result.success) {
      emit(state.copyWith(
        listStatus: SalesmanIncentiveListStatus.success,
        list: result.list,
        clearListError: true,
      ));
    } else {
      emit(state.copyWith(
        listStatus: SalesmanIncentiveListStatus.failure,
        listError: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  Future<void> _onLoadSetup(
      LoadSalesmanIncentiveSetup event,
      Emitter<SalesmanIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      detailStatus: SalesmanIncentiveDetailStatus.loading,
      clearDetail: true,
      isUnauthorized: false,
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
        isUnauthorized: result.isUnauthorized,
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
      isUnauthorized: false,
    ));
    final result = await _provider.saveSetup(event.request);
    if (result.success) {
      emit(state.copyWith(
        actionStatus: SalesmanIncentiveActionStatus.success,
        actionMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        actionStatus: SalesmanIncentiveActionStatus.failure,
        actionError: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
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
      isUnauthorized: false,
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
        actionError: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
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