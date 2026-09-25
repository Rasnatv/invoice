
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/estimateitemremoveprovider.dart';
import '../../../Apiprovider/ownerestimateprovider.dart';
import 'ownerviewestimatedetail_event.dart';
import 'ownerviewestimatedetail_state.dart';

class OwnerEstimateDetailBloc
    extends Bloc<OwnerEstimateDetailEvent, OwnerEstimateDetailState> {
  final OwnerEstimateProvider _provider;
  final EstimateItemProvider _itemProvider;

  OwnerEstimateDetailBloc({
    OwnerEstimateProvider? provider,
    EstimateItemProvider? itemProvider,
  })  : _provider = provider ?? OwnerEstimateProvider(),
        _itemProvider = itemProvider ?? EstimateItemProvider(),
        super(const OwnerEstimateDetailState()) {
    on<OwnerEstimateDetailLoadRequested>(_onLoadRequested);
    on<OwnerEstimateApproveRequested>(_onApproveRequested);
    on<OwnerEstimateRejectRequested>(_onRejectRequested);
    on<OwnerEstimateUpdateRequested>(_onUpdateRequested);
    on<OwnerEstimateItemRemoveRequested>(_onItemRemoveRequested);
    on<OwnerEstimateItemUpdateRequested>(_onItemUpdateRequested);
  }

  Future<void> _onLoadRequested(OwnerEstimateDetailLoadRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
      status: OwnerEstimateDetailStatus.loading,
      errorMessage: null,
      actionStatus: OwnerEstimateActionStatus.idle,
    ));
    final result = await _provider.getEstimateDetail(event.id);
    if (!result.success || result.detail == null) {
      emit(state.copyWith(
        status: OwnerEstimateDetailStatus.failure,
        errorMessage: result.errorMessage,
      ));
      return;
    }
    emit(state.copyWith(
      status: OwnerEstimateDetailStatus.success,
      detail: result.detail,
      actionStatus: OwnerEstimateActionStatus.idle,
    ));
  }

  Future<void> _onApproveRequested(OwnerEstimateApproveRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.inProgress,
        actionMessage: null));
    final result = await _provider.approveEstimate(event.request);
    if (!result.success) {
      emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.failure,
        actionMessage: result.message,
      ));
      return;
    }
    emit(state.copyWith(
      actionStatus: OwnerEstimateActionStatus.success,
      actionMessage: result.message,
    ));
    add(OwnerEstimateDetailLoadRequested(event.request.estimateId));
  }

  Future<void> _onRejectRequested(OwnerEstimateRejectRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.inProgress,
        actionMessage: null));
    final result = await _provider.rejectEstimate(event.request);
    if (!result.success) {
      emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.failure,
        actionMessage: result.message,
      ));
      return;
    }
    emit(state.copyWith(
      actionStatus: OwnerEstimateActionStatus.success,
      actionMessage: result.message,
    ));
    add(OwnerEstimateDetailLoadRequested(event.request.id));
  }

  Future<void> _onUpdateRequested(OwnerEstimateUpdateRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.inProgress,
        actionMessage: null));
    final result = await _provider.updateEstimate(event.request);
    if (!result.success) {
      emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.failure,
        actionMessage: result.errorMessage,
      ));
      return;
    }
    emit(state.copyWith(
      status: OwnerEstimateDetailStatus.success,
      detail: result.detail ?? state.detail,
      actionStatus: OwnerEstimateActionStatus.success,
      actionMessage: null,
    ));
    if (result.detail == null) {
      add(OwnerEstimateDetailLoadRequested(event.request.id));
    }
  }

  /// POST /estimates/remove-item, via the separate EstimateItemProvider
  /// (not OwnerEstimateProvider). Reports through
  /// `itemRemoveStatus`/`itemRemoveMessage` (kept separate from
  /// `actionStatus`) so the screen can spin just the affected row instead
  /// of disabling the whole Save Changes button. On success,
  /// `removedEstimateItemId` tells the listener which row to drop.
  Future<void> _onItemRemoveRequested(OwnerEstimateItemRemoveRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
      itemRemoveStatus: OwnerEstimateActionStatus.inProgress,
      itemRemoveMessage: null,
      removedEstimateItemId: null,
    ));
    final result = await _itemProvider.removeItem(
      estimateId: event.estimateId,
      estimateItemId: event.estimateItemId,
    );
    if (!result.success) {
      emit(state.copyWith(
        itemRemoveStatus: OwnerEstimateActionStatus.failure,
        itemRemoveMessage: result.errorMessage,
      ));
      return;
    }
    emit(state.copyWith(
      itemRemoveStatus: OwnerEstimateActionStatus.success,
      itemRemoveMessage: result.message,
      removedEstimateItemId: event.estimateItemId,
    ));
  }

  /// POST /estimates/update-item, via EstimateItemProvider.updateItem().
  /// Mirrors _onItemRemoveRequested: reports through
  /// `itemUpdateStatus`/`itemUpdateMessage` (kept separate from both
  /// `actionStatus` and `itemRemoveStatus`) so the screen can spin just
  /// the affected row. On success, `updatedEstimateItemId` tells the
  /// listener which row's server call succeeded.
  Future<void> _onItemUpdateRequested(OwnerEstimateItemUpdateRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
      itemUpdateStatus: OwnerEstimateActionStatus.inProgress,
      itemUpdateMessage: null,
      updatedEstimateItemId: null,
    ));
    final result = await _provider.updateItem(
      estimateId: event.estimateId,
      estimateItemId: event.estimateItemId,
      quantity: event.quantity,
      rate: event.rate,
      boxQuantity: event.boxQuantity,
      pieceQuantity: event.pieceQuantity,
    );
    if (!result.success) {
      emit(state.copyWith(
        itemUpdateStatus: OwnerEstimateActionStatus.failure,
        itemUpdateMessage: result.message,
      ));
      return;
    }
    emit(state.copyWith(
      itemUpdateStatus: OwnerEstimateActionStatus.success,
      itemUpdateMessage: result.message,
      updatedEstimateItemId: event.estimateItemId,
    ));
  }
}