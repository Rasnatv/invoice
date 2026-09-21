//
// double _asDouble(dynamic v) {
//   if (v == null) return 0;
//   if (v is num) return v.toDouble();
//   return double.tryParse(v.toString()) ?? 0;
// }
//
// int _asInt(dynamic v) {
//   if (v == null) return 0;
//   if (v is num) return v.toInt();
//   return int.tryParse(v.toString()) ?? 0;
// }
//
// String _asString(dynamic v) => v?.toString() ?? '';
//
// bool _asBool(dynamic v) {
//   final s = _asString(v);
//   return s == '1' || s.toLowerCase() == 'true';
// }
//
// /// One line item from a quotation/estimate detail response, including the
// /// incentive figures that were locked in at the time the item was added
// /// (bonus_type_at_time / min_quantity_at_time / incentive_percentage_at_time),
// /// so historical estimates keep showing the incentive terms that actually
// /// applied even if the product's incentive rules change later.
// class QuotationDetailItem {
//   final String id;
//   final String productId;
//   final String productName;
//   final String productSize;
//   final String productUnit;
//   final String companyName;
//   final double mrp;
//   final double quantity;
//   final double boxQuantity;
//   final double pieceQuantity;
//   final double rate;
//   final double amount;
//   final double incentiveAmount;
//   final bool isIncentiveEligible;
//   final String bonusTypeAtTime;
//   final double minQuantityAtTime;
//   final double incentivePercentageAtTime;
//
//   const QuotationDetailItem({
//     required this.id,
//     required this.productId,
//     required this.productName,
//     required this.productSize,
//     required this.productUnit,
//     required this.companyName,
//     required this.mrp,
//     required this.quantity,
//     required this.boxQuantity,
//     required this.pieceQuantity,
//     required this.rate,
//     required this.amount,
//     required this.incentiveAmount,
//     required this.isIncentiveEligible,
//     required this.bonusTypeAtTime,
//     required this.minQuantityAtTime,
//     required this.incentivePercentageAtTime,
//   });
//
//   factory QuotationDetailItem.fromJson(Map<String, dynamic> json) {
//     return QuotationDetailItem(
//       id: _asString(json['id']),
//       productId: _asString(json['product_id']),
//       productName: _asString(json['product_name']),
//       productSize: _asString(json['product_size']),
//       productUnit: _asString(json['product_unit']),
//       companyName: _asString(json['company_name']),
//       mrp: _asDouble(json['mrp']),
//       quantity: _asDouble(json['quantity']),
//       boxQuantity: _asDouble(json['box_quantity']),
//       pieceQuantity: _asDouble(json['piece_quantity']),
//       rate: _asDouble(json['rate']),
//       amount: _asDouble(json['amount']),
//       incentiveAmount: _asDouble(json['incentive_amount']),
//       isIncentiveEligible: _asBool(json['is_incentive_eligible']),
//       bonusTypeAtTime: _asString(json['bonus_type_at_time']),
//       minQuantityAtTime: _asDouble(json['min_quantity_at_time']),
//       incentivePercentageAtTime: _asDouble(json['incentive_percentage_at_time']),
//     );
//   }
// }
//
// class QuotationCustomer {
//   final String id;
//   final String name;
//   final String phone;
//   final String email;
//   final String address;
//
//   const QuotationCustomer({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.address,
//   });
//
//   factory QuotationCustomer.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return const QuotationCustomer(id: '', name: '', phone: '', email: '', address: '');
//     }
//     return QuotationCustomer(
//       id: _asString(json['id']),
//       name: _asString(json['name']),
//       phone: _asString(json['phone']),
//       email: _asString(json['email']),
//       address: _asString(json['address']),
//     );
//   }
// }
//
// class QuotationSalesman {
//   final String id;
//   final String name;
//   final String employeeCode;
//
//   const QuotationSalesman({
//     required this.id,
//     required this.name,
//     required this.employeeCode,
//   });
//
//   factory QuotationSalesman.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return const QuotationSalesman(id: '', name: '', employeeCode: '');
//     return QuotationSalesman(
//       id: _asString(json['id']),
//       name: _asString(json['name']),
//       employeeCode: _asString(json['employee_code']),
//     );
//   }
// }
//
// class QuotationContractor {
//   final String id;
//   final String name;
//   final String mobile;
//   final String email;
//   final String address;
//
//   const QuotationContractor({
//     required this.id,
//     required this.name,
//     required this.mobile,
//     required this.email,
//     required this.address,
//   });
//
//   factory QuotationContractor.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return const QuotationContractor(id: '', name: '', mobile: '', email: '', address: '');
//     }
//     return QuotationContractor(
//       id: _asString(json['id']),
//       name: _asString(json['name']),
//       mobile: _asString(json['mobile']),
//       email: _asString(json['email']),
//       address: _asString(json['address']),
//     );
//   }
// }
//
// /// The `created_by` block from /quotations/show — includes `role_label`
// /// (a human-readable role name like "Salesman") alongside id/email/name/role.
// class QuotationCreatedBy {
//   final String id;
//   final String name;
//   final String email;
//   final String role;
//   final String roleLabel;
//
//   const QuotationCreatedBy({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//     required this.roleLabel,
//   });
//
//   factory QuotationCreatedBy.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return const QuotationCreatedBy(id: '', name: '', email: '', role: '', roleLabel: '');
//     }
//     return QuotationCreatedBy(
//       id: _asString(json['id']),
//       name: _asString(json['name']),
//       email: _asString(json['email']),
//       role: _asString(json['role']),
//       roleLabel: _asString(json['role_label']),
//     );
//   }
// }
//
// /// Full detail of a single quotation/estimate, from POST /quotations/show.
// class QuotationDetailModel {
//   final String id;
//   final String quotationNumber;
//
//   /// Date as sent by the server (yyyy-MM-dd) — kept as a string plus a
//   /// parsed DateTime for display flexibility.
//   final String dateRaw;
//   final DateTime? date;
//
//   final String status;
//   final String notes;
//   final String createdAt;
//   final String updatedAt;
//
//   final double subtotal;
//   final double handlingCharge;
//   final double grandTotal;
//   final double totalSquareFeet;
//
//   final int itemsCount;
//   final double totalQuantity;
//
//   final List<QuotationDetailItem> items;
//
//   final bool hasSiteVisit;
//   final String? siteVisitId;
//
//   final QuotationCustomer customer;
//   final QuotationSalesman salesman;
//   final QuotationContractor contractor;
//   final QuotationCreatedBy createdBy;
//
//   const QuotationDetailModel({
//     required this.id,
//     required this.quotationNumber,
//     required this.dateRaw,
//     required this.date,
//     required this.status,
//     required this.notes,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.subtotal,
//     required this.handlingCharge,
//     required this.grandTotal,
//     required this.totalSquareFeet,
//     required this.itemsCount,
//     required this.totalQuantity,
//     required this.items,
//     required this.hasSiteVisit,
//     required this.siteVisitId,
//     required this.customer,
//     required this.salesman,
//     required this.contractor,
//     required this.createdBy,
//   });
//
//   factory QuotationDetailModel.fromJson(Map<String, dynamic> json) {
//     final totals = json['totals'];
//     final totalsMap = totals is Map<String, dynamic> ? totals : const <String, dynamic>{};
//     final rawItems = json['items'];
//     final dateRaw = _asString(json['date']);
//
//     return QuotationDetailModel(
//       id: _asString(json['id']),
//       quotationNumber: _asString(json['quotation_number']),
//       dateRaw: dateRaw,
//       date: DateTime.tryParse(dateRaw),
//       status: _asString(json['status']),
//       notes: _asString(json['notes']),
//       createdAt: _asString(json['created_at']),
//       updatedAt: _asString(json['updated_at']),
//       subtotal: _asDouble(json['subtotal']),
//       handlingCharge: _asDouble(json['handling_charge']),
//       grandTotal: _asDouble(json['grand_total']),
//       totalSquareFeet: _asDouble(json['total_square_feet']),
//       itemsCount: _asInt(totalsMap['items_count']),
//       totalQuantity: _asDouble(totalsMap['total_quantity']),
//       items: rawItems is List
//           ? rawItems
//           .whereType<Map>()
//           .map((e) => QuotationDetailItem.fromJson(e.cast<String, dynamic>()))
//           .toList()
//           : const [],
//       hasSiteVisit: _asBool(json['has_site_visit']),
//       siteVisitId: json['site_visit_id'] == null ? null : _asString(json['site_visit_id']),
//       customer: QuotationCustomer.fromJson(json['customer'] as Map<String, dynamic>?),
//       salesman: QuotationSalesman.fromJson(json['salesman'] as Map<String, dynamic>?),
//       contractor: QuotationContractor.fromJson(json['contractor'] as Map<String, dynamic>?),
//       createdBy: QuotationCreatedBy.fromJson(json['created_by'] as Map<String, dynamic>?),
//     );
//   }
//
//   bool get isDraft => status.toLowerCase() == 'draft';
//
//   /// Total MRP value across all items (unit MRP × quantity, summed).
//   /// Items with no MRP from the API (mrp == 0) simply contribute 0, so
//   /// this stays consistent even when the backend sends "mrp": "0" for
//   /// every line — the detail screen's "Mrp Total" row reads this.
//   double get mrp => items.fold<double>(0, (sum, i) => sum + (i.mrp * i.quantity));
//
//   QuotationDetailModel copyWith({String? status}) {
//     return QuotationDetailModel(
//       id: id,
//       quotationNumber: quotationNumber,
//       dateRaw: dateRaw,
//       date: date,
//       status: status ?? this.status,
//       notes: notes,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//       subtotal: subtotal,
//       handlingCharge: handlingCharge,
//       grandTotal: grandTotal,
//       totalSquareFeet: totalSquareFeet,
//       itemsCount: itemsCount,
//       totalQuantity: totalQuantity,
//       items: items,
//       hasSiteVisit: hasSiteVisit,
//       siteVisitId: siteVisitId,
//       customer: customer,
//       salesman: salesman,
//       contractor: contractor,
//       createdBy: createdBy,
//     );
//   }
// }
//
// class QuotationDetailResponseModel {
//   final String status;
//   final String statusCode;
//   final QuotationDetailModel? data;
//   final String message;
//
//   const QuotationDetailResponseModel({
//     required this.status,
//     required this.statusCode,
//     required this.data,
//     required this.message,
//   });
//
//   factory QuotationDetailResponseModel.fromJson(Map<String, dynamic> json) {
//     final data = json['data'];
//     return QuotationDetailResponseModel(
//       status: _asString(json['status']),
//       statusCode: _asString(json['status_code']),
//       message: _asString(json['message']),
//       data: data is Map<String, dynamic> && data.isNotEmpty
//           ? QuotationDetailModel.fromJson(data)
//           : null,
//     );
//   }
// }
double _asDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _asString(dynamic v) => v?.toString() ?? '';

