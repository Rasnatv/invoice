class DesignationModel {
  final int id;
  final String name;

  DesignationModel({
    required this.id,
    required this.name,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  DesignationModel copyWith({int? id, String? name}) {
    return DesignationModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}