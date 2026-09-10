
import '../../Apiprovider/product_enums.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.companyId,
    required this.company,
    required this.size,
    required this.unitId,
    required this.isBoxUnit,
    required this.piecesPerBox,
    required this.packing,
    required this.minQuantity,
    required this.measurementQty,
    required this.mrp,
    required this.rate,
    required this.incentiveType,
    required this.incentivePercentage,
    required this.incentiveAmount,
    required this.bonusType,
    required this.isActive,
  });

  final String id;
  final String name;
  final String companyId;
  final String company;
  final String size;
  final String unitId;

  /// From API's "is_box_unit": "0"/"1". Source of truth for whether
  /// packing/pieces-per-box apply to this product. Note: some legacy
  /// records report "0" here while still having pieces_per_box/packing
  /// populated (e.g. id 33 — is_box_unit "0" but packing "6pcs/Box"). Use
  /// [hasBoxPacking] as a fallback in the UI when this alone isn't enough.
  final bool isBoxUnit;

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

  /// Parsed incentive type ('percentage' / 'fixed' / absent -> none).
  /// This is the SOURCE OF TRUTH for which incentive field applies — don't
  /// infer it from incentivePercentage/incentiveAmount being non-zero,
  /// since both can be populated simultaneously by the API.
  final ProductIncentiveType incentiveType;

  final double incentivePercentage;
  final double incentiveAmount;

  /// Parsed bonus type ('bulk' / 'single' / absent-or-empty -> none).
  /// Many legacy records return "" for bonus_type, which correctly resolves
  /// to ProductBonusType.none (shown as "None" in the edit screen).
  final ProductBonusType bonusType;

  final bool isActive;

  /// True when this product carries box-packing info. Kept as a display/
  /// fallback helper; prefer [isBoxUnit] first, falling back to this when
  /// isBoxUnit is false but packing data is actually present.
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
      isBoxUnit: json['is_box_unit']?.toString() == '1',
      piecesPerBox: json['pieces_per_box']?.toString() ?? '',
      packing: json['packing']?.toString() ?? '',
      minQuantity: double.tryParse(json['min_quantity']?.toString() ?? '') ?? 0,
      measurementQty: json['measurement_qty']?.toString() ?? '',
      mrp: double.tryParse(json['mrp']?.toString() ?? '') ?? 0,
      rate: double.tryParse(json['rate']?.toString() ?? '') ?? 0,
      incentiveType: _incentiveTypeFromApi(json['incentive_type']?.toString()),
      incentivePercentage:
      double.tryParse(json['incentive_percentage']?.toString() ?? '') ?? 0,
      incentiveAmount:
      double.tryParse(json['incentive_amount']?.toString() ?? '') ?? 0,
      bonusType: _bonusTypeFromApi(json['bonus_type']?.toString()),
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
      'is_box_unit': isBoxUnit ? '1' : '0',
      'pieces_per_box': piecesPerBox,
      'packing': packing,
      'min_quantity': minQuantity,
      'measurement_qty': measurementQty,
      'mrp': mrp,
      'rate': rate,
      if (incentiveType.apiValue != null)
        'incentive_type': incentiveType.apiValue,
      'incentive_percentage': incentivePercentage,
      'incentive_amount': incentiveAmount,
      if (bonusType.apiValue != null) 'bonus_type': bonusType.apiValue,
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
    bool? isBoxUnit,
    String? piecesPerBox,
    String? packing,
    double? minQuantity,
    String? measurementQty,
    double? mrp,
    double? rate,
    ProductIncentiveType? incentiveType,
    double? incentivePercentage,
    double? incentiveAmount,
    ProductBonusType? bonusType,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      company: company ?? this.company,
      size: size ?? this.size,
      unitId: unitId ?? this.unitId,
      isBoxUnit: isBoxUnit ?? this.isBoxUnit,
      piecesPerBox: piecesPerBox ?? this.piecesPerBox,
      packing: packing ?? this.packing,
      minQuantity: minQuantity ?? this.minQuantity,
      measurementQty: measurementQty ?? this.measurementQty,
      mrp: mrp ?? this.mrp,
      rate: rate ?? this.rate,
      incentiveType: incentiveType ?? this.incentiveType,
      incentivePercentage: incentivePercentage ?? this.incentivePercentage,
      incentiveAmount: incentiveAmount ?? this.incentiveAmount,
      bonusType: bonusType ?? this.bonusType,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Parses the raw API string ('fixed' / 'percentage' / anything else,
/// incl. null/empty) into [ProductIncentiveType]. Defaults to `none`.
/// Private to this file since product_enums.dart doesn't expose a parser.
ProductIncentiveType _incentiveTypeFromApi(String? value) {
  switch (value) {
    case 'fixed':
      return ProductIncentiveType.fixed;
    case 'percentage':
      return ProductIncentiveType.percentage;
    default:
      return ProductIncentiveType.none;
  }
}

/// Parses the raw API string ('bulk' / 'single' / anything else, incl.
/// null/empty) into [ProductBonusType]. Defaults to `none`.
ProductBonusType _bonusTypeFromApi(String? value) {
  switch (value) {
    case 'bulk':
      return ProductBonusType.bulk;
    case 'single':
      return ProductBonusType.single;
    default:
      return ProductBonusType.none;
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