
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

/// Safely reads a nested object field. Unlike `json['x'] as Map<String, dynamic>?`,
/// this does NOT throw when the API sends an empty string, an empty list, or
/// any other non-map "no value" placeholder for a relation — it just treats
/// it as absent. Some backends send `""` instead of `null` for empty
/// relations (e.g. an estimate with no linked site visit / contractor),
/// and a hard cast on that throws a TypeError that gets silently swallowed
/// by callers' generic `catch (_)` blocks, surfacing as a vague
/// "Something went wrong" with no indication of the real cause.
Map<String, dynamic>? _asMap(dynamic v) => v is Map<String, dynamic> ? v : null;

bool _asBool(dynamic v) {
  final s = _asString(v);
  return s == '1' || s.toLowerCase() == 'true';
}

class EstimateDetailItem {
  final String id;
  final String productId;
  final String productName;
  final String productSize;
  final String companyName;
  final String unitName;
  final double mrp;
  final double quantity;
  final double rate;
  final double amount;
  final double incentiveAmount;
  final bool isIncentiveEligible;

  const EstimateDetailItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSize,
    required this.companyName,
    required this.unitName,
    required this.mrp,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.incentiveAmount,
    required this.isIncentiveEligible,
  });

  factory EstimateDetailItem.fromJson(Map<String, dynamic> json) {
    return EstimateDetailItem(
      id: _asString(json['id']),
      productId: _asString(json['product_id']),
      productName: _asString(json['product_name']),
      productSize: _asString(json['product_size']),
      companyName: _asString(json['company_name']),
      unitName: _asString(json['unit_name']),
      mrp: _asDouble(json['mrp']),
      quantity: _asDouble(json['quantity']),
      rate: _asDouble(json['rate']),
      amount: _asDouble(json['amount']),
      incentiveAmount: _asDouble(json['incentive_amount']),
      isIncentiveEligible: _asBool(json['is_incentive_eligible']),
    );
  }
}

/// The customer-facing party on an estimate. The API returns this under
/// the `contractor` key (not `customer`), and uses `mobile` rather than
/// `phone` for the contact number.
class EstimateCustomer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;

  const EstimateCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory EstimateCustomer.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EstimateCustomer(id: '', name: '', phone: '', email: '', address: '');
    }
    return EstimateCustomer(
      id: _asString(json['id']),
      name: _asString(json['name']),
      // API field is `mobile`; fall back to `phone` in case an older
      // payload shape is ever returned.
      phone: _asString(json['mobile'] ?? json['phone']),
      email: _asString(json['email']),
      address: _asString(json['address']),
    );
  }
}

class EstimateSalesman {
  final String id;
  final String name;
  final String employeeCode;

  const EstimateSalesman({required this.id, required this.name, required this.employeeCode});

  factory EstimateSalesman.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EstimateSalesman(id: '', name: '', employeeCode: '');
    return EstimateSalesman(
      id: _asString(json['id']),
      name: _asString(json['name']),
      employeeCode: _asString(json['employee_code']),
    );
  }
}

class EstimateFieldStaff {
  final String id;
  final String name;
  final String email;

  const EstimateFieldStaff({required this.id, required this.name, required this.email});

  factory EstimateFieldStaff.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EstimateFieldStaff(id: '', name: '', email: '');
    return EstimateFieldStaff(
      id: _asString(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
    );
  }
}

class EstimateSiteVisit {
  final String id;
  final String customerName;
  final String customerPhone;
  final String siteAddress;
  final String visitDate;
  final String status;
  final String statusLabel;
  final String fieldStaffName;
  final String fieldStaffId;
  final EstimateFieldStaff fieldStaff;

  const EstimateSiteVisit({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.siteAddress,
    required this.visitDate,
    required this.status,
    required this.statusLabel,
    required this.fieldStaffName,
    required this.fieldStaffId,
    required this.fieldStaff,
  });

  factory EstimateSiteVisit.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EstimateSiteVisit(
        id: '',
        customerName: '',
        customerPhone: '',
        siteAddress: '',
        visitDate: '',
        status: '',
        statusLabel: '',
        fieldStaffName: '',
        fieldStaffId: '',
        fieldStaff: EstimateFieldStaff.fromJson(null),
      );
    }
    return EstimateSiteVisit(
      id: _asString(json['id']),
      customerName: _asString(json['customer_name']),
      customerPhone: _asString(json['customer_phone']),
      siteAddress: _asString(json['site_address']),
      visitDate: _asString(json['visit_date']),
      status: _asString(json['status']),
      statusLabel: _asString(json['status_label']),
      fieldStaffName: _asString(json['field_staff_name']),
      // Present alongside the nested `field_staff` object in the response;
      // kept as a flat convenience field in addition to `fieldStaff`.
      fieldStaffId: _asString(json['field_staff_id']),
      fieldStaff: EstimateFieldStaff.fromJson(_asMap(json['field_staff'])),
    );
  }
}

