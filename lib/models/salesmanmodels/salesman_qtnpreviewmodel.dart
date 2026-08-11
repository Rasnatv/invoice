import 'cretaeestimate_quotationmodel.dart' show QuotationItemRequest;

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

/// Request body for POST /quotations/preview.
///
/// Deliberately mirrors only what the Create Estimate screen has actually
/// collected so far (party/contractor details + items + handling charge/
/// notes/terms). Discount and payment aren't captured anywhere in this
/// flow yet, so they're always omitted here rather than faked.
class QuotationPreviewRequest {
  final String date;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? contractorName;
  final String? contractorPhone;
  final String? contractorEmail;
  final String? contractorAddress;
  final double handlingCharge;
  final String? notes;
  final String? termsConditions;
  final List<QuotationItemRequest> items;

  const QuotationPreviewRequest({
    required this.date,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    this.contractorName,
    this.contractorPhone,
    this.contractorEmail,
    this.contractorAddress,
    required this.handlingCharge,
    this.notes,
    this.termsConditions,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    if (customerEmail != null && customerEmail!.isNotEmpty) 'customer_email': customerEmail,
    if (customerAddress != null && customerAddress!.isNotEmpty)
      'customer_address': customerAddress,
    if (contractorName != null && contractorName!.isNotEmpty)
      'contractor_name': contractorName,
    if (contractorPhone != null && contractorPhone!.isNotEmpty)
      'contractor_phone': contractorPhone,
    if (contractorEmail != null && contractorEmail!.isNotEmpty)
      'contractor_email': contractorEmail,
    if (contractorAddress != null && contractorAddress!.isNotEmpty)
      'contractor_address': contractorAddress,
    'handling_charge': handlingCharge,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (termsConditions != null && termsConditions!.isNotEmpty)
      'terms_conditions': termsConditions,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

/// Shared shape for both `customer` and `contractor` in the response.
class QuotationPreviewParty {
  final String name;
  final String phone;
  final String email;
  final String address;

  const QuotationPreviewParty({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory QuotationPreviewParty.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationPreviewParty(name: '', phone: '', email: '', address: '');
    }
    return QuotationPreviewParty(
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      address: _asString(json['address']),
    );
  }
}

class QuotationPreviewItem {
  final String productId;
  final String productName;
  final String productSize;
  final String productUnit;
  final double mrp;
  final double rate;
  final double quantity;
  final double amount;
  final double mrpTotal;
  final double incentiveAmount;
  final bool isIncentiveEligible;
  final double perUnitIncentive;

  const QuotationPreviewItem({
    required this.productId,
    required this.productName,
    required this.productSize,
    required this.productUnit,
    required this.mrp,
    required this.rate,
    required this.quantity,
    required this.amount,
    required this.mrpTotal,
    required this.incentiveAmount,
    required this.isIncentiveEligible,
    required this.perUnitIncentive,
  });

  factory QuotationPreviewItem.fromJson(Map<String, dynamic> json) {
    return QuotationPreviewItem(
      productId: _asString(json['product_id']),
      productName: _asString(json['product_name']),
      productSize: _asString(json['product_size']),
      productUnit: _asString(json['product_unit']),
      mrp: _asDouble(json['mrp']),
      rate: _asDouble(json['rate']),
      quantity: _asDouble(json['quantity']),
      amount: _asDouble(json['amount']),
      mrpTotal: _asDouble(json['mrp_total']),
      incentiveAmount: _asDouble(json['incentive_amount']),
      isIncentiveEligible: _asString(json['is_incentive_eligible']) == '1',
      perUnitIncentive: _asDouble(json['per_unit_incentive']),
    );
  }
}

class QuotationPreviewTotals {
  final double subtotal;
  final double handlingCharge;
  final double grandTotal;
  final double amountAfterDiscount;
  final double mrpTotal;
  final String mrpTotalFormatted;
  final int totalItems;
  final double totalQuantity;
  final double totalSquareFeet;
  final double totalIncentive;
  final String totalIncentiveFormatted;

  const QuotationPreviewTotals({
    required this.subtotal,
    required this.handlingCharge,
    required this.grandTotal,
    required this.amountAfterDiscount,
    required this.mrpTotal,
    required this.mrpTotalFormatted,
    required this.totalItems,
    required this.totalQuantity,
    required this.totalSquareFeet,
    required this.totalIncentive,
    required this.totalIncentiveFormatted,
  });

  factory QuotationPreviewTotals.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationPreviewTotals(
        subtotal: 0,
        handlingCharge: 0,
        grandTotal: 0,
        amountAfterDiscount: 0,
        mrpTotal: 0,
        mrpTotalFormatted: '',
        totalItems: 0,
        totalQuantity: 0,
        totalSquareFeet: 0,
        totalIncentive: 0,
        totalIncentiveFormatted: '',
      );
    }
    return QuotationPreviewTotals(
      subtotal: _asDouble(json['subtotal']),
      handlingCharge: _asDouble(json['handling_charge']),
      grandTotal: _asDouble(json['grand_total']),
      amountAfterDiscount: _asDouble(json['amount_after_discount']),
      mrpTotal: _asDouble(json['mrp_total']),
      mrpTotalFormatted: _asString(json['mrp_total_formatted']),
      totalItems: _asInt(json['total_items']),
      totalQuantity: _asDouble(json['total_quantity']),
      totalSquareFeet: _asDouble(json['total_square_feet']),
      totalIncentive: _asDouble(json['total_incentive']),
      totalIncentiveFormatted: _asString(json['total_incentive_formatted']),
    );
  }
}

class QuotationPreviewDiscount {
  final String type;
  final double value;
  final double amount;
  final String amountFormatted;
  final String notes;

