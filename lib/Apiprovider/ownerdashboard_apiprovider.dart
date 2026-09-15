
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesman_dashboardmodel.dart';

class OwnerDashboardFetchResult {
  final bool success;
  final DashboardHomeData data;
  final String? errorMessage;

  const OwnerDashboardFetchResult.success(this.data)
      : success = true,
        errorMessage = null;

  OwnerDashboardFetchResult.failure(this.errorMessage)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DashboardHomeApiResponse.fromJson(response.data);
        if (parsed.status == '1') return OwnerDashboardFetchResult.success(parsed.data);
        return OwnerDashboardFetchResult.failure(parsed.message);
      }
      return OwnerDashboardFetchResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerDashboardFetchResult.failure(message);
    }
  }
}