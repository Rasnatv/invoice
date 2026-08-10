import 'package:intl/intl.dart';

double _asDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _asString(dynamic v) => v?.toString() ?? '';

/// Single row from GET /quotations/my → data.list[].
///
/// Server sends every numeric value as a string (e.g. "88000"), so all
/// parsing goes through the `_as*` helpers above rather than assuming a
/// JSON type.
class QuotationListItem {
  final String id;
  final String quotationNumber;
  final String estimateNumber;
  final String customerName;

  /// Raw status string from the server: 'draft', 'sent', etc. Kept as-is
  /// (not an enum) so the UI can display whatever the backend sends
  /// without this model going stale if new statuses are added.
  final String status;

  final DateTime? date;
  final int totalItems;
  final double totalQuantity;
  final double grandTotal;

  const QuotationListItem({
    required this.id,
    required this.quotationNumber,
    required this.estimateNumber,
    required this.customerName,
    required this.status,
    required this.date,
    required this.totalItems,
    required this.totalQuantity,
    required this.grandTotal,
  });

  factory QuotationListItem.fromJson(Map<String, dynamic> json) {
    return QuotationListItem(
      id: _asString(json['id']),
      quotationNumber: _asString(json['quotation_number']),
      estimateNumber: _asString(json['estimate_number']),
      customerName: _asString(json['customer_name']),
      status: _asString(json['status']),
      date: _parseDate(_asString(json['date'])),
      totalItems: _asInt(json['total_items']),
      totalQuantity: _asDouble(json['total_quantity']),
      grandTotal: _asDouble(json['grand_total']),
    );
  }

  static DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      // Server sends this list's date as dd-MM-yyyy.
      return DateFormat('dd-MM-yyyy').parseStrict(raw);
    } catch (_) {
      return DateTime.tryParse(raw);
    }
  }

  bool get isDraft => status.toLowerCase() == 'draft';

  QuotationListItem copyWith({String? status}) {
    return QuotationListItem(
      id: id,
      quotationNumber: quotationNumber,
      estimateNumber: estimateNumber,
      customerName: customerName,
      status: status ?? this.status,
      date: date,
      totalItems: totalItems,
      totalQuantity: totalQuantity,
      grandTotal: grandTotal,
    );
  }
}

class QuotationListResponseModel {
  final String status;
  final String statusCode;
  final List<QuotationListItem> list;
  final String message;

  const QuotationListResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory QuotationListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = (data is Map<String, dynamic>) ? data['list'] : null;
    return QuotationListResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
      list: rawList is List
          ? rawList
          .whereType<Map>()
          .map((e) => QuotationListItem.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
    );
  }
}