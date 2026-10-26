
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

  /// Date as dd-MM-yyyy text. Empty if missing.
  String get dateLabel => _formatDate(date);

  /// Approved date as dd-MM-yyyy text. Empty if not approved yet.
  String get approvedAtLabel => _formatDate(approvedAt);

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

  static double _parseDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '') ?? 0;

  /// Parses "23-10-2026" (dd-MM-yyyy), "23/10/2026" or ISO "2026-10-23".
  static DateTime? _parseDate(dynamic v) {
    final s = v?.toString().trim();
    if (s == null || s.isEmpty) return null;

    final m = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(s);
    if (m != null) {
      return DateTime(
        int.parse(m.group(3)!),
        int.parse(m.group(2)!),
        int.parse(m.group(1)!),
      );
    }
    return DateTime.tryParse(s);
  }

  static String _formatDate(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
  }
}