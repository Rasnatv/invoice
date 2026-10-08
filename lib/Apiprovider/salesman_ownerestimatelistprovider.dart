
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/salesmanmodels/salesmanownerestimatemodel.dart';
import '../models/salesmanmodels/salesmanownerresponseestimatemodel.dart';

class EstimateListResult {
  final bool success;
  final List<SalesmanowrEstimateModel> estimates;
  final String? errorMessage;

  const EstimateListResult.success(this.estimates)
      : success = true,
        errorMessage = null;

  const EstimateListResult.failure(this.errorMessage)
      : success = false,
        estimates = const [];
}

class SalesmanOwnerEstimateProvider {
  final ApiClient _apiClient;

  SalesmanOwnerEstimateProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /estimates/all?page=&per_page=
  Future<EstimateListResult> getEstimates({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.estimates(page: page, perPage: perPage);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse with the WRAPPER model (status/list/message),
        // never with the single-row SalesmanowrEstimateModel.
        final parsed =
        SalesmanownrEstimateListResponseModel.fromJson(response.data);
        return EstimateListResult.success(parsed.list);
      }
      return EstimateListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return EstimateListResult.failure(message);
    }
  }
}