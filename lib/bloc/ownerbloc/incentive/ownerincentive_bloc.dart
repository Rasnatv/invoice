import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/ownerincentiveprovider.dart';
import '../../../models/salesmanmodels/salesmanowner_incentivemodel.dart';
import 'ownerincentive_event.dart';
import 'ownerincentive_state.dart';


class OwnerIncentiveBloc extends Bloc<OwnerIncentiveEvent, OwnerIncentiveState> {
  final OwnerIncentiveProvider _provider;

  /// [isOwner] controls whether `salesman_id` is required/sent on every
  /// request. Pass `false` (and leave [initialSalesmanId] null) when a
  /// salesman is viewing their own incentives.
  OwnerIncentiveBloc({
    OwnerIncentiveProvider? provider,
    required bool isOwner,
    String? initialSalesmanId,
    String? initialSalesmanName,
  })  : _provider = provider ?? OwnerIncentiveProvider(),
        super(OwnerIncentiveState.initial(
        isOwner: isOwner,
        selectedSalesmanId: initialSalesmanId,
        selectedSalesmanName: initialSalesmanName,
      )) {
    on<LoadActiveSalesmen>(_onLoadActiveSalesmen);
    on<SelectSalesman>(_onSelectSalesman);
    on<SelectMonth>(_onSelectMonth);
    on<LoadIncentiveSummary>(_onLoadSummary);
    on<RefreshIncentiveSummary>(_onLoadSummary);
    on<MarkIncentiveAsPaid>(_onMarkPaid);
    on<ClearMarkPaidStatus>(_onClearMarkPaidStatus);
  }

  Future<void> _onLoadActiveSalesmen(
      LoadActiveSalesmen event,
      Emitter<OwnerIncentiveState> emit,
      ) async {
    emit(state.copyWith(loadingSalesmen: true, clearSalesmenErrorMessage: true));
    final result = await _provider.getActiveSalesmen();
    if (result.success) {
      emit(state.copyWith(loadingSalesmen: false, activeSalesmen: result.salesmen));
    } else {
      emit(state.copyWith(
        loadingSalesmen: false,
        salesmenErrorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  Future<void> _onSelectSalesman(
      SelectSalesman event,
      Emitter<OwnerIncentiveState> emit,
      ) async {
    emit(state.copyWith(
      selectedSalesmanId: event.salesmanId,
      selectedSalesmanName: event.salesmanName,
    ));
    add(const LoadIncentiveSummary());
  }

  Future<void> _onSelectMonth(
      SelectMonth event,
      Emitter<OwnerIncentiveState> emit,
      ) async {
    emit(state.copyWith(selectedMonth: event.month));
    add(const LoadIncentiveSummary());
  }

  Future<void> _onLoadSummary(
      OwnerIncentiveEvent event,
      Emitter<OwnerIncentiveState> emit,
      ) async {
    if (!state.canLoadSummary) return; // owner hasn't picked a salesman yet

    emit(state.copyWith(status: SalesmanIncentiveStatus.loading, clearErrorMessage: true));

    final request = SalesmanIncentiveSummaryRequest(
      salesmanId: state.isOwner ? int.tryParse(state.selectedSalesmanId ?? '') : null,
      year: state.selectedMonth.year,
      month: state.selectedMonth.month,
    );

    final result = await _provider.getSummary(request);

    if (result.success && result.data != null) {
      emit(state.copyWith(
        status: SalesmanIncentiveStatus.loaded,
        summary: result.data!.summary,
        productList: result.data!.productList,
      ));
    } else {
      emit(state.copyWith(
        status: SalesmanIncentiveStatus.error,
        errorMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  Future<void> _onMarkPaid(
      MarkIncentiveAsPaid event,
      Emitter<OwnerIncentiveState> emit,
      ) async {
    if (!state.canLoadSummary) return;

    emit(state.copyWith(markPaidStatus: MarkPaidStatus.submitting, clearMarkPaidMessage: true));

    final request = MarkIncentivePaidRequest(
      salesmanId: state.isOwner ? int.tryParse(state.selectedSalesmanId ?? '') : null,
      year: state.selectedMonth.year,
      month: state.selectedMonth.month,
      paymentReference: event.paymentReference,
      paymentDate: event.paymentDate,
      notes: event.notes,
    );

    final result = await _provider.markPaid(request);

    if (result.success) {
      emit(state.copyWith(
        markPaidStatus: MarkPaidStatus.success,
        markPaidMessage: result.message ?? 'Incentive marked as paid.',
      ));
      add(const RefreshIncentiveSummary());
    } else {
      emit(state.copyWith(
        markPaidStatus: MarkPaidStatus.error,
        markPaidMessage: result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  void _onClearMarkPaidStatus(
      ClearMarkPaidStatus event,
      Emitter<OwnerIncentiveState> emit,
      ) {
    emit(state.copyWith(markPaidStatus: MarkPaidStatus.idle, clearMarkPaidMessage: true));
  }
}