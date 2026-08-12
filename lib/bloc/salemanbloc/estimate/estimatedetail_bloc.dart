import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/salesman_estimatedetailprovider.dart';
import 'estimate_detail_event.dart';
import 'estimate_detail_state.dart';

class EstimateDetailBloc extends Bloc<EstimateDetailEvent, EstimateDetailState> {
  final EstimateProvider _provider;

  EstimateDetailBloc({EstimateProvider? provider})
      : _provider = provider ?? EstimateProvider(),
        super(const EstimateDetailState()) {
    on<EstimateDetailRequested>(_onDetailRequested);
    on<EstimateDetailCleared>(_onDetailCleared);
  }

  Future<void> _onDetailRequested(
      EstimateDetailRequested event, Emitter<EstimateDetailState> emit) async {
    emit(state.copyWith(status: EstimateDetailStatus.loading, clearError: true));
    final result = await _provider.getEstimateDetail(event.id);
    if (result.success) {
      emit(state.copyWith(status: EstimateDetailStatus.success, detail: result.detail));
    } else {
      emit(state.copyWith(
        status: EstimateDetailStatus.failure,
        error: result.errorMessage ?? 'Failed to load estimate.',
      ));
    }
  }

  void _onDetailCleared(EstimateDetailCleared event, Emitter<EstimateDetailState> emit) {
    emit(state.copyWith(
      status: EstimateDetailStatus.initial,
      clearDetail: true,
      clearError: true,
    ));
  }
}