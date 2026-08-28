import 'package:equatable/equatable.dart';
import '../../../models/owner_reportmodel/quotationreportmodel.dart';

abstract class QuotationReportState extends Equatable {
  const QuotationReportState();

  @override
  List<Object?> get props => [];
}

class QuotationReportInitial extends QuotationReportState {
  const QuotationReportInitial();
}

class QuotationReportLoading extends QuotationReportState {
  const QuotationReportLoading();
}

/// `data.summary` and `data.list` come straight from the API response —
/// the UI just renders them, it never re-filters or re-labels rows itself.
class QuotationReportLoaded extends QuotationReportState {
  const QuotationReportLoaded({
    required this.data,
    required this.type,
    required this.personName,
    required this.fromDate,
    required this.toDate,
    required this.status,
  });

  final QuotationReportDataModel data;
  final String type;
  final String personName;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;

  @override
  List<Object?> get props => [data, type, personName, fromDate, toDate, status];
}

class QuotationReportError extends QuotationReportState {
  const QuotationReportError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class QuotationReportUnauthorized extends QuotationReportState {
  const QuotationReportUnauthorized();
}