import 'package:dio/dio.dart';
import '../../../core/errors/apierrorhandler.dart';
import '../../../core/models/loginmodel.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dioclient.dart';

/// Thrown for any login failure — bad credentials, server error, or
/// network failure. `message` is already user-friendly (built by
/// ApiErrorHandler) and safe to show directly via AppSnackbar.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Talks to the /login endpoint via the shared Dio client. The bloc
/// depends on this, not on Dio directly, so networking can be swapped
/// or mocked in tests.
class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<LoginData> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (loginResponse.isSuccess && loginResponse.data != null) {
        return loginResponse.data!;
      }

      throw AuthException(
        loginResponse.message.isNotEmpty ? loginResponse.message : 'Login failed',
      );
    } on DioException catch (e) {
      throw AuthException(ApiErrorHandler.handleDioError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Unexpected response from server.');
    }
  }
}