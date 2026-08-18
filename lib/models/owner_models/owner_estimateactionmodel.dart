/// Request body for POST /estimates/approve.
/// Only `estimateId` is required — every other field is optional and is
/// omitted from the JSON body entirely when null/empty, matching the API
/// contract ("Required only id, others optional").
class OwnerApproveEstimateRequest {
  final String estimateId;
  final double? handlingCharge;
  final String? approvalNotes;

  // Discount
  final String? discountType; // 'percentage' | 'flat'
  final double? discountValue;
  final String? discountNotes;

  // Initial payment
  final double? paymentAmount;
  final String? paymentMethod;
  final String? paymentReference;
  final String? paymentDate; // yyyy-MM-dd
  final String? paymentNotes;

  const OwnerApproveEstimateRequest({
    required this.estimateId,
    this.handlingCharge,
    this.approvalNotes,
    this.discountType,
    this.discountValue,
    this.discountNotes,
    this.paymentAmount,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.paymentNotes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'estimate_id': int.tryParse(estimateId) ?? estimateId,
    };
    if (handlingCharge != null) map['handling_charge'] = handlingCharge;
    if (approvalNotes != null && approvalNotes!.trim().isNotEmpty) {
      map['approval_notes'] = approvalNotes!.trim();
    }
    if (discountType != null && discountType!.isNotEmpty) {
      map['discount_type'] = discountType;
    }
    if (discountValue != null) map['discount_value'] = discountValue;
    if (discountNotes != null && discountNotes!.trim().isNotEmpty) {
      map['discount_notes'] = discountNotes!.trim();
    }
    if (paymentAmount != null) map['payment_amount'] = paymentAmount;
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      map['payment_method'] = paymentMethod;
    }
    if (paymentReference != null && paymentReference!.trim().isNotEmpty) {
      map['payment_reference'] = paymentReference!.trim();
    }
    if (paymentDate != null && paymentDate!.isNotEmpty) {
      map['payment_date'] = paymentDate;
    }
    if (paymentNotes != null && paymentNotes!.trim().isNotEmpty) {
      map['payment_notes'] = paymentNotes!.trim();
    }
    return map;
  }
}

/// Request body for POST /quotations/reject.
class OwnerRejectEstimateRequest {
  final String id;
  final String rejectionNotes;

  const OwnerRejectEstimateRequest({
    required this.id,
    required this.rejectionNotes,
  });

  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? id,
    'rejection_notes': rejectionNotes,
  };
}

/// Generic success/message result for the approve & reject calls, which
/// both just return { status, status_code, data: {}, message }.
class OwnerActionResult {
  final bool success;
  final String message;
  const OwnerActionResult({required this.success, required this.message});
}