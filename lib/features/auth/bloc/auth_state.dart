// part of 'auth_bloc.dart';
//
// enum AuthStatus { initial, submitting, success, failure }
//
// /// Who logged in — LoginScreen routes to a different dashboard based on
// /// this. `none` is the default/unset value before a successful login.
// enum UserRole { none, owner, salesman }
//
// class AuthState extends Equatable {
//   final String phone;
//   final String password;
//   final bool obscurePassword;
//   final AuthStatus status;
//   final String? errorMessage;
//   final UserRole role;
//
//   const AuthState({
//     this.phone = '',
//     this.password = '',
//     this.obscurePassword = true,
//     this.status = AuthStatus.initial,
//     this.errorMessage,
//     this.role = UserRole.none,
//   });
//
//   // Kept deliberately simple for the demo: both fields just need to be
//   // non-empty. Tighten this back up (e.g. email format / min password
//   // length) once real validation rules are defined.
//   bool get isValid => phone.trim().isNotEmpty && password.trim().isNotEmpty;
//
//   AuthState copyWith({
//     String? phone,
//     String? password,
//     bool? obscurePassword,
//     AuthStatus? status,
//     String? errorMessage,
//     UserRole? role,
//   }) {
//     return AuthState(
//       phone: phone ?? this.phone,
//       password: password ?? this.password,
//       obscurePassword: obscurePassword ?? this.obscurePassword,
//       status: status ?? this.status,
//       errorMessage: errorMessage,
//       role: role ?? this.role,
//     );
//   }
//
//   @override
//   List<Object?> get props => [phone, password, obscurePassword, status, errorMessage, role];
// }
part of 'auth_bloc.dart';

enum AuthStatus { initial, submitting, success, failure }

/// Who logged in — LoginScreen routes to a different dashboard based on
/// this. `none` is the default/unset value before a successful login.
enum UserRole { none, owner, salesman, driver }

class AuthState extends Equatable {
  final String phone;
  final String password;
  final bool obscurePassword;
  final AuthStatus status;
  final String? errorMessage;
  final UserRole role;

  const AuthState({
    this.phone = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.role = UserRole.none,
  });

  // Kept deliberately simple for the demo: both fields just need to be
  // non-empty. Tighten this back up (e.g. email format / min password
  // length) once real validation rules are defined.
  bool get isValid => phone.trim().isNotEmpty && password.trim().isNotEmpty;

  AuthState copyWith({
    String? phone,
    String? password,
    bool? obscurePassword,
    AuthStatus? status,
    String? errorMessage,
    UserRole? role,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [phone, password, obscurePassword, status, errorMessage, role];
}