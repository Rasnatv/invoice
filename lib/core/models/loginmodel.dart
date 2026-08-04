// /// The `data` object inside a successful login response.
// /// `empId` and `mobile` are only present for staff logins (salesman/driver_features/
// /// field staff); owners may not have them, so both stay nullable.
// class LoginData {
//   final String name;
//   final String email;
//   final String designation;
//   final String? empId;
//   final String token;
//   final String tokenType;
//
//   const LoginData({
//     required this.name,
//     required this.email,
//     required this.designation,
//     this.empId,
//     required this.token,
//     required this.tokenType,
//   });
//
//   factory LoginData.fromJson(Map<String, dynamic> json) {
//     return LoginData(
//       name: json['name'] as String? ?? '',
//       email: json['email'] as String? ?? '',
//       designation: _parseDesignation(json['designation']),
//       empId: json['emp_id'] as String?,
//       token: json['token'] as String? ?? '',
//       tokenType: json['token_type'] as String? ?? 'Bearer',
//     );
//   }
//
//   /// `designation` is a plain string for Owner/Driver/Field Staff logins,
//   /// but a nested object (id, name, code, ...) for Salesman logins. Both
//   /// shapes get normalized to a single string here so nothing downstream
//   /// (roleFromDesignation, the UI) needs to know which shape it got.
//   static String _parseDesignation(dynamic raw) {
//     if (raw is String) return raw;
//     if (raw is Map<String, dynamic>) {
//       return (raw['name'] as String?) ?? (raw['code'] as String?) ?? '';
//     }
//     return '';
//   }
//
//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'email': email,
//     'designation': designation,
//     'emp_id': empId,
//     'token': token,
//     'token_type': tokenType,
//   };
// }
//
// /// The full `/login` response envelope:
// /// { "status": "1", "status_code": "200", "data": {...}, "message": "..." }
// class LoginResponse {
//   final String status;
//   final String statusCode;
//   final String message;
//   final LoginData? data;
//
//   const LoginResponse({
//     required this.status,
//     required this.statusCode,
//     required this.message,
//     this.data,
//   });
//
//   /// API returns status as the string "1" for success.
//   bool get isSuccess => status == '1';
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(
//       status: json['status']?.toString() ?? '0',
//       statusCode: json['status_code']?.toString() ?? '',
//       message: json['message'] as String? ?? '',
//       data: json['data'] != null
//           ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }
/// The `data` object inside a successful login response.
/// `empId` and `mobile` are only present for staff logins (salesman/driver/
/// field staff); owners may not have them, so both stay nullable.
// class LoginData {
//   final String name;
//   final String email;
//   final String designation;
//   final String? empId;
//   final String token;
//   final String tokenType;
//
//   const LoginData({
//     required this.name,
//     required this.email,
//     required this.designation,
//     this.empId,
//     required this.token,
//     required this.tokenType,
//   });
//
//   factory LoginData.fromJson(Map<String, dynamic> json) {
//     return LoginData(
//       name: json['name'] as String? ?? '',
//       email: json['email'] as String? ?? '',
//       designation: _parseDesignation(json['designation']),
//       empId: json['emp_id'] as String?,
//       token: json['token'] as String? ?? '',
//       tokenType: json['token_type'] as String? ?? 'Bearer',
//     );
//   }
//
//   /// `designation` is a plain string for Owner/Driver/Field Staff logins,
//   /// but a nested object (id, name, code, ...) for Salesman logins. Both
//   /// shapes get normalized to a single string here so nothing downstream
//   /// (roleFromDesignation, the UI) needs to know which shape it got.
//   static String _parseDesignation(dynamic raw) {
//     if (raw is String) return raw;
//     if (raw is Map<String, dynamic>) {
//       return (raw['name'] as String?) ?? (raw['code'] as String?) ?? '';
//     }
//     return '';
//   }
//
//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'email': email,
//     'designation': designation,
//     'emp_id': empId,
//     'token': token,
//     'token_type': tokenType,
//   };
// }
//
// /// The full `/login` response envelope:
// /// { "status": "1", "status_code": "200", "data": {...}, "message": "..." }
// class LoginResponse {
//   final String status;
//   final String statusCode;
//   final String message;
//   final LoginData? data;
//
//   const LoginResponse({
//     required this.status,
//     required this.statusCode,
//     required this.message,
//     this.data,
//   });
//
//   /// API returns status as the string "1" for success.
//   bool get isSuccess => status == '1';
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//     return LoginResponse(
//       status: json['status']?.toString() ?? '0',
//       statusCode: json['status_code']?.toString() ?? '',
//       message: json['message'] as String? ?? '',
//       data: json['data'] != null
//           ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }