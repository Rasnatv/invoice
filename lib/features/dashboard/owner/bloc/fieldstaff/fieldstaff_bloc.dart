import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/apierrorhandler.dart';
import '../../data/model/fieldstaff_getmodel.dart';
import '../../data/repository/fieldstaff_repo.dart';
import 'fieldstaff_event.dart';
import 'fieldstaffstate.dart';



class FieldStaffBloc extends Bloc<FieldStaffEvent, FieldStaffState> {
  FieldStaffBloc({required NewFieldStaffRepository repository})
      : _repository = repository,
        super(FieldStaffState.initial()) {
    on<FetchFieldStaffListEvent>(_onFetchList);
    on<AddFieldStaffEvent>(_onAdd);
    on<UpdateFieldStaffEvent>(_onUpdate);
    on<DeleteFieldStaffEvent>(_onDelete);
  }

  final NewFieldStaffRepository _repository;

  Future<void> _onFetchList(
      FetchFieldStaffListEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.loading));
    try {
      final list = await _repository.fetchFieldStaffList();
      emit(state.copyWith(status: FieldStaffStatus.loaded, staffList: list));
    } catch (e) {
      emit(state.copyWith(
        status: FieldStaffStatus.loadError,
        message: await _resolveError(e),
      ));
    }
  }

  Future<void> _onAdd(
      AddFieldStaffEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.submitting));
    try {
      final created = await _repository.createFieldStaff(event.staff);
      final createdEntity = FieldStaffModel(
        id: created.id,
        name: created.name,
        email: created.email,
        mobile: created.mobile,
        address: created.address,
        joiningDate: created.joiningDate,
      );
      emit(state.copyWith(
        status: FieldStaffStatus.submitSuccess,
        staffList: [createdEntity, ...state.staffList],
        message: 'Field staff added successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FieldStaffStatus.submitError,
        message: await _resolveError(e),
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateFieldStaffEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.submitting));
    try {
      final updated = await _repository.updateFieldStaff(event.staff);
      final updatedEntity = FieldStaffModel(
        id: updated.id,
        name: updated.name,
        email: updated.email,
        mobile: updated.mobile,
        address: updated.address,
        joiningDate: updated.joiningDate,
      );
      final updatedList = state.staffList
          .map((s) => s.id == updatedEntity.id ? updatedEntity : s)
          .toList();
      emit(state.copyWith(
        status: FieldStaffStatus.submitSuccess,
        staffList: updatedList,
        message: 'Field staff updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FieldStaffStatus.submitError,
        message: await _resolveError(e),
      ));
    }
  }

  Future<void> _onDelete(
      DeleteFieldStaffEvent event,
      Emitter<FieldStaffState> emit,
      ) async {
    emit(state.copyWith(status: FieldStaffStatus.deleting));
    try {
      await _repository.deleteFieldStaff(event.staff);
      final updatedList =
      state.staffList.where((s) => s.id != event.staff.id).toList();
      emit(state.copyWith(
        status: FieldStaffStatus.deleteSuccess,
        staffList: updatedList,
        message: 'Field staff removed successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FieldStaffStatus.deleteError,
        message: await _resolveError(e),
      ));
    }
  }

  /// Routes Dio errors through ApiErrorHandler so 401 responses clear the
  /// token and redirect to the login screen; everything else falls back
  /// to the plain exception message.
  Future<String> _resolveError(Object e) async {
    if (e is DioException) {
      return await ApiErrorHandler.handleDioError(e);
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}