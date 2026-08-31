import 'package:equatable/equatable.dart';
import '../../../models/drivermodels/driverdashboardmodel.dart';

enum DriverDashboardStatus { initial, loading, success, failure }

class DriverDashboardState extends Equatable {
  final DriverDashboardStatus status;
  final DriverDashboardResponse? dashboard;
  final String? errorMessage;

  const DriverDashboardState({
    this.status = DriverDashboardStatus.initial,
    this.dashboard,
    this.errorMessage,
  });

  DriverDashboardState copyWith({
    DriverDashboardStatus? status,
    DriverDashboardResponse? dashboard,
    String? errorMessage,
  }) {
    return DriverDashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dashboard, errorMessage];
}