bool _asBool(dynamic v) {
  final s = _asString(v);
  return s == '1' || s.toLowerCase() == 'true';
}

/// Returns the first non-empty string found under any of [keys].
String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final s = _asString(json[k]);
    if (s.isNotEmpty) return s;
  }
  return '';
}

/// Returns the first non-null value found under any of [keys].
dynamic _firstValue(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json[k] != null) return json[k];
  }
  return null;
}

/// One line item from a quotation/estimate detail response, including the
/// incentive figures that were locked in at the time the item was added
/// (bonus_type_at_time / min_quantity_at_time / incentive_percentage_at_time),
/// so historical estimates keep showing the incentive terms that actually
/// applied even if the product's incentive rules change later.
class QuotationDetailItem {
  final String id;
  final String productId;
  final String productName;
  final String productSize;
  final String productUnit;
  final String companyName;
  final double mrp;
  final double quantity;
  final double boxQuantity;
  final double pieceQuantity;
  final double rate;
  final double amount;
  final double incentiveAmount;
  final bool isIncentiveEligible;
  final String bonusTypeAtTime;
  final double minQuantityAtTime;
  final double incentivePercentageAtTime;

  const QuotationDetailItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSize,
    required this.productUnit,
    required this.companyName,
    required this.mrp,
    required this.quantity,
    required this.boxQuantity,
    required this.pieceQuantity,
    required this.rate,
    required this.amount,
    required this.incentiveAmount,
    required this.isIncentiveEligible,
    required this.bonusTypeAtTime,
    required this.minQuantityAtTime,
    required this.incentivePercentageAtTime,
  });

  factory QuotationDetailItem.fromJson(Map<String, dynamic> json) {
    return QuotationDetailItem(
      id: _asString(json['id']),
      productId: _asString(json['product_id']),
      productName: _asString(json['product_name']),
      productSize: _asString(json['product_size']),
      productUnit: _asString(json['product_unit']),
      companyName: _asString(json['company_name']),
      mrp: _asDouble(json['mrp']),
      quantity: _asDouble(json['quantity']),
      boxQuantity: _asDouble(json['box_quantity']),
      pieceQuantity: _asDouble(json['piece_quantity']),
      rate: _asDouble(json['rate']),
      amount: _asDouble(json['amount']),
      incentiveAmount: _asDouble(json['incentive_amount']),
      isIncentiveEligible: _asBool(json['is_incentive_eligible']),
      bonusTypeAtTime: _asString(json['bonus_type_at_time']),
      minQuantityAtTime: _asDouble(json['min_quantity_at_time']),
      incentivePercentageAtTime: _asDouble(json['incentive_percentage_at_time']),
    );
  }
}

/// A single payment received against a quotation.
///
/// The detail endpoint may return these under `payments`. Key names are read
/// defensively (payment_method / method, payment_date / date, ...) so small
/// naming differences on the backend do not break parsing.
class QuotationPayment {
  final String id;
  final String method;
  final double amount;
  final String date;
  final String reference;
  final String notes;

  const QuotationPayment({
    required this.id,
    required this.method,
    required this.amount,
    required this.date,
    required this.reference,
    required this.notes,
  });

  factory QuotationPayment.fromJson(Map<String, dynamic> json) {
    return QuotationPayment(
      id: _asString(json['id']),
      method: _firstString(json, ['payment_method', 'method', 'mode']),
      amount: _asDouble(_firstValue(json, ['amount', 'payment_amount'])),
      date: _firstString(json, ['payment_date', 'date', 'created_at']),
      reference: _firstString(json, ['payment_reference', 'reference']),
      notes: _firstString(json, ['payment_notes', 'notes']),
    );
  }

  /// "bank_transfer" -> "Bank Transfer", "cheque" -> "Cheque".
  String get methodLabel {
    if (method.isEmpty) return 'Payment';
    return method
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class QuotationCustomer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;

  const QuotationCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory QuotationCustomer.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationCustomer(id: '', name: '', phone: '', email: '', address: '');
    }
    return QuotationCustomer(
      id: _asString(json['id']),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      address: _asString(json['address']),
    );
  }
}

