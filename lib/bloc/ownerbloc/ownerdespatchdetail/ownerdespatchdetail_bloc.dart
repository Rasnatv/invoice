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
        errorMessage: result.errorMessage ?? 'Failed to load dispatch bill.',
        isUnauthorized: result.isUnauthorized,
      ));
    }
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

    if (result.success && result.dispatch != null) {
      emit(state.copyWith(
        status: DispatchDetailStatus.success,
        dispatch: result.dispatch,
        actionStatus: DispatchActionStatus.success,
        actionMessage: 'Marked as in transit.',
        actionType: 'in_transit',
      ));
    } else {
      emit(state.copyWith(
        actionStatus: DispatchActionStatus.failure,
        actionMessage: result.errorMessage ?? 'Failed to mark as in transit.',
        isUnauthorized: result.isUnauthorized,
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

    if (result.success && result.dispatch != null) {
      emit(state.copyWith(
        status: DispatchDetailStatus.success,
        dispatch: result.dispatch,
        actionStatus: DispatchActionStatus.success,
        actionMessage: 'Marked as delivered.',
        actionType: 'delivered',
      ));
    } else {
      emit(state.copyWith(
        actionStatus: DispatchActionStatus.failure,
        actionMessage: result.errorMessage ?? 'Failed to mark as delivered.',
        isUnauthorized: result.isUnauthorized,
        actionType: 'delivered',
      ));
    }
  }
}