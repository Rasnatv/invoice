import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Apiprovider/ownerdespatchprovider.dart';

import 'ownerdespatchdetail_event.dart';
import 'ownerdespatchdetail_state.dart';

class DispatchDetailBloc extends Bloc<DispatchDetailEvent, DispatchDetailState> {
  final DispatchProvider provider;

  DispatchDetailBloc(this.provider) : super(const DispatchDetailState()) {
    on<FetchDispatchDetail>(_onFetch);
    on<MarkInTransitRequested>(_onMarkInTransit);
    on<MarkDeliveredRequested>(_onMarkDelivered);
  }

  Future<void> _onFetch(FetchDispatchDetail event, Emitter<DispatchDetailState> emit) async {
    emit(state.copyWith(status: DispatchDetailStatus.loading, clearError: true));
    final result = await provider.getDispatchDetail(event.dispatchId);

    if (result.success) {
      emit(state.copyWith(status: DispatchDetailStatus.loaded, dispatch: result.dispatch, clearError: true));
      return;
    }
    emit(state.copyWith(
      status: DispatchDetailStatus.failure,
      errorMessage: result.errorMessage,
    ));
  }

  Future<void> _onMarkInTransit(MarkInTransitRequested event, Emitter<DispatchDetailState> emit) async {
    emit(state.copyWith(
      status: DispatchDetailStatus.actionInProgress,
      actionInProgressType: 'transit',
      clearError: true,
    ));
    final result = await provider.markInTransit(event.dispatchId);

    if (result.success) {
      emit(state.copyWith(
        status: DispatchDetailStatus.loaded,
        dispatch: result.dispatch,
        clearAction: true,
        clearError: true,
      ));
      return;
    }
    // Keep showing the previously loaded dispatch, surface the error via listener.
    emit(state.copyWith(
      status: DispatchDetailStatus.loaded,
      errorMessage: result.errorMessage,
      clearAction: true,
    ));
  }

  Future<void> _onMarkDelivered(MarkDeliveredRequested event, Emitter<DispatchDetailState> emit) async {
    emit(state.copyWith(
      status: DispatchDetailStatus.actionInProgress,
      actionInProgressType: 'delivered',
      clearError: true,
    ));
    final result = await provider.markDelivered(
      id: event.dispatchId,
      customerSignatureBase64: event.customerSignatureBase64,
      driverSignatureBase64: event.driverSignatureBase64,
    );

    if (result.success) {
      emit(state.copyWith(
        status: DispatchDetailStatus.loaded,
        dispatch: result.dispatch,
        clearAction: true,
        clearError: true,
      ));
      return;
    }
    emit(state.copyWith(
      status: DispatchDetailStatus.loaded,
      errorMessage: result.errorMessage,
      clearAction: true,
    ));
  }
}
