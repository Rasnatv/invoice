/// Core field staff entity — used for display, list items, and prefilling
/// the edit form. Not tied to any single API's request/response shape.
class FieldStaffModel {
  FieldStaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.joiningDate,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String joiningDate; // "yyyy-MM-dd"

  factory FieldStaffModel.fromJson(Map<String, dynamic> json) {
    return FieldStaffModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
    );
  }

  FieldStaffModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? address,
    String? joiningDate,
  }) {
    return FieldStaffModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FieldStaffModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.mobile == mobile &&
        other.address == address &&
        other.joiningDate == joiningDate;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, mobile, address, joiningDate);
}