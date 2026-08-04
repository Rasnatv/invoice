
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Apiprovider/authprovider.dart';
import '../../../core/models/loginrequestmodel.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import 'package:tileshop/core/models/loginresponsemodel.dart'; // LoginData, LoginResponse
import 'package:tileshop/core/utils/dashboardrouter.dart'; // roleFromStoredString
import 'package:tileshop/core/network/tokenstorage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider _authProvider;

  AuthBloc({AuthProvider? authProvider})
      : _authProvider = authProvider ?? AuthProvider(),
        super(const AuthState()) {
    on<AuthEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email, errorMessage: null));
    });

    on<AuthPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password, errorMessage: null));
    });

    on<AuthTogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(obscurePassword: !state.obscurePassword));
    });

    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
      AuthLoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    final email = state.email.trim();
    final password = state.password;

    if (email.isEmpty || password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Email and password are required.',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.submitting, errorMessage: null));

    final AuthResult result = await _authProvider.login(
      LoginRequest(email: email, password: password),
    );

    final LoginResponse? response = result.response;
    final LoginData? user = response?.data;

    if (result.success && user != null) {
      final role = roleFromStoredString(user.designation);

      // Save the raw designation string — the same format Splash reads
      // back with roleFromStoredString, so there's one mapping, not two.
      await TokenStorage.save(token: user.token, tokenType: user.tokenType);
      await TokenStorage.saveRole(user.designation);

      if (role == null) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unrecognized account type. Contact support.',
        ));
        return;
      }

      emit(state.copyWith(
        status: AuthStatus.success,
        role: role,
        name: user.name,
        token: user.token,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: result.errorMessage ?? 'Login failed.',
      ));
    }
  }

  /// Call this from Splash to silently restore a session — mirrors what
  /// SplashScreen already does with TokenStorage + roleFromStoredString,
  /// just exposed through the bloc too in case you want Splash on AuthBloc.
  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    final token = await TokenStorage.readToken();
    final role = roleFromStoredString(await TokenStorage.readRole());

    if (token != null && token.isNotEmpty && role != null) {
      emit(state.copyWith(status: AuthStatus.success, role: role, token: token));
    } else {
      emit(state.copyWith(status: AuthStatus.initial));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await TokenStorage.clear();
    emit(const AuthState());
  }
}