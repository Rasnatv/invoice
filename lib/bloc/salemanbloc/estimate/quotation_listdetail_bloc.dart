
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/estimate/qtn_listdetail_event.dart';
import 'package:tileshop/bloc/salemanbloc/estimate/qtn_listdetail_state.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';


class SalesmanQuotationBloc extends Bloc<SalesmanQuotationEvent, SalesmanQuotationState> {
  final QuotationProvider _provider;

  SalesmanQuotationBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const SalesmanQuotationState()) {
    on<QuotationListRequested>(_onListRequested);
    on<QuotationDetailRequested>(_onDetailRequested);
    on<QuotationDetailCleared>(_onDetailCleared);
    on<QuotationDeleteRequested>(_onDeleteRequested);
    on<QuotationSubmitForApprovalRequested>(_onSubmitForApprovalRequested);
    on<QuotationUpdateSubmitted>(_onUpdateSubmitted);
    on<QuotationActionResultConsumed>(_onActionResultConsumed);
  }

  Future<void> _onListRequested(
      QuotationListRequested event, Emitter<SalesmanQuotationState> emit) async {
    emit(state.copyWith(listStatus: QuotationLoadStatus.loading, listError: null));
    final result = await _provider.getMyQuotations();
    if (result.success) {
      emit(state.copyWith(listStatus: QuotationLoadStatus.success, list: result.list));
    } else {
      emit(state.copyWith(
        listStatus: QuotationLoadStatus.failure,
        listError: result.errorMessage ?? 'Failed to load quotations.',
      ));
    }
  }

  Future<void> _onDetailRequested(
      QuotationDetailRequested event, Emitter<SalesmanQuotationState> emit) async {
    emit(state.copyWith(detailStatus: QuotationLoadStatus.loading, detailError: null));
    final result = await _provider.getQuotationDetail(event.id);
    if (result.success) {
      emit(state.copyWith(detailStatus: QuotationLoadStatus.success, detail: result.detail));
    } else {
      emit(state.copyWith(
        detailStatus: QuotationLoadStatus.failure,
        detailError: result.errorMessage ?? 'Failed to load quotation.',
      ));
    }
  }

  void _onDetailCleared(QuotationDetailCleared event, Emitter<SalesmanQuotationState> emit) {
    emit(state.copyWith(
      detailStatus: QuotationLoadStatus.initial,
      detail: null,
      detailError: null,
    ));
  }

  Future<void> _onDeleteRequested(
      QuotationDeleteRequested event, Emitter<SalesmanQuotationState> emit) async {
    emit(state.copyWith(
      deleteStatus: QuotationActionStatus.inProgress,
      deletingId: event.id,
      deleteError: null,
    ));
    final result = await _provider.deleteQuotation(event.id);
    if (result.success) {
      final updatedList = state.list.where((q) => q.id != event.id).toList();
      emit(state.copyWith(
        deleteStatus: QuotationActionStatus.success,
        list: updatedList,
        deletingId: null,
      ));
    } else {
      emit(state.copyWith(
        deleteStatus: QuotationActionStatus.failure,
        deleteError: result.errorMessage ?? 'Failed to delete quotation.',
        deletingId: null,
      ));
    }
  }

  Future<void> _onSubmitForApprovalRequested(
      QuotationSubmitForApprovalRequested event, Emitter<SalesmanQuotationState> emit) async {
    emit(state.copyWith(
      submitStatus: QuotationActionStatus.inProgress,
      submittingId: event.id,
      submitError: null,
      submitMessage: null,
    ));
    final result = await _provider.submitQuotationForApproval(event.id);
    if (result.success) {
      // Reflect the new status locally right away so the list/detail don't
      // keep showing a stale "draft" chip until the next full refresh.
      final updatedList = state.list
          .map((q) => q.id == event.id ? q.copyWith(status: 'sent') : q)
          .toList();
      final updatedDetail =
      state.detail?.id == event.id ? state.detail!.copyWith(status: 'sent') : state.detail;
      emit(state.copyWith(
        submitStatus: QuotationActionStatus.success,
        submitMessage: result.message ?? 'Submitted for approval successfully.',
        list: updatedList,
        detail: updatedDetail,
        submittingId: null,
      ));
    } else {
      emit(state.copyWith(
        submitStatus: QuotationActionStatus.failure,
        submitError: result.errorMessage ?? 'Failed to submit for approval.',
        submittingId: null,
      ));
    }
  }

  Future<void> _onUpdateSubmitted(
      QuotationUpdateSubmitted event, Emitter<SalesmanQuotationState> emit) async {
    emit(state.copyWith(
      submitStatus: QuotationActionStatus.inProgress,
      submitError: null,
      submitMessage: null,
    ));
    final result = await _provider.updateQuotation(event.request);
    if (result.success) {
      emit(state.copyWith(
        submitStatus: QuotationActionStatus.success,
        submitMessage: result.message ?? 'Quotation updated successfully.',
      ));
      add(QuotationDetailRequested(event.request.id));
    } else {
      emit(state.copyWith(
        submitStatus: QuotationActionStatus.failure,
        submitError: result.errorMessage ?? 'Failed to update quotation.',
      ));
    }
  }

  void _onActionResultConsumed(
      QuotationActionResultConsumed event, Emitter<SalesmanQuotationState> emit) {
    emit(state.copyWith(
      deleteStatus: QuotationActionStatus.idle,
      deleteError: null,
      submitStatus: QuotationActionStatus.idle,
      submitError: null,
      submitMessage: null,
    ));
  }
}