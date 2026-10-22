
import 'package:equatable/equatable.dart';

abstract class QuotationReportEvent extends Equatable {
  const QuotationReportEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on screen open, and again whenever the user changes the
/// status filter. Always loads page 1 and resets the accumulated list.
class FetchQuotationReport extends QuotationReportEvent {
  const FetchQuotationReport({
    required this.type,
    required this.personId,
    required this.personName,
    required this.fromDate,
    required this.toDate,
    this.status = 'all',
  });

  /// '' (All), 'salesman' or 'contractor' — sent as-is to the API.
  final String type;
  final String personId;

  /// Kept only for display in the screen header, not sent to the API.
  final String personName;

  final DateTime fromDate;
  final DateTime toDate;

  /// 'all' or a backend status key.
  final String status;

  @override
  List<Object?> get props =>
      [type, personId, personName, fromDate, toDate, status];
}

/// Dispatched when the user scrolls near the bottom of the list.
/// Loads the next page for the filter currently held in the state.
class LoadMoreQuotationReport extends QuotationReportEvent {
  const LoadMoreQuotationReport();
}