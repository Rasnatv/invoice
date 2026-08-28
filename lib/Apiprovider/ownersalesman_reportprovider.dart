import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/salesmanreportmodel.dart';


class SalesmanPerformanceReportResult {
  final bool success;
  final SalesmanPerformanceReportData? report;
  final String? errorMessage;
  final bool isUnauthorized;

  const SalesmanPerformanceReportResult.success(this.report)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SalesmanPerformanceReportResult.failure(this.errorMessage, {this.isUnauthorized = false})
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
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = SalesmanPerformanceReportResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return SalesmanPerformanceReportResult.success(parsed.data);
        }
        return SalesmanPerformanceReportResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch salesman report.',
        );
      }
      return SalesmanPerformanceReportResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SalesmanPerformanceReportResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SalesmanPerformanceReportResult.failure('Something went wrong. Please try again.');
    }
  }
}