class EstimateApprovedBy {
  final String id;
  final String name;
  final String email;
  final String role;

  const EstimateApprovedBy({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory EstimateApprovedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EstimateApprovedBy(id: '', name: '', email: '', role: '');
    return EstimateApprovedBy(
      id: _asString(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      role: _asString(json['role']),
    );
  }

  /// Server sends id: "0" as a sentinel for "not yet approved".
  bool get exists => id.isNotEmpty && id != '0';
}

/// Who created the estimate (e.g. the salesman/field staff role that
/// submitted it), as returned under `created_by_details`.
class EstimateCreatedBy {
  final String role;
  final String roleLabel;

  const EstimateCreatedBy({required this.role, required this.roleLabel});

  factory EstimateCreatedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EstimateCreatedBy(role: '', roleLabel: '');
    return EstimateCreatedBy(
      role: _asString(json['role']),
      roleLabel: _asString(json['role_label']),
    );
  }
}

class EstimateQuotationRef {
  final String id;
  final String quotationNumber;
  final String status;

  const EstimateQuotationRef({
    required this.id,
    required this.quotationNumber,
    required this.status,
  });

  factory EstimateQuotationRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EstimateQuotationRef(id: '0', quotationNumber: '', status: '');
    return EstimateQuotationRef(
      id: _asString(json['id']),
      quotationNumber: _asString(json['quotation_number']),
      status: _asString(json['status']),
    );
  }

  /// Server sends id: "0" as a sentinel for "no linked quotation".
  bool get exists => id.isNotEmpty && id != '0';
}

class EstimatePayment {
  final String id;
  final double amount;
  final String method;
  final String date;
  final String notes;

  const EstimatePayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    required this.notes,
  });

  factory EstimatePayment.fromJson(Map<String, dynamic> json) {
    return EstimatePayment(
      id: _asString(json['id']),
      amount: _asDouble(json['amount']),
      method: _asString(json['method']),
      date: _asString(json['date']),
      notes: _asString(json['notes']),
    );
  }
}

/// Full detail of a single estimate, from POST /estimates/show.
///
/// `status` drives what the UI is allowed to show: while the estimate is
/// still `pending_approval` (or any non-approved state), discount and
/// payment/balance figures aren't finalized yet, so the detail screen
/// hides those sections and the "Create Despatch Sheet" action — both
/// only become meaningful once an owner/admin has approved the estimate.
/// Later lifecycle states (e.g. `delivered`) are also treated as
/// "approved" for these purposes via [isApproved].
class EstimateDetailModel {
  final String id;
  final String estimateNumber;
  final String dateRaw;
  final DateTime? date;

  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String customerEmail;

  final double subtotal;
  final double handlingCharge;
  final double grandTotal;
  final double totalSquareFeet;

  final String status;
  final String notes;
  final String termsConditions;
  final String createdAt;
  final String updatedAt;

  final String approvedBy;
  final String approvedAt;
  final String approvalNotes;

  final String siteVisitId;
  final String fieldStaffId;

  final String discountType;
  final String discountTypeLabel;
  final double discountValue;
  final double discountAmount;
  final String discountNotes;
  final double amountAfterDiscount;

  final double totalPaid;
  final double balanceAmount;
  final String balanceStatus;
  final String balanceStatusLabel;
  final String balanceStatusColor;
  final bool isFullyPaid;

  final int itemsCount;
  final double totalQuantity;

  final EstimateSiteVisit siteVisit;
  final List<EstimatePayment> payments;
  final EstimateCustomer customer;
  final EstimateSalesman salesman;
  final EstimateApprovedBy approvedByDetails;
  final EstimateCreatedBy createdByDetails;
  final List<EstimateDetailItem> items;
  final EstimateQuotationRef quotation;

