import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/ownergetallsitevisitmodel.dart';


class OwnerGetAllSiteVisitResult {
  final bool success;
  final SiteVisitsSummaryModel? data;
  final String? errorMessage;

  const OwnerGetAllSiteVisitResult.success(this.data)
      : success = true,
        errorMessage = null;

  const OwnerGetAllSiteVisitResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class OwnerGetAllSiteVisitProvider {
  final ApiClient _apiClient;

  OwnerGetAllSiteVisitProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /site-visits/all
  Future<OwnerGetAllSiteVisitResult> getAllSiteVisits() async {
    try {
      final response = await _apiClient.siteVisitsAll();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OwnerGetAllSiteVisitResult.success(
          SiteVisitsSummaryModel.fromJson(response.data['data'] as Map<String, dynamic>),
        );
      }
      return OwnerGetAllSiteVisitResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerGetAllSiteVisitResult.failure(message);
    }
  }
}