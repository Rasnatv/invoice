import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesmanapprovedbillsmodel.dart';

/// Result wrapper for GET /estimates/myapproved.
class ApprovedEstimateListResult {
  final bool success;
  final List<ApprovedEstimateListItem> list;
  final String? errorMessage;
  final bool isUnauthorized;

  const ApprovedEstimateListResult.success(this.list)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ApprovedEstimateListResult.failure(this.errorMessage, {this.isUnauthorized = false})
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
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = ApprovedEstimateListResponseModel.fromJson(body);
        if (parsed.status == '1') return ApprovedEstimateListResult.success(parsed.list);
        return ApprovedEstimateListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch approved estimates.',
        );
      }
      return ApprovedEstimateListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ApprovedEstimateListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ApprovedEstimateListResult.failure('Something went wrong. Please try again.');
    }
  }
}