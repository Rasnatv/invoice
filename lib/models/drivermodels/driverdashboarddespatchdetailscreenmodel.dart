/// Response model for POST /drivers/show
class DriverDespatchDetail {
  final String id;
  final String dsNumber;
  final String refNo;
  final String partyName;
  final String contactNumber;
  final String deliveryAddress;
  final String salesmanName;
  final String roleId;
  final String despatchedAtDisplay;
  final String driverName;
  final String driverContact;
  final String statusLabel;
  final double grandTotal;
  final String grandTotalFormatted;
  final List<DriverDespatchItem> items;

  /// Signature captured on delivery — either a base64 data URI (older
  /// records) or a hosted image URL (current mark-delivered response
  /// format: "https://.../storage/signatures/xxx.png"). Null/empty until
  /// the despatch has actually been marked delivered. The UI branches on
  /// the value's shape (http prefix vs data URI) when rendering it.
  final String? customerSignatureBase64;
  final String? driverSignatureBase64;

  const DriverDespatchDetail({
    required this.id,
    required this.dsNumber,
    required this.refNo,
    required this.partyName,
    required this.contactNumber,
    required this.deliveryAddress,
    required this.salesmanName,
    required this.roleId,
    required this.despatchedAtDisplay,
    required this.driverName,
    required this.driverContact,
    required this.statusLabel,
    required this.grandTotal,
    required this.grandTotalFormatted,
    required this.items,
    this.customerSignatureBase64,
    this.driverSignatureBase64,
  });

  bool get isPending => statusLabel.toLowerCase() == 'pending';
  bool get isInTransit => statusLabel.toLowerCase() == 'in transit';
  bool get isDelivered => statusLabel.toLowerCase() == 'delivered';
  bool get isCancelled => statusLabel.toLowerCase() == 'cancelled';

  /// Safely reads a signature value out of the response. Deliberately uses
  /// `?.toString()` instead of an `as String?` hard cast: the backend's
  /// signature format changed recently (base64 -> hosted URL on
  /// mark-delivered), so if `/drivers/show` ever returns this field in a
  /// shape we don't expect (e.g. a nested object, an empty list instead of
  /// null, etc.) we want a null field, not a thrown TypeError that fails
  /// the whole response parse and silently strands the UI on stale data.
  static String? _readSignature(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty || s.toLowerCase() == 'null' ? null : s;
  }

  /// [id] is passed in separately since /drivers/show doesn't echo the id
  /// back in its response body — only the request carries it.
  factory DriverDespatchDetail.fromJson(Map<String, dynamic> json, {required String id}) {
    return DriverDespatchDetail(
      id: id,
      dsNumber: json['ds_number']?.toString() ?? '',
      refNo: json['ref_no']?.toString() ?? '',
      partyName: json['party_name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? '',
      despatchedAtDisplay: json['despatched_at']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      driverContact: json['driver_contact']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      grandTotal: double.tryParse('${json['grand_total'] ?? 0}') ?? 0,
      grandTotalFormatted: json['grand_total_formatted']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => DriverDespatchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerSignatureBase64: _readSignature(json['customer_signature']),
      driverSignatureBase64: _readSignature(json['driver_signature']),
    );
  }
}

class DriverDespatchItem {
  final String slNo;
  final String itemName;
  final String company;
  final String size;
  final String boxes;
  final String pieces;
  final String quantity;

  const DriverDespatchItem({
    required this.slNo,
    required this.itemName,
    required this.company,
    required this.size,
    required this.boxes,
    required this.pieces,
    required this.quantity,
  });

  factory DriverDespatchItem.fromJson(Map<String, dynamic> json) {
    return DriverDespatchItem(
      slNo: json['sl_no']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      boxes: json['boxes']?.toString() ?? '',
      pieces: json['pieces']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
    );
  }
}