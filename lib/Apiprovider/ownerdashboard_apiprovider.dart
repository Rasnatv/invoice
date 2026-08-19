import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesman_dashboardmodel.dart';

class OwnerDashboardFetchResult {
  final bool success;
  final DashboardHomeData data;
  final String? errorMessage;
  final bool isUnauthorized;

  const OwnerDashboardFetchResult.success(this.data)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  OwnerDashboardFetchResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        data = DashboardHomeData.empty();
}

class OwnerDashboardApiProvider {
  final ApiClient _apiClient;

  OwnerDashboardApiProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /owner/dashboard
  ///
  /// NOTE: add an `ownerDashboard()` method to your ApiClient — same
  /// pattern as `dashboard()`, but hitting the owner-scoped endpoint
  /// (adjust the path below to whatever your backend actually exposes,
  /// e.g. '/owner/dashboard' vs a query param on the shared endpoint):
  ///
  ///   Future<Response> ownerDashboard() => _dio.get('/owner/dashboard');
  Future<OwnerDashboardFetchResult> getDashboard() async {
    try {
      final response = await _apiClient.dashboard();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = DashboardHomeApiResponse.fromJson(body);
        if (parsed.status == '1') return OwnerDashboardFetchResult.success(parsed.data);
        return OwnerDashboardFetchResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch dashboard.',
        );
      }
      return OwnerDashboardFetchResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return OwnerDashboardFetchResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return OwnerDashboardFetchResult.failure('Something went wrong. Please try again.');
    }
  }
}