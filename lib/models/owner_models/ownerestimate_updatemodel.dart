// /// Request body for POST /estimates/update.
// ///
// /// This is a PARTIAL update — only the fields you set (non-null) are sent
// /// to the server, so any field you leave null keeps its existing value on
// /// the backend. The one exception is [items]: if you provide a list at
// /// all (even empty), it fully REPLACES the estimate's existing items, per
// /// the API contract.
// ///
// /// Discount and payment fields intentionally have no place here — the API
// /// does not allow updating them via this endpoint. Use the existing
// /// approve (`POST /quotations/approve` / `/estimates/approve`) or payments
// /// endpoints for those.
// class EstimateUpdateItem {
//   final String productId;
//   final double quantity;
//   final double boxQuantity;
//   final double pieceQuantity;
//   final double rate;
//
//   const EstimateUpdateItem({
//     required this.productId,
//     required this.quantity,
//     this.boxQuantity = 0,
//     this.pieceQuantity = 0,
//     required this.rate,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'product_id': int.tryParse(productId) ?? productId,
//     'quantity': quantity,
//     'box_quantity': boxQuantity,
//     'piece_quantity': pieceQuantity,
//     'rate': rate,
//   };
// }
//
// class OwnerUpdateEstimateRequest {
//   final String id;
//
//   final String? customerName;
//   final String? customerPhone;
//   final String? customerAddress;
//   final String? customerEmail;
//
//   final String? date; // yyyy-MM-dd
//   final String? notes;
//   final String? termsConditions;
//
//   /// Full replacement list. Leave null to keep the existing items untouched.
//   final List<EstimateUpdateItem>? items;
//
//   /// Set to change the linked site visit. Leave both this and
//   /// [clearSiteVisit] unset/false to keep the existing value untouched.
//   final String? siteVisitId;
//
//   /// Set true to explicitly clear the linked site visit (sends
//   /// `site_visit_id: null`), reverting the estimate to "pending".
//   final bool clearSiteVisit;
//
//   const OwnerUpdateEstimateRequest({
//     required this.id,
//     this.customerName,
//     this.customerPhone,
//     this.customerAddress,
//     this.customerEmail,
//     this.date,
//     this.notes,
//     this.termsConditions,
//     this.items,
//     this.siteVisitId,
//     this.clearSiteVisit = false,
//   });
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       'id': int.tryParse(id) ?? id,
//     };
//     if (customerName != null) map['customer_name'] = customerName;
//     if (customerPhone != null) map['customer_phone'] = customerPhone;
//     if (customerAddress != null) map['customer_address'] = customerAddress;
//     if (customerEmail != null) map['customer_email'] = customerEmail;
//     if (date != null) map['date'] = date;
//     if (notes != null) map['notes'] = notes;
//     if (termsConditions != null) map['terms_conditions'] = termsConditions;
//     if (items != null) {
//       map['items'] = items!.map((e) => e.toJson()).toList();
//     }
//     if (clearSiteVisit) {
//       map['site_visit_id'] = null;
//     } else if (siteVisitId != null && siteVisitId!.isNotEmpty) {
//       map['site_visit_id'] = siteVisitId;
//     }
//     return map;
//   }
// }
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
/// Item payload for POST /estimates/update.
///
/// `boxQuantity` / `pieceQuantity` are nullable now instead of defaulting
/// to 0. That lets you distinguish three states per field:
///   1. Leave unchanged   -> pass null, clear flag false -> field omitted
///   2. Set a real value  -> pass the value               -> field sent
///   3. Explicitly clear  -> set clearBoxQuantity/clearPieceQuantity true
///                           -> field sent as literal `null`
class EstimateUpdateItem {
  final String productId;
  final double quantity;
  final double? boxQuantity;
  final double? pieceQuantity;
  final double rate;

  /// Send `box_quantity: null` explicitly (clears it server-side) instead
  /// of omitting the field. Takes priority over [boxQuantity].
  final bool clearBoxQuantity;

  /// Send `piece_quantity: null` explicitly. Takes priority over
  /// [pieceQuantity].
  final bool clearPieceQuantity;

  const EstimateUpdateItem({
    required this.productId,
    required this.quantity,
    this.boxQuantity,
    this.pieceQuantity,
    required this.rate,
    this.clearBoxQuantity = false,
    this.clearPieceQuantity = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'product_id': int.tryParse(productId) ?? productId,
      'quantity': quantity,
      'rate': rate,
    };

    if (clearBoxQuantity) {
      map['box_quantity'] = null;
    } else if (boxQuantity != null) {
      map['box_quantity'] = boxQuantity;
    }

    if (clearPieceQuantity) {
      map['piece_quantity'] = null;
    } else if (pieceQuantity != null) {
      map['piece_quantity'] = pieceQuantity;
    }

    return map;
  }
}

/// Request body for POST /estimates/update.
///
/// Optional string fields follow this convention: passing null leaves the
/// field untouched on the server (the key is omitted entirely — a partial
/// update). To explicitly *clear* a field (send it as JSON `null`), set
/// the matching `clearX` flag to true instead of trying to pass null as
/// a "value" (Dart can't tell "don't touch" apart from "set to null" on
/// a single nullable field, hence the separate flags — same pattern as
/// the existing `clearSiteVisit`).
class OwnerUpdateEstimateRequest {
  final String id;

  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final bool clearCustomerAddress;
  final String? customerEmail;
  final bool clearCustomerEmail;

  // Contractor (the `contractor` party on the estimate — see
  // EstimateCustomer in estimatedetail.model.dart). Per the confirmed
  // /estimates/update request shape, the API accepts contractor_name,
  // contractor_phone and contractor_email only — there is no
  // contractor_address field on this endpoint. If the backend adds one,
  // add contractorAddress here following the same pattern as
  // customerAddress above.
  final String? contractorName;
  final String? contractorPhone;
  final bool clearContractorPhone;
  final String? contractorEmail;
  final bool clearContractorEmail;

  final String? date; // yyyy-MM-dd
  final String? notes;
  final bool clearNotes;
  final String? termsConditions;
  final bool clearTermsConditions;

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
    this.clearCustomerAddress = false,
    this.customerEmail,
    this.clearCustomerEmail = false,
    this.contractorName,
    this.contractorPhone,
    this.clearContractorPhone = false,
    this.contractorEmail,
    this.clearContractorEmail = false,
    this.date,
    this.notes,
    this.clearNotes = false,
    this.termsConditions,
    this.clearTermsConditions = false,
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

    if (clearCustomerAddress) {
      map['customer_address'] = null;
    } else if (customerAddress != null) {
      map['customer_address'] = customerAddress;
    }

    if (clearCustomerEmail) {
      map['customer_email'] = null;
    } else if (customerEmail != null) {
      map['customer_email'] = customerEmail;
    }

    if (contractorName != null) map['contractor_name'] = contractorName;

    if (clearContractorPhone) {
      map['contractor_phone'] = null;
    } else if (contractorPhone != null) {
      map['contractor_phone'] = contractorPhone;
    }

    if (clearContractorEmail) {
      map['contractor_email'] = null;
    } else if (contractorEmail != null) {
      map['contractor_email'] = contractorEmail;
    }

    if (date != null) map['date'] = date;

    if (clearNotes) {
      map['notes'] = null;
    } else if (notes != null) {
      map['notes'] = notes;
    }

    if (clearTermsConditions) {
      map['terms_conditions'] = null;
    } else if (termsConditions != null) {
      map['terms_conditions'] = termsConditions;
    }

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