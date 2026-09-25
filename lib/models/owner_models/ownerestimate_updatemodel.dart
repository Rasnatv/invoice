// //
// // class EstimateUpdateItem {
// //   final String productId;
// //   final double quantity;
// //   final double? boxQuantity;
// //   final double? pieceQuantity;
// //   final double rate;
// //
// //   /// Send `box_quantity: null` explicitly (clears it server-side) instead
// //   /// of omitting the field. Takes priority over [boxQuantity].
// //   final bool clearBoxQuantity;
// //
// //   /// Send `piece_quantity: null` explicitly. Takes priority over
// //   /// [pieceQuantity].
// //   final bool clearPieceQuantity;
// //
// //   const EstimateUpdateItem({
// //     required this.productId,
// //     required this.quantity,
// //     this.boxQuantity,
// //     this.pieceQuantity,
// //     required this.rate,
// //     this.clearBoxQuantity = false,
// //     this.clearPieceQuantity = false,
// //   });
// //
// //   Map<String, dynamic> toJson() {
// //     final map = <String, dynamic>{
// //       'product_id': int.tryParse(productId) ?? productId,
// //       'quantity': quantity,
// //       'rate': rate,
// //     };
// //
// //     if (clearBoxQuantity) {
// //       map['box_quantity'] = null;
// //     } else if (boxQuantity != null) {
// //       map['box_quantity'] = boxQuantity;
// //     }
// //
// //     if (clearPieceQuantity) {
// //       map['piece_quantity'] = null;
// //     } else if (pieceQuantity != null) {
// //       map['piece_quantity'] = pieceQuantity;
// //     }
// //
// //     return map;
// //   }
// // }
// //
// // /// Request body for POST /estimates/update.
// // ///
// // /// Optional string fields follow this convention: passing null leaves the
// // /// field untouched on the server (the key is omitted entirely — a partial
// // /// update). To explicitly *clear* a field (send it as JSON `null`), set
// // /// the matching `clearX` flag to true instead of trying to pass null as
// // /// a "value" (Dart can't tell "don't touch" apart from "set to null" on
// // /// a single nullable field, hence the separate flags — same pattern as
// // /// the existing `clearSiteVisit`).
// // class OwnerUpdateEstimateRequest {
// //   final String id;
// //
// //   final String? customerName;
// //   final String? customerPhone;
// //   final String? customerAddress;
// //   final bool clearCustomerAddress;
// //   final String? customerEmail;
// //   final bool clearCustomerEmail;
// //
// //   // Contractor (the `contractor` party on the estimate — see
// //   // EstimateCustomer in estimatedetail.model.dart). Per the confirmed
// //   // /estimates/update request shape, the API accepts contractor_name,
// //   // contractor_phone and contractor_email only — there is no
// //   // contractor_address field on this endpoint. If the backend adds one,
// //   // add contractorAddress here following the same pattern as
// //   // customerAddress above.
// //   final String? contractorName;
// //   final String? contractorPhone;
// //   final bool clearContractorPhone;
// //   final String? contractorEmail;
// //   final bool clearContractorEmail;
// //
// //   final String? date; // yyyy-MM-dd
// //   final String? notes;
// //   final bool clearNotes;
// //   final String? termsConditions;
// //   final bool clearTermsConditions;
// //
// //   /// Full replacement list. Leave null to keep the existing items untouched.
// //   final List<EstimateUpdateItem>? items;
// //
// //   /// Set to change the linked site visit. Leave both this and
// //   /// [clearSiteVisit] unset/false to keep the existing value untouched.
// //   final String? siteVisitId;
// //
// //   /// Set true to explicitly clear the linked site visit (sends
// //   /// `site_visit_id: null`), reverting the estimate to "pending".
// //   final bool clearSiteVisit;
// //
// //   const OwnerUpdateEstimateRequest({
// //     required this.id,
// //     this.customerName,
// //     this.customerPhone,
// //     this.customerAddress,
// //     this.clearCustomerAddress = false,
// //     this.customerEmail,
// //     this.clearCustomerEmail = false,
// //     this.contractorName,
// //     this.contractorPhone,
// //     this.clearContractorPhone = false,
// //     this.contractorEmail,
// //     this.clearContractorEmail = false,
// //     this.date,
// //     this.notes,
// //     this.clearNotes = false,
// //     this.termsConditions,
// //     this.clearTermsConditions = false,
// //     this.items,
// //     this.siteVisitId,
// //     this.clearSiteVisit = false,
// //   });
// //
// //   Map<String, dynamic> toJson() {
// //     final map = <String, dynamic>{
// //       'id': int.tryParse(id) ?? id,
// //     };
// //
// //     if (customerName != null) map['customer_name'] = customerName;
// //     if (customerPhone != null) map['customer_phone'] = customerPhone;
// //
// //     if (clearCustomerAddress) {
// //       map['customer_address'] = null;
// //     } else if (customerAddress != null) {
// //       map['customer_address'] = customerAddress;
// //     }
// //
// //     if (clearCustomerEmail) {
// //       map['customer_email'] = null;
// //     } else if (customerEmail != null) {
// //       map['customer_email'] = customerEmail;
// //     }
// //
// //     if (contractorName != null) map['contractor_name'] = contractorName;
// //
// //     if (clearContractorPhone) {
// //       map['contractor_phone'] = null;
// //     } else if (contractorPhone != null) {
// //       map['contractor_phone'] = contractorPhone;
// //     }
// //
// //     if (clearContractorEmail) {
// //       map['contractor_email'] = null;
// //     } else if (contractorEmail != null) {
// //       map['contractor_email'] = contractorEmail;
// //     }
// //
// //     if (date != null) map['date'] = date;
// //
// //     if (clearNotes) {
// //       map['notes'] = null;
// //     } else if (notes != null) {
// //       map['notes'] = notes;
// //     }
// //
// //     if (clearTermsConditions) {
// //       map['terms_conditions'] = null;
// //     } else if (termsConditions != null) {
// //       map['terms_conditions'] = termsConditions;
// //     }
// //
// //     if (items != null) {
// //       map['items'] = items!.map((e) => e.toJson()).toList();
// //     }
// //
// //     if (clearSiteVisit) {
// //       map['site_visit_id'] = null;
// //     } else if (siteVisitId != null && siteVisitId!.isNotEmpty) {
// //       map['site_visit_id'] = siteVisitId;
// //     }
// //
// //     return map;
// //   }
// // }
// class EstimateUpdateItem {
//   final String productId;
//   final double quantity;
//   final double? boxQuantity;
//   final double? pieceQuantity;
//   final double rate;
//
//   /// Send `box_quantity: null` explicitly (clears it server-side) instead
//   /// of omitting the field. Takes priority over [boxQuantity].
//   final bool clearBoxQuantity;
//
//   /// Send `piece_quantity: null` explicitly. Takes priority over
//   /// [pieceQuantity].
//   final bool clearPieceQuantity;
//
//   const EstimateUpdateItem({
//     required this.productId,
//     required this.quantity,
//     this.boxQuantity,
//     this.pieceQuantity,
//     required this.rate,
//     this.clearBoxQuantity = false,
//     this.clearPieceQuantity = false,
//   });
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       'product_id': int.tryParse(productId) ?? productId,
//       'quantity': quantity,
//       'rate': rate,
//     };
//
//     if (clearBoxQuantity) {
//       map['box_quantity'] = null;
//     } else if (boxQuantity != null) {
//       map['box_quantity'] = boxQuantity;
//     }
//
//     if (clearPieceQuantity) {
//       map['piece_quantity'] = null;
//     } else if (pieceQuantity != null) {
//       map['piece_quantity'] = pieceQuantity;
//     }
//
//     return map;
//   }
// }
//
// /// Request body for POST /estimates/update.
// ///
// /// Optional string fields follow this convention: passing null leaves the
// /// field untouched on the server (the key is omitted entirely — a partial
// /// update). To explicitly *clear* a field (send it as JSON `null`), set
// /// the matching `clearX` flag to true.
// ///
// /// NEW: on the clearable text fields (customer address/email, contractor
// /// phone/email, notes, terms) an EMPTY string is also treated as "clear"
// /// and is sent as JSON `null` instead of `""`. The edit screen passes the
// /// raw text-field value, so a cleared field arrives here as "" — sending
// /// "" made the server keep the old value (or reject the request on
// /// validation), which is why removing the contractor email did nothing and
// /// why adding a contractor name with empty phone/email could fail.
// class OwnerUpdateEstimateRequest {
//   final String id;
//
//   final String? customerName;
//   final String? customerPhone;
//   final String? customerAddress;
//   final bool clearCustomerAddress;
//   final String? customerEmail;
//   final bool clearCustomerEmail;
//
//   // Contractor (the `contractor` party on the estimate — see
//   // EstimateCustomer in estimatedetail.model.dart). Per the confirmed
//   // /estimates/update request shape, the API accepts contractor_name,
//   // contractor_phone and contractor_email only — there is no
//   // contractor_address field on this endpoint.
//   final String? contractorName;
//   final String? contractorPhone;
//   final bool clearContractorPhone;
//   final String? contractorEmail;
//   final bool clearContractorEmail;
//
//   final String? date; // yyyy-MM-dd
//   final String? notes;
//   final bool clearNotes;
//   final String? termsConditions;
//   final bool clearTermsConditions;
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
//     this.clearCustomerAddress = false,
//     this.customerEmail,
//     this.clearCustomerEmail = false,
//     this.contractorName,
//     this.contractorPhone,
//     this.clearContractorPhone = false,
//     this.contractorEmail,
//     this.clearContractorEmail = false,
//     this.date,
//     this.notes,
//     this.clearNotes = false,
//     this.termsConditions,
//     this.clearTermsConditions = false,
//     this.items,
//     this.siteVisitId,
//     this.clearSiteVisit = false,
//   });
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       'id': int.tryParse(id) ?? id,
//     };
//
//     // Clearable text field: explicit clear flag OR an empty string => JSON
//     // null (clears it). Non-empty => the trimmed value. Null => omitted.
//     void putClearable(String key, String? value, bool clear) {
//       if (clear || (value != null && value.trim().isEmpty)) {
//         map[key] = null;
//       } else if (value != null) {
//         map[key] = value.trim();
//       }
//     }
//
//     if (customerName != null) map['customer_name'] = customerName;
//     if (customerPhone != null) map['customer_phone'] = customerPhone;
//
//     putClearable('customer_address', customerAddress, clearCustomerAddress);
//     putClearable('customer_email', customerEmail, clearCustomerEmail);
//
//     if (contractorName != null) map['contractor_name'] = contractorName;
//
//     putClearable('contractor_phone', contractorPhone, clearContractorPhone);
//     putClearable('contractor_email', contractorEmail, clearContractorEmail);
//
//     if (date != null) map['date'] = date;
//
//     putClearable('notes', notes, clearNotes);
//     putClearable('terms_conditions', termsConditions, clearTermsConditions);
//
//     if (items != null) {
//       map['items'] = items!.map((e) => e.toJson()).toList();
//     }
//
//     if (clearSiteVisit) {
//       map['site_visit_id'] = null;
//     } else if (siteVisitId != null && siteVisitId!.isNotEmpty) {
//       map['site_visit_id'] = siteVisitId;
//     }
//
//     return map;
//   }
// }
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
/// the matching `clearX` flag to true.
///
/// NEW: on the clearable text fields (customer address/email, contractor
/// phone/email, notes, terms) an EMPTY string is also treated as "clear"
/// and is sent as JSON `null` instead of `""`. The edit screen passes the
/// raw text-field value, so a cleared field arrives here as "" — sending
/// "" made the server keep the old value (or reject the request on
/// validation), which is why removing the contractor email did nothing and
/// why adding a contractor name with empty phone/email could fail.
class OwnerUpdateEstimateRequest {
  final String id;

  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final bool clearCustomerAddress;
  final String? customerEmail;
  final bool clearCustomerEmail;

