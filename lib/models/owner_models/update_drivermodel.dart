
import 'package:intl/intl.dart';

/// Request body for POST /drivers/update.
///
/// {
///   "id": 3, "name": "Dri1", "email": "dri111@ceramo.com",
///   "mobile": "9871143210", "license_number": "Dq000001",
///   "vehicle_number": "Kq-01-AB-1234",
///   "joining_date": "25-01-2025",   // dd-MM-yyyy
///   "is_active": 1
/// }
class DriverUpdateRequestModel {
  DriverUpdateRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.joiningDate,
    required this.isActive,
    this.password,
  });

  /// Convenience: pass the picked [DateTime] and it is formatted as dd-MM-yyyy.
  factory DriverUpdateRequestModel.fromDate({
    required int id,
    required String name,
    required String email,
    required String mobile,
    required String licenseNumber,
    required String vehicleNumber,
    required DateTime joiningDate,
    required bool isActive,
    String? password,
  }) {
    return DriverUpdateRequestModel(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      licenseNumber: licenseNumber,
      vehicleNumber: vehicleNumber,
      joiningDate: DateFormat('dd-MM-yyyy').format(joiningDate),
      isActive: isActive,
      password: password,
    );
  }

  final int id;
  final String name;
  final String email;
  final String mobile;
  final String licenseNumber;
  final String vehicleNumber;

  /// "dd-MM-yyyy" (e.g. "25-01-2025").
  final String joiningDate;
  final bool isActive;

  /// Optional — only sent when the owner wants to reset the driver's password.
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
      'is_active': isActive ? 1 : 0,
    };
  }
}

/// Response of POST /drivers/update.
///
/// Error example:
/// { "status": "0", "status_code": "404", "data": {}, "message": "Driver not found" }
class DriverUpdateResponseModel {
  DriverUpdateResponseModel({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final String status;
  final String statusCode;

  /// Raw `data` object. Empty on errors (e.g. 404). On success it may carry
  /// the updated driver — parse it with DriverGetModel.fromJson if needed.
  final Map<String, dynamic> data;
  final String message;

  bool get isSuccess => status == '1';

  factory DriverUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return DriverUpdateResponseModel(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: raw is Map<String, dynamic> ? raw : <String, dynamic>{},
      message: json['message']?.toString() ?? '',
    );
  }
}