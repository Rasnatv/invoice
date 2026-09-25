
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/estmateitemupdatemodel.dart';
import '../models/owner_models/owner_estimateactionmodel.dart';
import '../models/owner_models/ownerestimate_updatemodel.dart';
import '../models/salesmanmodels/salesmanownerestimatemodel.dart';
import '../models/salesmanmodels/salesmanownerresponseestimatemodel.dart';
import '../models/salesmanmodels/estimatedetail.model.dart';


class OwnerEstimateListResult {
  final bool success;
  final List<SalesmanowrEstimateModel> estimates;
  final String? errorMessage;

  const OwnerEstimateListResult.success(this.estimates)
      : success = true,
        errorMessage = null;

  const OwnerEstimateListResult.failure(this.errorMessage)
      : success = false,
        estimates = const [];
}

class OwnerEstimateDetailResult {
  final bool success;
  final EstimateDetailModel? detail;
  final String? errorMessage;

  const OwnerEstimateDetailResult.success(this.detail)
      : success = true,
        errorMessage = null;

  const OwnerEstimateDetailResult.failure(this.errorMessage)
      : success = false,
        detail = null;
}

class OwnerActionResult {
  final bool success;
  final String? message;

  const OwnerActionResult({
    required this.success,
    this.message,
  });
}

/// Single provider for the owner's estimate list, detail, approve, reject
/// and update calls — mirrors SalesmanOwnerEstimateProvider / EstimateProvider
/// but adds the owner-only action endpoints.
class OwnerEstimateProvider {
  final ApiClient _apiClient;

  OwnerEstimateProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /estimates/all?page=&per_page=
  Future<OwnerEstimateListResult> getEstimates(
      {int page = 1, int perPage = 100}) async {
    try {
      final response = await _apiClient.estimates(page: page, perPage: perPage);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanownrEstimateListResponseModel.fromJson(
            response.data);
        return OwnerEstimateListResult.success(parsed.list);
      }
      return OwnerEstimateListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerEstimateListResult.failure(message);
    }
  }

  /// POST /estimates/show — body: { "id": "..." }
  Future<OwnerEstimateDetailResult> getEstimateDetail(String id) async {
    try {
      final response = await _apiClient.showEstimate({'id': id});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = EstimateDetailResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return OwnerEstimateDetailResult.success(parsed.data);
        }
        return OwnerEstimateDetailResult.failure(parsed.message);
      }
      return OwnerEstimateDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerEstimateDetailResult.failure(message);
    }
  }

  Future<OwnerEstimateDetailResult> updateEstimate(
      OwnerUpdateEstimateRequest request) async {
    try {
      final response = await _apiClient.updateEstimate(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        final parsed = EstimateDetailResponseModel.fromJson(body);

        // Body-level failure with an HTTP 200/201 wrapper — treat as a
        // real failure and surface the backend's message instead of
        // silently returning success(null).
        final bodyStatus = body is Map ? body['status']?.toString() : null;
        if (bodyStatus != null && bodyStatus != '1' && bodyStatus != 'true') {
          return OwnerEstimateDetailResult.failure(
            parsed.message ?? 'Update failed.',
          );
        }

        return OwnerEstimateDetailResult.success(parsed.data);
      }
      return OwnerEstimateDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerEstimateDetailResult.failure(message);
    }
  }


  /// POST /estimates/approve
  Future<OwnerActionResult> approveEstimate(
      OwnerApproveEstimateRequest request) =>
      _actionCall(
            () => _apiClient.approveEstimate(request.toJson()),
      );

  /// POST /quotations/reject
  Future<OwnerActionResult> rejectEstimate(
      OwnerRejectEstimateRequest request) =>
      _actionCall(
            () => _apiClient.rejectEstimate(request.toJson()),
      );

  /// Shared response handling for /estimates/approve and /quotations/reject
  /// — both return `{ status, message }`.
  Future<OwnerActionResult> _actionCall(
      Future<Response> Function() request,) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        final status = body['status']?.toString();
        final message = body['message']?.toString();
        return OwnerActionResult(success: status == '1', message: message);
      }
      return OwnerActionResult(
        success: false,
        message: response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerActionResult(success: false, message: message);
    }
  }

  /// POST /estimates/update-item — body: { estimate_id, estimate_item_id,
  /// quantity, rate, box_quantity, piece_quantity }. Updates a single
  /// saved line item without touching the rest of the estimate.
  Future<OwnerActionResult> updateItem({
    required String estimateId,
    required String estimateItemId,
    required double quantity,
    required double rate,
    double boxQuantity = 0,
    double pieceQuantity = 0,
  }) async {
    try {
      final request = UpdateEstimateItemRequest(
        estimateId: int.parse(estimateId),
        estimateItemId: int.parse(estimateItemId),
        quantity: quantity.toInt(),
        rate: rate,
        boxQuantity: boxQuantity.toInt(),
        pieceQuantity: pieceQuantity.toInt(),
      );

      debugPrint(
          'OwnerEstimateProvider.updateItem: PUT estimates/update-item -> ${request
              .toJson()}');

      final response = await _apiClient.updateEstimateItem(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = UpdateEstimateItemResponse.fromJson(response.data);
        debugPrint(
            'OwnerEstimateProvider.updateItem: response -> status=${parsed
                .status} message=${parsed.message}');
        return OwnerActionResult(
            success: parsed.isSuccess, message: parsed.message);
      }
      return OwnerActionResult(
          success: false, message: response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      debugPrint('OwnerEstimateProvider.updateItem: DioException -> $message');
      return OwnerActionResult(success: false, message: message);
    }
  }}