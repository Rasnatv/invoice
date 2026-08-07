/// GET /companies/active — used to populate the company dropdown.
class CompanyActiveModel {
  const CompanyActiveModel({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  /// What the dropdown should display, e.g. "Somany Ceramics new - SOM NEW".
  String get label => '$name - $code';

  factory CompanyActiveModel.fromJson(Map<String, dynamic> json) {
    return CompanyActiveModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }
}

class CompanyActiveListResponseModel {
  const CompanyActiveListResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });

  final String status;
  final List<CompanyActiveModel> data;
  final String message;

  factory CompanyActiveListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList =
        (json['data'] as Map<String, dynamic>?)?['list'] as List<dynamic>? ?? [];
    return CompanyActiveListResponseModel(
      status: json['status']?.toString() ?? '0',
      data: rawList
          .map((e) => CompanyActiveModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}
