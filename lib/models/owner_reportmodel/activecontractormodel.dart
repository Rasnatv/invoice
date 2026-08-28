/// Mirrors the pattern of your existing ActiveSalesmanModel.
/// If a similar contractor model already exists elsewhere in the
/// codebase, reuse that one and delete this file to avoid a duplicate type.
class ActiveContractorModel {
  final String id;
  final String name;
  final String mobile;

  const ActiveContractorModel({
    required this.id,
    required this.name,
    required this.mobile,
  });

  factory ActiveContractorModel.fromJson(Map<String, dynamic> json) => ActiveContractorModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    mobile: json['mobile']?.toString() ?? '',
  );

  /// Some contractors in the sample payload have an empty `name` — fall
  /// back to the mobile number so the dropdown never shows a blank row.
  String get displayLabel => name.trim().isNotEmpty ? name : mobile;
}

class ActiveContractorResponseModel {
  final String status;
  final String statusCode;
  final List<ActiveContractorModel> data;
  final String message;

  const ActiveContractorResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory ActiveContractorResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? const {};
    final list = (dataMap['list'] as List<dynamic>? ?? const [])
        .map((e) => ActiveContractorModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ActiveContractorResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: list,
      message: json['message']?.toString() ?? '',
    );
  }
}