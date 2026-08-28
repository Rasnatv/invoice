
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