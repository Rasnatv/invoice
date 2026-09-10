

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  const VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}

/// ---------------------------------------------------------------------
/// Response
/// ---------------------------------------------------------------------

class AuthActionResponseModel {
  final String status;
  final String statusCode;
  final Map<String, dynamic>? data;
  final String message;

  const AuthActionResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == '1';

  factory AuthActionResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthActionResponseModel(
      status: json['status']?.toString() ?? '0',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'status_code': statusCode,
    'data': data,
    'message': message,
  };
}