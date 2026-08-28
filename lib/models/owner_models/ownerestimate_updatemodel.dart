/// Request body for POST /estimates/update.
///
/// This is a PARTIAL update — only the fields you set (non-null) are sent
/// to the server, so any field you leave null keeps its existing value on
/// the backend. The one exception is [items]: if you provide a list at
/// all (even empty), it fully REPLACES the estimate's existing items, per
/// the API contract.
///
/// Discount and payment fields intentionally have no place here — the API
/// does not allow updating them via this endpoint. Use the existing
/// approve (`POST /quotations/approve` / `/estimates/approve`) or payments
/// endpoints for those.
class EstimateUpdateItem {
  final String productId;
  final double quantity;
  final double boxQuantity;
  final double pieceQuantity;
  final double rate;

  const EstimateUpdateItem({
    required this.productId,
    required this.quantity,
    this.boxQuantity = 0,
    this.pieceQuantity = 0,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
    'product_id': int.tryParse(productId) ?? productId,
    'quantity': quantity,
    'box_quantity': boxQuantity,
    'piece_quantity': pieceQuantity,
    'rate': rate,
  };
}

class OwnerUpdateEstimateRequest {
  final String id;

  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerEmail;

  final String? date; // yyyy-MM-dd
  final String? notes;
  final String? termsConditions;

  /// Full replacement list. Leave null to keep the existing items untouched.
  final List<EstimateUpdateItem>? items;

  /// Set to change the linked site visit. Leave both this and
  /// [clearSiteVisit] unset/false to keep the existing value untouched.
  final String? siteVisitId;

  /// Set true to explicitly clear the linked site visit (sends
  /// `site_visit_id: null`), reverting the estimate to "pending".
  final bool clearSiteVisit;

  const OwnerUpdateEstimateRequest({
    required this.id,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.customerEmail,
    this.date,
    this.notes,
    this.termsConditions,
    this.items,
    this.siteVisitId,
    this.clearSiteVisit = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': int.tryParse(id) ?? id,
    };
    if (customerName != null) map['customer_name'] = customerName;
    if (customerPhone != null) map['customer_phone'] = customerPhone;
    if (customerAddress != null) map['customer_address'] = customerAddress;
    if (customerEmail != null) map['customer_email'] = customerEmail;
    if (date != null) map['date'] = date;
    if (notes != null) map['notes'] = notes;
    if (termsConditions != null) map['terms_conditions'] = termsConditions;
    if (items != null) {
      map['items'] = items!.map((e) => e.toJson()).toList();
    }
    if (clearSiteVisit) {
      map['site_visit_id'] = null;
    } else if (siteVisitId != null && siteVisitId!.isNotEmpty) {
      map['site_visit_id'] = siteVisitId;
    }
    return map;
  }
}