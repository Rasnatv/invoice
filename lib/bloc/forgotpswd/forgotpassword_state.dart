import 'package:equatable/equatable.dart';

enum RequestStatus { initial, loading, success, failure }

/// One state class covers all three screens in the flow. Each step
/// (send OTP / resend OTP / verify OTP / reset password) has its own
/// status + error so each screen can react only to the step it cares
/// about, while [email] and [otp] are carried forward for the later
/// steps that need them (verify-otp and reset-password both need the
/// email; reset-password also needs the otp that was verified).
class ForgotPasswordState extends Equatable {
  final String email;
  final String otp;

  final RequestStatus sendOtpStatus;
  final String? sendOtpError;

  final RequestStatus resendOtpStatus;
  final String? resendOtpError;

  final RequestStatus verifyOtpStatus;
  final String? verifyOtpError;

  final RequestStatus resetPasswordStatus;
  final String? resetPasswordError;

  const ForgotPasswordState({
    this.email = '',
    this.otp = '',
    this.sendOtpStatus = RequestStatus.initial,
    this.sendOtpError,
    this.resendOtpStatus = RequestStatus.initial,
    this.resendOtpError,
    this.verifyOtpStatus = RequestStatus.initial,
    this.verifyOtpError,
    this.resetPasswordStatus = RequestStatus.initial,
    this.resetPasswordError,
  });

  factory ForgotPasswordState.initial() => const ForgotPasswordState();

  ForgotPasswordState copyWith({
    String? email,
    String? otp,
    RequestStatus? sendOtpStatus,
    String? sendOtpError,
    bool clearSendOtpError = false,
    RequestStatus? resendOtpStatus,
    String? resendOtpError,
    bool clearResendOtpError = false,
    RequestStatus? verifyOtpStatus,
    String? verifyOtpError,
    bool clearVerifyOtpError = false,
    RequestStatus? resetPasswordStatus,
    String? resetPasswordError,
    bool clearResetPasswordError = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      sendOtpError:
      clearSendOtpError ? null : (sendOtpError ?? this.sendOtpError),
      resendOtpStatus: resendOtpStatus ?? this.resendOtpStatus,
      resendOtpError: clearResendOtpError
          ? null
          : (resendOtpError ?? this.resendOtpError),
      verifyOtpStatus: verifyOtpStatus ?? this.verifyOtpStatus,
      verifyOtpError: clearVerifyOtpError
          ? null
          : (verifyOtpError ?? this.verifyOtpError),
      resetPasswordStatus: resetPasswordStatus ?? this.resetPasswordStatus,
      resetPasswordError: clearResetPasswordError
          ? null
          : (resetPasswordError ?? this.resetPasswordError),
    );
  }

  @override
  List<Object?> get props => [
    email,
    otp,
    sendOtpStatus,
    sendOtpError,
    resendOtpStatus,
    resendOtpError,
    verifyOtpStatus,
    verifyOtpError,
    resetPasswordStatus,
    resetPasswordError,
  ];
}