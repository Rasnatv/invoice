// //
// // import '../../Apiprovider/product_enums.dart';
// //
// // /// Request body for POST /products/update. Same shape as add, plus
// // /// id and is_active.
// // class ProductUpdateRequestModel {
// //   const ProductUpdateRequestModel({
// //     required this.id,
// //     required this.name,
// //     required this.companyId,
// //     required this.size,
// //     required this.unitId,
// //     required this.mrp,
// //     required this.rate,
// //     required this.incentiveType,
// //     this.incentiveAmount,
// //     this.incentivePercentage,
// //     required this.bonusType,
// //     required this.minQuantity,
// //     this.isActive = true,
// //     this.piecesPerBox,
// //     this.packing,
// //     this.isBoxUnit = false,
// //   });
// //
// //   final String id;
// //   final String name;
// //   final String companyId;
// //   final String size;
// //   final String unitId;
// //   final double mrp;
// //   final double rate;
// //   final ProductIncentiveType incentiveType;
// //   final double? incentiveAmount;
// //   final double? incentivePercentage;
// //   final ProductBonusType bonusType;
// //
// //   /// Minimum orderable quantity. Only meaningful when [bonusType] is bulk,
// //   /// but ALWAYS sent to the API (as '0' when not bulk) — the backend
// //   /// expects the key present with a value of 0, not omitted/null.
// //   final String minQuantity;
// //
// //   final bool isActive;
// //
// //   /// Only sent when the selected unit is a "box"-type unit.
// //   /// e.g. "8" (number of pieces packed per box).
// //   final String? piecesPerBox;
// //
// //   /// Sent for EVERY unit now (square feet, box, kg, etc.) as long as a
// //   /// value was typed — not gated to box-type units. e.g. "8pcs/box",
// //   /// "30kg/bag".
// //   final String? packing;
// //
// //   /// Set this to true when the unit picked in [unitId] is a "Box" unit.
// //   /// Controls whether [piecesPerBox] is sent to the API at all — for
// //   /// non-box units it's omitted entirely, not sent empty. Does NOT gate
// //   /// [packing] anymore, since packing applies to every unit.
// //   final bool isBoxUnit;
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'id': id,
// //       'name': name,
// //       'company_id': companyId,
// //       'size': size,
// //       'unit_id': unitId,
// //       // pieces_per_box only applies to box/sq-ft type units.
// //       if (isBoxUnit && piecesPerBox != null && piecesPerBox!.isNotEmpty)
// //         'pieces_per_box': piecesPerBox,
// //       // UPDATED: packing is now entered for every unit, not just box
// //       // units — previously this was also gated behind isBoxUnit, which
// //       // silently dropped the typed value from the request for every
// //       // non-box unit. Send it whenever it's actually present.
// //       if (packing != null && packing!.isNotEmpty) 'packing': packing,
// //       'mrp': mrp,
// //       'rate': rate,
// //       'incentive_type': incentiveType.apiValue,
// //       // Only the field matching the active incentive_type is sent.
// //       if (incentiveType == ProductIncentiveType.fixed)
// //         'incentive_amount': incentiveAmount.toString(),
// //       if (incentiveType == ProductIncentiveType.percentage)
// //         'incentive_percentage': incentivePercentage,
// //       'bonus_type': bonusType.apiValue,
// //       // FIX: always send min_quantity (0 when not bulk) instead of null —
// //       // matches the API's expected body shape exactly.
// //       'min_quantity': bonusType == ProductBonusType.bulk
// //           ? (int.tryParse(minQuantity) ?? 0)
// //           : 0,
// //       'is_active': isActive ? 1 : 0,
// //     };
// //   }
// // }
// //
// // class ProductUpdateResponseModel {
// //   const ProductUpdateResponseModel({
// //     required this.status,
// //     required this.statusCode,
// //     required this.message,
// //   });
// //
// //   final String status;
// //   final String statusCode;
// //   final String message;
// //
// //   factory ProductUpdateResponseModel.fromJson(Map<String, dynamic> json) {
// //     return ProductUpdateResponseModel(
// //       status: json['status']?.toString() ?? '0',
// //       statusCode: json['status_code']?.toString() ?? '',
// //       message: json['message']?.toString() ?? '',
// //     );
// //   }
// // }
// import '../../Apiprovider/product_enums.dart';
//
// /// Request body for POST /products/update. Same shape as add, plus
// /// id and is_active.
// class ProductUpdateRequestModel {
//   const ProductUpdateRequestModel({
//     required this.id,
//     required this.name,
//     required this.companyId,
//     required this.size,
//     required this.unitId,
//     required this.mrp,
//     required this.rate,
//     required this.incentiveType,
//     this.incentiveAmount,
//     this.incentivePercentage,
//     required this.bonusType,
//     required this.minQuantity,
//     this.isActive = true,
//     this.piecesPerBox,
//     this.packing,
//     this.isBoxUnit = false,
//   });
//
//   final String id;
//   final String name;
//   final String companyId;
//   final String size;
//   final String unitId;
//   final double mrp;
//   final double rate;
//   final ProductIncentiveType incentiveType;
//   final double? incentiveAmount;
//   final double? incentivePercentage;
//   final ProductBonusType bonusType;
//
//   /// Minimum orderable quantity. Only meaningful when [bonusType] is bulk,
//   /// but ALWAYS sent to the API (as '0' when not bulk) — the backend
//   /// expects the key present with a value of 0, not omitted/null.
//   final String minQuantity;
//
//   final bool isActive;
//
//   /// Only sent when the selected unit is a "box"-type unit.
//   /// e.g. "8" (number of pieces packed per box).
//   final String? piecesPerBox;
//
//   /// Sent for EVERY unit now (square feet, box, kg, etc.) as long as a
//   /// value was typed — not gated to box-type units. e.g. "8pcs/box",
//   /// "30kg/bag".
//   final String? packing;
//
//   /// Set this to true when the unit picked in [unitId] is a "Box" unit.
//   /// Controls whether [piecesPerBox] is sent to the API at all — for
//   /// non-box units it's omitted entirely, not sent empty. Does NOT gate
//   /// [packing] anymore, since packing applies to every unit.
//   final bool isBoxUnit;
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'company_id': companyId,
//       'size': size,
//       'unit_id': unitId,
//       // pieces_per_box only applies to box/sq-ft type units.
//       if (isBoxUnit && piecesPerBox != null && piecesPerBox!.isNotEmpty)
//         'pieces_per_box': piecesPerBox,
//       // Packing is now entered for every unit, not just box units — send
//       // it whenever it's actually present.
//       if (packing != null && packing!.isNotEmpty) 'packing': packing,
//       'mrp': mrp,
//       'rate': rate,
//       // FIX: incentiveType.apiValue is null for ProductIncentiveType.none.
//       // Previously that sent a literal `null` in the JSON body for
//       // "incentive_type" instead of an empty string, so selecting "None"
//       // didn't round-trip the same way the GET API represents "no
//       // incentive type" (""). Default to '' to match.
//       'incentive_type': incentiveType.apiValue ?? '',
//       // Only the field matching the active incentive_type is sent.
//       if (incentiveType == ProductIncentiveType.fixed)
//         'incentive_amount': incentiveAmount.toString(),
//       if (incentiveType == ProductIncentiveType.percentage)
//         'incentive_percentage': incentivePercentage,
//       // FIX: same null-vs-empty-string issue as incentive_type above —
//       // bonusType.apiValue is null for ProductBonusType.none.
//       'bonus_type': bonusType.apiValue ?? '',
//       // Always send min_quantity (0 when not bulk) instead of null —
//       // matches the API's expected body shape exactly.
//       'min_quantity': bonusType == ProductBonusType.bulk
//           ? (int.tryParse(minQuantity) ?? 0)
//           : 0,
//       'is_active': isActive ? 1 : 0,
//     };
//   }
// }
//
// class ProductUpdateResponseModel {
//   const ProductUpdateResponseModel({
//     required this.status,
//     required this.statusCode,
//     required this.message,
//   });
//
//   final String status;
//   final String statusCode;
//   final String message;
//
//   factory ProductUpdateResponseModel.fromJson(Map<String, dynamic> json) {
//     return ProductUpdateResponseModel(
//       status: json['status']?.toString() ?? '0',
//       statusCode: json['status_code']?.toString() ?? '',
//       message: json['message']?.toString() ?? '',
//     );
//   }
// }
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

  /// Minimum orderable quantity. Only meaningful when [bonusType] is bulk,
  /// but ALWAYS sent to the API (as '0' when not bulk) — the backend
  /// expects the key present with a value of 0, not omitted/null.
  final String minQuantity;

  final bool isActive;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_id': companyId,
      'size': size,
      'unit_id': unitId,
      // pieces_per_box only applies to box/sq-ft type units.
      if (isBoxUnit && piecesPerBox != null && piecesPerBox!.isNotEmpty)
        'pieces_per_box': piecesPerBox,
      // Packing is entered for every unit, not just box units — send it
      // whenever it's actually present.
      if (packing != null && packing!.isNotEmpty) 'packing': packing,
      // Sent as strings to match the confirmed-working Postman payload
      // exactly (mrp/rate came through as "560"/"450", not 560/450).
      'mrp': mrp.toString(),
      'rate': rate.toString(),
      // incentive_type is ALWAYS sent — '' for none, never omitted.
      'incentive_type': incentiveType.apiValue ?? '',
      // FIX (the actual bug): incentive_amount and incentive_percentage
      // must ALWAYS be sent too, as '' when they're not the active type —
      // never omitted. Omitting them left the backend's old stored value
      // untouched, which is exactly what caused old percentage/fixed
      // values to keep reappearing after switching a product to "None".
      // Confirmed by the working Postman payload, which explicitly sends
      // both as "" and the backend correctly resets them to 0.00.
      'incentive_amount': incentiveType == ProductIncentiveType.fixed
          ? (incentiveAmount ?? 0).toString()
          : '',
      'incentive_percentage': incentiveType == ProductIncentiveType.percentage
          ? (incentivePercentage ?? 0).toString()
          : '',
      // bonus_type is ALWAYS sent — '' for none, never omitted.
      'bonus_type': bonusType.apiValue ?? '',
      // Always send min_quantity (0 when not bulk) instead of null —
      // matches the API's expected body shape exactly.
      'min_quantity': bonusType == ProductBonusType.bulk
          ? (int.tryParse(minQuantity) ?? 0)
          : 0,
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