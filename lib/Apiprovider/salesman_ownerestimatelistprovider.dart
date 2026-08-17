import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesmanownerestimatemodel.dart';
import '../models/salesmanmodels/salesmanownerresponseestimatemodel.dart';

class EstimateListResult {
  final bool success;
  final List<SalesmanowrEstimateModel> estimates;
  final String? errorMessage;
  final bool isUnauthorized;

  const EstimateListResult.success(this.estimates)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const EstimateListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        estimates = const [];
}

// Renamed 'salesmanowrEstimateProvider' -> 'SalesmanOwnerEstimateProvider'
// to fix the UpperCamelCase lint. Update every place you instantiate this
// provider (bloc, DI setup, etc.) to use the new name.
class SalesmanOwnerEstimateProvider {
  final ApiClient _apiClient;

  SalesmanOwnerEstimateProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /estimates/all?page=&per_page=
  Future<EstimateListResult> getEstimates({int page = 1, int perPage = 100}) async {
    try {
      final response = await _apiClient.estimates(page: page, perPage: perPage);
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        // IMPORTANT: parse with the WRAPPER model (has status/list/message),
        // never with SalesmanowrEstimateModel (that's a single row and has
        // neither .list nor .message - that mismatch is what caused all
        // three analyzer errors).
        final parsed = SalesmanownrEstimateListResponseModel.fromJson(body);
        if (parsed.status == '1') return EstimateListResult.success(parsed.list);
        return EstimateListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch estimates.',
        );
      }
      return EstimateListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return EstimateListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const EstimateListResult.failure('Something went wrong. Please try again.');
    }
  }
}