import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/designationmodel.dart';
import '../../data/repository/designationrepo.dart';
import 'designationevent.dart';
import 'designationstate.dart';

class DesignationBloc extends Bloc<DesignationEvent, DesignationState> {
  final DesignationRepository repository;

  List<DesignationModel> _cachedDesignations = [];

  DesignationBloc({required this.repository}) : super(DesignationInitial()) {
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
    try {
      final designations = await repository.getDesignations();
      _cachedDesignations = designations;
      emit(DesignationLoaded(designations));
    } catch (e) {
      emit(DesignationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddDesignation(
      AddDesignation event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationActionLoading());
    try {
      final created = await repository.addDesignation(event.name);
      _cachedDesignations = [..._cachedDesignations, created];
      emit(DesignationActionSuccess(
        message: 'Designation added successfully',
        designations: _cachedDesignations,
      ));
      emit(DesignationLoaded(_cachedDesignations));
    } catch (e) {
      emit(DesignationActionFailure(e.toString().replaceAll('Exception: ', '')));
      emit(DesignationLoaded(_cachedDesignations));
    }
  }

  Future<void> _onUpdateDesignation(
      UpdateDesignation event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationActionLoading());
    try {
      final updated = await repository.updateDesignation(event.id, event.name);
      _cachedDesignations = _cachedDesignations
          .map((d) => d.id == updated.id ? updated : d)
          .toList();
      emit(DesignationActionSuccess(
        message: 'Designation updated successfully',
        designations: _cachedDesignations,
      ));
      emit(DesignationLoaded(_cachedDesignations));
    } catch (e) {
      emit(DesignationActionFailure(e.toString().replaceAll('Exception: ', '')));
      emit(DesignationLoaded(_cachedDesignations));
    }
  }

  Future<void> _onDeleteDesignation(
      DeleteDesignation event,
      Emitter<DesignationState> emit,
      ) async {
    emit(DesignationActionLoading());
    try {
      await repository.deleteDesignation(event.id);
      _cachedDesignations =
          _cachedDesignations.where((d) => d.id != event.id).toList();
      emit(DesignationActionSuccess(
        message: 'Designation deleted successfully',
        designations: _cachedDesignations,
      ));
      emit(DesignationLoaded(_cachedDesignations));
    } catch (e) {
      emit(DesignationActionFailure(e.toString().replaceAll('Exception: ', '')));
      emit(DesignationLoaded(_cachedDesignations));
    }
  }
}