import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/owner_viewquotationprovider.dart';
import 'ownercancelquotation_event.dart';
import 'ownercancelquotation_state.dart';

class OwnerCancelQuotationBloc
    extends Bloc<OwnerCancelQuotationEvent, OwnerCancelQuotationState> {
  final OwnerviewQuotationProvider _provider;

  OwnerCancelQuotationBloc({OwnerviewQuotationProvider? provider})
      : _provider = provider ?? OwnerviewQuotationProvider(),
        super(const OwnerCancelQuotationState()) {
    on<OwnerCancelQuotationRequested>(_onCancelRequested);
    on<OwnerCancelQuotationResultConsumed>(_onResultConsumed);
  }

  // POST /quotations/cancel — body: { id }
  Future<void> _onCancelRequested(
      OwnerCancelQuotationRequested event,
      Emitter<OwnerCancelQuotationState> emit,
      ) async {
    emit(state.copyWith(status: OwnerCancelQuotationStatus.inProgress));

    final result = await _provider.cancelQuotation(event.id);

    if (result.success) {
      emit(state.copyWith(
        status: OwnerCancelQuotationStatus.success,
        message: result.message ?? 'Quotation cancelled successfully.',
      ));
    } else {
      emit(state.copyWith(
        status: OwnerCancelQuotationStatus.failure,
        errorMessage: result.errorMessage ?? 'Failed to cancel quotation.',
      ));
    }
  }

  void _onResultConsumed(
      OwnerCancelQuotationResultConsumed event,
      Emitter<OwnerCancelQuotationState> emit,
      ) {
    emit(state.copyWith(status: OwnerCancelQuotationStatus.initial));
  }
}