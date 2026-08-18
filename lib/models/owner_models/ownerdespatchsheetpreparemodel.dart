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

// ---------------------------------------------------------------------
// POST /despatches/suggest  — body: { "estimate_id": "5" }
// ---------------------------------------------------------------------

class DespatchSuggestionItem {
  final String estimateItemId;
  final String productName;
  final String unit;
  final double remainingQuantity;
  final int suggestedBoxes;
  final int suggestedPieces;
  final double suggestedQuantity;

  const DespatchSuggestionItem({
    required this.estimateItemId,
    required this.productName,
    required this.unit,
    required this.remainingQuantity,
    required this.suggestedBoxes,
    required this.suggestedPieces,
    required this.suggestedQuantity,
  });

  factory DespatchSuggestionItem.fromJson(Map<String, dynamic> json) {
    return DespatchSuggestionItem(
      estimateItemId: _asString(json['estimate_item_id']),
      productName: _asString(json['product_name']),
      unit: _asString(json['unit']),
      remainingQuantity: _asDouble(json['remaining_quantity']),
      suggestedBoxes: _asInt(json['suggested_boxes']),
      suggestedPieces: _asInt(json['suggested_pieces']),
      suggestedQuantity: _asDouble(json['suggested_quantity']),
    );
  }
}

class DespatchSuggestionModel {
  final String estimateId;
  final String estimateNumber;
  final String partyName;
  final String contactNumber;
  final String deliveryAddress;
  final String previewDsNumber;
  final List<DespatchSuggestionItem> items;

  const DespatchSuggestionModel({
    required this.estimateId,
    required this.estimateNumber,
    required this.partyName,
    required this.contactNumber,
    required this.deliveryAddress,
    required this.previewDsNumber,
    required this.items,
  });

  factory DespatchSuggestionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return DespatchSuggestionModel(
      estimateId: _asString(json['estimate_id']),
      estimateNumber: _asString(json['estimate_number']),
      partyName: _asString(json['party_name']),
      contactNumber: _asString(json['contact_number']),
      deliveryAddress: _asString(json['delivery_address']),
      previewDsNumber: _asString(json['preview_ds_number']),
      items: rawItems is List
          ? rawItems
          .whereType<Map>()
          .map((e) => DespatchSuggestionItem.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
    );
  }
}

class DespatchSuggestionResponseModel {
  final String status;
  final String statusCode;
  final DespatchSuggestionModel? data;
  final String message;

  const DespatchSuggestionResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory DespatchSuggestionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DespatchSuggestionResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
      data: data is Map<String, dynamic> && data.isNotEmpty
          ? DespatchSuggestionModel.fromJson(data)
          : null,
    );
  }
}

// ---------------------------------------------------------------------
// GET /drivers/active
// ---------------------------------------------------------------------

class DriverModel {
  final String id;
  final String name;

  const DriverModel({required this.id, required this.name});

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: _asString(json['id']),
      name: _asString(json['name']),
    );
  }
}

class DriverListResponseModel {
  final String status;
  final String statusCode;
  final List<DriverModel> list;
  final String message;

  const DriverListResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory DriverListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = data is Map<String, dynamic> ? data['list'] : null;
    return DriverListResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
      list: rawList is List
          ? rawList
          .whereType<Map>()
          .map((e) => DriverModel.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
    );
  }
}

// ---------------------------------------------------------------------
// POST /despatches/create
// ---------------------------------------------------------------------

class OwnerDespatchItemRequest {
  final String estimateItemId;
  final int boxes;
  final int pieces;
  final double quantity;

  const OwnerDespatchItemRequest({
    required this.estimateItemId,
    required this.boxes,
    required this.pieces,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'estimate_item_id': int.tryParse(estimateItemId) ?? estimateItemId,
    'boxes': boxes,
    'pieces': pieces,
    'quantity': quantity,
  };
}

class OwnerDespatchCreateRequest {
  final String estimateId;
  final String refNo;
  final String partyName;
  final String contactNumber;
  final String deliveryAddress;
  final String driverId;
  final String driverName;
  final String vehicleNumber;
  final List<OwnerDespatchItemRequest> items;
  final String despatchDate; // yyyy-MM-dd
  final String? deliveryNotes;

  const OwnerDespatchCreateRequest({
    required this.estimateId,
    required this.refNo,
    required this.partyName,
    required this.contactNumber,
    required this.deliveryAddress,
    required this.driverId,
    required this.driverName,
    required this.vehicleNumber,
    required this.items,
    required this.despatchDate,
    this.deliveryNotes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'estimate_id': int.tryParse(estimateId) ?? estimateId,
      'ref_no': refNo,
      'party_name': partyName,
      'contact_number': contactNumber,
      'delivery_address': deliveryAddress,
      'driver_id': int.tryParse(driverId) ?? driverId,
      'driver_name': driverName,
      'vehicle_number': vehicleNumber,
      'items': items.map((e) => e.toJson()).toList(),
      'despatch_date': despatchDate,
    };
    if (deliveryNotes != null && deliveryNotes!.trim().isNotEmpty) {
      map['delivery_notes'] = deliveryNotes!.trim();
    }
    return map;
  }
}

/// Generic success/message result — matches the {status, status_code,
/// data, message} shape returned by /despatches/create.
class OwnerDespatchActionResult {
  final bool success;
  final String message;
  const OwnerDespatchActionResult({required this.success, required this.message});
}