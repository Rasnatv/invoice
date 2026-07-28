part of 'auth_bloc.dart';

enum AuthStatus { initial, submitting, success, failure }

/// Who logged in — LoginScreen routes to a different dashboard based on
/// this. `none` is the default/unset value before a successful login,
/// or when the API returns a designation we don't recognize.
enum UserRole { none, owner, salesman, driver }

UserRole roleFromDesignation(String designation) {
  switch (designation.trim().toLowerCase()) {
    case 'owner':
      return UserRole.owner;
    case 'salesman':
    case 'salesperson':
    case 'sales':
      return UserRole.salesman;
    case 'driver':
      return UserRole.driver;
    default:
      return UserRole.none;
  }
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
  final UserRole role;

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
    this.role = UserRole.none,
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
      role: role ?? this.role,
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