

import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesman_dashboardmodel.dart';

class DashboardHomeFetchResult {
  final bool success;
  final DashboardHomeData data;
  final String? errorMessage;

  const DashboardHomeFetchResult.success(this.data)
      : success = true,
        errorMessage = null;

  DashboardHomeFetchResult.failure(this.errorMessage)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DashboardHomeApiResponse.fromJson(response.data);
        if (parsed.status == '1') return DashboardHomeFetchResult.success(parsed.data);
        return DashboardHomeFetchResult.failure(parsed.message);
      }
      return DashboardHomeFetchResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DashboardHomeFetchResult.failure(message);
    }
  }
}