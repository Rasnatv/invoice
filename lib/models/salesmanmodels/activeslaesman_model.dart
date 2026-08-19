// NOTE: if your codebase already has an ActiveSalesmanModel (e.g. used by
// the "Assign to Salesman" dropdown on the Owner Create Estimate screen),
// reuse that one and delete this file to avoid a duplicate type.

class ActiveSalesmanModel {
  final String id;
  final String name;
  final String designationDisplay;

  const ActiveSalesmanModel({
    required this.id,
    required this.name,
    required this.designationDisplay,
  });

  factory ActiveSalesmanModel.fromJson(Map<String, dynamic> json) => ActiveSalesmanModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    designationDisplay: json['designation_display']?.toString() ?? '',
  );

  String get displayLabel => designationDisplay.isNotEmpty ? '$name • $designationDisplay' : name;
}

class ActiveSalesmanResponseModel {
  final String status;
  final String statusCode;
  final List<ActiveSalesmanModel> data;
  final String message;

  const ActiveSalesmanResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory ActiveSalesmanResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? const {};
    final list = (dataMap['list'] as List<dynamic>? ?? const [])
        .map((e) => ActiveSalesmanModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ActiveSalesmanResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: list,
      message: json['message']?.toString() ?? '',
    );
  }
}