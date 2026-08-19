
import '../../../models/owner_models/salesmanmodel.dart';

abstract class SalesmanState {}

class SalesmanInitial extends SalesmanState {}

class SalesmanLoading extends SalesmanState {}

class SalesmanLoaded extends SalesmanState {
  final List<HSalesmanModel> salesmen;

  SalesmanLoaded(this.salesmen);
}

class SalesmanError extends SalesmanState {
  final String message;

  SalesmanError(this.message);
}

class SalesmanActionLoading extends SalesmanState {}

class SalesmanActionSuccess extends SalesmanState {
  final String message;
  final List<HSalesmanModel> salesmen;

  SalesmanActionSuccess({
    required this.message,
    required this.salesmen,
  });
}

class SalesmanActionFailure extends SalesmanState {
  final String message;

  SalesmanActionFailure(this.message);
}