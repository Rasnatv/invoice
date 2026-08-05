import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Apiprovider/fieldstaffprovider.dart';
import '../../models/owner_models/fieldstaff_getmodel.dart';
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
    } else if (!result.isUnauthorized) {
      // On 401 the provider already triggered the login redirect — nothing
      // further to show here, so stay quiet rather than flash an error.
      emit(state.copyWith(
        status: FieldStaffStatus.loadError,
        message: result.errorMessage ?? 'Failed to load field staff',
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
      // The create endpoint returns an empty "data" object, so the display
      // entity is built from what was submitted rather than the response.
      // id/employee_code stay unknown until the list is refetched.
      final created = FieldStaffModel(
        id: 0,
        name: event.staff.name,
        email: event.staff.email,
        mobile: event.staff.mobile,
        address: event.staff.address,
        employeeCode: '',
        joiningDate: event.staff.joiningDate,
        isActive: true,
      );
      emit(state.copyWith(
        status: FieldStaffStatus.submitSuccess,
        staffList: [created, ...state.staffList],
        message: result.message,
      ));
    } else if (!result.isUnauthorized) {
      emit(state.copyWith(
        status: FieldStaffStatus.submitError,
        message: result.errorMessage ?? 'Failed to add field staff',
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
    } else if (!result.isUnauthorized) {
      emit(state.copyWith(
        status: FieldStaffStatus.submitError,
        message: result.errorMessage ?? 'Failed to update field staff',
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
    } else if (!result.isUnauthorized) {
      emit(state.copyWith(
        status: FieldStaffStatus.deleteError,
        message: result.errorMessage ?? 'Failed to remove field staff',
      ));
    }
  }
}