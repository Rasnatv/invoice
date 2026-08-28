import 'package:flutter/foundation.dart';

@immutable
abstract class IncentiveReportEvent {
  const IncentiveReportEvent();
}

/// Fires the POST /reports/incentives call.
///
/// [type] must be exactly 'salesman' or 'field_staff'.
/// [status] is optional — pass null (or 'all') to fetch every status.
class FetchIncentiveReport extends IncentiveReportEvent {
  final String type;
  final String personId;
  final String fromDate;
  final String toDate;
  final String? status;
  final int page;
  final int perPage;

  const FetchIncentiveReport({
    required this.type,
    required this.personId,
    required this.fromDate,
    required this.toDate,
    this.status,
    this.page = 1,
    this.perPage = 10,
  });
}

/// Loads the next page of the currently loaded report and appends it to
/// the list already on screen.
class LoadMoreIncentiveReport extends IncentiveReportEvent {
  const LoadMoreIncentiveReport();
}

class ResetIncentiveReport extends IncentiveReportEvent {
  const ResetIncentiveReport();
}