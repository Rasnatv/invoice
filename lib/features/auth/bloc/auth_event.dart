part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthPhoneChanged extends AuthEvent {
  final String phone;
  const AuthPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
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

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
