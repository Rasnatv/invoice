import 'package:equatable/equatable.dart';

abstract class FieldStaffIncentiveEvent extends Equatable {
  const FieldStaffIncentiveEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the summary cards + active field staff dropdown + first page of
/// the list, for the given date range. Call this once when the screen opens.
class LoadFieldStaffIncentives extends FieldStaffIncentiveEvent {
  final String dateFrom;
  final String dateTo;

  const LoadFieldStaffIncentives({required this.dateFrom, required this.dateTo});

  @override
  List<Object?> get props => [dateFrom, dateTo];
}

/// Pull-to-refresh — reloads summary + list for the current filters.
class RefreshFieldStaffIncentives extends FieldStaffIncentiveEvent {
  const RefreshFieldStaffIncentives();
}

/// Fired when the user picks a staff member from the dropdown
/// (null id = "All Field Staff").
class FilterByFieldStaff extends FieldStaffIncentiveEvent {
  final String? fieldStaffId;

  const FilterByFieldStaff(this.fieldStaffId);

  @override
  List<Object?> get props => [fieldStaffId];
}

/// Fired when the user taps one of the All / Pending / Approved / Paid tabs.
class FilterByStatus extends FieldStaffIncentiveEvent {
  final String status; // all | pending | approved | paid

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Fired when the user picks a different date range (e.g. from a date
/// range picker on the header). Reloads summary + list for the new range.
class FilterByDateRange extends FieldStaffIncentiveEvent {
  final String dateFrom;
  final String dateTo;

  const FilterByDateRange({required this.dateFrom, required this.dateTo});

  @override
  List<Object?> get props => [dateFrom, dateTo];
}

/// Infinite-scroll pagination.
class LoadMoreIncentives extends FieldStaffIncentiveEvent {
  const LoadMoreIncentives();
}

class ClearIncentiveListFeedback extends FieldStaffIncentiveEvent {
  const ClearIncentiveListFeedback();
}