class OwnerviewQuotationModel {
  final String id;
  final String quotationNumber;
  final String estimateNumber;
  final String customerName;
  final String customerPhone;
  final String salesmanName;
  final String status;
  final String date;
  final String totalItems;
  final String totalQuantity;
  final String grandTotal;

  OwnerviewQuotationModel({
    required this.id,
    required this.quotationNumber,
    required this.estimateNumber,
    required this.customerName,
    required this.customerPhone,
    required this.salesmanName,
    required this.status,
    required this.date,
    required this.totalItems,
    required this.totalQuantity,
    required this.grandTotal,
  });

  factory OwnerviewQuotationModel.fromJson(Map<String, dynamic> json) {
    return OwnerviewQuotationModel(
      id: json['id']?.toString() ?? '',
      quotationNumber: json['quotation_number']?.toString() ?? '',
      estimateNumber: json['estimate_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      salesmanName: json['salesman_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      totalItems: json['total_items']?.toString() ?? '0',
      totalQuantity: json['total_quantity']?.toString() ?? '0',
      grandTotal: json['grand_total']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_number': quotationNumber,
      'estimate_number': estimateNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'salesman_name': salesmanName,
      'status': status,
      'date': date,
      'total_items': totalItems,
      'total_quantity': totalQuantity,
      'grand_total': grandTotal,
    };
  }

  double get grandTotalValue => double.tryParse(grandTotal) ?? 0;
  int get totalItemsValue => int.tryParse(totalItems) ?? 0;
  int get totalQuantityValue => int.tryParse(totalQuantity) ?? 0;

  /// Parses the "dd-MM-yyyy" date string from the API into a DateTime.
  /// Returns null if parsing fails.
  DateTime? get parsedDate {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }
}

class QuotationDataModel {
  final List<OwnerviewQuotationModel> myQuotations;
  final List<OwnerviewQuotationModel> salesmanQuotations;

  QuotationDataModel({
    required this.myQuotations,
    required this.salesmanQuotations,
  });

  factory QuotationDataModel.fromJson(Map<String, dynamic> json) {
    return QuotationDataModel(
      myQuotations: (json['my_quotations'] as List<dynamic>? ?? [])
          .map((e) => OwnerviewQuotationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      salesmanQuotations: (json['salesman_quotations'] as List<dynamic>? ?? [])
          .map((e) => OwnerviewQuotationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuotationListResponseModel {
  final String status;
  final String statusCode;
  final QuotationDataModel data;
  final String message;

  QuotationListResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory QuotationListResponseModel.fromJson(Map<String, dynamic> json) {
    return QuotationListResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: QuotationDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
      message: json['message']?.toString() ?? '',
    );
  }
}