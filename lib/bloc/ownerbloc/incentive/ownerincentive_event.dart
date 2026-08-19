import 'package:equatable/equatable.dart';

abstract class OwnerIncentiveEvent extends Equatable {
  const OwnerIncentiveEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the active-salesmen dropdown data. Only relevant when the bloc is
/// created in "owner" mode.
class LoadActiveSalesmen extends OwnerIncentiveEvent {
  const LoadActiveSalesmen();
}

/// Fired when the owner picks a salesman from the dropdown.
/// Automatically triggers a summary reload.
class SelectSalesman extends OwnerIncentiveEvent {
  final String salesmanId;
  final String salesmanName;

  const SelectSalesman({required this.salesmanId, required this.salesmanName});

  @override
  List<Object?> get props => [salesmanId, salesmanName];
}

/// Fired when the month/year picker changes. Automatically triggers a
/// summary reload.
class SelectMonth extends OwnerIncentiveEvent {
  final DateTime month;

  const SelectMonth(this.month);

  @override
  List<Object?> get props => [month];
}

/// Loads (or reloads) the incentive summary for the currently selected
/// salesman + month.
class LoadIncentiveSummary extends OwnerIncentiveEvent {
  const LoadIncentiveSummary();
}

/// Pull-to-refresh style reload, kept as a distinct event so the UI can
/// tell the two apart if it ever needs different loading indicators.
class RefreshIncentiveSummary extends OwnerIncentiveEvent {
  const RefreshIncentiveSummary();
}

/// Submits POST /salesman-incentives/mark-paid for the selected
/// salesman + month.
class MarkIncentiveAsPaid extends OwnerIncentiveEvent {
  final String paymentReference;
  final String paymentDate; // yyyy-MM-dd
  final String? notes;

  const MarkIncentiveAsPaid({
    required this.paymentReference,
    required this.paymentDate,
    this.notes,
  });

  @override
  List<Object?> get props => [paymentReference, paymentDate, notes];
}

/// Resets the mark-paid status back to idle, e.g. after showing a
/// snackbar/dialog for a completed submission.
class ClearMarkPaidStatus extends OwnerIncentiveEvent {
  const ClearMarkPaidStatus();
}