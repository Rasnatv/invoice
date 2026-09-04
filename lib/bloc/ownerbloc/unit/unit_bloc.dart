//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../Apiprovider/unitprovider.dart';
// import '../../../core/apiclient/statemodel.dart';
// import '../../../models/owner_models/uintmodel.dart';
// import 'unit_event.dart';
// import 'unit_state.dart';
//
// class UnitBloc extends Bloc<UnitEvent, UnitState> {
//   UnitBloc({required UnitProvider provider})
//       : _provider = provider,
//         super(const UnitState()) {
//     on<LoadUnits>(_onLoadUnits);
//     on<AddUnitRequested>(_onAddUnit);
//     on<UpdateUnitRequested>(_onUpdateUnit);
//     on<DeleteUnitRequested>(_onDeleteUnit);
//     on<UnitMessageConsumed>(_onMessageConsumed);
//   }
//
//   final UnitProvider _provider;
//
//   Future<void> _onLoadUnits(LoadUnits event, Emitter<UnitState> emit) async {
//     emit(state.copyWith(status: UnitStatus.loading, clearError: true));
//     final result = await _provider.getUnitsProvider();
//
//     if (result is SuccessState<UnitGetResponseModel>) {
//       emit(state.copyWith(status: UnitStatus.loaded, units: result.value.data));
//     } else if (result is ErrorState<UnitGetResponseModel>) {
//       emit(state.copyWith(status: UnitStatus.failure, errorMessage: result.msg));
//     } else {
//       // result == null — treat as an unhandled/unauthorized case, no
//       // message to show (mirrors the old isUnauthorized silent-skip).
//       emit(state.copyWith(status: UnitStatus.failure));
//     }
//   }
//
//   /// The create API returns no unit object (empty data), so instead of
//   /// fabricating a local entry with a fake id, we reload the full list to
//   /// pick up the real server-assigned id.
//   Future<void> _onAddUnit(AddUnitRequested event, Emitter<UnitState> emit) async {
//     emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
//     final result = await _provider.addUnitProvider(
//       UnitAddRequestModel(name: event.name, abbreviation: event.abbreviation),
//     );
//
//     if (result is SuccessState<UnitAddResponseModel>) {
//       emit(state.copyWith(
//         isSubmitting: false,
//         successMessage: result.value.message,
//       ));
//       add(const LoadUnits());
//     } else if (result is ErrorState<UnitAddResponseModel>) {
//       emit(state.copyWith(isSubmitting: false, errorMessage: result.msg));
//     } else {
//       emit(state.copyWith(isSubmitting: false));
//     }
//   }
//
//   Future<void> _onUpdateUnit(UpdateUnitRequested event, Emitter<UnitState> emit) async {
//     emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
//     final result = await _provider.updateUnitProvider(
//       UnitUpdateRequestModel(id: event.id, name: event.name, abbreviation: event.abbreviation),
//     );
//
//     if (result is SuccessState<UnitAddResponseModel>) {
//       final updated = state.units
//           .map((u) => u.id == event.id
//           ? u.copyWith(name: event.name, abbreviation: event.abbreviation)
//           : u)
//           .toList();
//       emit(state.copyWith(
//         isSubmitting: false,
//         units: updated,
//         successMessage: result.value.message,
//       ));
//     } else if (result is ErrorState<UnitAddResponseModel>) {
//       emit(state.copyWith(isSubmitting: false, errorMessage: result.msg));
//     } else {
//       emit(state.copyWith(isSubmitting: false));
//     }
//   }
//
//   Future<void> _onDeleteUnit(DeleteUnitRequested event, Emitter<UnitState> emit) async {
//     emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
//     final result = await _provider.deleteUnitProvider(UnitDeleteRequestModel(event.id));
//
//     if (result is SuccessState<UnitAddResponseModel>) {
//       final updated = state.units.where((u) => u.id != event.id).toList();
//       emit(state.copyWith(
//         isSubmitting: false,
//         units: updated,
//         successMessage: result.value.message,
//       ));
//     } else if (result is ErrorState<UnitAddResponseModel>) {
//       emit(state.copyWith(isSubmitting: false, errorMessage: result.msg));
//     } else {
//       emit(state.copyWith(isSubmitting: false));
//     }
//   }
//
//   void _onMessageConsumed(UnitMessageConsumed event, Emitter<UnitState> emit) {
//     emit(state.copyWith(clearError: true, clearSuccess: true));
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/unitprovider.dart';
import '../../../models/owner_models/uintmodel.dart';
import 'unit_event.dart';
import 'unit_state.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  UnitBloc({required UnitProvider provider})
      : _provider = provider,
        super(const UnitState()) {
    on<LoadUnits>(_onLoadUnits);
    on<AddUnitRequested>(_onAddUnit);
    on<UpdateUnitRequested>(_onUpdateUnit);
    on<DeleteUnitRequested>(_onDeleteUnit);
    on<UnitMessageConsumed>(_onMessageConsumed);
  }

  final UnitProvider _provider;

  Future<void> _onLoadUnits(LoadUnits event, Emitter<UnitState> emit) async {
    emit(state.copyWith(status: UnitStatus.loading, clearError: true));
    final result = await _provider.getUnitsProvider();

    if (result.success) {
      emit(state.copyWith(status: UnitStatus.loaded, units: result.data?.data ?? const []));
    } else {
      emit(state.copyWith(status: UnitStatus.failure, errorMessage: result.errorMessage));
    }
  }

  /// The create API returns no unit object (empty data), so instead of
  /// fabricating a local entry with a fake id, we reload the full list to
  /// pick up the real server-assigned id.
  Future<void> _onAddUnit(AddUnitRequested event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await _provider.addUnitProvider(
      UnitAddRequestModel(name: event.name, abbreviation: event.abbreviation),
    );

    if (result.success) {
      emit(state.copyWith(
        isSubmitting: false,
        successMessage: result.message,
      ));
      add(const LoadUnits());
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.message));
    }
  }

  Future<void> _onUpdateUnit(UpdateUnitRequested event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await _provider.updateUnitProvider(
      UnitUpdateRequestModel(id: event.id, name: event.name, abbreviation: event.abbreviation),
    );

    if (result.success) {
      final updated = state.units
          .map((u) => u.id == event.id
          ? u.copyWith(name: event.name, abbreviation: event.abbreviation)
          : u)
          .toList();
      emit(state.copyWith(
        isSubmitting: false,
        units: updated,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.message));
    }
  }

  Future<void> _onDeleteUnit(DeleteUnitRequested event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    final result = await _provider.deleteUnitProvider(UnitDeleteRequestModel(event.id));

    if (result.success) {
      final updated = state.units.where((u) => u.id != event.id).toList();
      emit(state.copyWith(
        isSubmitting: false,
        units: updated,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.message));
    }
  }

  void _onMessageConsumed(UnitMessageConsumed event, Emitter<UnitState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}