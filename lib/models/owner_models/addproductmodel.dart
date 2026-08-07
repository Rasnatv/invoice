

import '../../Apiprovider/product_enums.dart';

/// Request body for POST /products/create.
class ProductAddRequestModel {
  const ProductAddRequestModel({
    required this.name,
    required this.companyId,
    required this.size,
    required this.unitId,
    required this.mrp,
    required this.rate,
    required this.incentiveType,
    this.incentiveAmount,
    this.incentivePercentage,
    required this.bonusType,
    this.minQuantity = 0,
  });

  final String name;
  final String companyId;
  final String size;
  final String unitId;
  final double mrp;
  final double rate;
  final ProductIncentiveType incentiveType;

  /// Only sent (and required) when [incentiveType] is fixed.
  final double? incentiveAmount;

  /// Only sent (and required) when [incentiveType] is percentage.
  final double? incentivePercentage;
  final ProductBonusType bonusType;

  /// Only meaningful when [bonusType] is bulk — kept at 0 for single.
  final num minQuantity;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company_id': companyId,
      'size': size,
      'unit_id': unitId,
      'mrp': mrp.toString(),
      'rate': rate.toString(),
      'incentive_type': incentiveType.apiValue,
      if (incentiveType == ProductIncentiveType.fixed)
        'incentive_amount': incentiveAmount.toString(),
      if (incentiveType == ProductIncentiveType.percentage)
        'incentive_percentage': incentivePercentage,
      'bonus_type': bonusType.apiValue,
      'min_quantity': minQuantity,
    };
  }
}

class ProductAddResponseModel {
  const ProductAddResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  final String status;
  final String statusCode;
  final String message;

  factory ProductAddResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductAddResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
