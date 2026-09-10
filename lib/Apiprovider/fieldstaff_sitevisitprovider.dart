
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/fieldstaffmodels/fieldstaffshowsitevisitmodel.dart';
import '../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';
import '../models/fieldstaffmodels/sitevisitdeletemodel.dart';
import '../models/fieldstaffmodels/sitevisitupdatemodel.dart';

class SiteVisitListResult {
  final bool success;
  final SiteVisitMyDataModel data;
  final String? errorMessage;

  const SiteVisitListResult.success(this.data)
      : success = true,
        errorMessage = null;

  const SiteVisitListResult.failure(this.errorMessage)
      : success = false,
        data = SiteVisitMyDataModel.empty;
}

class SiteVisitDetailResult {
  final bool success;
  final SiteVisitDetailModel? detail;
  final String? errorMessage;

  const SiteVisitDetailResult.success(this.detail)
      : success = true,
        errorMessage = null;

  const SiteVisitDetailResult.failure(this.errorMessage)
      : success = false,
        detail = null;
}

class SiteVisitActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const SiteVisitActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const SiteVisitActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class SiteVisitProvider {
  final ApiClient _apiClient;

  SiteVisitProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /site-visits/my
  Future<SiteVisitListResult> getMySiteVisits() async {
    try {
      final response = await _apiClient.mySiteVisits();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SiteVisitMyResponseModel.fromJson(response.data);
        return SiteVisitListResult.success(parsed.data);
      }
      return SiteVisitListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SiteVisitListResult.failure(message);
    }
  }

  /// POST /site-visits/show
  Future<SiteVisitDetailResult> showSiteVisit(SiteVisitShowRequestModel request) async {
    try {
      final response = await _apiClient.showSiteVisit(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SiteVisitShowResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return SiteVisitDetailResult.success(parsed.data);
        }
        return SiteVisitDetailResult.failure(parsed.message);
      }
      return SiteVisitDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SiteVisitDetailResult.failure(message);
    }
  }

  // ---------------- actions ----------------

  /// POST /site-visits/create
  Future<SiteVisitActionResult> createSiteVisit(SiteVisitCreateRequestModel request) => _actionCall(
        () => _apiClient.createSiteVisit(request.toJson()),
  );

  /// POST /site-visits/update
  Future<SiteVisitActionResult> updateSiteVisit(SiteVisitUpdateRequestModel request) => _actionCall(
        () => _apiClient.updateSiteVisit(request.toJson()),
  );

  /// POST /site-visits/delete
  Future<SiteVisitActionResult> deleteSiteVisit(SiteVisitDeleteRequestModel request) => _actionCall(
        () => _apiClient.deleteSiteVisit(request.toJson()),
  );

  /// Shared response handling for /site-visits/create, /update and
  /// /delete — all three return the same envelope shape, parsed via
  /// [SiteVisitActionResponseModel].
  Future<SiteVisitActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SiteVisitActionResponseModel.fromJson(response.data);
        return SiteVisitActionResult.success(parsed.message);
      }
      return SiteVisitActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SiteVisitActionResult.failure(message);
    }
  }
}