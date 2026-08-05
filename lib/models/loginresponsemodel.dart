// This is your lib/core/models/loginresponsemodel.dart — the ONLY file that
// should define LoginResponse / LoginData in the project.
import 'package:tileshop/router/dashboardrouter.dart'; // UserRole, roleFromStoredString

class LoginData {
  final String name;
  final String email;
  final String designation;
  final String token;
  final String tokenType;

  const LoginData({
    required this.name,
    required this.email,
    required this.designation,
    required this.token,
    required this.tokenType,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'designation': designation,
    'token': token,
    'token_type': tokenType,
  };

  /// null if the API ever returns a designation we don't recognize.
  UserRole? get role => roleFromStoredString(designation);
}

class LoginResponse {
  final String status;
  final String statusCode;
  final LoginData? data;
  final String message;

  const LoginResponse({
    required this.status,
    required this.statusCode,
    required this.data,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString() ?? '',
    );
  }

  bool get isSuccess => status == '1' && statusCode == '200';
}