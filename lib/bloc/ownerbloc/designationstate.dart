
import '../../models/owner_models/designationmodel.dart';


abstract class DesignationState {}

class DesignationInitial extends DesignationState {}

class DesignationLoading extends DesignationState {}

class DesignationLoaded extends DesignationState {
  final List<DesignationModel> designations;

  DesignationLoaded(this.designations);
}

class DesignationError extends DesignationState {
  final String message;

  DesignationError(this.message);
}

class DesignationActionLoading extends DesignationState {}

class DesignationActionSuccess extends DesignationState {
  final String message;
  final List<DesignationModel> designations;

  DesignationActionSuccess({
    required this.message,
    required this.designations,
  });
}

class DesignationActionFailure extends DesignationState {
  final String message;

  DesignationActionFailure(this.message);
}