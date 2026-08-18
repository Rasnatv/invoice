import 'package:dio/dio.dart';
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
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final parsed = DespatchSuggestionResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return DespatchSuggestionResult.success(parsed.data);
        }
        return DespatchSuggestionResult.failure(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to fetch despatch suggestions.',
        );
      }
      return DespatchSuggestionResult.failure(
          'Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DespatchSuggestionResult.failure(
          message ?? 'Failed to fetch despatch suggestions.');
    } catch (_) {
      return const DespatchSuggestionResult.failure(
          'Something went wrong. Please try again.');
    }
  }

  /// GET /drivers/active
  Future<DriverListResult> getActiveDrivers() async {
    try {
      final response = await _apiClient.activeDrivers();
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final parsed = DriverListResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return DriverListResult.success(parsed.list);
        }
        return DriverListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch drivers.',
        );
      }
      return DriverListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DriverListResult.failure(message ?? 'Failed to fetch drivers.');
    } catch (_) {
      return const DriverListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /despatches/create
  Future<OwnerDespatchActionResult> createDespatch(
      OwnerDespatchCreateRequest request) async {
    try {
      final response = await _apiClient.createDespatch(request.toJson());
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return OwnerDespatchActionResult(
            success: true,
            message: message.isNotEmpty ? message : 'Despatch sheet created successfully.',
          );
        }
        return OwnerDespatchActionResult(
          success: false,
          message: message.isNotEmpty ? message : 'Failed to create despatch sheet.',
        );
      }
      return const OwnerDespatchActionResult(
          success: false, message: 'Unexpected response from server.');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerDespatchActionResult(
          success: false, message: message ?? 'Failed to create despatch sheet.');
    } catch (_) {
      return const OwnerDespatchActionResult(
          success: false, message: 'Something went wrong. Please try again.');
    }
  }
}