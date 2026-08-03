part of 'auth_bloc.dart';

enum AuthStatus { initial, submitting, success, failure }

/// Who logged in — LoginScreen routes to a different dashboard based on
/// this. Only real roles live here; "not logged in yet" or "backend sent
/// an unrecognized designation" is represented by `role == null`.
enum UserRole { owner, salesman, driver, fieldStaff }

/// Returns null if the designation doesn't match any known role.
UserRole? roleFromDesignation(String designation) {
  final d = designation.trim().toLowerCase();
  if (d.contains('owner')) return UserRole.owner;
  if (d.contains('driver_features')) return UserRole.driver;
  if (d.contains('sales')) return UserRole.salesman;
  if (d.contains('field')) return UserRole.fieldStaff;
  return null;
}

class AuthState extends Equatable {
  // Login form fields — `email` doubles as the field the user types into
  // AND gets overwritten with the confirmed value from the API response
  // on success (same value, just the source of truth switches).
  final String email;
  final String password;
  final bool obscurePassword;
  final AuthStatus status;
  final String? errorMessage;
  final UserRole? role;

  // Populated on a successful login — useful for a profile header,
  // and for attaching the token to future authenticated requests.
  final String? name;
  final String? empId;
  final String? mobile;
  final String? token;
  final String? tokenType;

  const AuthState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.role,
    this.name,
    this.empId,
    this.mobile,
    this.token,
    this.tokenType,
  });

  // Kept deliberately simple: both fields just need to be non-empty.
  // Tighten this up (e.g. email format / min password length) once real
  // validation rules are defined.
  bool get isValid => email.trim().isNotEmpty && password.trim().isNotEmpty;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    AuthStatus? status,
    String? errorMessage,
    UserRole? role,
    bool clearRole = false, // pass true to explicitly reset role to null
    String? name,
    String? empId,
    String? mobile,
    String? token,
    String? tokenType,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      role: clearRole ? null : (role ?? this.role),
      name: name ?? this.name,
      empId: empId ?? this.empId,
      mobile: mobile ?? this.mobile,
      token: token ?? this.token,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    obscurePassword,
    status,
    errorMessage,
    role,
    name,
    empId,
    mobile,
    token,
    tokenType,
  ];
}