import 'package:equatable/equatable.dart';
import '../../data/model/get_drivermodel.dart';

enum DriverStatus { initial, loading, loaded, actionInProgress, error }

class DriverState extends Equatable {
  const DriverState({
    this.status = DriverStatus.initial,
    this.drivers = const [],
    this.errorMessage,
    this.successMessage,
    this.generatedPassword,
    this.isUnauthorized = false,
  });

  factory DriverState.initial() => const DriverState();

  final DriverStatus status;
  final List<DriverGetModel> drivers;
  final String? errorMessage;
  final String? successMessage;

  /// True when the last failure was a silent 401 — a redirect to
  /// /login is already in flight, so the UI should show nothing
  /// (or a loading spinner) instead of the "Could not load drivers"
  /// error state.
  final bool isUnauthorized;

  /// Set right after a successful add — the API returns a one-time
  /// password the owner needs to share with the driver.
  final String? generatedPassword;

  bool get isLoading => status == DriverStatus.loading;
  bool get isActionInProgress => status == DriverStatus.actionInProgress;

  DriverState copyWith({
    DriverStatus? status,
    List<DriverGetModel>? drivers,
    String? errorMessage,
    String? successMessage,
    String? generatedPassword,
    bool? isUnauthorized,
    bool clearFeedback = false,
  }) {
    return DriverState(
      status: status ?? this.status,
      drivers: drivers ?? this.drivers,
      errorMessage: clearFeedback ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearFeedback ? null : (successMessage ?? this.successMessage),
      generatedPassword:
      clearFeedback ? null : (generatedPassword ?? this.generatedPassword),
      isUnauthorized: isUnauthorized ?? (clearFeedback ? false : this.isUnauthorized),
    );
  }

  @override
  List<Object?> get props =>
      [status, drivers, errorMessage, successMessage, generatedPassword, isUnauthorized];
}