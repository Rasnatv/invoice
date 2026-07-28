import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/loginmodel.dart';
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

    emit(state.copyWith(status: AuthStatus.submitting, errorMessage: null));

    try {
      final LoginData data = await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
      );

      emit(state.copyWith(
        status: AuthStatus.success,
        role: roleFromDesignation(data.designation),
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
        role: UserRole.none,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
        role: UserRole.none,
      ));
    }
  }
}