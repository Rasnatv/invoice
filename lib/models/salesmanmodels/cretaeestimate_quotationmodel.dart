
class QuotationItemRequest {
  final String productId;
  final double quantity;

  /// Number of full boxes for this line item (0 if the product isn't
  /// sold in boxes, or the salesman/owner only entered loose pieces).
  final double boxQuantity;

  /// Number of loose pieces for this line item (in addition to, or
  /// instead of, boxQuantity — matches how stock was actually counted,
  /// not a derived value).
  final double pieceQuantity;

  final double rate;

  const QuotationItemRequest({
    required this.productId,
    required this.quantity,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity.toString(),
    'box_quantity': boxQuantity.toString(),
    'piece_quantity': pieceQuantity.toString(),
    'rate': rate.toString(),
  };
}

/// discount_type values accepted by the API.
class QuotationDiscountType {
  static const percentage = 'percentage';
  static const fixed = 'fixed';
}

/// payment_method values accepted by the API.
class QuotationPaymentMethod {
  static const cash = 'cash';
  static const cheque = 'cheque';
  static const online = 'online';
  static const credit = 'credit';
  static const bankTransfer = 'bank_transfer';
}

/// Request body for POST /quotations/create.
///
/// [action] is one of:
///  - 'save_quotation' -> saved as a draft (salesman or owner)
///  - 'submit'          -> submitted for admin/owner approval (salesman)
///  - 'approve'         -> owner-only. Creates the estimate AND finalizes
///                         it as approved in one call. This is the only
///                         action for which [salesmanId], the discount_*
///                         fields, and the payment_* fields are used by
///                         the backend — they're harmless but ignored for
///                         'save_quotation' / 'submit'.
class QuotationCreateRequest {
  final String action;
  final String date;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String customerAddress;
  final String? contractorName;
  final String? contractorPhone;
  final String? contractorEmail;
  final String? contractorAddress;

  /// id of the pending site visit this estimate was created from, if one
  /// was picked via the phone-number lookup. Optional — a walk-in
  /// customer with no prior site visit can still be quoted.
  final String? siteVisitId;
  final double handlingCharge;
  final String? notes;
  final String? termsConditions;
  final List<QuotationItemRequest> items;

  // ---- Owner-approve-only fields ----

  /// id of the salesman this estimate should be credited/assigned to.
  /// Required by the backend when action == 'approve'.
  final int? salesmanId;

  /// 'percentage' or 'fixed' — see [QuotationDiscountType]. Null when no
  /// additional discount was given.
  final String? discountType;

  /// For 'percentage': 10 means 10%. For 'fixed': a rupee amount.
  final double? discountValue;
  final String? discountNotes;

  /// Amount received as payment at approval time.
  final double? paymentAmount;

  /// 'cash' (default), 'cheque', 'online', 'credit', or 'bank_transfer' —
  /// see [QuotationPaymentMethod].
  final String? paymentMethod;
  final String? paymentReference;

  /// yyyy-MM-dd — defaults to today on the backend if omitted.
  final String? paymentDate;
  final String? paymentNotes;

  const QuotationCreateRequest({
    required this.action,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.customerAddress,
    this.contractorName,
    this.contractorPhone,
    this.contractorEmail,
    this.contractorAddress,
    this.siteVisitId,
    required this.handlingCharge,
    this.notes,
    this.termsConditions,
    required this.items,
    this.salesmanId,
    this.discountType,
    this.discountValue,
    this.discountNotes,
    this.paymentAmount,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.paymentNotes,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'date': date,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    if (customerEmail != null && customerEmail!.isNotEmpty)
      'customer_email': customerEmail,
    'customer_address': customerAddress,
    if (contractorName != null && contractorName!.isNotEmpty)
      'contractor_name': contractorName,
    if (contractorPhone != null && contractorPhone!.isNotEmpty)
      'contractor_phone': contractorPhone,
    if (contractorEmail != null && contractorEmail!.isNotEmpty)
      'contractor_email': contractorEmail,
    if (contractorAddress != null && contractorAddress!.isNotEmpty)
      'contractor_address': contractorAddress,
    if (siteVisitId != null && siteVisitId!.isNotEmpty)
      'site_visit_id': siteVisitId,
    'handling_charge': handlingCharge,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (termsConditions != null && termsConditions!.isNotEmpty)
      'terms_conditions': termsConditions,
    if (salesmanId != null) 'salesman_id': salesmanId,
    if (discountType != null && discountType!.isNotEmpty)
      'discount_type': discountType,
    if (discountValue != null) 'discount_value': discountValue,
    if (discountNotes != null && discountNotes!.isNotEmpty)
      'discount_notes': discountNotes,
    if (paymentAmount != null) 'payment_amount': paymentAmount,
    if (paymentMethod != null && paymentMethod!.isNotEmpty)
      'payment_method': paymentMethod,
    if (paymentReference != null && paymentReference!.isNotEmpty)
      'payment_reference': paymentReference,
    if (paymentDate != null && paymentDate!.isNotEmpty)
      'payment_date': paymentDate,
    if (paymentNotes != null && paymentNotes!.isNotEmpty)
      'payment_notes': paymentNotes,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class QuotationCreateResponseModel {
  final String status;
  final String statusCode;
  final String message;

  const QuotationCreateResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory QuotationCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationCreateResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}