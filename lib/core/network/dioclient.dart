import 'package:dio/dio.dart';
import 'package:tileshop/core/network/tokenstorage.dart';
import 'api_constants.dart';

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
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.readToken();
        final tokenType = await TokenStorage.readTokenType();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = '${tokenType ?? 'Bearer'} $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        handler.next(error);
      },
    ),
  );
}
