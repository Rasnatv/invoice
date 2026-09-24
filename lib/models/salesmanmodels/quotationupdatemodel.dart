// class QuotationUpdateItemRequest {
//   final String productId;
//   final double quantity;
//   final double rate;
//   final double? boxQuantity;
//   final double? pieceQuantity;
//
//   const QuotationUpdateItemRequest({
//     required this.productId,
//     required this.quantity,
//     required this.rate,
//     this.boxQuantity,
//     this.pieceQuantity,
//   });
//
//   /// Formats a double the same way the rest of the app does when sending
//   /// it to this API — drop the trailing ".0" for whole numbers, otherwise
//   /// keep it as-is.
//   static String _fmt(double value) =>
//       value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       'product_id': productId,
//       'quantity': _fmt(quantity),
//       'rate': _fmt(rate),
//     };
//     if (boxQuantity != null) map['box_quantity'] = _fmt(boxQuantity!);
//     if (pieceQuantity != null) map['piece_quantity'] = _fmt(pieceQuantity!);
//     return map;
//   }
// }
//
// /// Body for POST /quotations/update. `id` is required; every other field
// /// is optional so the caller only needs to send what actually changed —
// /// null fields are simply omitted from the request body.
// class QuotationUpdateRequest {
//   final String id;
//   final String? customerName;
//   final String? customerPhone;
//   final String? customerEmail;
//   final String? customerAddress;
//   final String? contractorName;
//   final String? contractorPhone;
//   final String? contractorEmail;
//   final String? contractorAddress;
//   final double? handlingCharge;
//   final String? notes;
//   final String? termsConditions;
//   final List<QuotationUpdateItemRequest>? items;
//
//   const QuotationUpdateRequest({
//     required this.id,
//     this.customerName,
//     this.customerPhone,
//     this.customerEmail,
//     this.customerAddress,
//     this.contractorName,
//     this.contractorPhone,
//     this.contractorEmail,
//     this.contractorAddress,
//     this.handlingCharge,
//     this.notes,
//     this.termsConditions,
//     this.items,
//   });
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{'id': id};
//     if (customerName != null) map['customer_name'] = customerName;
//     if (customerPhone != null) map['customer_phone'] = customerPhone;
//     if (customerEmail != null) map['customer_email'] = customerEmail;
//     if (customerAddress != null) map['customer_address'] = customerAddress;
//     if (contractorName != null) map['contractor_name'] = contractorName;
//     if (contractorPhone != null) map['contractor_phone'] = contractorPhone;
//     if (contractorEmail != null) map['contractor_email'] = contractorEmail;
//     if (contractorAddress != null) map['contractor_address'] = contractorAddress;
//     // Sent as a string to match the confirmed-working payload
//     // ("handling_charge": "500") — sending it as a raw JSON number was the
//     // cause of "handling charge added not properly working".
//     if (handlingCharge != null) {
//       map['handling_charge'] = handlingCharge == handlingCharge!.roundToDouble()
//           ? handlingCharge!.toStringAsFixed(0)
//           : handlingCharge.toString();
//     }
//     if (notes != null) map['notes'] = notes;
//     if (termsConditions != null) map['terms_conditions'] = termsConditions;
//     if (items != null) map['items'] = items!.map((e) => e.toJson()).toList();
//     return map;
//   }
// }
//
// /// Shared { "id": "..." } body used by /quotations/show, /quotations/delete
// /// and /quotations/submit.
// class QuotationIdRequest {
//   final String id;
//   const QuotationIdRequest(this.id);
//
//   Map<String, dynamic> toJson() => {'id': id};
// }
// class QuotationUpdateItemRequest {
//   final String productId;
//   final double quantity;
//   final double rate;
//   final double? boxQuantity;
//   final double? pieceQuantity;
//
//   const QuotationUpdateItemRequest({
//     required this.productId,
//     required this.quantity,
//     required this.rate,
//     this.boxQuantity,
//     this.pieceQuantity,
//   });
//
//   /// Formats a double the same way the rest of the app does when sending
//   /// it to this API — drop the trailing ".0" for whole numbers, otherwise
//   /// keep it as-is.
//   static String _fmt(double value) =>
//       value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       'product_id': productId,
//       'quantity': _fmt(quantity),
//       'rate': _fmt(rate),
//     };
//     if (boxQuantity != null) map['box_quantity'] = _fmt(boxQuantity!);
//     if (pieceQuantity != null) map['piece_quantity'] = _fmt(pieceQuantity!);
//     return map;
//   }
// }
//
// /// Body for POST /quotations/update. `id` is required.
// ///
// /// How text fields (customer_*, contractor_*, notes, terms_conditions) are sent:
// ///
// /// * [sendAllFields] = true (default, use from the Edit screen where the
// ///   whole form is submitted): every text field is ALWAYS sent. `null` is
// ///   sent as an empty string, so:
// ///     - adding a value that was empty before works,
// ///     - clearing a value (e.g. removing contractor email) works.
// ///
// /// * [sendAllFields] = false (partial update): a `null` field is omitted
// ///   and the server keeps the old value. An empty string still clears it.
// class QuotationUpdateRequest {
//   final String id;
//   final String? customerName;
//   final String? customerPhone;
//   final String? customerEmail;
//   final String? customerAddress;
//   final String? contractorName;
//   final String? contractorPhone;
//   final String? contractorEmail;
//   final String? contractorAddress;
//   final double? handlingCharge;
//   final String? notes;
//   final String? termsConditions;
//
//   /// Quotation date in yyyy-MM-dd format (e.g. "2026-07-31"). Omitted if null.
//   final String? date;
//   final List<QuotationUpdateItemRequest>? items;
//   final bool sendAllFields;
//
//   const QuotationUpdateRequest({
//     required this.id,
//     this.customerName,
//     this.customerPhone,
//     this.customerEmail,
//     this.customerAddress,
//     this.contractorName,
//     this.contractorPhone,
//     this.contractorEmail,
//     this.contractorAddress,
//     this.handlingCharge,
//     this.notes,
//     this.termsConditions,
//     this.date,
//     this.items,
//     this.sendAllFields = true,
//   });
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{'id': id};
//
//     // Adds a text field. Empty string = "clear this value" on the server.
//     void putText(String key, String? value) {
//       if (value != null) {
//         map[key] = value.trim();
//       } else if (sendAllFields) {
//         map[key] = '';
//       }
//     }
//
//     putText('customer_name', customerName);
//     putText('customer_phone', customerPhone);
//     putText('customer_email', customerEmail);
//     putText('customer_address', customerAddress);
//     putText('contractor_name', contractorName);
//     putText('contractor_phone', contractorPhone);
//     putText('contractor_email', contractorEmail);
//     putText('contractor_address', contractorAddress);
//
//     // Sent as a string to match the confirmed-working payload
//     // ("handling_charge": "500") — sending it as a raw JSON number was the
//     // cause of "handling charge added not properly working".
//     if (handlingCharge != null) {
//       map['handling_charge'] = handlingCharge == handlingCharge!.roundToDouble()
//           ? handlingCharge!.toStringAsFixed(0)
//           : handlingCharge.toString();
//     }
//
//     putText('notes', notes);
//     putText('terms_conditions', termsConditions);
//     if (date != null && date!.trim().isNotEmpty) map['date'] = date!.trim();
//
//     if (items != null) map['items'] = items!.map((e) => e.toJson()).toList();
//     return map;
//   }
// }
//
// /// Shared { "id": "..." } body used by /quotations/show, /quotations/delete
// /// and /quotations/submit.
// class QuotationIdRequest {
//   final String id;
//   const QuotationIdRequest(this.id);
//
//   Map<String, dynamic> toJson() => {'id': id};
// }
class QuotationUpdateItemRequest {
  final String productId;
  final double quantity;
  final double rate;
  final double? boxQuantity;
  final double? pieceQuantity;

