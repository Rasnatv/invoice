/// Represents a single company (brand/manufacturer) as returned by the
/// /companies API endpoints.
class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    required this.code,
    this.website,
  });

  final String id;
  final String name;
  final String code;

  /// Optional — the API accepts and returns an empty string for "no
  /// website", so this is normalized to null when empty for easier
  /// handling on the UI side (e.g. deciding whether to show a link).
  final String? website;

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final site = json['website']?.toString() ?? '';
    return CompanyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      website: site.isEmpty ? null : site,
    );
  }

  /// Body for POST /companies/create — `id` is intentionally excluded
  /// since the create endpoint doesn't take one.
  Map<String, dynamic> toCreateJson() => {
    'name': name,
    'code': code,
    'website': website ?? '',
  };

  /// Body for POST /companies/update.
  Map<String, dynamic> toUpdateJson() => {
    'id': id,
    'name': name,
    'code': code,
    'website': website ?? '',
  };

  /// Body for POST /companies/delete.
  Map<String, dynamic> toDeleteJson() => {'id': id};

  CompanyModel copyWith({
    String? id,
    String? name,
    String? code,
    String? website,
    bool clearWebsite = false,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      website: clearWebsite ? null : (website ?? this.website),
    );
  }

  @override
  String toString() {
    return 'CompanyModel(id: $id, name: $name, code: $code, website: $website)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanyModel &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.website == website;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ code.hashCode ^ website.hashCode;
}

/// Response wrapper for GET /companies.
///
/// Real shape:
/// ```
/// {
///   "status": "1",
///   "status_code": "200",
///   "data": { "list": [ {...}, {...} ] },
///   "message": "Companies fetched successfully"
/// }
/// ```
/// Note the list is nested under `data.list`, not `data` directly.
class CompanyGetResponseModel {
  const CompanyGetResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<CompanyModel> data;
  final String message;

  factory CompanyGetResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? const {};
    final list = dataMap['list'] as List<dynamic>? ?? const [];
    return CompanyGetResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      data: list
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Shared response wrapper for create/update/delete.
///
/// All three confirmed real responses return `"data": {}` — empty, no
/// id or company fields — so only `status` and `message` carry anything
/// useful. Callers must not expect a company object back from these.
class CompanyActionResponseModel {
  const CompanyActionResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  final String status;
  final String statusCode;
  final String message;

  factory CompanyActionResponseModel.fromJson(Map<String, dynamic> json) {
    return CompanyActionResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}