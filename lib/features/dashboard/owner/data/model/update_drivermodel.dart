/// Request body for POST /drivers/update.
class DriverUpdateRequestModel {
  DriverUpdateRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
    this.password,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;
  final String joiningDate; // "yyyy-MM-dd"

  /// Optional — only send when the owner wants to reset the driver's password.
  final String? password;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (password != null && password!.isNotEmpty) 'password': password,
      'mobile': mobile,
      'license_number': licenseNumber,
      'vehicle_number': vehicleNumber,
      'joining_date': joiningDate,
    };
  }
}