  const QuotationUpdateItemRequest({
    required this.productId,
    required this.quantity,
    required this.rate,
    this.boxQuantity,
    this.pieceQuantity,
  });

  /// Formats a double the same way the rest of the app does when sending
  /// it to this API — drop the trailing ".0" for whole numbers, otherwise
  /// keep it as-is.
  static String _fmt(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'product_id': productId,
      'quantity': _fmt(quantity),
      'rate': _fmt(rate),
    };
    if (boxQuantity != null) map['box_quantity'] = _fmt(boxQuantity!);
    if (pieceQuantity != null) map['piece_quantity'] = _fmt(pieceQuantity!);
    return map;
  }
}

/// Body for POST /quotations/update. `id` is required.
///
/// How text fields are sent:
///
/// REQUIRED fields (customer_name, customer_phone):
///   always sent as the trimmed text.
///
/// OPTIONAL / clearable fields (customer_email, customer_address,
/// contractor_*, notes, terms_conditions):
///   * non-empty text  -> sent as the trimmed text
///   * empty string    -> sent as JSON `null` (clears the value on the server)
///   * null            -> with [sendAllFields] = true (Edit screen, whole
///                        form submitted) sent as JSON `null`;
///                        with [sendAllFields] = false the key is omitted
///                        and the server keeps the old value.
///
/// Previously empty optional fields were sent as "" — the server tried to
/// validate "" as a phone number / email, so adding a contractor name with
/// the other contractor fields left blank failed or was ignored.
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

  /// Quotation date in yyyy-MM-dd format (e.g. "2026-07-31"). Omitted if null.
  final String? date;
  final List<QuotationUpdateItemRequest>? items;
  final bool sendAllFields;

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
    this.date,
    this.items,
    this.sendAllFields = true,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'id': id};

    // Required text field: always the trimmed value.
    void putRequired(String key, String? value) {
      if (value != null) {
        map[key] = value.trim();
      } else if (sendAllFields) {
        map[key] = '';
      }
    }

    // Optional text field: empty => JSON null (clears it on the server).
    void putClearable(String key, String? value) {
      if (value == null) {
        if (sendAllFields) map[key] = null;
        return;
      }
      final t = value.trim();
      map[key] = t.isEmpty ? null : t;
    }

    putRequired('customer_name', customerName);
    putRequired('customer_phone', customerPhone);
    putClearable('customer_email', customerEmail);
    putClearable('customer_address', customerAddress);
    putClearable('contractor_name', contractorName);
    putClearable('contractor_phone', contractorPhone);
    putClearable('contractor_email', contractorEmail);
    putClearable('contractor_address', contractorAddress);

    // Sent as a string to match the confirmed-working payload
    // ("handling_charge": "500") — sending it as a raw JSON number was the
    // cause of "handling charge added not properly working".
    if (handlingCharge != null) {
      map['handling_charge'] = handlingCharge == handlingCharge!.roundToDouble()
          ? handlingCharge!.toStringAsFixed(0)
          : handlingCharge.toString();
    }

    putClearable('notes', notes);
    putClearable('terms_conditions', termsConditions);
    if (date != null && date!.trim().isNotEmpty) map['date'] = date!.trim();

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