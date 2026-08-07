import '../../Apiprovider/product_enums.dart';

/// Request body for POST /products/update. Same shape as add, plus
/// id and is_active.
class ProductUpdateRequestModel {
  const ProductUpdateRequestModel({
    required this.id,
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
    required this.minQuantity,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String companyId;
  final String size;
  final String unitId;
  final double mrp;
  final double rate;
  final ProductIncentiveType incentiveType;
  final double? incentiveAmount;
  final double? incentivePercentage;
  final ProductBonusType bonusType;
  final String minQuantity;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_id': companyId,
      'size': size,
      'unit_id': unitId,
      'mrp': mrp,
      'rate': rate,
      'incentive_type': incentiveType.apiValue,
      if (incentiveType == ProductIncentiveType.fixed)
        'incentive_amount': incentiveAmount.toString(),
      if (incentiveType == ProductIncentiveType.percentage)
        'incentive_percentage': incentivePercentage,
      'bonus_type': bonusType.apiValue,
      'min_quantity': minQuantity,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class ProductUpdateResponseModel {
  const ProductUpdateResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  final String status;
  final String statusCode;
  final String message;

  factory ProductUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductUpdateResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
