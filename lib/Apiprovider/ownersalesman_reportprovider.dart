

import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/salesmanreportmodel.dart';


class SalesmanPerformanceReportResult {
  final bool success;
  final SalesmanPerformanceReportData? report;
  final String? errorMessage;

  const SalesmanPerformanceReportResult.success(this.report)
      : success = true,
        errorMessage = null;

  const SalesmanPerformanceReportResult.failure(this.errorMessage)
      : success = false,
        report = null;
}

class OwnerReportsProvider {
  final ApiClient _apiClient;

  OwnerReportsProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /reports/salesman-performance
  Future<SalesmanPerformanceReportResult> getSalesmanPerformanceReport(
      SalesmanPerformanceReportRequest request) async {
    try {
      final response = await _apiClient.salesmanPerformanceReport(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanPerformanceReportResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return SalesmanPerformanceReportResult.success(parsed.data);
        }
        return SalesmanPerformanceReportResult.failure(parsed.message);
      }
      return SalesmanPerformanceReportResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanPerformanceReportResult.failure(message);
    }
  }
}