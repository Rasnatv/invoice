/// Represents a single unit (e.g. Box, Piece, Square Feet) as returned by
/// the /units API endpoints.
class UnitModel {
  const UnitModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  final String id;
  final String name;
  final String abbreviation;

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      abbreviation: json['abbreviation']?.toString() ?? '',
    );
  }

  UnitModel copyWith({String? id, String? name, String? abbreviation}) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
    );
  }
}

/// GET /units — the list lives at data.list
class UnitGetResponseModel {
  const UnitGetResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final List<UnitModel> data;

  factory UnitGetResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? const {};
    final list = dataMap['list'] as List<dynamic>? ?? const [];
    return UnitGetResponseModel(
      status: json['status']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
      data: list.map((e) => UnitModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// POST /units — request body for creating a unit.
class UnitAddRequestModel {
  const UnitAddRequestModel({required this.name, required this.abbreviation});

  final String name;
  final String abbreviation;

  Map<String, dynamic> toJson() => {'name': name, 'abbreviation': abbreviation};
}

/// POST /units — response `data` is always empty; only status/message matter.
class UnitAddResponseModel {
  const UnitAddResponseModel({required this.status, required this.message});

  final String status;
  final String message;

  factory UnitAddResponseModel.fromJson(Map<String, dynamic> json) {
    return UnitAddResponseModel(
      status: json['status']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
    );
  }
}

/// POST /units/update — `id` is sent as an int, matching the real API.
class UnitUpdateRequestModel {
  const UnitUpdateRequestModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  final String id;
  final String name;
  final String abbreviation;

  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? id,
    'name': name,
    'abbreviation': abbreviation,
  };
}

/// POST /units/delete — `id` is sent as an int, matching the real API.
class UnitDeleteRequestModel {
  const UnitDeleteRequestModel(this.id);

  final String id;

  Map<String, dynamic> toJson() => {'id': int.tryParse(id) ?? id};
}