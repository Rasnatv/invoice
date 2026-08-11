import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesman_dashboardmodel.dart';

class DashboardHomeFetchResult {
  final bool success;
  final DashboardHomeData data;
  final String? errorMessage;
  final bool isUnauthorized;

  const DashboardHomeFetchResult.success(this.data)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  DashboardHomeFetchResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        data = DashboardHomeData.empty();
}

class DashboardHomeApiProvider {
  final ApiClient _apiClient;

  DashboardHomeApiProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /dashboard
  Future<DashboardHomeFetchResult> getDashboard() async {
    try {
      // NOTE: add a `dashboard()` method to your ApiClient (same pattern as
      // `drivers()`) that hits GET /dashboard and returns the Response.
      final response = await _apiClient.dashboard();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = DashboardHomeApiResponse.fromJson(body);
        if (parsed.status == '1') return DashboardHomeFetchResult.success(parsed.data);
        return DashboardHomeFetchResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch dashboard.',
        );
      }
      return DashboardHomeFetchResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      // Returns a display message AND, on 401, clears the token and
      // pushes LoginScreen via AppRouter.navigatorKey.
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DashboardHomeFetchResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return DashboardHomeFetchResult.failure('Something went wrong. Please try again.');
    }
  }
}