
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerdespatchprovider.dart';
import 'ownerdespatchdetail_event.dart';
import 'ownerdespatchdetail_state.dart';


class DispatchDetailBloc extends Bloc<DispatchDetailEvent, DispatchDetailState> {
  DispatchDetailBloc(this._provider) : super(const DispatchDetailState.initial()) {
    on<FetchDispatchDetail>((e, emit) => _fetch(e.id, emit));
    on<RefreshDispatchDetail>((e, emit) => _fetch(e.id, emit));
    on<MarkInTransitRequested>(_onMarkInTransit);
    on<MarkDeliveredRequested>(_onMarkDelivered);
    on<ClearDispatchActionStatus>((event, emit) {
      emit(state.copyWith(actionStatus: DispatchActionStatus.idle, clearActionMessage: true));
    });
  }

  final DispatchProvider _provider;

  Future<void> _fetch(String id, Emitter<DispatchDetailState> emit) async {
    emit(state.copyWith(status: DispatchDetailStatus.loading, clearErrorMessage: true));

    final result = await _provider.getDispatchDetail(id);

    if (result.success && result.dispatch != null) {
      emit(state.copyWith(status: DispatchDetailStatus.success, dispatch: result.dispatch));
    } else {
      emit(state.copyWith(
        status: DispatchDetailStatus.failure,
        errorMessage: result.errorMessage,
      ));
    }
  }

  /// Re-fetches the full dispatch detail after an action succeeds, WITHOUT
  /// touching actionStatus/actionMessage (those already carry the
  /// success/failure the UI needs to show for the action itself).
  ///
  /// This exists because the mark-in-transit / mark-delivered endpoints
  /// return a partial dispatch object (just enough to confirm the status
  /// change), not the full record with party details, items, etc. If we
  /// emit that partial object directly into `dispatch`, it overwrites the
  /// full data the detail screen needs — which is why the screen showed
  /// blank/dash fields and a stale "Pending delivery" banner right after
  /// marking in-transit, until a manual pull-to-refresh called the full
  /// getDispatchDetail endpoint and fixed it.
  Future<void> _refreshAfterAction(String id, Emitter<DispatchDetailState> emit) async {
    final result = await _provider.getDispatchDetail(id);
    if (result.success && result.dispatch != null) {
      emit(state.copyWith(dispatch: result.dispatch));
    }
    // If this refresh happens to fail, we deliberately don't overwrite
    // status/errorMessage here — the user already saw the action succeed,
    // and the existing (now slightly stale) dispatch stays on screen
    // instead of the page breaking. A subsequent manual refresh will
    // still correct it.
  }

  Future<void> _onMarkInTransit(
      MarkInTransitRequested event,
      Emitter<DispatchDetailState> emit,
      ) async {
    emit(state.copyWith(
      actionStatus: DispatchActionStatus.inProgress,
      clearActionMessage: true,
      actionType: 'in_transit',
    ));

    final result = await _provider.markInTransit(event.id);

    if (result.success) {
      emit(state.copyWith(
        actionStatus: DispatchActionStatus.success,
        actionMessage: 'Marked as in transit.',
        actionType: 'in_transit',
      ));
      await _refreshAfterAction(event.id, emit);
    } else {
      emit(state.copyWith(
        actionStatus: DispatchActionStatus.failure,
        actionMessage: result.errorMessage,
        actionType: 'in_transit',
      ));
    }
  }

  Future<void> _onMarkDelivered(
      MarkDeliveredRequested event,
      Emitter<DispatchDetailState> emit,
      ) async {
    emit(state.copyWith(
      actionStatus: DispatchActionStatus.inProgress,
      clearActionMessage: true,
      actionType: 'delivered',
    ));

    final result = await _provider.markDelivered(
      id: event.id,
      customerSignatureBase64: event.customerSignatureBase64,
      driverSignatureBase64: event.driverSignatureBase64,
    );

    if (result.success) {
      emit(state.copyWith(
        actionStatus: DispatchActionStatus.success,
        actionMessage: 'Marked as delivered.',
        actionType: 'delivered',
      ));
      await _refreshAfterAction(event.id, emit);
    } else {
      emit(state.copyWith(
        actionStatus: DispatchActionStatus.failure,
        actionMessage: result.errorMessage,
        actionType: 'delivered',
      ));
    }
  }
}