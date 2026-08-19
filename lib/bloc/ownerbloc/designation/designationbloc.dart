import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Apiprovider/designation_provider.dart';
import '../../../models/owner_models/designationmodel.dart';
import 'designationevent.dart';
import 'designationstate.dart';

class DesignationBloc extends Bloc<DesignationEvent, DesignationState> {
  final DesignationProvider provider;

  List<DesignationModel> _cachedDesignations = [];

  DesignationBloc({required this.provider}) : super(DesignationInitial()) {
    on<FetchDesignations>(_onFetchDesignations);
    on<AddDesignation>(_onAddDesignation);
    on<UpdateDesignation>(_onUpdateDesignation);
    on<DeleteDesignation>(_onDeleteDesignation);
  }

  Future<void> _onFetchDesignations(
      FetchDesignations event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationLoading());
    final result = await provider.getDesignations();
    if (result.success) {
      _cachedDesignations = result.designations;
      emit(DesignationLoaded(_cachedDesignations));
    } else {
      emit(DesignationError(result.errorMessage ?? 'Failed to fetch designations'));
    }
  }

  /// Create returns no designation object back (empty data), so we reload
  /// the full list afterward to pick up the server-assigned id.
  Future<void> _onAddDesignation(
      AddDesignation event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationActionLoading());
    final result = await provider.addDesignation(
      DesignationAddRequestModel(name: event.name),
    );
    if (result.success) {
      final refreshed = await provider.getDesignations();
      if (refreshed.success) _cachedDesignations = refreshed.designations;
      emit(DesignationActionSuccess(
        message: result.message ?? 'Designation added successfully',
        designations: _cachedDesignations,
      ));
      emit(DesignationLoaded(_cachedDesignations));
    } else {
      emit(DesignationActionFailure(result.errorMessage ?? 'Failed to add designation'));
      emit(DesignationLoaded(_cachedDesignations));
    }
  }

  /// Update also returns empty data, so apply the change locally using the
  /// values we already sent instead of waiting on a server object.
  Future<void> _onUpdateDesignation(
      UpdateDesignation event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationActionLoading());
    final result = await provider.updateDesignation(
      DesignationUpdateRequestModel(id: event.id, name: event.name),
    );
    if (result.success) {
      _cachedDesignations = _cachedDesignations
          .map((d) => d.id == event.id ? d.copyWith(name: event.name) : d)
          .toList();
      emit(DesignationActionSuccess(
        message: result.message ?? 'Designation updated successfully',
        designations: _cachedDesignations,
      ));
      emit(DesignationLoaded(_cachedDesignations));
    } else {
      emit(DesignationActionFailure(result.errorMessage ?? 'Failed to update designation'));
      emit(DesignationLoaded(_cachedDesignations));
    }
  }

  Future<void> _onDeleteDesignation(
      DeleteDesignation event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationActionLoading());
    final result = await provider.deleteDesignation(
      DesignationDeleteRequestModel(event.id),
    );
    if (result.success) {
      _cachedDesignations =
          _cachedDesignations.where((d) => d.id != event.id).toList();
      emit(DesignationActionSuccess(
        message: result.message ?? 'Designation deleted successfully',
        designations: _cachedDesignations,
      ));
      emit(DesignationLoaded(_cachedDesignations));
    } else {
      emit(DesignationActionFailure(result.errorMessage ?? 'Failed to delete designation'));
      emit(DesignationLoaded(_cachedDesignations));
    }
  }
}