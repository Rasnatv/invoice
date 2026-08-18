/// Row model for GET /despatches/my (dispatch bill listing).
class DispatchListItem {
  final String id;
  final String dsNumber;
  final String estimateNumber;
  final String partyName;
  final String status; // pending | in_transit | delivered
  final int totalItems;
  final String despatchedBy;
  final double totalAmount;
  final DateTime? despatchDate;
  final DateTime? deliveredAt;
  final String balanceStatus;

  const DispatchListItem({
    required this.id,
    required this.dsNumber,
    required this.estimateNumber,
    required this.partyName,
    required this.status,
    required this.totalItems,
    required this.despatchedBy,
    required this.totalAmount,
    this.despatchDate,
    this.deliveredAt,
    required this.balanceStatus,
  });

  factory DispatchListItem.fromJson(Map<String, dynamic> json) {
    return DispatchListItem(
      id: json['id']?.toString() ?? '',
      dsNumber: json['ds_number']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      partyName: json['party_name']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      totalItems: int.tryParse(json['total_items']?.toString() ?? '') ?? 0,
      despatchedBy: json['despatched_by']?.toString() ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '') ?? 0,
      despatchDate: _parseDate(json['despatch_date']?.toString()),
      deliveredAt: _parseDate(json['delivered_at']?.toString()),
      balanceStatus: json['balance_status']?.toString() ?? '',
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool get isPending => status == 'pending';
  bool get isInTransit => status == 'in_transit';
  bool get isDelivered => status == 'delivered';
}

/// Envelope for GET /despatches/my — `{ status, message, data: { list: [...] } }`.
class DispatchListResponseModel {
  final String status;
  final String message;
  final List<DispatchListItem> data;

  const DispatchListResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DispatchListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawList = (rawData is Map ? rawData['list'] : null) as List<dynamic>? ?? const [];
    return DispatchListResponseModel(
      status: json['status']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
      data: rawList
          .map((e) => DispatchListItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
