/// Response model for GET /drivers
class DriverGetResponseModel {
  DriverGetResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;
  final List<DriverGetModel> data;
  final String message;

  factory DriverGetResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverGetResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => DriverGetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Model for each driver
class DriverGetModel {
  DriverGetModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;
  final String joiningDate;
  final bool isActive;
  final String createdAt;

  factory DriverGetModel.fromJson(Map<String, dynamic> json) {
    return DriverGetModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
      isActive: _asBool(json['is_active']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  DriverGetModel copyWith({
    int? id,
    String? name,
    String? email,
    String? mobile,
    String? licenseNumber,
    String? vehicleNumber,
    String? joiningDate,
    bool? isActive,
    String? createdAt,
  }) {
    return DriverGetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      joiningDate: joiningDate ?? this.joiningDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString().toLowerCase() == 'true';
  }
}