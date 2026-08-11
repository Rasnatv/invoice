import 'package:equatable/equatable.dart';

abstract class DashboardHomeEvent extends Equatable {
  const DashboardHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the dashboard screen is first opened.
class DashboardHomeRequested extends DashboardHomeEvent {
  const DashboardHomeRequested();
}

/// Fired on pull-to-refresh.
class DashboardHomeRefreshed extends DashboardHomeEvent {
  const DashboardHomeRefreshed();
}