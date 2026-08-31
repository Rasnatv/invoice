import 'package:intl/intl.dart';

/// Response model for GET /drivers/dashboard
class DriverDashboardResponse {
  final int total;
  final int pending;
  final int inTransit;
  final int delivered;
  final int cancelled;
  final List<DriverDespatchListItem> list;

  const DriverDashboardResponse({
    required this.total,
    required this.pending,
    required this.inTransit,
    required this.delivered,
    required this.cancelled,
    required this.list,
  });

  factory DriverDashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return DriverDashboardResponse(
      total: int.tryParse('${data['total'] ?? 0}') ?? 0,
      pending: int.tryParse('${data['pending'] ?? 0}') ?? 0,
      inTransit: int.tryParse('${data['in_transit'] ?? 0}') ?? 0,
      delivered: int.tryParse('${data['delivered'] ?? 0}') ?? 0,
      cancelled: int.tryParse('${data['cancelled'] ?? 0}') ?? 0,
      list: (data['list'] as List<dynamic>? ?? [])
          .map((e) => DriverDespatchListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single despatch row from the driver dashboard list.
class DriverDespatchListItem {
  final String id;
  final String dsNumber;
  final String partyName;
  final String address;
  final String contactNumber;
  final int itemsCount;
  final String salesmanName;
  final String roleId;
  final double grandTotal;
  final String statusLabel;
  final DateTime? despatchedAt;
  final DateTime? deliveredAt;

  const DriverDespatchListItem({
    required this.id,
    required this.dsNumber,
    required this.partyName,
    required this.address,
    required this.contactNumber,
    required this.itemsCount,
    required this.salesmanName,
    required this.roleId,
    required this.grandTotal,
    required this.statusLabel,
    this.despatchedAt,
    this.deliveredAt,
  });

  bool get isPending => statusLabel.toLowerCase() == 'pending';
  bool get isInTransit => statusLabel.toLowerCase() == 'in transit';
  bool get isDelivered => statusLabel.toLowerCase() == 'delivered';
  bool get isCancelled => statusLabel.toLowerCase() == 'cancelled';

  factory DriverDespatchListItem.fromJson(Map<String, dynamic> json) {
    return DriverDespatchListItem(
      id: '${json['id'] ?? ''}',
      dsNumber: json['ds_number']?.toString() ?? '',
      partyName: json['party_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      itemsCount: int.tryParse('${json['items_count'] ?? 0}') ?? 0,
      salesmanName: json['salesman_name']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? '',
      grandTotal: double.tryParse('${json['grand_total'] ?? 0}') ?? 0,
      statusLabel: json['status_label']?.toString() ?? '',
      despatchedAt: _parseDate(json['despatched_at']),
      deliveredAt: _parseDate(json['delivered_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(str);
    } catch (_) {
      return null;
    }
  }
}