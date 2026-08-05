/// Request model for POST /field-staff.
/// The API's "data" on success is an empty object ({}), so there's nothing
/// to parse back — this model only needs toJson() for the request body.
class FieldStaffCreateModel {
  FieldStaffCreateModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.joiningDate,
  });

  final String name;
  final String email;
  final String mobile;
  final String address;
  final String joiningDate; // "yyyy-MM-dd"

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'joining_date': joiningDate,
    };
  }
}