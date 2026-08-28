// POST /reports/estimates?page=&per_page=
// Body:  { type: 'salesman' | 'contractor', person_id, from_date, to_date, status }
// Response shape matches the sample you shared:
// { status, status_code, data: { summary, list }, message }

/// Request body for the estimate report endpoint.
class EstimateReportRequest {
  const EstimateReportRequest({
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

class EstimateReportSummaryModel {
  const EstimateReportSummaryModel({
    required this.totalEstimates,
    required this.totalValue,
    required this.convertedCount,
    required this.pendingCount,
  });

  final int totalEstimates;
  final double totalValue;
  final int convertedCount;
  final int pendingCount;

  static const empty = EstimateReportSummaryModel(
    totalEstimates: 0,
    totalValue: 0,
    convertedCount: 0,
    pendingCount: 0,
  );

  factory EstimateReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return EstimateReportSummaryModel(
      totalEstimates: int.tryParse('${json['total_estimates'] ?? 0}') ?? 0,
      totalValue: double.tryParse('${json['total_value'] ?? 0}') ?? 0,
      convertedCount: int.tryParse('${json['converted_count'] ?? 0}') ?? 0,
      pendingCount: int.tryParse('${json['pending_count'] ?? 0}') ?? 0,
    );
  }
}

/// One row of the estimate report list. `status` is the raw backend key
/// (e.g. "despatched"), `statusLabel` is what the backend wants shown to
/// the user (e.g. "Despatched"). The UI should always render `statusLabel`
/// and never re-derive it locally.
class EstimateListItemModel {
  const EstimateListItemModel({
    required this.id,
    required this.estimateNumber,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.grandTotal,
    required this.status,
    required this.statusLabel,
    required this.salesmanName,
    required this.contractorName,
    required this.approvedAt,
  });

  final String id;
  final String estimateNumber;
  final String customerName;
  final String customerPhone;
  final DateTime? date;
  final double grandTotal;
  final String status;
  final String statusLabel;
  final String salesmanName;
  final String contractorName;

  /// Null when the estimate hasn't been approved yet (backend sends "").
  final DateTime? approvedAt;

  factory EstimateListItemModel.fromJson(Map<String, dynamic> json) {
    final approvedRaw = '${json['approved_at'] ?? ''}';
    return EstimateListItemModel(
      id: '${json['id'] ?? ''}',
      estimateNumber: '${json['estimate_number'] ?? ''}',
      customerName: '${json['customer_name'] ?? ''}',
      customerPhone: '${json['customer_phone'] ?? ''}',
      date: DateTime.tryParse('${json['date'] ?? ''}'),
      grandTotal: double.tryParse('${json['grand_total'] ?? 0}') ?? 0,
      status: '${json['status'] ?? ''}',
      statusLabel: '${json['status_label'] ?? json['status'] ?? ''}',
      salesmanName: '${json['salesman_name'] ?? ''}',
      contractorName: '${json['contractor_name'] ?? ''}',
      approvedAt: approvedRaw.isEmpty ? null : DateTime.tryParse(approvedRaw),
    );
  }
}

class EstimateReportDataModel {
  const EstimateReportDataModel({required this.summary, required this.list});

  final EstimateReportSummaryModel summary;
  final List<EstimateListItemModel> list;

  static const empty = EstimateReportDataModel(
    summary: EstimateReportSummaryModel.empty,
    list: [],
  );

  factory EstimateReportDataModel.fromJson(Map<String, dynamic> json) {
    return EstimateReportDataModel(
      summary: EstimateReportSummaryModel.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      list: ((json['list'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EstimateListItemModel.fromJson)
          .toList(),
    );
  }
}

class EstimateReportResponseModel {
  const EstimateReportResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final EstimateReportDataModel? data;
  final String message;

  factory EstimateReportResponseModel.fromJson(Map<String, dynamic> json) {
    return EstimateReportResponseModel(
      status: '${json['status'] ?? ''}',
      statusCode: '${json['status_code'] ?? ''}',
      data: json['data'] is Map<String, dynamic>
          ? EstimateReportDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: '${json['message'] ?? ''}',
    );
  }
}