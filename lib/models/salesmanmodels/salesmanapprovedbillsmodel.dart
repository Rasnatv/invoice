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

/// Single row from GET /estimates/myapproved → data.list[].
class ApprovedEstimateListItem {
  final String id;
  final String estimateNumber;
  final String dateRaw;
  final DateTime? date;
  final String customerName;
  final double grandTotal;
  final String status;
  final int totalItems;
  final String salesmanName;
  final String createdBy;
  final String approvedBy;
  final String approvedAt;
  final String balanceStatusLabel;
  final double balanceAmount;
  final double totalPaid;

  const ApprovedEstimateListItem({
    required this.id,
    required this.estimateNumber,
    required this.dateRaw,
    required this.date,
    required this.customerName,
    required this.grandTotal,
    required this.status,
    required this.totalItems,
    required this.salesmanName,
    required this.createdBy,
    required this.approvedBy,
    required this.approvedAt,
    required this.balanceStatusLabel,
    required this.balanceAmount,
    required this.totalPaid,
  });

  factory ApprovedEstimateListItem.fromJson(Map<String, dynamic> json) {
    final dateRaw = _asString(json['date']);
    return ApprovedEstimateListItem(
      id: _asString(json['id']),
      estimateNumber: _asString(json['estimate_number']),
      dateRaw: dateRaw,
      date: DateTime.tryParse(dateRaw),
      customerName: _asString(json['customer_name']),
      grandTotal: _asDouble(json['grand_total']),
      status: _asString(json['status']),
      totalItems: _asInt(json['total_items']),
      salesmanName: _asString(json['salesman_name']),
      createdBy: _asString(json['created_by']),
      approvedBy: _asString(json['approved_by']),
      approvedAt: _asString(json['approved_at']),
      balanceStatusLabel: _asString(json['balance_status_label']),
      balanceAmount: _asDouble(json['balance_amount']),
      totalPaid: _asDouble(json['total_paid']),
    );
  }
}

class ApprovedEstimateListResponseModel {
  final String status;
  final String statusCode;
  final List<ApprovedEstimateListItem> list;
  final String message;

  const ApprovedEstimateListResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory ApprovedEstimateListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = (data is Map<String, dynamic>) ? data['list'] : null;
    return ApprovedEstimateListResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
      list: rawList is List
          ? rawList
          .whereType<Map>()
          .map((e) => ApprovedEstimateListItem.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
    );
  }
}