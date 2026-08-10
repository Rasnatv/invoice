class ActiveProductModel {
  final String id;
  final String name;
  final String company;
  final String size;
  final String unit;

  /// MRP as returned by /products/active — display-only reference price,
  /// not sent back to the server. Some products may have "0.00" if no MRP
  /// is set for them.
  final double mrp;

  /// Default/base rate as returned by /products/active — used to
  /// auto-fill the Rate field when a product is selected, but the field
  /// stays editable so the salesman can override it manually.
  final double rate;

  const ActiveProductModel({
    required this.id,
    required this.name,
    required this.company,
    required this.size,
    required this.unit,
    required this.mrp,
    required this.rate,
  });

  factory ActiveProductModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
    return ActiveProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      mrp: toDouble(json['mrp']),
      rate: toDouble(json['rate']),
    );
  }
}

class ActiveProductResponseModel {
  final String status;
  final String statusCode;
  final List<ActiveProductModel> list;
  final String message;

  const ActiveProductResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory ActiveProductResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = (data is Map<String, dynamic>) ? data['list'] : null;
    return ActiveProductResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      list: rawList is List
          ? rawList
          .whereType<Map<String, dynamic>>()
          .map(ActiveProductModel.fromJson)
          .toList()
          : const [],
      message: json['message']?.toString() ?? '',
    );
  }
}