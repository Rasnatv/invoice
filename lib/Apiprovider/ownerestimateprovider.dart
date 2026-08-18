import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/owner_estimateactionmodel.dart';
import '../models/salesmanmodels/salesmanownerestimatemodel.dart';
import '../models/salesmanmodels/salesmanownerresponseestimatemodel.dart';
import '../models/salesmanmodels/estimatedetail.model.dart';


class OwnerEstimateListResult {
  final bool success;
  final List<SalesmanowrEstimateModel> estimates;
  final String? errorMessage;
  final bool isUnauthorized;

  const OwnerEstimateListResult.success(this.estimates)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const OwnerEstimateListResult.failure(this.errorMessage,
      {this.isUnauthorized = false})
      : success = false,
        estimates = const [];
}

class OwnerEstimateDetailResult {
  final bool success;
  final EstimateDetailModel? detail;
  final String? errorMessage;
  final bool isUnauthorized;

  const OwnerEstimateDetailResult.success(this.detail)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const OwnerEstimateDetailResult.failure(this.errorMessage,
      {this.isUnauthorized = false})
      : success = false,
        detail = null;
}

/// Single provider for the owner's estimate list, detail, approve and
/// reject calls — mirrors SalesmanOwnerEstimateProvider / EstimateProvider
/// but adds the two owner-only action endpoints.
class OwnerEstimateProvider {
  final ApiClient _apiClient;

  OwnerEstimateProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /estimates/all?page=&per_page=
  Future<OwnerEstimateListResult> getEstimates(
      {int page = 1, int perPage = 100}) async {
    try {
      final response = await _apiClient.estimates(page: page, perPage: perPage);
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = SalesmanownrEstimateListResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return OwnerEstimateListResult.success(parsed.list);
        }
        return OwnerEstimateListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch estimates.',
        );
      }
      return OwnerEstimateListResult.failure(
          'Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return OwnerEstimateListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const OwnerEstimateListResult.failure(
          'Something went wrong. Please try again.');
    }
  }

  /// POST /estimates/show — body: { "id": "..." }
  Future<OwnerEstimateDetailResult> getEstimateDetail(String id) async {
    try {
      final response = await _apiClient.showEstimate({'id': id});
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = EstimateDetailResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return OwnerEstimateDetailResult.success(parsed.data);
        }
        return OwnerEstimateDetailResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch estimate.',
        );
      }
      return OwnerEstimateDetailResult.failure(
          'Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return OwnerEstimateDetailResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const OwnerEstimateDetailResult.failure(
          'Something went wrong. Please try again.');
    }
  }

  /// POST /estimates/approve
  Future<OwnerActionResult> approveEstimate(
      OwnerApproveEstimateRequest request) async {
    try {
      final response = await _apiClient.approveEstimate(request.toJson());
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return OwnerActionResult(
            success: true,
            message: message.isNotEmpty ? message : 'Estimate approved successfully.',
          );
        }
        return OwnerActionResult(
          success: false,
          message: message.isNotEmpty ? message : 'Failed to approve estimate.',
        );
      }
      return const OwnerActionResult(
          success: false, message: 'Unexpected response from server.');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerActionResult(
          success: false, message: message ?? 'Failed to approve estimate.');
    } catch (_) {
      return const OwnerActionResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/reject
  Future<OwnerActionResult> rejectEstimate(
      OwnerRejectEstimateRequest request) async {
    try {
      final response = await _apiClient.rejectEstimate(request.toJson());
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return OwnerActionResult(
            success: true,
            message: message.isNotEmpty ? message : 'Estimate rejected successfully.',
          );
        }
        return OwnerActionResult(
          success: false,
          message: message.isNotEmpty ? message : 'Failed to reject estimate.',
        );
      }
      return const OwnerActionResult(
          success: false, message: 'Unexpected response from server.');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerActionResult(
          success: false, message: message ?? 'Failed to reject estimate.');
    } catch (_) {
      return const OwnerActionResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }
}