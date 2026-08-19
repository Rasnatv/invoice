import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerestimateprovider.dart';
import 'ownerviewestimatedetail_event.dart';
import 'ownerviewestimatedetail_state.dart';

class OwnerEstimateDetailBloc
    extends Bloc<OwnerEstimateDetailEvent, OwnerEstimateDetailState> {
  final OwnerEstimateProvider _provider;

  OwnerEstimateDetailBloc({OwnerEstimateProvider? provider})
      : _provider = provider ?? OwnerEstimateProvider(),
        super(const OwnerEstimateDetailState()) {
    on<OwnerEstimateDetailLoadRequested>(_onLoadRequested);
    on<OwnerEstimateApproveRequested>(_onApproveRequested);
    on<OwnerEstimateRejectRequested>(_onRejectRequested);
  }

  Future<void> _onLoadRequested(OwnerEstimateDetailLoadRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(status: OwnerEstimateDetailStatus.loading, errorMessage: null));
    final result = await _provider.getEstimateDetail(event.id);
    if (!result.success || result.detail == null) {
      emit(state.copyWith(
        status: OwnerEstimateDetailStatus.failure,
        errorMessage: result.errorMessage ?? 'Failed to load estimate.',
      ));
      return;
    }
    emit(state.copyWith(status: OwnerEstimateDetailStatus.success, detail: result.detail));
  }

  Future<void> _onApproveRequested(OwnerEstimateApproveRequested event,
      Emitter<OwnerEstimateDetailState> emit) async {
    emit(state.copyWith(
        actionStatus: OwnerEstimateActionStatus.inProgress, actionMessage: null));
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
        actionStatus: OwnerEstimateActionStatus.inProgress, actionMessage: null));
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
}