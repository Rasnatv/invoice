
import 'package:equatable/equatable.dart';

abstract class EstimateReportEvent extends Equatable {
  const EstimateReportEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on screen open, when the status chip changes, and when the
/// user scrolls to the bottom (page > 1 = load more).
class FetchEstimateReport extends EstimateReportEvent {
  const FetchEstimateReport({
    required this.type,
    required this.personId,
    required this.personName,
    required this.fromDate,
    required this.toDate,
    this.status = 'all',
    this.page = 1,
  });

  final String type;
  final String personId;
  final String personName;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;

  /// 1 = fresh load (replaces list). >1 = load more (appends).
  final int page;

  @override
  List<Object?> get props =>
      [type, personId, personName, fromDate, toDate, status, page];
}