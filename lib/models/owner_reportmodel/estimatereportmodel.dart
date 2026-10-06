

/// Request body for the estimate report endpoint.
class EstimateReportRequest {
  const EstimateReportRequest({
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

/// Safe parsers — the backend sends numbers as strings ("13", "115875.00"),
/// but this also copes with real numbers, null and blank values.
int _toInt(dynamic v) => int.tryParse('${v ?? 0}'.trim()) ?? 0;
double _toDouble(dynamic v) => double.tryParse('${v ?? 0}'.trim()) ?? 0;

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
      totalEstimates: _toInt(json['total_estimates']),
      totalValue: _toDouble(json['total_value']),
      convertedCount: _toInt(json['converted_count']),
      pendingCount: _toInt(json['pending_count']),
    );
  }
}

/// One row of the estimate report list. `status` is the raw backend key
/// (e.g. "despatched"), `statusLabel` is what the backend wants shown to
/// the user (e.g. "Despatched"). The UI should always render `statusLabel`
/// and never re-derive it locally.
///
/// In the "All" report a row can belong to a salesman, a contractor, both,
/// or neither (both names empty) — use [ownerName] for display.
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

  /// Who raised the estimate: salesman, else contractor, else empty.
  String get ownerName {
    if (salesmanName.trim().isNotEmpty) return salesmanName.trim();
    if (contractorName.trim().isNotEmpty) return contractorName.trim();
    return '';
  }

  factory EstimateListItemModel.fromJson(Map<String, dynamic> json) {
    final approvedRaw = '${json['approved_at'] ?? ''}'.trim();
    final status = '${json['status'] ?? ''}';
    final label = '${json['status_label'] ?? ''}'.trim();
    return EstimateListItemModel(
      id: '${json['id'] ?? ''}',
      estimateNumber: '${json['estimate_number'] ?? ''}',
      customerName: '${json['customer_name'] ?? ''}',
      customerPhone: '${json['customer_phone'] ?? ''}',
      date: DateTime.tryParse('${json['date'] ?? ''}'),
      grandTotal: _toDouble(json['grand_total']),
      status: status,
      statusLabel: label.isNotEmpty ? label : status,
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