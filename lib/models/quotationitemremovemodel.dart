String _asString(dynamic v) => v?.toString() ?? '';

/// Body for POST /quotations/remove-item.
///
/// Example:
/// { "quotation_id": 12, "quotation_item_id": 84 }
class QuotationRemoveItemRequest {
  final String quotationId;
  final String quotationItemId;

  const QuotationRemoveItemRequest({
    required this.quotationId,
    required this.quotationItemId,
  });

  Map<String, dynamic> toJson() => {
    'quotation_id': quotationId,
    'quotation_item_id': quotationItemId,
  };
}

/// Response for POST /quotations/remove-item.
///
/// The confirmed real response returns an empty `data: {}` on success —
/// there's nothing to parse out of it besides status/message, e.g.:
/// { "status": "1", "status_code": "200", "data": {}, "message": "Item removed successfully" }
class QuotationRemoveItemResponseModel {
  final String status;
  final String statusCode;
  final String message;

  const QuotationRemoveItemResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory QuotationRemoveItemResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationRemoveItemResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
    );
  }

  bool get isSuccess => status == '1' || statusCode == '200';
}