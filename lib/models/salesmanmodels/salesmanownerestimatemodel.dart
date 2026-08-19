// class SalesmanowrEstimateModel {
//   final String id;
//   final String estimateNumber;
//   final String customerName;
//   final String customerPhone;
//   final String salesmanName;
//   final String contractorName;
//   final String date;
//   final String grandTotalFormatted;
//   final String balanceAmountFormatted;
//   final String canPayNow;
//   final String approvedBy;
//   final String approvedAt;
//   final String totalItems;
//   final String quotationNumber;
//   final String status;
//
//   const SalesmanowrEstimateModel({
//     required this.id,
//     required this.estimateNumber,
//     required this.customerName,
//     required this.customerPhone,
//     required this.salesmanName,
//     required this.contractorName,
//     required this.date,
//     required this.grandTotalFormatted,
//     required this.balanceAmountFormatted,
//     required this.canPayNow,
//     required this.approvedBy,
//     required this.approvedAt,
//     required this.totalItems,
//     required this.quotationNumber,
//     required this.status,
//   });
//
//   factory SalesmanowrEstimateModel.fromJson(Map<String, dynamic> json) {
//     return SalesmanowrEstimateModel(
//       id: json['id']?.toString() ?? '',
//       estimateNumber: json['estimate_number']?.toString() ?? '',
//       customerName: json['customer_name']?.toString() ?? '',
//       customerPhone: json['customer_phone']?.toString() ?? '',
//       salesmanName: json['salesman_name']?.toString() ?? '',
//       contractorName: json['contractor_name']?.toString() ?? '',
//       date: json['date']?.toString() ?? '',
//       grandTotalFormatted: json['grand_total_formatted']?.toString() ?? '',
//       balanceAmountFormatted: json['balance_amount_formatted']?.toString() ?? '',
//       canPayNow: json['can_pay_now']?.toString() ?? '0',
//       approvedBy: json['approved_by']?.toString() ?? '',
//       approvedAt: json['approved_at']?.toString() ?? '',
//       totalItems: json['total_items']?.toString() ?? '0',
//       quotationNumber: json['quotation_number']?.toString() ?? '',
//       status: json['status']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'estimate_number': estimateNumber,
//       'customer_name': customerName,
//       'customer_phone': customerPhone,
//       'salesman_name': salesmanName,
//       'contractor_name': contractorName,
//       'date': date,
//       'grand_total_formatted': grandTotalFormatted,
//       'balance_amount_formatted': balanceAmountFormatted,
//       'can_pay_now': canPayNow,
//       'approved_by': approvedBy,
//       'approved_at': approvedAt,
//       'total_items': totalItems,
//       'quotation_number': quotationNumber,
//       'status': status,
//     };
//   }
//
//   bool get canPayNowBool => canPayNow == '1';
//   bool get isApproved => approvedBy.trim().isNotEmpty;
//   bool get hasQuotation => quotationNumber.trim().isNotEmpty;
//   bool get hasBalance =>
//       balanceAmountFormatted.trim().isNotEmpty && balanceAmountFormatted != '₹0.00';
//
//   /// Normalized key used for grouping/filtering. The API sends an empty
//   /// string for estimates that aren't linked to a quotation yet, so those
//   /// are grouped under 'new' instead of being lost as a blank tab.
//   String get statusKey => status.trim().isEmpty ? 'new' : status.trim().toLowerCase();
//
//   /// Human friendly label for chips / badges.
//   String get statusLabel {
//     if (status.trim().isEmpty) return 'New';
//     return status[0].toUpperCase() + status.substring(1).toLowerCase();
//   }
// }
class SalesmanowrEstimateModel {
  final String id;
  final String estimateNumber;
  final String customerName;
  final String customerPhone;
  final String salesmanName;
  final String contractorName;
  final String date;
  final String grandTotalFormatted;
  final String balanceAmountFormatted;
  final String canPayNow;
  final String approvedBy;
  final String approvedAt;
  final String totalItems;
  final String quotationNumber;
  final String status;

  const SalesmanowrEstimateModel({
    required this.id,
    required this.estimateNumber,
    required this.customerName,
    required this.customerPhone,
    required this.salesmanName,
    required this.contractorName,
    required this.date,
    required this.grandTotalFormatted,
    required this.balanceAmountFormatted,
    required this.canPayNow,
    required this.approvedBy,
    required this.approvedAt,
    required this.totalItems,
    required this.quotationNumber,
    required this.status,
  });

  factory SalesmanowrEstimateModel.fromJson(Map<String, dynamic> json) {
    return SalesmanowrEstimateModel(
      id: json['id']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      contractorName: json['contractor_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      grandTotalFormatted: json['grand_total_formatted']?.toString() ?? '',
      balanceAmountFormatted: json['balance_amount_formatted']?.toString() ?? '',
      canPayNow: json['can_pay_now']?.toString() ?? '0',
      approvedBy: json['approved_by']?.toString() ?? '',
      approvedAt: json['approved_at']?.toString() ?? '',
      totalItems: json['total_items']?.toString() ?? '0',
      quotationNumber: json['quotation_number']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estimate_number': estimateNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'salesman_name': salesmanName,
      'contractor_name': contractorName,
      'date': date,
      'grand_total_formatted': grandTotalFormatted,
      'balance_amount_formatted': balanceAmountFormatted,
      'can_pay_now': canPayNow,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'total_items': totalItems,
      'quotation_number': quotationNumber,
      'status': status,
    };
  }

  bool get canPayNowBool => canPayNow == '1';
  bool get isApproved => approvedBy.trim().isNotEmpty;
  bool get hasQuotation => quotationNumber.trim().isNotEmpty;
  bool get hasBalance =>
      balanceAmountFormatted.trim().isNotEmpty && balanceAmountFormatted != '₹0.00';

  /// Strips currency symbol / commas / spaces from a formatted string like
  /// "₹50,500.00" and parses it back to a double. Falls back to 0.0 if the
  /// string is empty or unparsable.
  static double _parseFormattedAmount(String formatted) {
    final cleaned = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get grandTotalValue => _parseFormattedAmount(grandTotalFormatted);
  double get balanceAmountValue => _parseFormattedAmount(balanceAmountFormatted);

  /// Derived amount paid. The list API doesn't send "amount paid" directly,
  /// so this is total minus outstanding balance. Clamped so it never goes
  /// negative or above the grand total if the formatted strings are off.
  double get amountPaidValue =>
      (grandTotalValue - balanceAmountValue).clamp(0, grandTotalValue);

  /// Normalized key used for grouping/filtering. The API sends an empty
  /// string for estimates that aren't linked to a quotation yet, so those
  /// are grouped under 'new' instead of being lost as a blank tab.
  String get statusKey => status.trim().isEmpty ? 'new' : status.trim().toLowerCase();

  /// Human friendly label for chips / badges.
  String get statusLabel {
    if (status.trim().isEmpty) return 'New';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}