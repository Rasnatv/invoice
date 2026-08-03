import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/salesman_getmodel.dart';
import '../../data/repository/salesman_repository.dart';

import 'salesman_event.dart';
import 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  final SalesmanRepository repository;

  List<HSalesmanModel> _cachedSalesmen = [];

  SalesmanBloc({required this.repository}) : super(SalesmanInitial()) {
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
    try {
      final salesmen = await repository.getSalesmen();
      _cachedSalesmen = salesmen;
      emit(SalesmanLoaded(salesmen));
    } catch (e) {
      emit(SalesmanError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddSalesman(
      AddSalesman event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanActionLoading());
    try {
      // The create response doesn't include mobile/joining_date, so
      // re-fetch the full list to stay in sync instead of merging a
      // partial record.
      await repository.addSalesman(
        name: event.name,
        email: event.email,
        designationId: event.designationId,
        mobile: event.mobile,
        salary: event.salary,
        joiningDate: event.joiningDate,
        password: event.password,
      );
      final refreshed = await repository.getSalesmen();
      _cachedSalesmen = refreshed;
      emit(SalesmanActionSuccess(
        message: 'Salesman added successfully',
        salesmen: _cachedSalesmen,
      ));
      emit(SalesmanLoaded(_cachedSalesmen));
    } catch (e) {
      emit(SalesmanActionFailure(e.toString().replaceAll('Exception: ', '')));
      emit(SalesmanLoaded(_cachedSalesmen));
    }
  }

  Future<void> _onUpdateSalesman(
      UpdateSalesman event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanActionLoading());
    try {
      final updated = await repository.updateSalesman(
        id: event.id,
        name: event.name,
        email: event.email,
        designationId: event.designationId,
        mobile: event.mobile,
        salary: event.salary,
        joiningDate: event.joiningDate,
        password: event.password,
        isActive: event.isActive,
      );
      final updatedModel = updated.toSalesmanModel();
      _cachedSalesmen = _cachedSalesmen
          .map((s) => s.id == updatedModel.id ? updatedModel : s)
          .toList();
      emit(SalesmanActionSuccess(
        message: 'Salesman updated successfully',
        salesmen: _cachedSalesmen,
      ));
      emit(SalesmanLoaded(_cachedSalesmen));
    } catch (e) {
      emit(SalesmanActionFailure(e.toString().replaceAll('Exception: ', '')));
      emit(SalesmanLoaded(_cachedSalesmen));
    }
  }

  Future<void> _onDeleteSalesman(
      DeleteSalesman event,
      Emitter<SalesmanState> emit,
      ) async {
    emit(SalesmanActionLoading());
    try {
      final result = await repository.deleteSalesman(event.id);
      _cachedSalesmen =
          _cachedSalesmen.where((s) => s.id != event.id).toList();
      emit(SalesmanActionSuccess(
        message: result.message.isNotEmpty ? result.message : 'Salesman deleted successfully',
        salesmen: _cachedSalesmen,
      ));
      emit(SalesmanLoaded(_cachedSalesmen));
    } catch (e) {
      emit(SalesmanActionFailure(e.toString().replaceAll('Exception: ', '')));
      emit(SalesmanLoaded(_cachedSalesmen));
    }
  }
}