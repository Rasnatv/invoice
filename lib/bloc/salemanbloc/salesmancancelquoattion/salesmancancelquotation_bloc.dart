import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/salesmancancelquoattion/salesmancancelquotation_event.dart';
import 'package:tileshop/bloc/salemanbloc/salesmancancelquoattion/salesmancancelquotation_state.dart';

import '../../../Apiprovider/salesman_quotationprovider.dart';



class SalesmanCancelQuotationBloc
    extends Bloc<SalesmanCancelQuotationEvent, SalesmanCancelQuotationState> {
  final QuotationProvider _provider;

  SalesmanCancelQuotationBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const SalesmanCancelQuotationState()) {
    on<SalesmanCancelQuotationRequested>(_onCancelRequested);
    on<SalesmanCancelQuotationResultConsumed>(_onResultConsumed);
  }

  // POST /quotations/cancel — body: { id }
  Future<void> _onCancelRequested(
      SalesmanCancelQuotationRequested event,
      Emitter<SalesmanCancelQuotationState> emit,
      ) async {
    emit(state.copyWith(status: SalesmanCancelQuotationStatus.inProgress));

    final result = await _provider.cancelQuotation(event.id);

    if (result.success) {
      emit(state.copyWith(
        status: SalesmanCancelQuotationStatus.success,
        message: result.message ?? 'Quotation cancelled successfully.',
      ));
    } else {
      emit(state.copyWith(
        status: SalesmanCancelQuotationStatus.failure,
        errorMessage: result.message ?? 'Failed to cancel quotation.',
      ));
    }
  }

  void _onResultConsumed(
      SalesmanCancelQuotationResultConsumed event,
      Emitter<SalesmanCancelQuotationState> emit,
      ) {
    emit(state.copyWith(status: SalesmanCancelQuotationStatus.initial));
  }
}