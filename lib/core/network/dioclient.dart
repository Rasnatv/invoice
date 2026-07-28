import 'package:dio/dio.dart';
import 'api_constants.dart';

/// Single shared Dio instance for the whole app. If you later need to
/// attach the auth token to every request, add an Interceptor here
/// (e.g. reading it from secure storage) instead of setting headers
/// per-repository.
class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}