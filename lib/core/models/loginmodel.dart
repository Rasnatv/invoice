/// The `data` object inside a successful login response.
/// `empId` and `mobile` are only present for staff logins (salesman/driver);
/// owners may not have them, so both are nullable.
class LoginData {
  final String name;
  final String email;
  final String designation;
  final String? empId;
  final String? mobile;
  final String token;
  final String tokenType;

  const LoginData({
    required this.name,
    required this.email,
    required this.designation,
    this.empId,
    this.mobile,
    required this.token,
    required this.tokenType,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      empId: json['emp_id'] as String?,
      mobile: json['mobile'] as String?,
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'designation': designation,
    'emp_id': empId,
    'mobile': mobile,
    'token': token,
    'token_type': tokenType,
  };
}

/// The full `/login` response envelope:
/// { "status": "1", "status_code": "200", "data": {...}, "message": "..." }
class LoginResponse {
  final String status;
  final String statusCode;
  final String message;
  final LoginData? data;

  const LoginResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  /// API returns status as the string "1" for success.
  bool get isSuccess => status == '1';

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}