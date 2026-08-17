
class UnitActiveModel {
  const UnitActiveModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.showPiecesPerBox,
  });

  final String id;
  final String name;
  final String abbreviation;

  /// Straight from the API's "show_pieces_per_box" flag ("1"/"0").
  /// true  -> this unit needs the Packing / Pieces-per-Box fields on the
  ///          product form (e.g. Square Feet today, maybe others later).
  /// false -> hide those fields for this unit.
  final bool showPiecesPerBox;

  String get label => abbreviation.isNotEmpty ? '$name ($abbreviation)' : name;

  factory UnitActiveModel.fromJson(Map<String, dynamic> json) {
    return UnitActiveModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      abbreviation: json['abbreviation']?.toString() ?? '',
      showPiecesPerBox: json['show_pieces_per_box']?.toString() == '1',
    );
  }
}

/// Top-level response for GET /units/active.
class UnitActiveListResponseModel {
  const UnitActiveListResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<UnitActiveModel> data;
  final String message;

  factory UnitActiveListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final listJson = (rawData is Map<String, dynamic>)
        ? (rawData['list'] as List<dynamic>? ?? const [])
        : const <dynamic>[];

    return UnitActiveListResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: listJson
          .whereType<Map<String, dynamic>>()
          .map((e) => UnitActiveModel.fromJson(e))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}