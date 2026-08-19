// lib/models/payment_models/payment_models.dart

/// Allowed values for `payment_method` on POST /payments.
class PaymentMethod {
  PaymentMethod._();

  static const String cash = 'cash';
  static const String cheque = 'cheque';
  static const String online = 'online';
  static const String credit = 'credit';
  static const String bankTransfer = 'bank_transfer';

  static const List<String> all = [cash, cheque, online, credit, bankTransfer];

  /// Human readable label for dropdowns / chips.
  static String label(String value) {
    switch (value) {
      case cheque:
        return 'Cheque';
      case online:
        return 'Online';
      case credit:
        return 'Credit';
      case bankTransfer:
        return 'Bank Transfer';
      case cash:
      default:
        return 'Cash';
    }
  }
}

/// ===================== REQUEST MODELS =====================

/// Body for POST /payments
class AddPaymentRequest {
  final int estimateId;
  final double amount;

  /// yyyy-MM-dd
  final String paymentDate;

  /// cash | cheque | online | credit | bank_transfer (default: cash)
  final String paymentMethod;
  final String? paymentReference;
  final String? notes;

  const AddPaymentRequest({
    required this.estimateId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentReference,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'estimate_id': estimateId,
    'amount': amount,
    'payment_date': paymentDate,
    'payment_method': paymentMethod,
    if (paymentReference != null && paymentReference!.trim().isNotEmpty)
      'payment_reference': paymentReference,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
  };
}

/// Body for POST /payments/delete
class DeletePaymentRequest {
  final int id;
  const DeletePaymentRequest(this.id);

  Map<String, dynamic> toJson() => {'id': id};
}

/// ===================== RESPONSE MODELS =====================

class PaymentEstimateSummary {
  final String id;
  final String estimateNumber;
  final String customerName;
  final String customerPhone;
  final String status;
  final String date;

  const PaymentEstimateSummary({
    required this.id,
    required this.estimateNumber,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.date,
  });

  factory PaymentEstimateSummary.fromJson(Map<String, dynamic> json) {
    return PaymentEstimateSummary(
      id: json['id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

class FinancialSummary {
  final double subtotal;
  final double handlingCharge;
  final double grandTotal;
  final double discountAmount;
  final double amountAfterDiscount;

  const FinancialSummary({
    required this.subtotal,
    required this.handlingCharge,
    required this.grandTotal,
    required this.discountAmount,
    required this.amountAfterDiscount,
  });

  static double _num(dynamic v) =>
      double.tryParse(v?.toString() ?? '') ?? 0.0;

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      subtotal: _num(json['subtotal']),
      handlingCharge: _num(json['handling_charge']),
      grandTotal: _num(json['grand_total']),
      discountAmount: _num(json['discount_amount']),
      amountAfterDiscount: _num(json['amount_after_discount']),
    );
  }
}

class PaymentSummary {
  final double totalPaid;
  final double balanceAmount;
  final String balanceStatus; // e.g. partial, paid, unpaid
  final bool isFullyPaid;
  final double availableBalance;

  const PaymentSummary({
    required this.totalPaid,
    required this.balanceAmount,
    required this.balanceStatus,
    required this.isFullyPaid,
    required this.availableBalance,
  });

  static double _num(dynamic v) =>
      double.tryParse(v?.toString() ?? '') ?? 0.0;

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalPaid: _num(json['total_paid']),
      balanceAmount: _num(json['balance_amount']),
      balanceStatus: json['balance_status']?.toString() ?? '',
      isFullyPaid: json['is_fully_paid']?.toString() == '1',
      availableBalance: _num(json['available_balance']),
    );
  }
}

class PaymentItem {
  final String id;
  final double amount;
  final String paymentMethod;
  final String paymentReference;
  final String paymentDate; // dd-MM-yyyy as returned by API
  final String notes;
  final String createdAt;
  final String createdBy;

  const PaymentItem({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentReference,
    required this.paymentDate,
    required this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? PaymentMethod.cash,
      paymentReference: json['payment_reference']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
    );
  }
}

class PaymentDetailsData {
  final PaymentEstimateSummary estimate;
  final FinancialSummary financialSummary;
  final PaymentSummary paymentSummary;
  final List<PaymentItem> payments;

  const PaymentDetailsData({
    required this.estimate,
    required this.financialSummary,
    required this.paymentSummary,
    required this.payments,
  });

  factory PaymentDetailsData.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsData(
      estimate: PaymentEstimateSummary.fromJson(
        (json['estimate'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      financialSummary: FinancialSummary.fromJson(
        (json['financial_summary'] as Map?)?.cast<String, dynamic>() ??
            const {},
      ),
      paymentSummary: PaymentSummary.fromJson(
        (json['payment_summary'] as Map?)?.cast<String, dynamic>() ??
            const {},
      ),
      payments: ((json['payments'] as List?) ?? const [])
          .map((e) => PaymentItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class PaymentDetailsResponse {
  final String status;
  final String statusCode;
  final PaymentDetailsData data;
  final String message;

  const PaymentDetailsResponse({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory PaymentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsResponse(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: PaymentDetailsData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}