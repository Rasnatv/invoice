
/// Request body for the quotation report endpoint.
class QuotationReportRequest {
  const QuotationReportRequest({
    this.type = '',
    this.personId = '',
    required this.fromDate,
    required this.toDate,
    this.status = 'all',
  });

  /// 'salesman' or 'contractor'. Empty = all.
  final String type;

  /// Empty = all people.
  final String personId;

  /// yyyy-MM-dd
  final String fromDate;

  /// yyyy-MM-dd
  final String toDate;

  /// 'all' or a specific status key understood by the backend.
  final String status;

  /// True when no specific person is chosen (the "All" report).
  bool get isAll => personId.trim().isEmpty;

  Map<String, dynamic> toJson() => {
    // For the "All" report both type and person_id must be blank.
    'type': isAll ? '' : type,
    'person_id': isAll ? '' : personId,
    'from_date': fromDate,
    'to_date': toDate,
    'status': status,
  };
}

/// Safe parsers — the backend sends numbers as strings ("4", "102295.00"),
/// but this also copes with real numbers, null and blank values.
int _toInt(dynamic v) => int.tryParse('${v ?? 0}'.trim()) ?? 0;
double _toDouble(dynamic v) => double.tryParse('${v ?? 0}'.trim()) ?? 0;

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
      totalQuotations: _toInt(json['total_quotations']),
      totalValue: _toDouble(json['total_value']),
      pendingCount: _toInt(json['pending_count']),
    );
  }
}

/// One row of the report list. `status` is the raw backend key (e.g. "draft"),
/// `statusLabel` is what the backend wants shown to the user (e.g. "Draft").
/// The UI should always render `statusLabel` and never re-derive it locally.
///
/// In the "All" report a row can belong to a salesman, a contractor, or
/// neither (both names empty) — use [ownerName] for display.
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

  /// Who raised the quotation: salesman, else contractor, else empty.
  String get ownerName {
    if (salesmanName.trim().isNotEmpty) return salesmanName.trim();
    if (contractorName.trim().isNotEmpty) return contractorName.trim();
    return '';
  }

  /// 'Salesman' / 'Contractor' / '' — handy for a small tag in the "All" list.
  String get ownerType {
    if (salesmanName.trim().isNotEmpty) return 'Salesman';
    if (contractorName.trim().isNotEmpty) return 'Contractor';
    return '';
  }

  factory QuotationListItemModel.fromJson(Map<String, dynamic> json) {
    final status = '${json['status'] ?? ''}';
    final label = '${json['status_label'] ?? ''}'.trim();
    return QuotationListItemModel(
      id: '${json['id'] ?? ''}',
      quotationNumber: '${json['quotation_number'] ?? ''}',
      customerName: '${json['customer_name'] ?? ''}',
      customerPhone: '${json['customer_phone'] ?? ''}',
      date: DateTime.tryParse('${json['date'] ?? ''}'),
      grandTotal: _toDouble(json['grand_total']),
      status: status,
      statusLabel: label.isNotEmpty ? label : status,
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