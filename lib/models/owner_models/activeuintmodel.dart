/// GET /units/active — used to populate the unit dropdown.
class UnitActiveModel {
  const UnitActiveModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  final String id;
  final String name;
  final String abbreviation;

  /// What the dropdown should display, e.g. "Sqare Feets - SqoFt".
  String get label => '$name - $abbreviation';

  factory UnitActiveModel.fromJson(Map<String, dynamic> json) {
    return UnitActiveModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      abbreviation: json['abbreviation']?.toString() ?? '',
    );
  }
}

class UnitActiveListResponseModel {
  const UnitActiveListResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });

  final String status;
  final List<UnitActiveModel> data;
  final String message;

  factory UnitActiveListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList =
        (json['data'] as Map<String, dynamic>?)?['list'] as List<dynamic>? ?? [];
    return UnitActiveListResponseModel(
      status: json['status']?.toString() ?? '0',
      data: rawList
          .map((e) => UnitActiveModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}
