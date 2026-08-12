import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/estimatedetail.model.dart';

/// Result wrapper for POST /estimates/show.
class EstimateDetailResult {
  final bool success;
  final EstimateDetailModel? detail;
  final String? errorMessage;
  final bool isUnauthorized;

  const EstimateDetailResult.success(this.detail)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const EstimateDetailResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        detail = null;
}

class EstimateProvider {
  final ApiClient _apiClient;

  EstimateProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /estimates/show — full detail of a single estimate. Body: { "id": "..." }
  Future<EstimateDetailResult> getEstimateDetail(String id) async {
    try {
      final response = await _apiClient.showEstimate({'id': id});
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = EstimateDetailResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return EstimateDetailResult.success(parsed.data);
        }
        return EstimateDetailResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch estimate.',
        );
      }
      return EstimateDetailResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return EstimateDetailResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const EstimateDetailResult.failure('Something went wrong. Please try again.');
    }
  }
}