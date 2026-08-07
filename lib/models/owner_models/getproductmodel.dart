// class ProductModel {
//   const ProductModel({
//     required this.id,
//     required this.name,
//     required this.companyId,
//     required this.company,
//     required this.size,
//     required this.unitId,
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
//   final double mrp;
//   final double rate;
//   final double incentivePercentage;
//   final double incentiveAmount;
//   final bool isActive;
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       companyId: json['company_id']?.toString() ?? '',
//       company: json['company']?.toString() ?? '',
//       size: json['size']?.toString() ?? '',
//       unitId: json['unit_id']?.toString() ?? '',
//       mrp: double.tryParse(json['mrp']?.toString() ?? '') ?? 0,
//       rate: double.tryParse(json['rate']?.toString() ?? '') ?? 0,
//       incentivePercentage:
//       double.tryParse(json['incentive_percentage']?.toString() ?? '') ?? 0,
//       incentiveAmount:
//       double.tryParse(json['incentive_amount']?.toString() ?? '') ?? 0,
//       isActive: json['is_active']?.toString() == '1',
//     );
//   }
// }
//
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
//     final listJson =
//         (json['data'] as Map<String, dynamic>?)?['list'] as List<dynamic>? ?? [];
//     return ProductGetResponseModel(
//       status: json['status']?.toString() ?? '',
//       statusCode: json['status_code']?.toString() ?? '',
//       data: listJson
//           .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
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
  final double mrp;
  final double rate;
  final double incentivePercentage;
  final double incentiveAmount;
  final bool isActive;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
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