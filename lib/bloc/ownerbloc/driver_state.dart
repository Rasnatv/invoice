import 'package:equatable/equatable.dart';
import '../../models/owner_models/get_drivermodel.dart';

enum DriverStatus { initial, loading, loaded, actionInProgress, error }

class DriverState extends Equatable {
  const DriverState({
    this.status = DriverStatus.initial,
    this.drivers = const [],
    this.errorMessage,
    this.successMessage,
    this.isUnauthorized = false,
  });

  factory DriverState.initial() => const DriverState();

  final DriverStatus status;
  final List<DriverGetModel> drivers;
  final String? errorMessage;
  final String? successMessage;

  /// True on a 401 — a redirect to /login is already in flight.
  final bool isUnauthorized;

  bool get isLoading => status == DriverStatus.loading;
  bool get isActionInProgress => status == DriverStatus.actionInProgress;

  DriverState copyWith({
    DriverStatus? status,
    List<DriverGetModel>? drivers,
    String? errorMessage,
    String? successMessage,
    bool? isUnauthorized,
    bool clearFeedback = false,
  }) {
    return DriverState(
      status: status ?? this.status,
      drivers: drivers ?? this.drivers,
      errorMessage: clearFeedback ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearFeedback ? null : (successMessage ?? this.successMessage),
      isUnauthorized: isUnauthorized ?? (clearFeedback ? false : this.isUnauthorized),
    );
  }

  @override
  List<Object?> get props =>
      [status, drivers, errorMessage, successMessage, isUnauthorized];
}