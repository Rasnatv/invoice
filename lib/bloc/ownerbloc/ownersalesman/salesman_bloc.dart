import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/salesmanprovider.dart';
import '../../../models/owner_models/salesmanmodel.dart';
import 'salesman_event.dart';
import 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  final SalesmanProvider provider;

  List<HSalesmanModel> _cachedSalesmen = [];

  SalesmanBloc({required this.provider}) : super(SalesmanInitial()) {
    on<FetchSalesmen>(_onFetchSalesmen);
    on<AddSalesman>(_onAddSalesman);
    on<UpdateSalesman>(_onUpdateSalesman);
    on<DeleteSalesman>(_onDeleteSalesman);
  }

  Future<void> _onFetchSalesmen(
      FetchSalesmen event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanLoading());
    final result = await provider.getSalesmen();
    if (result.success) {
      _cachedSalesmen = result.salesmen;
      emit(SalesmanLoaded(_cachedSalesmen));
    } else {
      emit(SalesmanError(result.errorMessage ?? 'Failed to fetch salesmen'));
    }
  }

  /// Create returns no salesman object back (empty data), so re-fetch the
  /// full list afterward instead of merging a partial/fabricated record.
  Future<void> _onAddSalesman(
      AddSalesman event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanActionLoading());
    final result = await provider.addSalesman(
      SalesmanAddRequestModel(
        name: event.name,
        email: event.email,
        designationId: event.designationId,
        mobile: event.mobile,
        salary: event.salary,
        joiningDate: event.joiningDate,
        password: event.password,
      ),
    );
    if (result.success) {
      final refreshed = await provider.getSalesmen();
      if (refreshed.success) _cachedSalesmen = refreshed.salesmen;
      emit(SalesmanActionSuccess(
        message: result.message ?? 'Salesman added successfully',
        salesmen: _cachedSalesmen,
      ));
      emit(SalesmanLoaded(_cachedSalesmen));
    } else {
      emit(SalesmanActionFailure(result.errorMessage ?? 'Failed to add salesman'));
      emit(SalesmanLoaded(_cachedSalesmen));
    }
  }

  /// Update also returns empty data (no designation_name back), so
  /// re-fetch to keep the list's designation label accurate.
  Future<void> _onUpdateSalesman(
      UpdateSalesman event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanActionLoading());
    final result = await provider.updateSalesman(
      SalesmanUpdateRequestModel(
        id: event.id,
        name: event.name,
        email: event.email,
        designationId: event.designationId,
        mobile: event.mobile,
        salary: event.salary,
        joiningDate: event.joiningDate,
        password: event.password,
        isActive: event.isActive,
      ),
    );
    if (result.success) {
      final refreshed = await provider.getSalesmen();
      if (refreshed.success) _cachedSalesmen = refreshed.salesmen;
      emit(SalesmanActionSuccess(
        message: result.message ?? 'Salesman updated successfully',
        salesmen: _cachedSalesmen,
      ));
      emit(SalesmanLoaded(_cachedSalesmen));
    } else {
      emit(SalesmanActionFailure(result.errorMessage ?? 'Failed to update salesman'));
      emit(SalesmanLoaded(_cachedSalesmen));
    }
  }

  Future<void> _onDeleteSalesman(
      DeleteSalesman event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanActionLoading());
    final result = await provider.deleteSalesman(SalesmanDeleteRequestModel(event.id));
    if (result.success) {
      _cachedSalesmen =
          _cachedSalesmen.where((s) => s.id != event.id).toList();
      emit(SalesmanActionSuccess(
        message: result.message ?? 'Salesman deleted successfully',
        salesmen: _cachedSalesmen,
      ));
      emit(SalesmanLoaded(_cachedSalesmen));
    } else {
      emit(SalesmanActionFailure(result.errorMessage ?? 'Failed to delete salesman'));
      emit(SalesmanLoaded(_cachedSalesmen));
    }
  }
}
