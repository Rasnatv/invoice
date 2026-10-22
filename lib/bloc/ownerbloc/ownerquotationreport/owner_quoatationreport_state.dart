
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

/// `data.summary` comes straight from the API (page 1 response).
/// `rows` is the accumulated list across every page loaded so far.
class QuotationReportLoaded extends QuotationReportState {
  const QuotationReportLoaded({
    required this.data,
    required this.rows,
    required this.type,
    required this.personId,
    required this.personName,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  /// Summary + first-page payload from the server.
  final QuotationReportDataModel data;

  /// All rows loaded so far (page 1 + every "load more" page).
  final List<QuotationListItemModel> rows;

  final String type;
  final String personId;
  final String personName;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;

  /// Last page successfully loaded.
  final int page;

  /// False once the server returns fewer rows than a full page.
  final bool hasMore;

  /// True while the next page is being fetched (footer spinner).
  final bool isLoadingMore;

  QuotationReportLoaded copyWith({
    List<QuotationListItemModel>? rows,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return QuotationReportLoaded(
      data: data,
      rows: rows ?? this.rows,
      type: type,
      personId: personId,
      personName: personName,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    data,
    rows,
    type,
    personId,
    personName,
    fromDate,
    toDate,
    status,
    page,
    hasMore,
    isLoadingMore,
  ];
}

class QuotationReportError extends QuotationReportState {
  const QuotationReportError(this.message);

  final String? message;

  @override
  List<Object?> get props => [message];
}