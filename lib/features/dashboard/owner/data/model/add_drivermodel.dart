/// Request body for POST /drivers (create driver).
class DriverAddRequestModel {
  DriverAddRequestModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
  });

  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;
  final String joiningDate; // "yyyy-MM-dd"

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'license_number': licenseNumber,
      'vehicle_number': vehicleNumber,
      'joining_date': joiningDate,
    };
  }
}

/// Response `data` object returned by POST /drivers.
class DriverAddResponseModel {
  DriverAddResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.generatedPassword,
    required this.message,
    required this.emailStatus,
    required this.emailMessage,
  });

  final int id;
  final String name;
  final String email;
  final String generatedPassword;
  final String message;
  final String emailStatus;
  final String emailMessage;

  factory DriverAddResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverAddResponseModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      generatedPassword: json['generated_password']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      emailStatus: json['email_status']?.toString() ?? '',
      emailMessage: json['email_message']?.toString() ?? '',
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}