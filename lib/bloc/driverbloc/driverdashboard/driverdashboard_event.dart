import 'package:equatable/equatable.dart';

abstract class DriverDashboardEvent extends Equatable {
  const DriverDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load — shows the full-screen loading indicator.
class FetchDriverDashboard extends DriverDashboardEvent {
  const FetchDriverDashboard();
}

/// Pull-to-refresh — reuses the same handler as [FetchDriverDashboard].
class RefreshDriverDashboard extends DriverDashboardEvent {
  const RefreshDriverDashboard();
}