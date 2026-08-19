import 'package:equatable/equatable.dart';

abstract class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the owner dashboard screen is first opened.
class OwnerDashboardRequested extends OwnerDashboardEvent {
  const OwnerDashboardRequested();
}

/// Fired on pull-to-refresh.
class OwnerDashboardRefreshed extends OwnerDashboardEvent {
  const OwnerDashboardRefreshed();
}