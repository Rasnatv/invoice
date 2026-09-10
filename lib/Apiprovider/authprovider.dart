//
// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
// import '../models/loginrequestmodel.dart';
// import '../models/loginresponsemodel.dart';
//
// /// Simple success/failure wrapper so the bloc doesn't need to know about
// /// Dio or exceptions at all.
// class AuthResult {
//   final bool success;
//   final LoginResponse? response;
//   final String? errorMessage;
//
//   const AuthResult.success(this.response)
//       : success = true,
//         errorMessage = null;
//
//   const AuthResult.failure(this.errorMessage)
//       : success = false,
//         response = null;
// }
//
// class AuthProvider {
//   final ApiClient _apiClient;
//
//   AuthProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   /// Single login call for owner / salesman / driver / fieldstaff — role
//   /// isn't chosen by the caller, it comes back in `data.designation`.
//   Future<AuthResult> login(LoginRequest request) async {
//     try {
//       final response = await _apiClient.userLogin(request);
//       final body = response.data;
//
//       if (response.statusCode == 200 && body is Map<String, dynamic>) {
//         final loginResponse = LoginResponse.fromJson(body);
//
//         if (loginResponse.isSuccess && loginResponse.data != null) {
//           return AuthResult.success(loginResponse);
//         }
//         return AuthResult.failure(
//           loginResponse.message.isNotEmpty
//               ? loginResponse.message
//               : 'Login failed.',
//         );
//       }
//
//       return AuthResult.failure(
//         'Unexpected response: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       final errorMsg = await ApiErrorHandler.handleDioError(e);
//       return AuthResult.failure(errorMsg);
//     } catch (_) {
//       return const AuthResult.failure('Something went wrong. Please try again.');
//     }
//   }
// }
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/forgotpasswordmodel.dart';
import '../models/loginrequestmodel.dart';
import '../models/loginresponsemodel.dart';

/// Simple success/failure wrapper so the bloc doesn't need to know about
/// Dio or exceptions at all.
class AuthResult {
  final bool success;
  final LoginResponse? response;
  final String? errorMessage;

  const AuthResult.success(this.response)
      : success = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : success = false,
        response = null;
}

/// Uniform result wrapper for the forgot-password flow — send-otp,
/// verify-otp and reset-password all return the same envelope shape
/// (status / status_code / data / message), so one result type covers
/// all three.
class AuthActionResult {
  final bool success;
  final String? message;

  const AuthActionResult({required this.success, this.message});
}

class AuthProvider {
  final ApiClient _apiClient;

  AuthProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Single login call for owner / salesman / driver / fieldstaff — role
  /// isn't chosen by the caller, it comes back in `data.designation`.
  Future<AuthResult> login(LoginRequest request) async {
    try {
      final response = await _apiClient.userLogin(request);
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final loginResponse = LoginResponse.fromJson(body);

        if (loginResponse.isSuccess && loginResponse.data != null) {
          return AuthResult.success(loginResponse);
        }
        return AuthResult.failure(
          loginResponse.message.isNotEmpty
              ? loginResponse.message
              : 'Login failed.',
        );
      }

      return AuthResult.failure(
        'Unexpected response: ${response.statusCode}',
      );
    } on DioException catch (e) {
      final errorMsg = await ApiErrorHandler.handleDioError(e);
      return AuthResult.failure(errorMsg);
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  /// ---------------------------------------------------------------------
  /// Forgot-password flow
  ///
  /// NOTE: the three ApiClient methods below (forgotPassword, verifyOtp,
  /// resetPassword) need to be added to ApiClient — mirroring the pattern
  /// of userLogin already there. I don't have api_client.dart's contents,
  /// so wire these in there:
  ///
  ///   Future<Response> forgotPassword(Map<String, dynamic> body) =>
  ///       _dio.post('/forgot-password', data: body);
  ///
  ///   Future<Response> verifyOtp(Map<String, dynamic> body) =>
  ///       _dio.post('/verify-otp', data: body);
  ///
  ///   Future<Response> resetPassword(Map<String, dynamic> body) =>
  ///       _dio.post('/reset-password', data: body);
  ///
  /// (Paths assume ApiClient's base URL already includes
  /// `https://neethu.astradevelops.in/ceramo/public/api` — adjust if not.)
  /// ---------------------------------------------------------------------

  /// POST /forgot-password — body: { "email": "..." }
  Future<AuthActionResult> forgotPassword(String email) async {
    return _postAuthAction(
      call: () => _apiClient.forgotPassword(
        ForgotPasswordRequest(email: email).toJson(),
      ),
    );
  }

  /// POST /verify-otp — body: { "email": "...", "otp": "..." }
  Future<AuthActionResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _postAuthAction(
      call: () => _apiClient.verifyOtp(
        VerifyOtpRequest(email: email, otp: otp).toJson(),
      ),
    );
  }

  /// POST /reset-password — body: { "email", "otp", "password",
  /// "password_confirmation" }
  Future<AuthActionResult> resetPassword(ResetPasswordRequest request) async {
    return _postAuthAction(
      call: () => _apiClient.resetPassword(request.toJson()),
    );
  }

  /// Shared request/parse/error-handling logic for the three forgot-password
  /// calls — they all return the same envelope, so this is the one place
  /// that needs to change if that ever stops being true.
  Future<AuthActionResult> _postAuthAction({
    required Future<Response> Function() call,
  }) async {
    try {
      final response = await call();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = AuthActionResponseModel.fromJson(response.data);
        return AuthActionResult(
          success: parsed.isSuccess,
          message: parsed.message,
        );
      }
      return AuthActionResult(
        success: false,
        message: response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return AuthActionResult(success: false, message: message);
    } catch (_) {
      return const AuthActionResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}