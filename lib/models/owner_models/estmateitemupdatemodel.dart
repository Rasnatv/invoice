/// Request model for:
/// POST https://neethu.astradevelops.in/ceramo/public/api/estimates/update-item
class UpdateEstimateItemRequest {
  final int estimateId;
  final int estimateItemId;
  final int quantity;
  final double rate;
  final int boxQuantity;
  final int pieceQuantity;

  UpdateEstimateItemRequest({
    required this.estimateId,
    required this.estimateItemId,
    required this.quantity,
    required this.rate,
    required this.boxQuantity,
    required this.pieceQuantity,
  });

  factory UpdateEstimateItemRequest.fromJson(Map<String, dynamic> json) {
    return UpdateEstimateItemRequest(
      estimateId: json['estimate_id'] as int,
      estimateItemId: json['estimate_item_id'] as int,
      quantity: json['quantity'] as int,
      rate: (json['rate'] as num).toDouble(),
      boxQuantity: json['box_quantity'] as int,
      pieceQuantity: json['piece_quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimate_id': estimateId,
      'estimate_item_id': estimateItemId,
      'quantity': quantity,
      'rate': rate,
      'box_quantity': boxQuantity,
      'piece_quantity': pieceQuantity,
    };
  }
}

/// Response model for the same endpoint.
/// Example response:
/// {
///   "status": "1",
///   "status_code": "200",
///   "data": {},
///   "message": "Item updated successfully"
/// }
class UpdateEstimateItemResponse {
  final String status;
  final String statusCode;
  final Map<String, dynamic> data;
  final String message;

  UpdateEstimateItemResponse({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory UpdateEstimateItemResponse.fromJson(Map<String, dynamic> json) {
    return UpdateEstimateItemResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'status_code': statusCode,
      'data': data,
      'message': message,
    };
  }

  /// Convenience getter since API returns status as string "1"/"0"
  bool get isSuccess => status == '1';
}