  // Contractor (the `contractor` party on the estimate — see
  // EstimateCustomer in estimatedetail.model.dart).
  final String? contractorName;
  final String? contractorPhone;
  final bool clearContractorPhone;
  final String? contractorEmail;
  final bool clearContractorEmail;
  final String? contractorAddress;
  final bool clearContractorAddress;

  final String? date; // yyyy-MM-dd

  /// New handling charge amount. Leave null to keep the existing value
  /// untouched. Unlike the text fields above, there's no "clear" flag here
  /// — a handling charge of 0 is itself a meaningful, intentional value
  /// (not an omission), so it's sent through as-is whenever non-null.
  final double? handlingCharge;

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
    this.contractorAddress,
    this.clearContractorAddress = false,
    this.date,
    this.handlingCharge,
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

    // Clearable text field: explicit clear flag OR an empty string => JSON
    // null (clears it). Non-empty => the trimmed value. Null => omitted.
    void putClearable(String key, String? value, bool clear) {
      if (clear || (value != null && value.trim().isEmpty)) {
        map[key] = null;
      } else if (value != null) {
        map[key] = value.trim();
      }
    }

    if (customerName != null) map['customer_name'] = customerName;
    if (customerPhone != null) map['customer_phone'] = customerPhone;

    putClearable('customer_address', customerAddress, clearCustomerAddress);
    putClearable('customer_email', customerEmail, clearCustomerEmail);

    if (contractorName != null) map['contractor_name'] = contractorName;

    putClearable('contractor_phone', contractorPhone, clearContractorPhone);
    putClearable('contractor_email', contractorEmail, clearContractorEmail);
    putClearable('contractor_address', contractorAddress, clearContractorAddress);

    if (date != null) map['date'] = date;

    if (handlingCharge != null) map['handling_charge'] = handlingCharge;

    putClearable('notes', notes, clearNotes);
    putClearable('terms_conditions', termsConditions, clearTermsConditions);

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