import 'package:equatable/equatable.dart';

abstract class FieldStaffIncentivesListEvent extends Equatable {
  const FieldStaffIncentivesListEvent();

  @override
  List<Object?> get props => [];
}

/// First page fetch — call when the screen opens.
class FetchFieldStaffIncentivesEvent extends FieldStaffIncentivesListEvent {
  final Map<String, dynamic> filters;

  const FetchFieldStaffIncentivesEvent({this.filters = const {}});

  @override
  List<Object?> get props => [filters];
}

/// Pull-to-refresh — resets to page 1, keeps current filters.
class RefreshFieldStaffIncentivesEvent extends FieldStaffIncentivesListEvent {
  const RefreshFieldStaffIncentivesEvent();
}

/// Loads the next page and appends it to the existing list (infinite scroll).
class FetchMoreFieldStaffIncentivesEvent extends FieldStaffIncentivesListEvent {
  const FetchMoreFieldStaffIncentivesEvent();
}

/// Fired when a status chip is tapped. Pass 'All' (kAllStatusFilter) to clear
/// the filter, or any label from state.chipOptions to filter by it.
class SelectFieldStaffIncentiveStatusEvent extends FieldStaffIncentivesListEvent {
  final String status;

  const SelectFieldStaffIncentiveStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}