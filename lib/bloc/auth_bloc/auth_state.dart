//
// part of 'auth_bloc.dart';
//
// enum AuthStatus { initial, submitting, success, failure }
//
// /// Who logged in — LoginScreen routes to a different dashboard based on
// /// this. Only real roles live here; "not logged in yet" or "backend sent
// /// an unrecognized designation" is represented by `role == null`.
// enum UserRole { owner, salesman, driver, fieldStaff }
//
// /// Maps the backend's numeric `designation` code to a [UserRole].
// /// Returns null if the code doesn't match any known role.
// ///
// /// Known codes (from /login responses):
// ///   "2" -> owner
// ///   "3" -> salesman
// ///   "4" -> driver
// ///   "5" -> fieldStaff
// UserRole? roleFromDesignation(String designation) {
//   switch (designation.trim()) {
//     case '2':
//       return UserRole.owner;
//     case '3':
//       return UserRole.salesman;
//     case '4':
//       return UserRole.driver;
//     case '5':
//       return UserRole.fieldStaff;
//     default:
//       return null;
//   }
// }
//
// class AuthState extends Equatable {
//   // Login form fields — `email` doubles as the field the user types into
//   // AND gets overwritten with the confirmed value from the API response
//   // on success (same value, just the source of truth switches).
//   final String email;
//   final String password;
//   final bool obscurePassword;
//   final AuthStatus status;
//   final String? errorMessage;
//   final UserRole? role;
//
//   // Populated on a successful login — useful for a profile header,
//   // and for attaching the token to future authenticated requests.
//   final String? name;
//   final String? empId;
//   final String? mobile;
//   final String? token;
//   final String? tokenType;
//
//   const AuthState({
//     this.email = '',
//     this.password = '',
//     this.obscurePassword = true,
//     this.status = AuthStatus.initial,
//     this.errorMessage,
//     this.role,
//     this.name,
//     this.empId,
//     this.mobile,
//     this.token,
//     this.tokenType,
//   });
//
//   // Kept deliberately simple: both fields just need to be non-empty.
//   // Tighten this up (e.g. email format / min password length) once real
//   // validation rules are defined.
//   bool get isValid => email.trim().isNotEmpty && password.trim().isNotEmpty;
//
//   bool get isAuthenticated => token != null && token!.isNotEmpty;
//
//   AuthState copyWith({
//     String? email,
//     String? password,
//     bool? obscurePassword,
//     AuthStatus? status,
//     String? errorMessage,
//     UserRole? role,
//     bool clearRole = false, // pass true to explicitly reset role to null
//     String? name,
//     String? empId,
//     String? mobile,
//     String? token,
//     String? tokenType,
//   }) {
//     return AuthState(
//       email: email ?? this.email,
//       password: password ?? this.password,
//       obscurePassword: obscurePassword ?? this.obscurePassword,
//       status: status ?? this.status,
//       errorMessage: errorMessage,
//       role: clearRole ? null : (role ?? this.role),
//       name: name ?? this.name,
//       empId: empId ?? this.empId,
//       mobile: mobile ?? this.mobile,
//       token: token ?? this.token,
//       tokenType: tokenType ?? this.tokenType,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     email,
//     password,
//     obscurePassword,
//     status,
//     errorMessage,
//     role,
//     name,
//     empId,
//     mobile,
//     token,
//     tokenType,
//   ];
// }
import 'package:equatable/equatable.dart';
import 'package:tileshop/router/dashboardrouter.dart'; // UserRole

enum AuthStatus { initial, submitting, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String email;
  final String password;
  final bool obscurePassword;
  final UserRole? role;
  final String? name;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.role,
    this.name,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    bool? obscurePassword,
    UserRole? role,
    String? name,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      role: role ?? this.role,
      name: name ?? this.name,
      token: token ?? this.token,
      // Deliberately not falling back to `this.errorMessage` — every
      // emit() should say explicitly whether an error is present or cleared.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    obscurePassword,
    role,
    name,
    token,
    errorMessage,
  ];
}