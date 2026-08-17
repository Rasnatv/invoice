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
  final double quantity;
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
    required this.quantity,
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
      quantity: _asDouble(json['quantity']),
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

class QuotationCreatedBy {
  final String id;
  final String name;
  final String email;
  final String role;

  const QuotationCreatedBy({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory QuotationCreatedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const QuotationCreatedBy(id: '', name: '', email: '', role: '');
    return QuotationCreatedBy(
      id: _asString(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      role: _asString(json['role']),
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
  final double grandTotal;
  final double totalSquareFeet;

  final int itemsCount;
  final double totalQuantity;

  final List<QuotationDetailItem> items;

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
    required this.itemsCount,
    required this.totalQuantity,
    required this.items,
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
    final dateRaw = _asString(json['date']);

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
      grandTotal: _asDouble(json['grand_total']),
      totalSquareFeet: _asDouble(json['total_square_feet']),
      itemsCount: _asInt(totalsMap['items_count']),
      totalQuantity: _asDouble(totalsMap['total_quantity']),
      items: rawItems is List
          ? rawItems
          .whereType<Map>()
          .map((e) => QuotationDetailItem.fromJson(e.cast<String, dynamic>()))
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
      itemsCount: itemsCount,
      totalQuantity: totalQuantity,
      items: items,
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
