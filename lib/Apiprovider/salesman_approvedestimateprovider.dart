
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesmanapprovedbillsmodel.dart';

/// Result wrapper for GET /estimates/myapproved.
class ApprovedEstimateListResult {
  final bool success;
  final List<ApprovedEstimateListItem> list;
  final String? errorMessage;

  const ApprovedEstimateListResult.success(this.list)
      : success = true,
        errorMessage = null;

  const ApprovedEstimateListResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

class ApprovedEstimateProvider {
  final ApiClient _apiClient;

  ApprovedEstimateProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /estimates/myapproved?page=&per_page=
  Future<ApprovedEstimateListResult> getMyApprovedEstimates({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.myApprovedEstimates(page: page, perPage: perPage);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ApprovedEstimateListResponseModel.fromJson(response.data);
        return ApprovedEstimateListResult.success(parsed.list);
      }
      return ApprovedEstimateListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ApprovedEstimateListResult.failure(message);
    }
  }
}