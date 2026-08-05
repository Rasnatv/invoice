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

  /// Body for create requests — `id` is intentionally excluded since the
  /// create endpoint doesn't take one (it's returned in the response).
  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'website': website ?? '',
  };

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
}