import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/ownerfieldsstaffincentiveprovider.dart';
import 'fieldstaffincentivedetail_event.dart';
import 'fieldstaffincentivedetail_state.dart';


class IncentiveDetailBloc extends Bloc<IncentiveDetailEvent, IncentiveDetailState> {
  final IncentiveProvider provider;
  final String incentiveId;

  IncentiveDetailBloc({required this.provider, required this.incentiveId})
      : super(IncentiveDetailState.initial()) {
    on<LoadIncentiveDetail>(_onLoad);
    on<MarkIncentivePaid>(_onMarkPaid);
    on<ClearIncentiveDetailFeedback>(_onClearFeedback);
  }

  Future<void> _onLoad(
      LoadIncentiveDetail event,
      Emitter<IncentiveDetailState> emit,
      ) async {
    emit(state.copyWith(status: IncentiveDetailStatus.loading));

    final result = await provider.getDetail(event.id);

    if (!result.success) {
      emit(state.copyWith(
        status: IncentiveDetailStatus.error,
        errorMessage: result.errorMessage ?? 'Could not load incentive',
      ));
      return;
    }

    emit(state.copyWith(
      status: IncentiveDetailStatus.loaded,
      incentive: result.incentive,
    ));
  }

  Future<void> _onMarkPaid(
      MarkIncentivePaid event,
      Emitter<IncentiveDetailState> emit,
      ) async {
    if (state.incentive == null) return;

    emit(state.copyWith(isSubmitting: true));

    final result = await provider.markPaid(
      id: state.incentive!.id,
      paymentReference: event.paymentReference,
      paymentDate: event.paymentDate,
      notes: event.notes,
    );

    if (!result.success) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: result.errorMessage ?? 'Could not mark incentive as paid',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: false,
      status: IncentiveDetailStatus.loaded,
      incentive: result.incentive,
      successMessage: 'Incentive marked as paid',
    ));
  }

  void _onClearFeedback(
      ClearIncentiveDetailFeedback event,
      Emitter<IncentiveDetailState> emit,
      ) {
    emit(state.copyWith(clearFeedback: true));
  }
}