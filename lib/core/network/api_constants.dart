/// Base URL + endpoint paths. baseUrl is consumed by DioClient's
/// BaseOptions, so every endpoint below is a relative path.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://neethu.astradevelops.in/ceramo/public/api';

  static const String login = '/login';

// Add future endpoints here, e.g.:
// static const String logout = '/logout';
// static const String profile = '/profile';
}