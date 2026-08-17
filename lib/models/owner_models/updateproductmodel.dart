
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
    this.piecesPerBox,
    this.packing,
    this.isBoxUnit = false,
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

  /// Only meaningful when [bonusType] is bulk. Sent as null otherwise.
  final String minQuantity;

  final bool isActive;

  /// Only sent when the selected unit is a "box"-type unit.
  /// e.g. "8" (number of pieces packed per box).
  final String? piecesPerBox;

  /// Only sent when the selected unit is a "box"-type unit.
  /// e.g. "8pcs/box".
  final String? packing;

  /// Set this to true when the unit picked in [unitId] is a "Box" unit.
  /// Controls whether [piecesPerBox] / [packing] are sent to the API at all —
  /// for non-box units these fields are omitted entirely, not sent empty.
  final bool isBoxUnit;

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
      // null when bonusType is ProductBonusType.none.
      'bonus_type': bonusType.apiValue,
      // null unless bonusType is bulk.
      'min_quantity': bonusType == ProductBonusType.bulk ? minQuantity : null,
      'is_active': isActive ? 1 : 0,
      if (isBoxUnit && piecesPerBox != null && piecesPerBox!.isNotEmpty)
        'pieces_per_box': piecesPerBox,
      if (isBoxUnit && packing != null && packing!.isNotEmpty)
        'packing': packing,
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