class QuotationSalesman {
  final String id;
  final String name;
  final String employeeCode;

  const QuotationSalesman({
    required this.id,
    required this.name,
    required this.employeeCode,
  });

  factory QuotationSalesman.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuotationSalesman(id: '', name: '', employeeCode: '');
    return QuotationSalesman(
      id: _asString(json['id']),
      name: _asString(json['name']),
      employeeCode: _asString(json['employee_code']),
    );
  }
}

class QuotationContractor {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String address;

  const QuotationContractor({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
  });

  factory QuotationContractor.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationContractor(id: '', name: '', mobile: '', email: '', address: '');
    }
    return QuotationContractor(
      id: _asString(json['id']),
      name: _asString(json['name']),
      mobile: _asString(json['mobile']),
      email: _asString(json['email']),
      address: _asString(json['address']),
    );
  }
}

/// The `created_by` block from /quotations/show — includes `role_label`
/// (a human-readable role name like "Salesman") alongside id/email/name/role.
class QuotationCreatedBy {
  final String id;
  final String name;
  final String email;
  final String role;
  final String roleLabel;

  const QuotationCreatedBy({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleLabel,
  });

  factory QuotationCreatedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationCreatedBy(id: '', name: '', email: '', role: '', roleLabel: '');
    }
    return QuotationCreatedBy(
      id: _asString(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      role: _asString(json['role']),
      roleLabel: _asString(json['role_label']),
    );
  }
}