  const QuotationPreviewDiscount({
    required this.type,
    required this.value,
    required this.amount,
    required this.amountFormatted,
    required this.notes,
  });

  factory QuotationPreviewDiscount.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationPreviewDiscount(
          type: '', value: 0, amount: 0, amountFormatted: '', notes: '');
    }
    return QuotationPreviewDiscount(
      type: _asString(json['type']),
      value: _asDouble(json['value']),
      amount: _asDouble(json['amount']),
      amountFormatted: _asString(json['amount_formatted']),
      notes: _asString(json['notes']),
    );
  }

  bool get hasDiscount => amount > 0;
}

class QuotationPreviewPayment {
  final double amount;
  final String amountFormatted;
  final String method;
  final String reference;
  final String date;
  final String notes;

  const QuotationPreviewPayment({
    required this.amount,
    required this.amountFormatted,
    required this.method,
    required this.reference,
    required this.date,
    required this.notes,
  });

  factory QuotationPreviewPayment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QuotationPreviewPayment(
          amount: 0, amountFormatted: '', method: '', reference: '', date: '', notes: '');
    }
    return QuotationPreviewPayment(
      amount: _asDouble(json['amount']),
      amountFormatted: _asString(json['amount_formatted']),
      method: _asString(json['method']),
      reference: _asString(json['reference']),
      date: _asString(json['date']),
      notes: _asString(json['notes']),
    );
  }
}

class QuotationPreviewData {
  final QuotationPreviewParty customer;
  final QuotationPreviewParty contractor;
  final String date;
  final String notes;
  final String termsConditions;
  final double handlingCharge;
  final List<QuotationPreviewItem> items;
  final QuotationPreviewTotals totals;
  final QuotationPreviewDiscount discount;
  final QuotationPreviewPayment payment;
  final double balanceDue;
  final String balanceDueFormatted;

  const QuotationPreviewData({
    required this.customer,
    required this.contractor,
    required this.date,
    required this.notes,
    required this.termsConditions,
    required this.handlingCharge,
    required this.items,
    required this.totals,
    required this.discount,
    required this.payment,
    required this.balanceDue,
    required this.balanceDueFormatted,
  });

  factory QuotationPreviewData.fromJson(Map<String, dynamic> json) {
    return QuotationPreviewData(
      customer: QuotationPreviewParty.fromJson(json['customer'] as Map<String, dynamic>?),
      contractor: QuotationPreviewParty.fromJson(json['contractor'] as Map<String, dynamic>?),
      date: _asString(json['date']),
      notes: _asString(json['notes']),
      termsConditions: _asString(json['terms_conditions']),
      handlingCharge: _asDouble(json['handling_charge']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => QuotationPreviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: QuotationPreviewTotals.fromJson(json['totals'] as Map<String, dynamic>?),
      discount: QuotationPreviewDiscount.fromJson(json['discount'] as Map<String, dynamic>?),
      payment: QuotationPreviewPayment.fromJson(json['payment'] as Map<String, dynamic>?),
      balanceDue: _asDouble(json['balance_due']),
      balanceDueFormatted: _asString(json['balance_due_formatted']),
    );
  }
}

class QuotationPreviewResponseModel {
  final String status;
  final String statusCode;
  final QuotationPreviewData? data;
  final String message;

  const QuotationPreviewResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory QuotationPreviewResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationPreviewResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      data: json['data'] is Map<String, dynamic>
          ? QuotationPreviewData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: _asString(json['message']),
    );
  }
}