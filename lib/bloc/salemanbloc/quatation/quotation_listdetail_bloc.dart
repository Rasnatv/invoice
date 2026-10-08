
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import 'package:tileshop/bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../../Apiprovider/salesman_quotationprovider.dart';

class SalesmanQuotationBloc extends Bloc<SalesmanQuotationEvent, SalesmanQuotationState> {
  final QuotationProvider _provider;

  static const int _perPage = 15;

  /// Incremented on every fresh list load so a slow in-flight load-more
  /// can't append stale data after a refresh.
  int _listGeneration = 0;

  SalesmanQuotationBloc({QuotationProvider? provider})
      : _provider = provider ?? QuotationProvider(),
        super(const SalesmanQuotationState()) {
    on<QuotationListRequested>(_onListRequested);
    on<QuotationLoadMoreRequested>(_onLoadMore);
    on<QuotationDetailRequested>(_onDetailRequested);
    on<QuotationDetailCleared>(_onDetailCleared);
    on<QuotationDeleteRequested>(_onDeleteRequested);
    on<QuotationSubmitForApprovalRequested>(_onSubmitForApprovalRequested);
    on<QuotationUpdateSubmitted>(_onUpdateSubmitted);
    on<QuotationActionResultConsumed>(_onActionResultConsumed);
  }

  Future<void> _onListRequested(
      QuotationListRequested event, Emitter<SalesmanQuotationState> emit) async {
    final gen = ++_listGeneration;

    emit(state.copyWith(
      listStatus: QuotationLoadStatus.loading,
      listError: null,
      isLoadingMore: false,
      loadMoreFailed: false,
    ));

    final result = await _provider.getMyQuotations(page: 1, perPage: _perPage);
    if (gen != _listGeneration) return;

    if (result.success) {
      emit(state.copyWith(
        listStatus: QuotationLoadStatus.success,
        list: result.list,
        listPage: 1,
        listHasMore: result.list.length >= _perPage,
      ));
    } else {
      emit(state.copyWith(
        listStatus: QuotationLoadStatus.failure,
        listError: result.errorMessage,
      ));
    }
  }

  Future<void> _onLoadMore(
      QuotationLoadMoreRequested event, Emitter<SalesmanQuotationState> emit) async {
    if (state.listStatus != QuotationLoadStatus.success ||
        !state.listHasMore ||
        state.isLoadingMore) {
      return;
    }

    final gen = _listGeneration;
    final nextPage = state.listPage + 1;

    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));

    final result = await _provider.getMyQuotations(page: nextPage, perPage: _perPage);
    if (gen != _listGeneration) return; // a refresh happened meanwhile

    if (!result.success) {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
      return;
    }

    // De-duplicate in case the server list shifted between pages.
    final existingIds = state.list.map((q) => q.id).toSet();
    final fresh = result.list.where((q) => !existingIds.contains(q.id)).toList();

    emit(state.copyWith(
      list: [...state.list, ...fresh],
      listPage: nextPage,
      listHasMore: result.list.length >= _perPage,
      isLoadingMore: false,
    ));
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
        detailError: result.errorMessage,
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
        deleteError: result.message,
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
        submitMessage: result.message,
        list: updatedList,
        detail: updatedDetail,
        submittingId: null,
      ));
    } else {
      emit(state.copyWith(
        submitStatus: QuotationActionStatus.failure,
        submitError: result.message,
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
        submitMessage: result.message,
      ));
      add(QuotationDetailRequested(event.request.id));
    } else {
      emit(state.copyWith(
        submitStatus: QuotationActionStatus.failure,
        submitError: result.message,
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