/// Full detail of a single quotation/estimate, from POST /quotations/show.
class QuotationDetailModel {
  final String id;
  final String quotationNumber;

  /// Date as sent by the server (yyyy-MM-dd) — kept as a string plus a
  /// parsed DateTime for display flexibility.
  final String dateRaw;
  final DateTime? date;

  final String status;
  final String notes;
  final String createdAt;
  final String updatedAt;

  final double subtotal;
  final double handlingCharge;

  /// Total BEFORE discount (subtotal + handling charge).
  final double grandTotal;
  final double totalSquareFeet;

  // ---- Discount / payment summary (present once a quotation is approved) ----

  /// 'percentage' | 'fixed' | '' (no discount).
  final String discountType;

  /// The raw value entered: 5 for "5 %", or the flat amount for 'fixed'.
  final double discountValue;

  /// The discount converted to currency (e.g. 140).
  final double discountAmount;

  /// grandTotal - discountAmount. This is the actual payable amount.
  final double amountAfterDiscount;

  final double totalPaid;
  final double balanceAmount;

  /// 'paid' | 'partial' | 'unpaid' | '' (not applicable yet).
  final String balanceStatus;

  final int itemsCount;
  final double totalQuantity;

  final List<QuotationDetailItem> items;

  /// Individual payments, if the endpoint returns them. Empty otherwise.
  final List<QuotationPayment> payments;

  final bool hasSiteVisit;
  final String? siteVisitId;

  final QuotationCustomer customer;
  final QuotationSalesman salesman;
  final QuotationContractor contractor;
  final QuotationCreatedBy createdBy;

  const QuotationDetailModel({
    required this.id,
    required this.quotationNumber,
    required this.dateRaw,
    required this.date,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.subtotal,
    required this.handlingCharge,
    required this.grandTotal,
    required this.totalSquareFeet,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.amountAfterDiscount,
    required this.totalPaid,
    required this.balanceAmount,
    required this.balanceStatus,
    required this.itemsCount,
    required this.totalQuantity,
    required this.items,
    required this.payments,
    required this.hasSiteVisit,
    required this.siteVisitId,
    required this.customer,
    required this.salesman,
    required this.contractor,
    required this.createdBy,
  });

  factory QuotationDetailModel.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'];
    final totalsMap = totals is Map<String, dynamic> ? totals : const <String, dynamic>{};
    final rawItems = json['items'];
    final rawPayments = json['payments'];
    final dateRaw = _asString(json['date']);

    final grandTotal = _asDouble(json['grand_total']);
    final discountAmount = _asDouble(json['discount_amount']);

    // amount_after_discount: trust the server, but fall back to
    // grand_total - discount when it is missing (older responses / drafts).
    final rawAfterDiscount = _asDouble(json['amount_after_discount']);
    final amountAfterDiscount =
    (json['amount_after_discount'] == null ||
        (rawAfterDiscount <= 0 && discountAmount <= 0))
        ? grandTotal - discountAmount
        : rawAfterDiscount;

    final totalPaid = _asDouble(json['total_paid']);

    // balance_amount: same idea — compute it if the server did not send it.
    final balanceAmount = json['balance_amount'] != null
        ? _asDouble(json['balance_amount'])
        : (amountAfterDiscount - totalPaid).clamp(0, double.infinity).toDouble();

