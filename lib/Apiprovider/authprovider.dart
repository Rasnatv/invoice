import 'package:dio/dio.dart';
import '../core/models/loginrequestmodel.dart';
import '../core/network/api_client.dart';
import 'package:tileshop/core/models/loginresponsemodel.dart';

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
      return AuthResult.failure(_messageFromDioException(e));
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  String _messageFromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Could not connect to server. Check your connection.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Something went wrong: ${e.message}';
    }
  }
}