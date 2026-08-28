/// Request/response models for:
///   POST /reports/salesman-performance
///   body: { "salesman_id": 10, "from_date": "2026-08-01", "to_date": "2026-08-31" }
///
/// Matches the sample payload shape:
/// {
///   "status": "1",
///   "status_code": "200",
///   "data": {
///     "salesman_name": "...",
///     "summary": { "quotations_made": "13", "estimates_made": "17", ... },
///     "quotations": [ { "id": "18", "quotation_number": "QOT0013-08-26", ... } ],
///     "estimates":  [ { "id": "41", "estimate_number": "REF0037-08-26", ... } ]
///   },
///   "message": "Salesman performance report"
/// }

class SalesmanPerformanceReportRequest {
  final String salesmanId;
  final DateTime fromDate;
  final DateTime toDate;

  const SalesmanPerformanceReportRequest({
    required this.salesmanId,
    required this.fromDate,
    required this.toDate,
  });

  Map<String, dynamic> toJson() => {
    // API sample sends salesman_id as a number - fall back to the raw
    // string if it isn't numeric so nothing silently gets dropped.
    'salesman_id': int.tryParse(salesmanId) ?? salesmanId,
    'from_date': _fmt(fromDate),
    'to_date': _fmt(toDate),
  };

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class SalesmanPerformanceSummary {
  final String quotationsMade;
  final String estimatesMade;
  final String totalSales;
  final String conversionRate;
  final String incentiveEarned;
  final String targetAchieved;

  const SalesmanPerformanceSummary({
    required this.quotationsMade,
    required this.estimatesMade,
    required this.totalSales,
    required this.conversionRate,
    required this.incentiveEarned,
    required this.targetAchieved,
  });

  static const empty = SalesmanPerformanceSummary(
    quotationsMade: '0',
    estimatesMade: '0',
    totalSales: '0',
    conversionRate: '0',
    incentiveEarned: '0',
    targetAchieved: '0',
  );

  factory SalesmanPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return SalesmanPerformanceSummary(
      quotationsMade: json['quotations_made']?.toString() ?? '0',
      estimatesMade: json['estimates_made']?.toString() ?? '0',
      totalSales: json['total_sales']?.toString() ?? '0',
      conversionRate: json['conversion_rate']?.toString() ?? '0',
      incentiveEarned: json['incentive_earned']?.toString() ?? '0',
      targetAchieved: json['target_achieved']?.toString() ?? '0',
    );
  }

  int get quotationsMadeCount => int.tryParse(quotationsMade) ?? 0;
  int get estimatesMadeCount => int.tryParse(estimatesMade) ?? 0;
  double get totalSalesValue => double.tryParse(totalSales) ?? 0;
  double get conversionRateValue => double.tryParse(conversionRate) ?? 0;
  double get incentiveEarnedValue => double.tryParse(incentiveEarned) ?? 0;
  double get targetAchievedValue => double.tryParse(targetAchieved) ?? 0;
}

class SalesmanPerformanceQuotationItem {
  final String id;
  final String quotationNumber;
  final String customerName;
  final String customerPhone;
  final String date;
  final String grandTotal;
  final String status;
  final String statusLabel;
  final String salesmanName;
  final String contractorName;

  const SalesmanPerformanceQuotationItem({
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

  factory SalesmanPerformanceQuotationItem.fromJson(Map<String, dynamic> json) {
    return SalesmanPerformanceQuotationItem(
      id: json['id']?.toString() ?? '',
      quotationNumber: json['quotation_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      grandTotal: json['grand_total']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      contractorName: json['contractor_name']?.toString() ?? '',
    );
  }

  double get grandTotalValue => double.tryParse(grandTotal) ?? 0;
  DateTime? get dateValue => DateTime.tryParse(date);
}

class SalesmanPerformanceEstimateItem {
  final String id;
  final String estimateNumber;
  final String customerName;
  final String customerPhone;
  final String date;
  final String grandTotal;
  final String status;
  final String statusLabel;
  final String salesmanName;
  final String contractorName;
  final String approvedAt;

  const SalesmanPerformanceEstimateItem({
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

  factory SalesmanPerformanceEstimateItem.fromJson(Map<String, dynamic> json) {
    return SalesmanPerformanceEstimateItem(
      id: json['id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      grandTotal: json['grand_total']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      contractorName: json['contractor_name']?.toString() ?? '',
      approvedAt: json['approved_at']?.toString() ?? '',
    );
  }

  double get grandTotalValue => double.tryParse(grandTotal) ?? 0;
  DateTime? get dateValue => DateTime.tryParse(date);
}

class SalesmanPerformanceReportData {
  final String salesmanName;
  final SalesmanPerformanceSummary summary;
  final List<SalesmanPerformanceQuotationItem> quotations;
  final List<SalesmanPerformanceEstimateItem> estimates;

  const SalesmanPerformanceReportData({
    required this.salesmanName,
    required this.summary,
    required this.quotations,
    required this.estimates,
  });

  factory SalesmanPerformanceReportData.fromJson(Map<String, dynamic> json) {
    return SalesmanPerformanceReportData(
      salesmanName: json['salesman_name']?.toString() ?? '',
      summary: SalesmanPerformanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      quotations: (json['quotations'] as List<dynamic>? ?? const [])
          .map((e) => SalesmanPerformanceQuotationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimates: (json['estimates'] as List<dynamic>? ?? const [])
          .map((e) => SalesmanPerformanceEstimateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SalesmanPerformanceReportResponseModel {
  final String status;
  final String statusCode;
  final SalesmanPerformanceReportData? data;
  final String message;

  const SalesmanPerformanceReportResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory SalesmanPerformanceReportResponseModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    return SalesmanPerformanceReportResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: dataJson == null ? null : SalesmanPerformanceReportData.fromJson(dataJson),
      message: json['message']?.toString() ?? '',
    );
  }
}