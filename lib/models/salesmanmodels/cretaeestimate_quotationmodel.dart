class QuotationItemRequest {
  final int productId;
  final double quantity;
  final double rate;

  const QuotationItemRequest({
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

/// Request body for POST /quotations/create.
///
/// [action] is one of:
///  - 'save_quotation' -> saved as a draft quotation
///  - 'submit'          -> submitted for admin/owner approval
/// ('approve' is a third valid value on the backend, but that's only ever
/// sent from the owner approval flow, never from the salesman screen.)
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

  /// id of the pending site visit this estimate was created from, if the
  /// salesman picked one via the phone-number lookup. Optional — a
  /// walk-in customer with no prior site visit can still be quoted.
  final String? siteVisitId;
  final double handlingCharge;
  final String? notes;
  final String? termsConditions;
  final List<QuotationItemRequest> items;

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
