
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/ownerdespatchsheetpreparemodel.dart';

class DespatchSuggestionResult {
  final bool success;
  final DespatchSuggestionModel? data;
  final String? errorMessage;

  const DespatchSuggestionResult.success(this.data)
      : success = true,
        errorMessage = null;

  const DespatchSuggestionResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class DriverListResult {
  final bool success;
  final List<DriverModel> drivers;
  final String? errorMessage;

  const DriverListResult.success(this.drivers)
      : success = true,
        errorMessage = null;

  const DriverListResult.failure(this.errorMessage)
      : success = false,
        drivers = const [];
}

class OwnerDespatchActionResult {
  final bool success;
  final String? message;

  const OwnerDespatchActionResult({
    required this.success,
    this.message,
  });
}

/// Handles the owner-side despatch flow: fetching quantity suggestions for
/// an approved estimate, fetching the active driver list, and creating the
/// despatch sheet itself.
///
/// NOTE: the three ApiClient methods below (despatchSuggest, activeDrivers,
/// createDespatch) need to be added to ApiClient — mirroring the pattern of
/// showEstimate/approveEstimate/rejectEstimate already there. I don't have
/// api_client.dart's contents, so wire these in there:
///
///   Future<Response> despatchSuggest(Map<String, dynamic> body) =>
///       _dio.post('/despatches/suggest', data: body);
///
///   Future<Response> activeDrivers() => _dio.get('/drivers/active');
///
///   Future<Response> createDespatch(Map<String, dynamic> body) =>
///       _dio.post('/despatches/create', data: body);
class OwnerDespatchProvider {
  final ApiClient _apiClient;

  OwnerDespatchProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// POST /despatches/suggest — body: { "estimate_id": "..." }
  Future<DespatchSuggestionResult> getSuggestion(String estimateId) async {
    try {
      final response =
      await _apiClient.despatchSuggest({'estimate_id': estimateId});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DespatchSuggestionResponseModel.fromJson(response.data);
        if (parsed.status == '1' && parsed.data != null) {
          return DespatchSuggestionResult.success(parsed.data);
        }
        return DespatchSuggestionResult.failure(parsed.message);
      }
      return DespatchSuggestionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DespatchSuggestionResult.failure(message);
    }
  }

  /// GET /drivers/active
  Future<DriverListResult> getActiveDrivers() async {
    try {
      final response = await _apiClient.activeDrivers();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DriverListResponseModel.fromJson(response.data);
        debugPrint('DRIVERS ACTIVE >>> status=${response.statusCode} body=${response.data}');
        if (parsed.status == '1') {
          return DriverListResult.success(parsed.list);
        }
        return DriverListResult.failure(parsed.message);
      }
      return DriverListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DriverListResult.failure(message);
    }
  }

  /// POST /despatches/create
  Future<OwnerDespatchActionResult> createDespatch(
      OwnerDespatchCreateRequest request) async {
    try {
      final response = await _apiClient.createDespatch(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString();
        return OwnerDespatchActionResult(
          success: status == '1',
          message: message,
        );
      }
      return OwnerDespatchActionResult(
        success: false,
        message: response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerDespatchActionResult(success: false, message: message);
    }
  }
}