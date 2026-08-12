//
// class ProductModel {
//   const ProductModel({
//     required this.id,
//     required this.name,
//     required this.companyId,
//     required this.company,
//     required this.size,
//     required this.unitId,
//     required this.piecesPerBox,
//     required this.packing,
//     required this.mrp,
//     required this.rate,
//     required this.incentivePercentage,
//     required this.incentiveAmount,
//     required this.isActive,
//   });
//
//   final String id;
//   final String name;
//   final String companyId;
//   final String company;
//   final String size;
//   final String unitId;
//
//   /// Empty string when the product's unit isn't a "box"-type unit.
//   final String piecesPerBox;
//
//   /// Empty string when the product's unit isn't a "box"-type unit.
//   final String packing;
//
//   final double mrp;
//   final double rate;
//   final double incentivePercentage;
//   final double incentiveAmount;
//   final bool isActive;
//
//   /// True when this product carries box-packing info, useful for
//   /// conditionally showing the packing/pieces-per-box fields in the UI.
//   bool get hasBoxPacking => piecesPerBox.isNotEmpty || packing.isNotEmpty;
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       companyId: json['company_id']?.toString() ?? '',
//       company: json['company']?.toString() ?? '',
//       size: json['size']?.toString() ?? '',
//       unitId: json['unit_id']?.toString() ?? '',
//       piecesPerBox: json['pieces_per_box']?.toString() ?? '',
//       packing: json['packing']?.toString() ?? '',
//       mrp: double.tryParse(json['mrp']?.toString() ?? '') ?? 0,
//       rate: double.tryParse(json['rate']?.toString() ?? '') ?? 0,
//       incentivePercentage:
//       double.tryParse(json['incentive_percentage']?.toString() ?? '') ?? 0,
//       incentiveAmount:
//       double.tryParse(json['incentive_amount']?.toString() ?? '') ?? 0,
//       isActive: json['is_active']?.toString() == '1',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'company_id': companyId,
//       'company': company,
//       'size': size,
//       'unit_id': unitId,
//       'pieces_per_box': piecesPerBox,
//       'packing': packing,
//       'mrp': mrp,
//       'rate': rate,
//       'incentive_percentage': incentivePercentage,
//       'incentive_amount': incentiveAmount,
//       'is_active': isActive ? '1' : '0',
//     };
//   }
//
//   ProductModel copyWith({
//     String? id,
//     String? name,
//     String? companyId,
//     String? company,
//     String? size,
//     String? unitId,
//     String? piecesPerBox,
//     String? packing,
//     double? mrp,
//     double? rate,
//     double? incentivePercentage,
//     double? incentiveAmount,
//     bool? isActive,
//   }) {
//     return ProductModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       companyId: companyId ?? this.companyId,
//       company: company ?? this.company,
//       size: size ?? this.size,
//       unitId: unitId ?? this.unitId,
//       piecesPerBox: piecesPerBox ?? this.piecesPerBox,
//       packing: packing ?? this.packing,
//       mrp: mrp ?? this.mrp,
//       rate: rate ?? this.rate,
//       incentivePercentage: incentivePercentage ?? this.incentivePercentage,
//       incentiveAmount: incentiveAmount ?? this.incentiveAmount,
//       isActive: isActive ?? this.isActive,
//     );
//   }
// }
//
// /// Top-level response for GET /products.
// /// Shape: { "status": "1", "status_code": "200", "data": { "list": [...] }, "message": "..." }
// class ProductGetResponseModel {
//   const ProductGetResponseModel({
//     required this.status,
//     required this.statusCode,
//     required this.data,
//     required this.message,
//   });
//
//   final String status;
//   final String statusCode;
//   final List<ProductModel> data;
//   final String message;
//
//   factory ProductGetResponseModel.fromJson(Map<String, dynamic> json) {
//     final rawData = json['data'];
//     final listJson = (rawData is Map<String, dynamic>)
//         ? (rawData['list'] as List<dynamic>? ?? const [])
//         : const <dynamic>[];
//
//     return ProductGetResponseModel(
//       status: json['status']?.toString() ?? '',
//       statusCode: json['status_code']?.toString() ?? '',
//       data: listJson
//           .whereType<Map<String, dynamic>>()
//           .map((e) => ProductModel.fromJson(e))
//           .toList(),
//       message: json['message']?.toString() ?? '',
//     );
//   }
// }
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.companyId,
    required this.company,
    required this.size,
    required this.unitId,
    required this.piecesPerBox,
    required this.packing,
    required this.minQuantity,
    required this.measurementQty,
    required this.mrp,
    required this.rate,
    required this.incentivePercentage,
    required this.incentiveAmount,
    required this.isActive,
  });

  final String id;
  final String name;
  final String companyId;
  final String company;
  final String size;
  final String unitId;

  /// Empty string when the product's unit isn't a "box"-type unit.
  final String piecesPerBox;

  /// Empty string when the product's unit isn't a "box"-type unit.
  final String packing;

  /// Minimum orderable quantity, as returned by the list API.
  final double minQuantity;

  /// Free-text measurement label (e.g. "As per Measurement"). Empty string
  /// when not applicable to this product's unit.
  final String measurementQty;

  final double mrp;
  final double rate;
  final double incentivePercentage;
  final double incentiveAmount;
  final bool isActive;

  /// True when this product carries box-packing info, useful for
  /// conditionally showing the packing/pieces-per-box fields in the UI.
  bool get hasBoxPacking => piecesPerBox.isNotEmpty || packing.isNotEmpty;

  /// True when this product is measured (e.g. "As per Measurement") rather
  /// than sold in fixed packs/boxes.
  bool get hasMeasurementQty => measurementQty.isNotEmpty;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      piecesPerBox: json['pieces_per_box']?.toString() ?? '',
      packing: json['packing']?.toString() ?? '',
      minQuantity: double.tryParse(json['min_quantity']?.toString() ?? '') ?? 0,
      measurementQty: json['measurement_qty']?.toString() ?? '',
      mrp: double.tryParse(json['mrp']?.toString() ?? '') ?? 0,
      rate: double.tryParse(json['rate']?.toString() ?? '') ?? 0,
      incentivePercentage:
      double.tryParse(json['incentive_percentage']?.toString() ?? '') ?? 0,
      incentiveAmount:
      double.tryParse(json['incentive_amount']?.toString() ?? '') ?? 0,
      isActive: json['is_active']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_id': companyId,
      'company': company,
      'size': size,
      'unit_id': unitId,
      'pieces_per_box': piecesPerBox,
      'packing': packing,
      'min_quantity': minQuantity,
      'measurement_qty': measurementQty,
      'mrp': mrp,
      'rate': rate,
      'incentive_percentage': incentivePercentage,
      'incentive_amount': incentiveAmount,
      'is_active': isActive ? '1' : '0',
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? companyId,
    String? company,
    String? size,
    String? unitId,
    String? piecesPerBox,
    String? packing,
    double? minQuantity,
    String? measurementQty,
    double? mrp,
    double? rate,
    double? incentivePercentage,
    double? incentiveAmount,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      company: company ?? this.company,
      size: size ?? this.size,
      unitId: unitId ?? this.unitId,
      piecesPerBox: piecesPerBox ?? this.piecesPerBox,
      packing: packing ?? this.packing,
      minQuantity: minQuantity ?? this.minQuantity,
      measurementQty: measurementQty ?? this.measurementQty,
      mrp: mrp ?? this.mrp,
      rate: rate ?? this.rate,
      incentivePercentage: incentivePercentage ?? this.incentivePercentage,
      incentiveAmount: incentiveAmount ?? this.incentiveAmount,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Top-level response for GET /products.
/// Shape: { "status": "1", "status_code": "200", "data": { "list": [...] }, "message": "..." }
class ProductGetResponseModel {
  const ProductGetResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<ProductModel> data;
  final String message;

  factory ProductGetResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final listJson = (rawData is Map<String, dynamic>)
        ? (rawData['list'] as List<dynamic>? ?? const [])
        : const <dynamic>[];

    return ProductGetResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: listJson
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductModel.fromJson(e))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}