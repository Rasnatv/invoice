String _asString(dynamic v) => v?.toString() ?? '';

/// Body for POST /quotations/approve.
///
/// Only [id] is required. Everything else — handling charge override,
/// discount, and an initial payment — is optional and only included in
/// the outgoing JSON when the owner actually filled it in on screen.
class QuotationApproveRequest {
  final String id;

  final double? handlingCharge;
  final String? approvalNotes;

  // Discount
  final String? discountType; // e.g. 'percentage' | 'flat'
  final double? discountValue;
  final String? discountNotes;

  // Initial payment
  final double? paymentAmount;
  final String? paymentMethod; // e.g. 'online' | 'cash' | 'cheque'
  final String? paymentReference;
  final String? paymentDate; // yyyy-MM-dd
  final String? paymentNotes;

  const QuotationApproveRequest({
    required this.id,
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
    final map = <String, dynamic>{'id': id};

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

  /// True when at least one discount field has been filled in — used by
  /// the UI to decide whether to send discount fields at all.
  bool get hasDiscount =>
      (discountType != null && discountType!.isNotEmpty) || discountValue != null;

  /// True when at least one payment field has been filled in.
  bool get hasPayment => paymentAmount != null;
}

class QuotationApproveResponseModel {
  final String status;
  final String statusCode;
  final String message;

  const QuotationApproveResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory QuotationApproveResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationApproveResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
    );
  }
}