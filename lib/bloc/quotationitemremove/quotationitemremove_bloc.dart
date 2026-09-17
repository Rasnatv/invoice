import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/quotationitemremove/quotationitemremove_event.dart';
import 'package:tileshop/bloc/quotationitemremove/quotationitemremove_state.dart';
import '../../Apiprovider/quotationproductitemremove_provider.dart';

class QuotationItemRemoveBloc
    extends Bloc<QuotationItemRemoveEvent, QuotationItemRemoveState> {
  final QuotationItemProvider _provider;

  QuotationItemRemoveBloc({QuotationItemProvider? provider})
      : _provider = provider ?? QuotationItemProvider(),
        super(const QuotationItemRemoveState()) {
    on<QuotationItemRemoveRequested>(_onRemoveRequested);
    on<QuotationItemRemoveResultConsumed>(_onResultConsumed);
  }

  Future<void> _onRemoveRequested(
      QuotationItemRemoveRequested event,
      Emitter<QuotationItemRemoveState> emit,
      ) async {
    emit(state.copyWith(
      status: QuotationItemRemoveStatus.inProgress,
      removedItemId: event.quotationItemId,
    ));

    final result = await _provider.removeItem(
      quotationId: event.quotationId,
      quotationItemId: event.quotationItemId,
    );

    if (result.success) {
      emit(state.copyWith(
        status: QuotationItemRemoveStatus.success,
        removedItemId: event.quotationItemId,
        message: result.message ?? 'Item removed successfully',
      ));
    } else {
      emit(state.copyWith(
        status: QuotationItemRemoveStatus.failure,
        removedItemId: event.quotationItemId,
        errorMessage: result.errorMessage ?? 'Failed to remove item',
      ));
    }
  }

  void _onResultConsumed(
      QuotationItemRemoveResultConsumed event,
      Emitter<QuotationItemRemoveState> emit,
      ) {
    emit(state.copyWith(status: QuotationItemRemoveStatus.initial));
  }
}