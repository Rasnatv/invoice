
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
  final String joiningDate; // yyyy-MM-dd

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

/// Response for POST /drivers.
class DriverAddResponseModel {
  DriverAddResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  final String status;
  final int statusCode;
  final String message;

  factory DriverAddResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverAddResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: _asInt(json['status_code']),
      message: json['message']?.toString() ?? '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}