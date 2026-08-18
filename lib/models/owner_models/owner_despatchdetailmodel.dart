/// Line item as returned inside the `items` array of
/// POST /despatches/show, /mark-in-transit and /mark-delivered.
class DispatchItemDetail {
  final String id;
  final String estimateItemId;
  final String productName;
  final String productSize;
  final String packing;
  final double boxes;
  final double pieces;
  final double quantity;

  const DispatchItemDetail({
    required this.id,
    required this.estimateItemId,
    required this.productName,
    required this.productSize,
    required this.packing,
    required this.boxes,
    required this.pieces,
    required this.quantity,
  });

  factory DispatchItemDetail.fromJson(Map<String, dynamic> json) {
    return DispatchItemDetail(
      id: json['id']?.toString() ?? '',
      estimateItemId: json['estimate_item_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productSize: json['product_size']?.toString() ?? '',
      packing: json['packing']?.toString() ?? '',
      boxes: double.tryParse(json['boxes']?.toString() ?? '') ?? 0,
      pieces: double.tryParse(json['pieces']?.toString() ?? '') ?? 0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0,
    );
  }
}

/// Nested `estimate` summary object.
class DispatchEstimateSummary {
  final String id;
  final String estimateNumber;
  final double grandTotal;
  final String status;
  final String balanceStatus;

  const DispatchEstimateSummary({
    required this.id,
    required this.estimateNumber,
    required this.grandTotal,
    required this.status,
    required this.balanceStatus,
  });

  factory DispatchEstimateSummary.fromJson(Map<String, dynamic> json) {
    return DispatchEstimateSummary(
      id: json['id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '',
      balanceStatus: json['balance_status']?.toString() ?? '',
    );
  }
}

/// Full detail model shared by /despatches/show, /mark-in-transit and
/// /mark-delivered — all three endpoints return the same `data` shape.
class DispatchDetail {
  final String id;
  final String dsNumber;
  final String estimateId;
  final String refNo;
  final String partyName;
  final String contactNumber;
  final String deliveryAddress;
  final String driverId;
  final String driverName;
  final String vehicleNumber;
  final String status; // pending | in_transit | delivered
  final DateTime? despatchedAt;
  final DateTime? deliveredAt;
  final String deliveryNotes;
  final String? customerSignature; // base64 data URI, once delivered
  final String? driverSignature; // base64 data URI, once delivered
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DispatchEstimateSummary? estimate;
  final List<DispatchItemDetail> items;
  final String balanceStatus;
  final bool isFullyPaid;

  const DispatchDetail({
    required this.id,
    required this.dsNumber,
    required this.estimateId,
    required this.refNo,
    required this.partyName,
    required this.contactNumber,
    required this.deliveryAddress,
    required this.driverId,
    required this.driverName,
    required this.vehicleNumber,
    required this.status,
    this.despatchedAt,
    this.deliveredAt,
    required this.deliveryNotes,
    this.customerSignature,
    this.driverSignature,
    this.createdAt,
    this.updatedAt,
    this.estimate,
    required this.items,
    required this.balanceStatus,
    required this.isFullyPaid,
  });

  factory DispatchDetail.fromJson(Map<String, dynamic> json) {
    String? nonEmpty(dynamic v) {
      final s = v?.toString() ?? '';
      return s.isEmpty ? null : s;
    }

    return DispatchDetail(
      id: json['id']?.toString() ?? '',
      dsNumber: json['ds_number']?.toString() ?? '',
      estimateId: json['estimate_id']?.toString() ?? '',
      refNo: json['ref_no']?.toString() ?? '',
      partyName: json['party_name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      despatchedAt: _parseDateTime(json['despatched_at']?.toString()),
      deliveredAt: _parseDateTime(json['delivered_at']?.toString()),
      deliveryNotes: json['delivery_notes']?.toString() ?? '',
      customerSignature: nonEmpty(json['customer_signature']),
      driverSignature: nonEmpty(json['driver_signature']),
      createdAt: _parseDateTime(json['created_at']?.toString()),
      updatedAt: _parseDateTime(json['updated_at']?.toString()),
      estimate: json['estimate'] != null
          ? DispatchEstimateSummary.fromJson(Map<String, dynamic>.from(json['estimate']))
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => DispatchItemDetail.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      balanceStatus: json['balance_status']?.toString() ?? '',
      isFullyPaid: (json['is_fully_paid']?.toString() ?? '0') == '1',
    );
  }

  static DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool get isPending => status == 'pending';
  bool get isInTransit => status == 'in_transit';
  bool get isDelivered => status == 'delivered';

  double get grandTotal => estimate?.grandTotal ?? 0;
}

/// Envelope shared by POST /despatches/show, /mark-in-transit and
/// /mark-delivered — `{ status, message, data: {...single dispatch...} }`.
class DispatchDetailResponseModel {
  final String status;
  final String message;
  final DispatchDetail? data;

  const DispatchDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory DispatchDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return DispatchDetailResponseModel(
      status: json['status']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
      data: rawData is Map ? DispatchDetail.fromJson(Map<String, dynamic>.from(rawData)) : null,
    );
  }
}
