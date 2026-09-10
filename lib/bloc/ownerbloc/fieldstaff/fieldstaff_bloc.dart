
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/fieldstaffprovider.dart';
import '../../../models/owner_models/fieldstaff_getmodel.dart';
import 'fieldstaff_event.dart';
import 'fieldstaffstate.dart';


class FieldStaffBloc extends Bloc<FieldStaffEvent, FieldStaffState> {
  FieldStaffBloc({required FieldStaffProvider provider})
      : _provider = provider,
        super(FieldStaffState.initial()) {
    on<FetchFieldStaffListEvent>(_onFetchList);
    on<AddFieldStaffEvent>(_onAdd);
    on<UpdateFieldStaffEvent>(_onUpdate);
    on<DeleteFieldStaffEvent>(_onDelete);
  }

  final FieldStaffProvider _provider;

  Future<void> _onFetchList(
      FetchFieldStaffListEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.loading));
    final result = await _provider.getFieldStaff();

    if (result.success) {
      emit(state.copyWith(
        status: FieldStaffStatus.loaded,
        staffList: result.staff,
        hasLoadedOnce: true,
      ));
    } else {
      emit(state.copyWith(
        status: FieldStaffStatus.loadError,
        message: result.errorMessage,
      ));
    }
  }

  Future<void> _onAdd(
      AddFieldStaffEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.submitting));
    final result = await _provider.addFieldStaff(event.staff);

    if (result.success) {
      // The create endpoint returns an empty "data" object — it never gives
      // us the new record's server-assigned id. Inserting a locally-built
      // FieldStaffModel with id: 0 meant that editing a just-added staff
      // member (before any refresh) submitted "id": 0 to the update API,
      // which the backend rejects. Refetching here guarantees the list only
      // ever holds staff with real, server-assigned ids.
      final listResult = await _provider.getFieldStaff();
      emit(state.copyWith(
        status: FieldStaffStatus.submitSuccess,
        staffList: listResult.success ? listResult.staff : state.staffList,
        hasLoadedOnce: listResult.success ? true : state.hasLoadedOnce,
        message: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: FieldStaffStatus.submitError,
        message: result.errorMessage,
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateFieldStaffEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.submitting));
    final result = await _provider.updateFieldStaff(event.staff);

    if (result.success) {
      final updatedList = state.staffList.map((s) {
        if (s.id != event.staff.id) return s;
        return s.copyWith(
          name: event.staff.name,
          email: event.staff.email,
          mobile: event.staff.mobile,
          address: event.staff.address,
          joiningDate: event.staff.joiningDate,
          isActive: event.staff.isActive,
        );
      }).toList();

      emit(state.copyWith(
        status: FieldStaffStatus.submitSuccess,
        staffList: updatedList,
        message: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: FieldStaffStatus.submitError,
        message: result.errorMessage,
      ));
    }
  }

  Future<void> _onDelete(
      DeleteFieldStaffEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.deleting));
    final result = await _provider.deleteFieldStaff(event.staff);

    if (result.success) {
      final updatedList =
      state.staffList.where((s) => s.id != event.staff.id).toList();
      emit(state.copyWith(
        status: FieldStaffStatus.deleteSuccess,
        staffList: updatedList,
        message: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: FieldStaffStatus.deleteError,
        message: result.errorMessage,
      ));
    }
  }
}