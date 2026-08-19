import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/driverprovider.dart';
import '../../../models/owner_models/add_drivermodel.dart';
import '../../../models/owner_models/deletedrivermodel.dart';
import '../../../models/owner_models/update_drivermodel.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  DriverBloc({required DriverProvider provider})
      : _provider = provider,
        super(DriverState.initial()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<AddDriver>(_onAddDriver);
    on<UpdateDriver>(_onUpdateDriver);
    on<DeleteDriver>(_onDeleteDriver);
    on<ClearDriverFeedback>(_onClearFeedback);
  }

  final DriverProvider _provider;

  Future<void> _onLoadDrivers(LoadDrivers event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.loading, clearFeedback: true));
    final result = await _provider.getDrivers();

    if (result.success) {
      emit(state.copyWith(status: DriverStatus.loaded, drivers: result.drivers));
    } else {
      emit(state.copyWith(
        status: DriverStatus.error,
        errorMessage: result.isUnauthorized ? null : result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
    }
  }

  Future<void> _onAddDriver(AddDriver event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.actionInProgress, clearFeedback: true));

    final result = await _provider.addDriver(
      DriverAddRequestModel(
        name: event.name,
        email: event.email,
        mobile: event.mobile,
        licenseNumber: event.licenseNumber,
        vehicleNumber: event.vehicleNumber,
        joiningDate: event.joiningDate,
      ),
    );

    if (!result.success) {
      emit(state.copyWith(
        status: DriverStatus.error,
        errorMessage: result.isUnauthorized ? null : result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
      return;
    }

    // Create returns an empty payload — reload to pick up the new id.
    final listResult = await _provider.getDrivers();
    emit(state.copyWith(
      status: DriverStatus.loaded,
      drivers: listResult.success ? listResult.drivers : state.drivers,
      successMessage:
      'Driver registered successfully. Login password sent to ${event.email}.',
    ));
  }

  Future<void> _onUpdateDriver(UpdateDriver event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.actionInProgress, clearFeedback: true));

    final result = await _provider.updateDriver(
      DriverUpdateRequestModel(
        id: event.id,
        name: event.name,
        email: event.email,
        mobile: event.mobile,
        licenseNumber: event.licenseNumber,
        vehicleNumber: event.vehicleNumber,
        joiningDate: event.joiningDate,
        isActive: event.isActive,
        password: event.password,
      ),
    );

    if (!result.success) {
      emit(state.copyWith(
        status: DriverStatus.error,
        errorMessage: result.isUnauthorized ? null : result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
      return;
    }

    final updatedList = state.drivers.map((d) {
      if (d.id != event.id) return d;
      return d.copyWith(
        name: event.name,
        email: event.email,
        mobile: event.mobile,
        licenseNumber: event.licenseNumber,
        vehicleNumber: event.vehicleNumber,
        joiningDate: event.joiningDate,
        isActive: event.isActive,
      );
    }).toList();

    emit(state.copyWith(
      status: DriverStatus.loaded,
      drivers: updatedList,
      successMessage: 'Driver updated successfully',
    ));
  }

  Future<void> _onDeleteDriver(DeleteDriver event, Emitter<DriverState> emit) async {
    emit(state.copyWith(status: DriverStatus.actionInProgress, clearFeedback: true));

    final result = await _provider.deleteDriver(DriverDeleteRequestModel(id: event.id));

    if (!result.success) {
      emit(state.copyWith(
        status: DriverStatus.error,
        errorMessage: result.isUnauthorized ? null : result.errorMessage,
        isUnauthorized: result.isUnauthorized,
      ));
      return;
    }

    final updatedList = state.drivers.where((d) => d.id != event.id).toList();
    emit(state.copyWith(
      status: DriverStatus.loaded,
      drivers: updatedList,
      successMessage: 'Driver removed',
    ));
  }

  void _onClearFeedback(ClearDriverFeedback event, Emitter<DriverState> emit) {
    emit(state.copyWith(clearFeedback: true));
  }
}