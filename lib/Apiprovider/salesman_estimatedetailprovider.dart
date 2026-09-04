
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/estimatedetail.model.dart';

/// Result wrapper for POST /estimates/show.
class EstimateDetailResult {
  final bool success;
  final EstimateDetailModel? detail;
  final String? errorMessage;

  const EstimateDetailResult.success(this.detail)
      : success = true,
        errorMessage = null;

  const EstimateDetailResult.failure(this.errorMessage)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = EstimateDetailResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return EstimateDetailResult.success(parsed.data);
        }
        return EstimateDetailResult.failure(parsed.message);
      }
      return EstimateDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return EstimateDetailResult.failure(message);
    }
  }
}