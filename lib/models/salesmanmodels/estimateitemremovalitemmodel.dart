/// Request/response models for POST /estimates/remove-item.
/// Mirrors quotationitemremovemodel.dart's shape for the quotation
/// endpoint. Server expects numeric ids in the JSON body (matches the
/// confirmed payload: {"estimate_id": 35, "estimate_item_id": 37}), so
/// toJson() coerces the string ids used elsewhere in the app back to
/// ints where possible.
class EstimateRemoveItemRequest {
  final String estimateId;
  final String estimateItemId;

  const EstimateRemoveItemRequest({
    required this.estimateId,
    required this.estimateItemId,
  });

  Map<String, dynamic> toJson() => {
    'estimate_id': int.tryParse(estimateId) ?? estimateId,
    'estimate_item_id': int.tryParse(estimateItemId) ?? estimateItemId,
  };
}

/// The confirmed real response returns an empty `data: {}` on success —
/// nothing to parse out of it beyond status/message. Callers should
/// remove the item from their local item list themselves after a
/// successful call rather than expect anything back in the result.
class EstimateRemoveItemResponseModel {
  final String? message;

  const EstimateRemoveItemResponseModel({this.message});

  factory EstimateRemoveItemResponseModel.fromJson(Map<String, dynamic> json) {
    return EstimateRemoveItemResponseModel(
      message: json['message'] as String?,
    );
  }
}