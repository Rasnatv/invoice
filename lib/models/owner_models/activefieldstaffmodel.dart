/// GET /field-staff-incentives/../field-staff/active
/// data: { list: [ { id, name } ] }
class ActiveFieldStaffModel {
  final String id;
  final String name;

  const ActiveFieldStaffModel({
    required this.id,
    required this.name,
  });

  factory ActiveFieldStaffModel.fromJson(Map<String, dynamic> json) {
    return ActiveFieldStaffModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}