import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/authprovider.dart';
import '../../models/forgotpasswordmodel.dart';
import 'forgotpassword_event.dart';
import 'forgotpassword_state.dart';

/// One bloc instance is created in ForgotPasswordScreen and carried down
/// through OtpVerificationScreen and SetNewPasswordScreen (via
/// BlocProvider.value), so `email` and `otp` collected on earlier screens
/// are available when later steps need them.
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthProvider _authProvider;

  ForgotPasswordBloc({AuthProvider? authProvider})
      : _authProvider = authProvider ?? AuthProvider(),
        super(ForgotPasswordState.initial()) {
    on<SendForgotPasswordOtp>(_onSendOtp);
    on<ResendForgotPasswordOtp>(_onResendOtp);
    on<VerifyForgotPasswordOtp>(_onVerifyOtp);
    on<SubmitNewPassword>(_onSubmitNewPassword);
    on<ResetForgotPasswordFlow>(_onResetFlow);
  }

  Future<void> _onSendOtp(
      SendForgotPasswordOtp event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    emit(state.copyWith(
      email: event.email,
      sendOtpStatus: RequestStatus.loading,
      clearSendOtpError: true,
    ));

    final result = await _authProvider.forgotPassword(event.email);

    emit(state.copyWith(
      sendOtpStatus:
      result.success ? RequestStatus.success : RequestStatus.failure,
      sendOtpError: result.success ? null : result.message,
    ));
  }

  Future<void> _onResendOtp(
      ResendForgotPasswordOtp event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    if (state.email.isEmpty) return;

    emit(state.copyWith(
      resendOtpStatus: RequestStatus.loading,
      clearResendOtpError: true,
    ));

    final result = await _authProvider.forgotPassword(state.email);

    emit(state.copyWith(
      resendOtpStatus:
      result.success ? RequestStatus.success : RequestStatus.failure,
      resendOtpError: result.success ? null : result.message,
    ));
  }

  Future<void> _onVerifyOtp(
      VerifyForgotPasswordOtp event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    emit(state.copyWith(
      otp: event.otp,
      verifyOtpStatus: RequestStatus.loading,
      clearVerifyOtpError: true,
    ));

    final result = await _authProvider.verifyOtp(
      email: state.email,
      otp: event.otp,
    );

    emit(state.copyWith(
      verifyOtpStatus:
      result.success ? RequestStatus.success : RequestStatus.failure,
      verifyOtpError: result.success ? null : result.message,
    ));
  }

  Future<void> _onSubmitNewPassword(
      SubmitNewPassword event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    emit(state.copyWith(
      resetPasswordStatus: RequestStatus.loading,
      clearResetPasswordError: true,
    ));

    final result = await _authProvider.resetPassword(
      ResetPasswordRequest(
        email: state.email,
        otp: state.otp,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );

    emit(state.copyWith(
      resetPasswordStatus:
      result.success ? RequestStatus.success : RequestStatus.failure,
      resetPasswordError: result.success ? null : result.message,
    ));
  }

  void _onResetFlow(
      ResetForgotPasswordFlow event,
      Emitter<ForgotPasswordState> emit,
      ) {
    emit(ForgotPasswordState.initial());
  }
}