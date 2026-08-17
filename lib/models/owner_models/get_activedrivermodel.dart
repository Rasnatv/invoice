/// One entry from GET /salesmen/active — used to populate the
/// "Assign to Salesman" dropdown on the Owner Create Estimate screen's
/// Preview step.
class SalesmanActiveModel {
  final String id;
  final String name;
  final String designationDisplay;

  const SalesmanActiveModel({
    required this.id,
    required this.name,
    required this.designationDisplay,
  });

  factory SalesmanActiveModel.fromJson(Map<String, dynamic> json) {
    return SalesmanActiveModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      designationDisplay: json['designation_display']?.toString() ?? '',
    );
  }

  /// "appus — kannur Senior Sales Executives (SSE)", or just "appus" when
  /// there's no designation on record.
  String get displayLabel =>
      designationDisplay.trim().isEmpty ? name : '$name — $designationDisplay';

  @override
  bool operator ==(Object other) => other is SalesmanActiveModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class SalesmanActiveResponseModel {
  final String status;
  final String statusCode;
  final List<SalesmanActiveModel> list;
  final String message;

  const SalesmanActiveResponseModel({
    required this.status,
    required this.statusCode,
    required this.list,
    required this.message,
  });

  factory SalesmanActiveResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawList = (data is Map<String, dynamic>) ? data['list'] : null;
    return SalesmanActiveResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      list: rawList is List
          ? rawList
          .whereType<Map<String, dynamic>>()
          .map(SalesmanActiveModel.fromJson)
          .toList()
          : const [],
      message: json['message']?.toString() ?? '',
    );
  }
}