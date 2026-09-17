import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/estimateitemremovalitemmodel.dart';

class EstimateItemActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const EstimateItemActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const EstimateItemActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class EstimateItemProvider {
  final ApiClient _apiClient;

  EstimateItemProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /estimates/remove-item
  ///
  /// The confirmed real response returns an empty `data: {}` on success —
  /// nothing to parse out of it beyond status/message. Callers should
  /// remove the item from their local item list themselves after a
  /// successful call rather than expect anything back in the result.
  Future<EstimateItemActionResult> removeItem({
    required String estimateId,
    required String estimateItemId,
  }) async {
    try {
      final response = await _apiClient.removeEstimateItem(
        EstimateRemoveItemRequest(
          estimateId: estimateId,
          estimateItemId: estimateItemId,
        ).toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = EstimateRemoveItemResponseModel.fromJson(response.data);
        return EstimateItemActionResult.success(parsed.message);
      }
      return EstimateItemActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return EstimateItemActionResult.failure(message);
    }
  }
}