/// One line item inside a POST /quotations/update body.
///
/// NOTE: product_id is a String here (not int) — confirmed against the
/// real working payload:
///   { "product_id": "12", "quantity": 100, "rate": 500 }
/// This matches how product ids are handled everywhere else on the
/// quotation detail/list side (ActiveProductModel.id is also a String).
class QuotationUpdateItemRequest {
  final String productId;
  final double quantity;
  final double rate;

  const QuotationUpdateItemRequest({
    required this.productId,
    required this.quantity,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'rate': rate,
  };
}

/// Body for POST /quotations/update. `id` is required; every other field
/// is optional so the caller only needs to send what actually changed —
/// null fields are simply omitted from the request body.
class QuotationUpdateRequest {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? contractorName;
  final String? contractorPhone;
  final String? contractorEmail;
  final String? contractorAddress;
  final double? handlingCharge;
  final String? notes;
  final String? termsConditions;
  final List<QuotationUpdateItemRequest>? items;

  const QuotationUpdateRequest({
    required this.id,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    this.contractorName,
    this.contractorPhone,
    this.contractorEmail,
    this.contractorAddress,
    this.handlingCharge,
    this.notes,
    this.termsConditions,
    this.items,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'id': id};
    if (customerName != null) map['customer_name'] = customerName;
    if (customerPhone != null) map['customer_phone'] = customerPhone;
    if (customerEmail != null) map['customer_email'] = customerEmail;
    if (customerAddress != null) map['customer_address'] = customerAddress;
    if (contractorName != null) map['contractor_name'] = contractorName;
    if (contractorPhone != null) map['contractor_phone'] = contractorPhone;
    if (contractorEmail != null) map['contractor_email'] = contractorEmail;
    if (contractorAddress != null) map['contractor_address'] = contractorAddress;
    if (handlingCharge != null) map['handling_charge'] = handlingCharge;
    if (notes != null) map['notes'] = notes;
    if (termsConditions != null) map['terms_conditions'] = termsConditions;
    if (items != null) map['items'] = items!.map((e) => e.toJson()).toList();
    return map;
  }
}

/// Shared { "id": "..." } body used by /quotations/show, /quotations/delete
/// and /quotations/submit.
class QuotationIdRequest {
  final String id;
  const QuotationIdRequest(this.id);

  Map<String, dynamic> toJson() => {'id': id};
}