
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/salesmanmodel.dart';

class SalesmanListResult {
  final bool success;
  final List<HSalesmanModel> salesmen;
  final String? errorMessage;

  const SalesmanListResult.success(this.salesmen)
      : success = true,
        errorMessage = null;

  const SalesmanListResult.failure(this.errorMessage)
      : success = false,
        salesmen = const [];
}

class SalesmanActionResult {
  final bool success;
  final String? message;

  const SalesmanActionResult({
    required this.success,
    this.message,
  });
}

class SalesmanProvider {
  final ApiClient _apiClient;

  SalesmanProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SalesmanListResult> getSalesmen() async {
    try {
      final response = await _apiClient.salesmen();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanGetResponseModel.fromJson(response.data);
        return SalesmanListResult.success(parsed.data);
      }
      return SalesmanListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanListResult.failure(message);
    }
  }

  Future<SalesmanActionResult> addSalesman(SalesmanAddRequestModel request) => _actionCall(
        () => _apiClient.addSalesman(request.toJson()),
  );

  Future<SalesmanActionResult> updateSalesman(SalesmanUpdateRequestModel request) => _actionCall(
        () => _apiClient.updateSalesman(request.toJson()),
  );

  Future<SalesmanActionResult> deleteSalesman(SalesmanDeleteRequestModel request) => _actionCall(
        () => _apiClient.deleteSalesman(request.toJson()),
  );

  /// Shared response handling for add/update/delete — all three report
  /// success via a body `status` field.
  Future<SalesmanActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        final status = body['status']?.toString();
        final message = body['message']?.toString();
        return SalesmanActionResult(success: status == '1', message: message);
      }
      return SalesmanActionResult(success: false, message: response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanActionResult(success: false, message: message);
    }
  }
}