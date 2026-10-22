//
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
//         detailError: result.errorMessage,
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
//         approveMessage: result.message,
//       ));
//       // Re-fetch so the screen reflects the now-approved status/totals.
//       add(OwnerQuotationDetailRequested(event.request.id));
//     } else {
//       emit(state.copyWith(
//         approveStatus: OwnerQuotationApproveStatus.failure,
//         approveError: result.message,
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
    on<OwnerQuotationRejectRequested>(_onRejectRequested);
    on<OwnerQuotationCancelRequested>(_onCancelRequested);
    on<OwnerQuotationActionResultConsumed>(_onActionResultConsumed);
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
      actionStatus: OwnerQuotationActionStatus.idle,
      actionType: OwnerQuotationActionType.none,
      actionError: null,
      actionMessage: null,
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

  // ---------------- reject (owner only) ----------------
  Future<void> _onRejectRequested(
      OwnerQuotationRejectRequested event,
      Emitter<OwnerQuotationDetailState> emit,
      ) async {
    emit(state.copyWith(
      actionStatus: OwnerQuotationActionStatus.inProgress,
      actionType: OwnerQuotationActionType.reject,
      actionError: null,
      actionMessage: null,
    ));
    final result = await _provider.rejectQuotation(
      id: event.id,
      rejectionNotes: event.rejectionNotes,
    );
    if (result.success) {
      emit(state.copyWith(
        actionStatus: OwnerQuotationActionStatus.success,
        actionMessage: result.message,
      ));
      add(OwnerQuotationDetailRequested(event.id));
    } else {
      emit(state.copyWith(
        actionStatus: OwnerQuotationActionStatus.failure,
        actionError: result.message,
      ));
    }
  }

  // ---------------- cancel ----------------
  Future<void> _onCancelRequested(
      OwnerQuotationCancelRequested event,
      Emitter<OwnerQuotationDetailState> emit,
      ) async {
    emit(state.copyWith(
      actionStatus: OwnerQuotationActionStatus.inProgress,
      actionType: OwnerQuotationActionType.cancel,
      actionError: null,
      actionMessage: null,
    ));
    final result = await _provider.cancelQuotation(event.id);
    if (result.success) {
      emit(state.copyWith(
        actionStatus: OwnerQuotationActionStatus.success,
        actionMessage: result.message,
      ));
      add(OwnerQuotationDetailRequested(event.id));
    } else {
      emit(state.copyWith(
        actionStatus: OwnerQuotationActionStatus.failure,
        actionError: result.message,
      ));
    }
  }

  void _onActionResultConsumed(
      OwnerQuotationActionResultConsumed event,
      Emitter<OwnerQuotationDetailState> emit,
      ) {
    emit(state.copyWith(
      actionStatus: OwnerQuotationActionStatus.idle,
      actionType: OwnerQuotationActionType.none,
      actionError: null,
      actionMessage: null,
    ));
  }
}