
class ProductIncentiveRequest {
  final int productId;
  final double quantity;
  final double rate;
  final double? boxQuantity;
  final double? pieceQuantity;

  const ProductIncentiveRequest({
    required this.productId,
    required this.quantity,
    required this.rate,
    this.boxQuantity,
    this.pieceQuantity,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'rate': rate,
    if (boxQuantity != null) 'box_quantity': boxQuantity,
    if (pieceQuantity != null) 'piece_quantity': pieceQuantity,
  };
}

class ProductIncentiveModel {
  final String productId;
  final String productName;
  final String productSize;
  final double quantity;
  final double rate;
  final String incentiveType;
  final double incentivePercentage;
  final double incentiveAmount;
  final String bonusType;
  final double minQuantity;
  final double perUnitIncentive;
  final double totalIncentive;
  final String totalIncentiveFormatted;
  final bool isEligible;
  final String eligibilityReason;
  final double amount;
  final String amountFormatted;
  final double boxQuantity;
  final double pieceQuantity;

  const ProductIncentiveModel({
    required this.productId,
    required this.productName,
    required this.productSize,
    required this.quantity,
    required this.rate,
    required this.incentiveType,
    required this.incentivePercentage,
    required this.incentiveAmount,
    required this.bonusType,
    required this.minQuantity,
    required this.perUnitIncentive,
    required this.totalIncentive,
    required this.totalIncentiveFormatted,
    required this.isEligible,
    required this.eligibilityReason,
    required this.amount,
    required this.amountFormatted,
    required this.boxQuantity,
    required this.pieceQuantity,
  });

  factory ProductIncentiveModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
    return ProductIncentiveModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productSize: json['product_size']?.toString() ?? '',
      quantity: toDouble(json['quantity']),
      rate: toDouble(json['rate']),
      incentiveType: json['incentive_type']?.toString() ?? '',
      incentivePercentage: toDouble(json['incentive_percentage']),
      incentiveAmount: toDouble(json['incentive_amount']),
      bonusType: json['bonus_type']?.toString() ?? '',
      minQuantity: toDouble(json['min_quantity']),
      perUnitIncentive: toDouble(json['per_unit_incentive']),
      totalIncentive: toDouble(json['total_incentive']),
      totalIncentiveFormatted: json['total_incentive_formatted']?.toString() ?? '',
      isEligible: json['is_eligible']?.toString() == '1',
      eligibilityReason: json['eligibility_reason']?.toString() ?? '',
      amount: toDouble(json['amount']),
      amountFormatted: json['amount_formatted']?.toString() ?? '',
      boxQuantity: toDouble(json['box_quantity']),
      pieceQuantity: toDouble(json['piece_quantity']),
    );
  }
}

class ProductIncentiveResponseModel {
  final String status;
  final String statusCode;
  final String message;
  final ProductIncentiveModel? data;

  const ProductIncentiveResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ProductIncentiveResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return ProductIncentiveResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: rawData is Map<String, dynamic>
          ? ProductIncentiveModel.fromJson(rawData)
          : null,
    );
  }
}