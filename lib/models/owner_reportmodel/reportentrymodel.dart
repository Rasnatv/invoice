/// A single quotation or estimate row as returned by:
///   POST /reports/salesman-performance
///   POST /reports/contractor-performance
///
/// The two source lists use different key names for the "number" field
/// (`quotation_number` vs `estimate_number`) and estimates additionally
/// carry an `approved_at` timestamp, so use the matching factory:
///   ReportEntryModel.fromQuotationJson(json)
///   ReportEntryModel.fromEstimateJson(json)
class ReportEntryModel {
  final String id;
  final String number;
  final String customerName;
  final String customerPhone;
  final DateTime? date;
  final double grandTotal;
  final String status;
  final String statusLabel;
  final String salesmanName;
  final String contractorName;
  final DateTime? approvedAt;
  final bool isEstimate;

  const ReportEntryModel({
    required this.id,
    required this.number,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.grandTotal,
    required this.status,
    required this.statusLabel,
    required this.salesmanName,
    required this.contractorName,
    required this.isEstimate,
    this.approvedAt,
  });

  factory ReportEntryModel.fromQuotationJson(Map<String, dynamic> json) {
    return ReportEntryModel(
      id: json['id']?.toString() ?? '',
      number: json['quotation_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      date: _parseDate(json['date']),
      grandTotal: _parseDouble(json['grand_total']),
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      contractorName: json['contractor_name']?.toString() ?? '',
      isEstimate: false,
    );
  }

  factory ReportEntryModel.fromEstimateJson(Map<String, dynamic> json) {
    return ReportEntryModel(
      id: json['id']?.toString() ?? '',
      number: json['estimate_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      date: _parseDate(json['date']),
      grandTotal: _parseDouble(json['grand_total']),
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      contractorName: json['contractor_name']?.toString() ?? '',
      approvedAt: _parseDate(json['approved_at']),
      isEstimate: true,
    );
  }

  static double _parseDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  static DateTime? _parseDate(dynamic v) {
    final s = v?.toString();
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}