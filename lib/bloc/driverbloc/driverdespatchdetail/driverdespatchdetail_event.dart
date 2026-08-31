import 'package:equatable/equatable.dart';

abstract class DriverDespatchDetailEvent extends Equatable {
  const DriverDespatchDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load — shows the full-screen loading indicator.
class FetchDriverDespatchDetail extends DriverDespatchDetailEvent {
  final String id;
  const FetchDriverDespatchDetail(this.id);

  @override
  List<Object?> get props => [id];
}

/// Pull-to-refresh — reuses the same handler as [FetchDriverDespatchDetail].
class RefreshDriverDespatchDetail extends DriverDespatchDetailEvent {
  final String id;
  const RefreshDriverDespatchDetail(this.id);

  @override
  List<Object?> get props => [id];
}

/// Driver confirms pickup — moves a pending despatch to "in transit".
class MarkInTransitRequested extends DriverDespatchDetailEvent {
  final String id;
  const MarkInTransitRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Driver confirms delivery. Both signatures are optional — the driver may
/// proceed without capturing either (or capturing just one).
class MarkDeliveredRequested extends DriverDespatchDetailEvent {
  final String id;
  final String? customerSignatureBase64;
  final String? driverSignatureBase64;

  const MarkDeliveredRequested({
    required this.id,
    this.customerSignatureBase64,
    this.driverSignatureBase64,
  });

  @override
  List<Object?> get props => [id, customerSignatureBase64, driverSignatureBase64];
}

/// Resets [actionStatus]/[actionMessage] back to idle after the UI has
/// consumed a success/failure snackbar, so it doesn't fire again on rebuild.
class ClearDriverDespatchActionStatus extends DriverDespatchDetailEvent {
  const ClearDriverDespatchActionStatus();
}