// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// part 'auth_event.dart';
// part 'auth_state.dart';
//
// // TODO(backend): these two accounts are a dummy/demo stand-in for a real
// // login API, so the Owner vs Salesman dashboards can be built and tested
// // before the backend exists. Replace the credential check inside
// // _onSubmitted with an actual repository call, and set `role` from that
// // response instead of a hardcoded match.
// const _ownerEmail = 'owner@gmail.com';
// const _ownerPassword = 'owner';
// const _salesmanEmail = 'salesman@gmail.com';
// const _salesmanPassword = 'salesman';
//
// /// Handles the Login screen's form state + a mocked authentication call.
// /// Swap the Future.delayed block for a real repository call when the
// /// backend is ready — the UI layer never needs to change.
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   AuthBloc() : super(const AuthState()) {
//     on<AuthPhoneChanged>((event, emit) => emit(state.copyWith(phone: event.phone)));
//     on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
//     on<AuthTogglePasswordVisibility>(
//       (event, emit) => emit(state.copyWith(obscurePassword: !state.obscurePassword)),
//     );
//     on<AuthLoginSubmitted>(_onSubmitted);
//     on<AuthLogoutRequested>((event, emit) => emit(const AuthState()));
//   }
//
//   Future<void> _onSubmitted(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
//     if (!state.isValid) {
//       emit(state.copyWith(
//         status: AuthStatus.failure,
//         errorMessage: 'Enter a valid email and password',
//       ));
//       return;
//     }
//
//     emit(state.copyWith(status: AuthStatus.submitting));
//     await Future.delayed(const Duration(milliseconds: 900));
//
//     final email = state.phone.trim().toLowerCase();
//     final password = state.password;
//
//     if (email == _ownerEmail && password == _ownerPassword) {
//       emit(state.copyWith(status: AuthStatus.success, role: UserRole.owner));
//     } else if (email == _salesmanEmail && password == _salesmanPassword) {
//       emit(state.copyWith(status: AuthStatus.success, role: UserRole.salesman));
//     } else {
//       emit(state.copyWith(
//         status: AuthStatus.failure,
//         errorMessage: 'Invalid login. Use owner@gmail.com/owner or salesman@gmail.com/salesman',
//         role: UserRole.none,
//       ));
//     }
//   }
// }
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// TODO(backend): these three accounts are a dummy/demo stand-in for a real
// login API, so the Owner vs Salesman vs Driver dashboards can be built
// and tested before the backend exists. Replace the credential check
// inside _onSubmitted with an actual repository call, and set `role` from
// that response instead of a hardcoded match.
const _ownerEmail = 'owner@gmail.com';
const _ownerPassword = 'owner';
const _salesmanEmail = 'salesman@gmail.com';
const _salesmanPassword = 'salesman';
const _driverEmail = 'driverlogin@gmail.com';
const _driverPassword = 'driver';

/// Handles the Login screen's form state + a mocked authentication call.
/// Swap the Future.delayed block for a real repository call when the
/// backend is ready — the UI layer never needs to change.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthPhoneChanged>((event, emit) => emit(state.copyWith(phone: event.phone)));
    on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<AuthTogglePasswordVisibility>(
          (event, emit) => emit(state.copyWith(obscurePassword: !state.obscurePassword)),
    );
    on<AuthLoginSubmitted>(_onSubmitted);
    on<AuthLogoutRequested>((event, emit) => emit(const AuthState()));
  }

  Future<void> _onSubmitted(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Enter a valid email and password',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.submitting));
    await Future.delayed(const Duration(milliseconds: 900));

    final email = state.phone.trim().toLowerCase();
    final password = state.password;

    if (email == _ownerEmail && password == _ownerPassword) {
      emit(state.copyWith(status: AuthStatus.success, role: UserRole.owner));
    } else if (email == _salesmanEmail && password == _salesmanPassword) {
      emit(state.copyWith(status: AuthStatus.success, role: UserRole.salesman));
    } else if (email == _driverEmail && password == _driverPassword) {
      emit(state.copyWith(status: AuthStatus.success, role: UserRole.driver));
    } else {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage:
        'Invalid login. Use owner@gmail.com/owner, salesman@gmail.com/salesman, or driverlogin@gmail.com/driver',
        role: UserRole.none,
      ));
    }
  }
}
