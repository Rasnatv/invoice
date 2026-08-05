/// Request model for POST /field-staff/update.
/// "data" on success is an empty object ({}), so this only needs toJson().
class FieldStaffUpdateModel {
  FieldStaffUpdateModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.joiningDate,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String joiningDate; // "yyyy-MM-dd"
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'joining_date': joiningDate,
      'is_active': isActive ? 1 : 0,
    };
  }
}