    return QuotationDetailModel(
      id: _asString(json['id']),
      quotationNumber: _asString(json['quotation_number']),
      dateRaw: dateRaw,
      date: DateTime.tryParse(dateRaw),
      status: _asString(json['status']),
      notes: _asString(json['notes']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
      subtotal: _asDouble(json['subtotal']),
      handlingCharge: _asDouble(json['handling_charge']),
      grandTotal: grandTotal,
      totalSquareFeet: _asDouble(json['total_square_feet']),
      discountType: _asString(json['discount_type']).toLowerCase(),
      discountValue: _asDouble(json['discount_value']),
      discountAmount: discountAmount,
      amountAfterDiscount: amountAfterDiscount,
      totalPaid: totalPaid,
      balanceAmount: balanceAmount,
      balanceStatus: _asString(json['balance_status']).toLowerCase(),
      itemsCount: _asInt(totalsMap['items_count']),
      totalQuantity: _asDouble(totalsMap['total_quantity']),
      items: rawItems is List
          ? rawItems
          .whereType<Map>()
          .map((e) => QuotationDetailItem.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
      payments: rawPayments is List
          ? rawPayments
          .whereType<Map>()
          .map((e) => QuotationPayment.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
      hasSiteVisit: _asBool(json['has_site_visit']),
      siteVisitId: json['site_visit_id'] == null ? null : _asString(json['site_visit_id']),
      customer: QuotationCustomer.fromJson(json['customer'] as Map<String, dynamic>?),
      salesman: QuotationSalesman.fromJson(json['salesman'] as Map<String, dynamic>?),
      contractor: QuotationContractor.fromJson(json['contractor'] as Map<String, dynamic>?),
      createdBy: QuotationCreatedBy.fromJson(json['created_by'] as Map<String, dynamic>?),
    );
  }

  bool get isDraft => status.toLowerCase() == 'draft';

  /// True when a discount was actually applied.
  bool get hasDiscount => discountAmount > 0;

  /// Label for the discount row, e.g. "Discount (5%)" or "Discount (Flat)".
  String get discountLabel {
    switch (discountType) {
      case 'percentage':
        final v = discountValue == discountValue.roundToDouble()
            ? discountValue.toStringAsFixed(0)
            : discountValue.toStringAsFixed(2);
        return 'Discount ($v%)';
      case 'fixed':
        return 'Discount (Flat)';
      default:
        return 'Discount';
    }
  }

  /// Payment summary (Total Paid / Balance) is only meaningful once the
  /// backend has started tracking payments for this quotation.
  bool get showPaymentSummary => balanceStatus.isNotEmpty || totalPaid > 0;

  /// Total MRP value across all items (unit MRP × quantity, summed).
  /// Items with no MRP from the API (mrp == 0) simply contribute 0, so
  /// this stays consistent even when the backend sends "mrp": "0" for
  /// every line — the detail screen's "Mrp Total" row reads this.
  double get mrp => items.fold<double>(0, (sum, i) => sum + (i.mrp * i.quantity));

  QuotationDetailModel copyWith({String? status}) {
    return QuotationDetailModel(
      id: id,
      quotationNumber: quotationNumber,
      dateRaw: dateRaw,
      date: date,
      status: status ?? this.status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      subtotal: subtotal,
      handlingCharge: handlingCharge,
      grandTotal: grandTotal,
      totalSquareFeet: totalSquareFeet,
      discountType: discountType,
      discountValue: discountValue,
      discountAmount: discountAmount,
      amountAfterDiscount: amountAfterDiscount,
      totalPaid: totalPaid,
      balanceAmount: balanceAmount,
      balanceStatus: balanceStatus,
      itemsCount: itemsCount,
      totalQuantity: totalQuantity,
      items: items,
      payments: payments,
      hasSiteVisit: hasSiteVisit,
      siteVisitId: siteVisitId,
      customer: customer,
      salesman: salesman,
      contractor: contractor,
      createdBy: createdBy,
    );
  }
}

class QuotationDetailResponseModel {
  final String status;
  final String statusCode;
  final QuotationDetailModel? data;
  final String message;

  const QuotationDetailResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory QuotationDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return QuotationDetailResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
      data: data is Map<String, dynamic> && data.isNotEmpty
          ? QuotationDetailModel.fromJson(data)
          : null,
    );
  }
}