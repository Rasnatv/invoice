import 'package:equatable/equatable.dart';
import '../../../models/drivermodels/driverdashboarddespatchdetailscreenmodel.dart';

enum DriverDespatchDetailStatus { initial, loading, success, failure }

/// Tracks the mark-in-transit / mark-delivered action separately from the
/// page load status, so a failed action doesn't blank out already-loaded
/// bill data.
enum DriverDespatchActionStatus { idle, inProgress, success, failure }

class DriverDespatchDetailState extends Equatable {
  final DriverDespatchDetailStatus status;
  final DriverDespatchDetail? dispatch;
  final String? errorMessage;
  final DriverDespatchActionStatus actionStatus;
  final String? actionMessage;

  const DriverDespatchDetailState({
    this.status = DriverDespatchDetailStatus.initial,
    this.dispatch,
    this.errorMessage,
    this.actionStatus = DriverDespatchActionStatus.idle,
    this.actionMessage,
  });

  DriverDespatchDetailState copyWith({
    DriverDespatchDetailStatus? status,
    DriverDespatchDetail? dispatch,
    String? errorMessage,
    DriverDespatchActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return DriverDespatchDetailState(
      status: status ?? this.status,
      dispatch: dispatch ?? this.dispatch,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, dispatch, errorMessage, actionStatus, actionMessage];
}