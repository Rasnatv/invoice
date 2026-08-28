import 'package:equatable/equatable.dart';

abstract class EstimateReportEvent extends Equatable {
  const EstimateReportEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on screen open, and again whenever the status chip changes
/// (re-fetched with the newly selected status).
class FetchEstimateReport extends EstimateReportEvent {
  const FetchEstimateReport({
    required this.type,
    required this.personId,
    required this.personName,
    required this.fromDate,
    required this.toDate,
    this.status = 'all',
  });

  /// 'salesman' or 'contractor' — sent as-is to the API.
  final String type;
  final String personId;

  /// Kept only for display in the screen header, not sent to the API.
  final String personName;

  final DateTime fromDate;
  final DateTime toDate;

  /// 'all' or a backend status key.
  final String status;

  @override
  List<Object?> get props => [type, personId, personName, fromDate, toDate, status];
}