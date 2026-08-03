/// One model for: POST /field-staff/update
/// - toJson()   -> used to build the request body (id is required here)
/// - fromJson() -> used to parse the "data" object from the response
class FieldStaffUpdateModel {
  FieldStaffUpdateModel({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'joining_date': joiningDate,
    };
  }

  factory FieldStaffUpdateModel.fromJson(Map<String, dynamic> json) {
    return FieldStaffUpdateModel(
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
}