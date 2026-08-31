import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/driverdespatchprovider.dart';
import 'driverdespatchdetail_event.dart';
import 'driverdespatchdetail_state.dart';

class DriverDespatchDetailBloc extends Bloc<DriverDespatchDetailEvent, DriverDespatchDetailState> {
  final DriverDespatchProvider _provider;

  DriverDespatchDetailBloc(this._provider) : super(const DriverDespatchDetailState()) {
    on<FetchDriverDespatchDetail>(_onFetch);
    on<RefreshDriverDespatchDetail>(_onFetch);
    on<MarkInTransitRequested>(_onMarkInTransit);
    on<MarkDeliveredRequested>(_onMarkDelivered);
    on<ClearDriverDespatchActionStatus>(_onClearActionStatus);
  }

  Future<void> _onFetch(
      DriverDespatchDetailEvent event,
      Emitter<DriverDespatchDetailState> emit,
      ) async {
    final id = event is FetchDriverDespatchDetail
        ? event.id
        : (event as RefreshDriverDespatchDetail).id;

    emit(state.copyWith(status: DriverDespatchDetailStatus.loading));
    final result = await _provider.getDetail(id);
    if (result.success) {
      emit(state.copyWith(
        status: DriverDespatchDetailStatus.success,
        dispatch: result.detail,
      ));
    } else {
      emit(state.copyWith(
        status: DriverDespatchDetailStatus.failure,
        errorMessage: result.errorMessage,
      ));
    }
  }

  /// Re-fetches the full despatch detail after an action succeeds, WITHOUT
  /// touching actionStatus/actionMessage (the caller already set those).
  ///
  /// The mark-in-transit / mark-delivered endpoints return a partial detail
  /// object (just enough to confirm the status change), not the full record
  /// with party/item details. Emitting that directly into `dispatch`
  /// overwrites the full data the screen needs -- same issue seen on the
  /// owner detail screen: correct snackbar, stale/blank fields underneath,
  /// only fixed by a manual pull-to-refresh.
  Future<void> _refreshAfterAction(String id, Emitter<DriverDespatchDetailState> emit) async {
    final result = await _provider.getDetail(id);
    if (result.success) {
      emit(state.copyWith(dispatch: result.detail));
    }
    // If this refresh call itself fails, we intentionally leave the
    // existing (now slightly stale) dispatch on screen rather than
    // breaking the page -- the user already saw the action succeed, and a
    // manual pull-to-refresh will still correct it.
  }

  Future<void> _onMarkInTransit(
      MarkInTransitRequested event,
      Emitter<DriverDespatchDetailState> emit,
      ) async {
    emit(state.copyWith(actionStatus: DriverDespatchActionStatus.inProgress));
    final result = await _provider.markInTransit(event.id);
    if (result.success) {
      emit(state.copyWith(
        actionStatus: DriverDespatchActionStatus.success,
        actionMessage: 'Marked as in transit',
      ));
      await _refreshAfterAction(event.id, emit);
    } else {
      emit(state.copyWith(
        actionStatus: DriverDespatchActionStatus.failure,
        actionMessage: result.errorMessage,
      ));
    }
  }

  Future<void> _onMarkDelivered(
      MarkDeliveredRequested event,
      Emitter<DriverDespatchDetailState> emit,
      ) async {
    emit(state.copyWith(actionStatus: DriverDespatchActionStatus.inProgress));
    final result = await _provider.markDelivered(
      id: event.id,
      customerSignatureBase64: event.customerSignatureBase64,
      driverSignatureBase64: event.driverSignatureBase64,
    );
    if (result.success) {
      emit(state.copyWith(
        actionStatus: DriverDespatchActionStatus.success,
        actionMessage: 'Marked as delivered',
      ));
      await _refreshAfterAction(event.id, emit);
    } else {
      emit(state.copyWith(
        actionStatus: DriverDespatchActionStatus.failure,
        actionMessage: result.errorMessage,
      ));
    }
  }

  void _onClearActionStatus(
      ClearDriverDespatchActionStatus event,
      Emitter<DriverDespatchDetailState> emit,
      ) {
    emit(state.copyWith(
      actionStatus: DriverDespatchActionStatus.idle,
      actionMessage: null,
    ));
  }
}
