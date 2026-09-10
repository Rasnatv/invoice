import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Screen 1 — ForgotPasswordScreen: send the OTP to [email].
class SendForgotPasswordOtp extends ForgotPasswordEvent {
  final String email;

  const SendForgotPasswordOtp(this.email);

  @override
  List<Object?> get props => [email];
}

/// Screen 2 — OtpVerificationScreen: resend the OTP.
class ResendForgotPasswordOtp extends ForgotPasswordEvent {
  const ResendForgotPasswordOtp();
}

/// Screen 2 — OtpVerificationScreen: verify the entered [otp].
class VerifyForgotPasswordOtp extends ForgotPasswordEvent {
  final String otp;

  const VerifyForgotPasswordOtp(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// Screen 3 — SetNewPasswordScreen: submit the new password.
class SubmitNewPassword extends ForgotPasswordEvent {
  final String password;
  final String passwordConfirmation;

  const SubmitNewPassword({
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [password, passwordConfirmation];
}

/// Resets the flow's status flags back to initial — call when leaving the
/// flow entirely (e.g. dispose of the outermost screen) if the bloc/provider
/// instance is reused elsewhere.
class ResetForgotPasswordFlow extends ForgotPasswordEvent {
  const ResetForgotPasswordFlow();
}