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
  final bool isUnauthorized;

  const SiteVisitListResult.success(this.data)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SiteVisitListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        data = SiteVisitMyDataModel.empty;
}

class SiteVisitDetailResult {
  final bool success;
  final SiteVisitDetailModel? detail;
  final String? errorMessage;
  final bool isUnauthorized;

  const SiteVisitDetailResult.success(this.detail)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SiteVisitDetailResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        detail = null;
}

class SiteVisitActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const SiteVisitActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SiteVisitActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
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
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = SiteVisitMyResponseModel.fromJson(body);
        if (parsed.status == '1') return SiteVisitListResult.success(parsed.data);
        return SiteVisitListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch site visits.',
        );
      }
      return SiteVisitListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SiteVisitListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SiteVisitListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /site-visits/show
  Future<SiteVisitDetailResult> showSiteVisit(SiteVisitShowRequestModel request) async {
    try {
      final response = await _apiClient.showSiteVisit(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = SiteVisitShowResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return SiteVisitDetailResult.success(parsed.data);
        }
        return SiteVisitDetailResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch visit details.',
        );
      }
      return SiteVisitDetailResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SiteVisitDetailResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SiteVisitDetailResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /site-visits/create
  Future<SiteVisitActionResult> createSiteVisit(SiteVisitCreateRequestModel request) async {
    try {
      final response = await _apiClient.createSiteVisit(request.toJson());
      return _handleActionResponse(
        response.data,
        response.statusCode,
        'Visit created successfully.',
        'Failed to create visit.',
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SiteVisitActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SiteVisitActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /site-visits/update
  Future<SiteVisitActionResult> updateSiteVisit(SiteVisitUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateSiteVisit(request.toJson());
      return _handleActionResponse(
        response.data,
        response.statusCode,
        'Visit updated successfully.',
        'Failed to update visit.',
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SiteVisitActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SiteVisitActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /site-visits/delete
  Future<SiteVisitActionResult> deleteSiteVisit(SiteVisitDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteSiteVisit(request.toJson());
      return _handleActionResponse(
        response.data,
        response.statusCode,
        'Visit deleted successfully.',
        'Failed to delete visit.',
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SiteVisitActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SiteVisitActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// create / update / delete all return the same
  /// {status, status_code, data: {}, message} envelope, so they share
  /// this parsing path.
  SiteVisitActionResult _handleActionResponse(
      dynamic body,
      int? statusCode,
      String defaultSuccessMessage,
      String defaultFailureMessage,
      ) {
    if (body is Map<String, dynamic>) {
      final parsed = SiteVisitActionResponseModel.fromJson(body);
      if (parsed.isSuccess) {
        return SiteVisitActionResult.success(
          parsed.message.isNotEmpty ? parsed.message : defaultSuccessMessage,
        );
      }
      return SiteVisitActionResult.failure(
        parsed.message.isNotEmpty ? parsed.message : defaultFailureMessage,
      );
    }
    return SiteVisitActionResult.failure('Unexpected response: $statusCode');
  }
}