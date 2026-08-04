
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthEmailChanged extends AuthEvent {
  final String email;
  const AuthEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthPasswordChanged extends AuthEvent {
  final String password;
  const AuthPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class AuthTogglePasswordVisibility extends AuthEvent {
  const AuthTogglePasswordVisibility();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}