import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/add_drivermodel.dart';
import '../../data/model/deletedrivermodel.dart';
import '../../data/model/get_drivermodel.dart';
import '../../data/model/update_drivermodel.dart';
import '../../data/repository/driver_repository.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  DriverBloc({required DriverRepository repository})
      : _repository = repository,
        super(DriverState.initial()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<AddDriver>(_onAddDriver);
    on<UpdateDriver>(_onUpdateDriver);
    on<DeleteDriver>(_onDeleteDriver);
    on<ClearDriverFeedback>(_onClearFeedback);
  }

  final DriverRepository _repository;

  /// Returns null (no message to show) if this was a silent
  /// DriverException (e.g. 401 → redirecting to login already handled).
  String? _messageFor(Object e) {
    if (e is DriverException && e.silent) return null;
    return e.toString();
  }

  bool _isUnauthorized(Object e) => e is DriverException && e.silent;

  Future<void> _onLoadDrivers(LoadDrivers event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.loading, clearFeedback: true));
    try {
      final drivers = await _repository.getDrivers();
      emit(state.copyWith(status: DriverStatus.loaded, drivers: drivers));
    } catch (e) {
      emit(state.copyWith(
        status: DriverStatus.error,
        errorMessage: _messageFor(e),
        isUnauthorized: _isUnauthorized(e),
      ));
    }
  }

  Future<void> _onAddDriver(AddDriver event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.actionInProgress, clearFeedback: true));
    try {
      final response = await _repository.addDriver(
        DriverAddRequestModel(
          name: event.name,
          email: event.email,
          mobile: event.mobile,
          licenseNumber: event.licenseNumber,
          vehicleNumber: event.vehicleNumber,
          joiningDate: event.joiningDate,
        ),
      );

      final newDriver = DriverGetModel(
        id: response.id,
        name: response.name,
        mobile: event.mobile,
        licenseNumber: event.licenseNumber,
        vehicleNumber: event.vehicleNumber,
        joiningDate: event.joiningDate,
        isActive: true,
        createdAt: '',
        email: event.email,
      );

      final updated = List<DriverGetModel>.from(state.drivers)..insert(0, newDriver);
      emit(state.copyWith(
        status: DriverStatus.loaded,
        drivers: updated,
        successMessage:
        'Driver registered successfully. Login password sent to ${event.email}.',
      ));
    } catch (e) {
      emit(state.copyWith(status: DriverStatus.error, errorMessage: _messageFor(e)));
    }
  }

  Future<void> _onUpdateDriver(UpdateDriver event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.actionInProgress, clearFeedback: true));
    try {
      await _repository.updateDriver(
        DriverUpdateRequestModel(
          id: event.id,
          name: event.name,
          email: event.email,
          mobile: event.mobile,
          licenseNumber: event.licenseNumber,
          vehicleNumber: event.vehicleNumber,
          joiningDate: event.joiningDate,
          password: event.password,
        ),
      );

      final updatedList = state.drivers.map((d) {
        if (d.id != event.id) return d;
        return d.copyWith(
          name: event.name,
          mobile: event.mobile,
          licenseNumber: event.licenseNumber,
          vehicleNumber: event.vehicleNumber,
          joiningDate: event.joiningDate,
        );
      }).toList();

      emit(state.copyWith(
        status: DriverStatus.loaded,
        drivers: updatedList,
        successMessage: 'Driver updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(status: DriverStatus.error, errorMessage: _messageFor(e)));
    }
  }

  Future<void> _onDeleteDriver(DeleteDriver event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.actionInProgress, clearFeedback: true));
    try {
      await _repository.deleteDriver(DriverDeleteRequestModel(id: event.id));
      final updatedList = state.drivers.where((d) => d.id != event.id).toList();
      emit(state.copyWith(
        status: DriverStatus.loaded,
        drivers: updatedList,
        successMessage: 'Driver removed',
      ));
    } catch (e) {
      emit(state.copyWith(status: DriverStatus.error, errorMessage: _messageFor(e)));
    }
  }

  void _onClearFeedback(ClearDriverFeedback event, Emitter<DriverState> emit) {
    emit(state.copyWith(clearFeedback: true));
  }
}