// POST /reports/quotations?page=&per_page=
// Body:  { type: 'salesman' | 'contractor', person_id, from_date, to_date, status }
// Response shape matches the sample you shared: { status, status_code, data: { summary, list }, message }

/// Request body for the quotation report endpoint.
class QuotationReportRequest {
  const QuotationReportRequest({
    required this.type,
    required this.personId,
    required this.fromDate,
    required this.toDate,
    this.status = 'all',
  });

  /// 'salesman' or 'contractor'
  final String type;
  final String personId;

  /// yyyy-MM-dd
  final String fromDate;

  /// yyyy-MM-dd
  final String toDate;

  /// 'all' or a specific status key understood by the backend.
  final String status;

  Map<String, dynamic> toJson() => {
    'type': type,
    'person_id': personId,
    'from_date': fromDate,
    'to_date': toDate,
    'status': status,
  };
}

class QuotationReportSummaryModel {
  const QuotationReportSummaryModel({
    required this.totalQuotations,
    required this.totalValue,
    required this.pendingCount,
  });

  final int totalQuotations;
  final double totalValue;
  final int pendingCount;

  static const empty = QuotationReportSummaryModel(
    totalQuotations: 0,
    totalValue: 0,
    pendingCount: 0,
  );

  factory QuotationReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuotationReportSummaryModel(
      totalQuotations: int.tryParse('${json['total_quotations'] ?? 0}') ?? 0,
      totalValue: double.tryParse('${json['total_value'] ?? 0}') ?? 0,
      pendingCount: int.tryParse('${json['pending_count'] ?? 0}') ?? 0,
    );
  }
}

/// One row of the report list. `status` is the raw backend key (e.g. "sent"),
/// `statusLabel` is what the backend wants shown to the user (e.g. "Pending").
/// The UI should always render `statusLabel` and never re-derive it locally.
class QuotationListItemModel {
  const QuotationListItemModel({
    required this.id,
    required this.quotationNumber,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.grandTotal,
    required this.status,
    required this.statusLabel,
    required this.salesmanName,
    required this.contractorName,
  });

  final String id;
  final String quotationNumber;
  final String customerName;
  final String customerPhone;
  final DateTime? date;
  final double grandTotal;
  final String status;
  final String statusLabel;
  final String salesmanName;
  final String contractorName;

  factory QuotationListItemModel.fromJson(Map<String, dynamic> json) {
    return QuotationListItemModel(
      id: '${json['id'] ?? ''}',
      quotationNumber: '${json['quotation_number'] ?? ''}',
      customerName: '${json['customer_name'] ?? ''}',
      customerPhone: '${json['customer_phone'] ?? ''}',
      date: DateTime.tryParse('${json['date'] ?? ''}'),
      grandTotal: double.tryParse('${json['grand_total'] ?? 0}') ?? 0,
      status: '${json['status'] ?? ''}',
      statusLabel: '${json['status_label'] ?? json['status'] ?? ''}',
      salesmanName: '${json['salesman_name'] ?? ''}',
      contractorName: '${json['contractor_name'] ?? ''}',
    );
  }
}

class QuotationReportDataModel {
  const QuotationReportDataModel({required this.summary, required this.list});

  final QuotationReportSummaryModel summary;
  final List<QuotationListItemModel> list;

  static const empty = QuotationReportDataModel(
    summary: QuotationReportSummaryModel.empty,
    list: [],
  );

  factory QuotationReportDataModel.fromJson(Map<String, dynamic> json) {
    return QuotationReportDataModel(
      summary: QuotationReportSummaryModel.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      list: ((json['list'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuotationListItemModel.fromJson)
          .toList(),
    );
  }
}

class QuotationReportResponseModel {
  const QuotationReportResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final QuotationReportDataModel? data;
  final String message;

  factory QuotationReportResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationReportResponseModel(
      status: '${json['status'] ?? ''}',
      statusCode: '${json['status_code'] ?? ''}',
      data: json['data'] is Map<String, dynamic>
          ? QuotationReportDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: '${json['message'] ?? ''}',
    );
  }
}