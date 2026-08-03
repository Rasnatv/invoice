// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../core/models/loginmodel.dart';
// import '../../../core/network/tokenstorage.dart';
// import '../data/auth_repository.dart';
//
// part 'auth_event.dart';
// part 'auth_state.dart';
//
// /// Handles the Login screen's form state and talks to [AuthRepository]
// /// for the real /login call. The UI layer never needs to change when the
// /// backend changes — only this bloc and the repository do.
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository _authRepository;
//
//   AuthBloc({AuthRepository? authRepository})
//       : _authRepository = authRepository ?? AuthRepository(),
//         super(const AuthState()) {
//     on<AuthEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
//     on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
//     on<AuthTogglePasswordVisibility>(
//           (event, emit) => emit(state.copyWith(obscurePassword: !state.obscurePassword)),
//     );
//     on<AuthLoginSubmitted>(_onSubmitted);
//     on<AuthLogoutRequested>(_onLogout);
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
//     emit(state.copyWith(status: AuthStatus.submitting, errorMessage: null));
//
//     try {
//       final LoginData data = await _authRepository.login(
//         email: state.email.trim(),
//         password: state.password,
//       );
//
//       final role = roleFromDesignation(data.designation);
//       if (role == null) {
//         // Backend returned a designation we don't recognize — treat it
//         // as a failure rather than guessing a dashboard for it.
//         emit(state.copyWith(
//           status: AuthStatus.failure,
//           errorMessage: 'Unrecognized account type. Please contact support.',
//           clearRole: true,
//         ));
//         return;
//       }
//
//       // Guard against a null/empty token instead of force-unwrapping —
//       // without a token every subsequent authenticated call will fail.
//       if (data.token == null || data.token!.isEmpty) {
//         emit(state.copyWith(
//           status: AuthStatus.failure,
//           errorMessage: 'Login succeeded but no token was returned.',
//           clearRole: true,
//         ));
//         return;
//       }
//
//       // Persist the token so DioClient's interceptor can attach it to
//       // every future request, and so it survives navigating away from
//       // (and disposing) this bloc.
//       await TokenStorage.save(token: data.token!, tokenType: data.tokenType);
//
//       emit(state.copyWith(
//         status: AuthStatus.success,
//         role: role,
//         name: data.name,
//         email: data.email,
//         empId: data.empId,
//         mobile: data.mobile,
//         token: data.token,
//         tokenType: data.tokenType,
//       ));
//     } on AuthException catch (e) {
//       emit(state.copyWith(
//         status: AuthStatus.failure,
//         errorMessage: e.message,
//         clearRole: true,
//       ));
//     } catch (_) {
//       emit(state.copyWith(
//         status: AuthStatus.failure,
//         errorMessage: 'Something went wrong. Please try again.',
//         clearRole: true,
//       ));
//     }
//   }
//
//   Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
//     await TokenStorage.clear();
//     emit(const AuthState());
//   }
// }
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/loginmodel.dart';
import '../../../core/network/tokenstorage.dart';
import '../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Handles the Login screen's form state and talks to [AuthRepository]
/// for the real /login call. The UI layer never needs to change when the
/// backend changes — only this bloc and the repository do.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const AuthState()) {
    on<AuthEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
    on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<AuthTogglePasswordVisibility>(
          (event, emit) => emit(state.copyWith(obscurePassword: !state.obscurePassword)),
    );
    on<AuthLoginSubmitted>(_onSubmitted);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onSubmitted(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Enter a valid email and password',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.submitting, errorMessage: null));

    try {
      final LoginData data = await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
      );

      final role = roleFromDesignation(data.designation);
      if (role == null) {
        // Backend returned a designation we don't recognize — treat it
        // as a failure rather than guessing a dashboard for it.
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unrecognized account type. Please contact support.',
          clearRole: true,
        ));
        return;
      }

      // Guard against a null/empty token instead of force-unwrapping —
      // without a token every subsequent authenticated call will fail.
      if (data.token == null || data.token!.isEmpty) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Login succeeded but no token was returned.',
          clearRole: true,
        ));
        return;
      }

      // Persist the token + role so DioClient's interceptor can attach
      // the token to every future request, and so Splash can auto-route
      // to the right dashboard on the next app launch without hitting
      // the login API again.
      await TokenStorage.save(token: data.token!, tokenType: data.tokenType);
      await TokenStorage.saveRole(role.name);

      emit(state.copyWith(
        status: AuthStatus.success,
        role: role,
        name: data.name,
        email: data.email,
        empId: data.empId,
        mobile: data.mobile,
        token: data.token,
        tokenType: data.tokenType,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
        clearRole: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
        clearRole: true,
      ));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await TokenStorage.clear();
    emit(const AuthState());
  }
}