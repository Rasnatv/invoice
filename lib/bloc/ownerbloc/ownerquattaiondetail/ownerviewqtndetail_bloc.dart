// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../Apiprovider/salesman_quotationprovider.dart';
// import 'ownerviewqtndetail_event.dart';
// import 'ownerviewqtndetail_state.dart';
//
// class OwnerQuotationDetailBloc
//     extends Bloc<OwnerQuotationDetailEvent, OwnerQuotationDetailState> {
//   final QuotationProvider _provider;
//
//   OwnerQuotationDetailBloc({QuotationProvider? provider})
//       : _provider = provider ?? QuotationProvider(),
//         super(const OwnerQuotationDetailState()) {
//     on<OwnerQuotationDetailRequested>(_onDetailRequested);
//     on<OwnerQuotationDetailCleared>(_onDetailCleared);
//     on<OwnerQuotationApproveRequested>(_onApproveRequested);
//     on<OwnerQuotationApproveResultConsumed>(_onApproveResultConsumed);
//   }
//
//   Future<void> _onDetailRequested(
//       OwnerQuotationDetailRequested event,
//       Emitter<OwnerQuotationDetailState> emit,
//       ) async {
//     emit(state.copyWith(
//       detailStatus: OwnerQuotationDetailStatus.loading,
//       detailError: null,
//     ));
//     final result = await _provider.getQuotationDetail(event.id);
//     if (result.success) {
//       emit(state.copyWith(
//         detailStatus: OwnerQuotationDetailStatus.success,
//         detail: result.detail,
//       ));
//     } else {
//       emit(state.copyWith(
//         detailStatus: OwnerQuotationDetailStatus.failure,
//         detailError: result.errorMessage ?? 'Failed to load quotation.',
//       ));
//     }
//   }
//
//   void _onDetailCleared(
//       OwnerQuotationDetailCleared event,
//       Emitter<OwnerQuotationDetailState> emit,
//       ) {
//     emit(state.copyWith(
//       detailStatus: OwnerQuotationDetailStatus.initial,
//       detail: null,
//       detailError: null,
//       approveStatus: OwnerQuotationApproveStatus.idle,
//       approveError: null,
//       approveMessage: null,
//     ));
//   }
//
//   Future<void> _onApproveRequested(
//       OwnerQuotationApproveRequested event,
//       Emitter<OwnerQuotationDetailState> emit,
//       ) async {
//     emit(state.copyWith(
//       approveStatus: OwnerQuotationApproveStatus.inProgress,
//       approveError: null,
//       approveMessage: null,
//     ));
//     final result = await _provider.approveQuotation(event.request);
//     if (result.success) {
//       emit(state.copyWith(
//         approveStatus: OwnerQuotationApproveStatus.success,
//         approveMessage: result.message ?? 'Quotation approved successfully.',
//       ));
//       // Re-fetch so the screen reflects the now-approved status/totals.
//       add(OwnerQuotationDetailRequested(event.request.id));
//     } else {
//       emit(state.copyWith(
//         approveStatus: OwnerQuotationApproveStatus.failure,
//         approveError: result.errorMessage ?? 'Failed to approve quotation.',
//       ));
//     }
//   }
//
//   void _onApproveResultConsumed(
//       OwnerQuotationApproveResultConsumed event,
//       Emitter<OwnerQuotationDetailState> emit,
//       ) {
//     emit(state.copyWith(
//       approveStatus: OwnerQuotationApproveStatus.idle,
//       approveError: null,
//       approveMessage: null,
//     ));
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';
import 'ownerviewqtndetail_event.dart';
import 'ownerviewqtndetail_state.dart';

class OwnerQuotationDetailBloc
    extends Bloc<OwnerQuotationDetailEvent, OwnerQuotationDetailState> {
  final QuotationProvider _provider;

  OwnerQuotationDetailBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const OwnerQuotationDetailState()) {
    on<OwnerQuotationDetailRequested>(_onDetailRequested);
    on<OwnerQuotationDetailCleared>(_onDetailCleared);
    on<OwnerQuotationApproveRequested>(_onApproveRequested);
    on<OwnerQuotationApproveResultConsumed>(_onApproveResultConsumed);
  }

  Future<void> _onDetailRequested(
      OwnerQuotationDetailRequested event,
      Emitter<OwnerQuotationDetailState> emit,
      ) async {
    emit(state.copyWith(
      detailStatus: OwnerQuotationDetailStatus.loading,
      detailError: null,
    ));
    final result = await _provider.getQuotationDetail(event.id);
    if (result.success) {
      emit(state.copyWith(
        detailStatus: OwnerQuotationDetailStatus.success,
        detail: result.detail,
      ));
    } else {
      emit(state.copyWith(
        detailStatus: OwnerQuotationDetailStatus.failure,
        detailError: result.errorMessage,
      ));
    }
  }

  void _onDetailCleared(
      OwnerQuotationDetailCleared event,
      Emitter<OwnerQuotationDetailState> emit,
      ) {
    emit(state.copyWith(
      detailStatus: OwnerQuotationDetailStatus.initial,
      detail: null,
      detailError: null,
      approveStatus: OwnerQuotationApproveStatus.idle,
      approveError: null,
      approveMessage: null,
    ));
  }

  Future<void> _onApproveRequested(
      OwnerQuotationApproveRequested event,
      Emitter<OwnerQuotationDetailState> emit,
      ) async {
    emit(state.copyWith(
      approveStatus: OwnerQuotationApproveStatus.inProgress,
      approveError: null,
      approveMessage: null,
    ));
    final result = await _provider.approveQuotation(event.request);
    if (result.success) {
      emit(state.copyWith(
        approveStatus: OwnerQuotationApproveStatus.success,
        approveMessage: result.message,
      ));
      // Re-fetch so the screen reflects the now-approved status/totals.
      add(OwnerQuotationDetailRequested(event.request.id));
    } else {
      emit(state.copyWith(
        approveStatus: OwnerQuotationApproveStatus.failure,
        approveError: result.message,
      ));
    }
  }

  void _onApproveResultConsumed(
      OwnerQuotationApproveResultConsumed event,
      Emitter<OwnerQuotationDetailState> emit,
      ) {
    emit(state.copyWith(
      approveStatus: OwnerQuotationApproveStatus.idle,
      approveError: null,
      approveMessage: null,
    ));
  }
}