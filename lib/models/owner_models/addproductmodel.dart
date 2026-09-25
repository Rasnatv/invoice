

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
    this.incentiveType = ProductIncentiveType.none,
    this.incentiveAmount,
    this.incentivePercentage,
    required this.bonusType,
    this.minQuantity = 0,
    this.piecesPerBox,
    this.packing,
    this.isBoxUnit = false,
  });

  final String name;
  final String companyId;
  final String size;
  final String unitId;
  final double mrp;
  final double rate;

  /// Defaults to [ProductIncentiveType.none] — when none, incentive_type,
  /// incentive_amount, and incentive_percentage are all omitted from the
  /// request entirely.
  final ProductIncentiveType incentiveType;

  /// Only sent (and required) when [incentiveType] is fixed.
  final double? incentiveAmount;

  /// Only sent (and required) when [incentiveType] is percentage.
  final double? incentivePercentage;

  final ProductBonusType bonusType;

  /// Only meaningful when [bonusType] is bulk. Omitted otherwise.
  final num minQuantity;

  /// Only sent when the selected unit is a "box"-type unit.
  /// e.g. "8" (number of pieces packed per box).
  final String? piecesPerBox;

  /// Sent for EVERY unit now (square feet, box, kg, etc.) as long as a
  /// value was typed — not gated to box-type units. e.g. "8pcs/box",
  /// "30kg/bag".
  final String? packing;

  /// Set this to true when the unit picked in [unitId] is a "Box" unit.
  /// Controls whether [piecesPerBox] is sent to the API at all — for
  /// non-box units it's omitted entirely, not sent empty. Does NOT gate
  /// [packing] anymore, since packing applies to every unit.
  final bool isBoxUnit;

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'company_id': companyId,
//       'size': size,
//       'unit_id': unitId,
//       'mrp': mrp.toString(),
//       'rate': rate.toString(),
//       // Omitted entirely (not sent as null) when incentiveType is none.
//       if (incentiveType != ProductIncentiveType.none)
//         'incentive_type': incentiveType.apiValue,
//       if (incentiveType == ProductIncentiveType.fixed && incentiveAmount != null)
//         'incentive_amount': incentiveAmount!.toString(),
//       if (incentiveType == ProductIncentiveType.percentage && incentivePercentage != null)
//         'incentive_percentage': incentivePercentage,
//       // Omitted entirely (not sent as null) when bonusType is none.
//       if (bonusType != ProductBonusType.none)
//         'bonus_type': bonusType.apiValue,
//       // Only sent when bonusType is bulk.
//       if (bonusType == ProductBonusType.bulk)
//         'min_quantity': minQuantity,
//       // pieces_per_box only applies to box/sq-ft type units.
//       if (isBoxUnit && piecesPerBox != null && piecesPerBox!.isNotEmpty)
//         'pieces_per_box': piecesPerBox,
//       // FIXED: packing is now entered for every unit, not just box units —
//       // this was previously gated behind isBoxUnit, which silently dropped
//       // the typed value from the create request for every non-box unit
//       // (e.g. Kilogram). Send it whenever it's actually present, matching
//       // the already-correct behavior in ProductUpdateRequestModel.
//       if (packing != null && packing!.isNotEmpty)
//         'packing': packing,
//     };
//   }
// }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company_id': companyId,
      'size': size,
      'unit_id': unitId,
      'mrp': mrp.toString(),
      'rate': rate.toString(),
      // FIX: always send incentive_type, as '' for none — previously this
      // key was omitted entirely when incentiveType was none, which didn't
      // match the API's expected create-request shape (see sample payload:
      // "incentive_type": ""). Matches ProductUpdateRequestModel now.
      'incentive_type': incentiveType.apiValue ?? '',
      if (incentiveType == ProductIncentiveType.fixed &&
          incentiveAmount != null)
        'incentive_amount': incentiveAmount!.toString(),
      if (incentiveType == ProductIncentiveType.percentage &&
          incentivePercentage != null)
        'incentive_percentage': incentivePercentage,
      // FIX: same issue as incentive_type above — always send bonus_type,
      // as '' for none, instead of omitting the key entirely.
      'bonus_type': bonusType.apiValue ?? '',
      // Only sent when bonusType is bulk.
      if (bonusType == ProductBonusType.bulk)
        'min_quantity': minQuantity,
      // pieces_per_box only applies to box/sq-ft type units.
      if (isBoxUnit && piecesPerBox != null && piecesPerBox!.isNotEmpty)
        'pieces_per_box': piecesPerBox,
      // packing is entered for every unit, not just box units — send it
      // whenever it's actually present.
      if (packing != null && packing!.isNotEmpty)
        'packing': packing,
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