  const EstimateDetailModel({
    required this.id,
    required this.estimateNumber,
    required this.dateRaw,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerEmail,
    required this.subtotal,
    required this.handlingCharge,
    required this.grandTotal,
    required this.totalSquareFeet,
    required this.status,
    required this.notes,
    required this.termsConditions,
    required this.createdAt,
    required this.updatedAt,
    required this.approvedBy,
    required this.approvedAt,
    required this.approvalNotes,
    required this.siteVisitId,
    required this.fieldStaffId,
    required this.discountType,
    required this.discountTypeLabel,
    required this.discountValue,
    required this.discountAmount,
    required this.discountNotes,
    required this.amountAfterDiscount,
    required this.totalPaid,
    required this.balanceAmount,
    required this.balanceStatus,
    required this.balanceStatusLabel,
    required this.balanceStatusColor,
    required this.isFullyPaid,
    required this.itemsCount,
    required this.totalQuantity,
    required this.siteVisit,
    required this.payments,
    required this.customer,
    required this.salesman,
    required this.approvedByDetails,
    required this.createdByDetails,
    required this.items,
    required this.quotation,
  });

  factory EstimateDetailModel.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'];
    final totalsMap = totals is Map<String, dynamic> ? totals : const <String, dynamic>{};
    final rawItems = json['items'];
    final rawPayments = json['payments'];
    final dateRaw = _asString(json['date']);

    return EstimateDetailModel(
      id: _asString(json['id']),
      estimateNumber: _asString(json['estimate_number']),
      dateRaw: dateRaw,
      date: DateTime.tryParse(dateRaw),
      customerName: _asString(json['customer_name']),
      customerPhone: _asString(json['customer_phone']),
      customerAddress: _asString(json['customer_address']),
      customerEmail: _asString(json['customer_email']),
      subtotal: _asDouble(json['subtotal']),
      handlingCharge: _asDouble(json['handling_charge']),
      grandTotal: _asDouble(json['grand_total']),
      totalSquareFeet: _asDouble(json['total_square_feet']),
      status: _asString(json['status']),
      notes: _asString(json['notes']),
      termsConditions: _asString(json['terms_conditions']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
      approvedBy: _asString(json['approved_by']),
      approvedAt: _asString(json['approved_at']),
      approvalNotes: _asString(json['approval_notes']),
      siteVisitId: _asString(json['site_visit_id']),
      fieldStaffId: _asString(json['field_staff_id']),
      discountType: _asString(json['discount_type']),
      discountTypeLabel: _asString(json['discount_type_label']),
      discountValue: _asDouble(json['discount_value']),
      discountAmount: _asDouble(json['discount_amount']),
      discountNotes: _asString(json['discount_notes']),
      amountAfterDiscount: _asDouble(json['amount_after_discount']),
      totalPaid: _asDouble(json['total_paid']),
      balanceAmount: _asDouble(json['balance_amount']),
      balanceStatus: _asString(json['balance_status']),
      balanceStatusLabel: _asString(json['balance_status_label']),
      balanceStatusColor: _asString(json['balance_status_color']),
      isFullyPaid: _asBool(json['is_fully_paid']),
      itemsCount: _asInt(totalsMap['items_count']),
      totalQuantity: _asDouble(totalsMap['total_quantity']),
      siteVisit: EstimateSiteVisit.fromJson(_asMap(json['site_visit'])),
      payments: rawPayments is List
          ? rawPayments
          .whereType<Map>()
          .map((e) => EstimatePayment.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
      // API returns this party under `contractor`, not `customer`.
      customer: EstimateCustomer.fromJson(_asMap(json['contractor'])),
      salesman: EstimateSalesman.fromJson(_asMap(json['salesman'])),
      approvedByDetails:
      EstimateApprovedBy.fromJson(_asMap(json['approved_by_details'])),
      createdByDetails:
      EstimateCreatedBy.fromJson(_asMap(json['created_by_details'])),
      items: rawItems is List
          ? rawItems
          .whereType<Map>()
          .map((e) => EstimateDetailItem.fromJson(e.cast<String, dynamic>()))
          .toList()
          : const [],
      quotation: EstimateQuotationRef.fromJson(_asMap(json['quotation'])),
    );
  }

  /// Statuses treated as "approved" for UI purposes: once an estimate has
  /// moved past pending approval — including later lifecycle states like
  /// `delivered` — discount/payment figures are considered finalized.
  static const _approvedStatuses = {'approved', 'delivered'};

  bool get isApproved => _approvedStatuses.contains(status.toLowerCase());

  bool get isPendingApproval => status.toLowerCase() == 'pending_approval';

  bool get hasDiscount => discountAmount > 0;
}

class EstimateDetailResponseModel {
  final String status;
  final String statusCode;
  final EstimateDetailModel? data;
  final String message;

  const EstimateDetailResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory EstimateDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return EstimateDetailResponseModel(
      status: _asString(json['status']),
      statusCode: _asString(json['status_code']),
      message: _asString(json['message']),
      data: data is Map<String, dynamic> && data.isNotEmpty
          ? EstimateDetailModel.fromJson(data)
          : null,
    );
  }
}