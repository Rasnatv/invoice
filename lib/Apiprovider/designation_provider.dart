
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/designationmodel.dart';


class DesignationListResult {
  final bool success;
  final List<DesignationModel> designations;
  final String? errorMessage;

  const DesignationListResult.success(this.designations)
      : success = true,
        errorMessage = null;

  const DesignationListResult.failure(this.errorMessage)
      : success = false,
        designations = const [];
}

class DesignationActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const DesignationActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const DesignationActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class DesignationProvider {
  final ApiClient _apiClient;

  DesignationProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /salesman-designations
  Future<DesignationListResult> getDesignations() async {
    try {
      final response = await _apiClient.salesmanDesignations();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DesignationListResponseModel.fromJson(response.data);
        return DesignationListResult.success(parsed.data);
      }
      return DesignationListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationListResult.failure(message);
    }
  }

  /// POST /salesman-designations/create
  Future<DesignationActionResult> addDesignation(DesignationAddRequestModel request) async {
    try {
      final response = await _apiClient.addDesignation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return DesignationActionResult.success(message);
      }
      return DesignationActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationActionResult.failure(message);
    }
  }

  /// POST /salesman-designations/update
  Future<DesignationActionResult> updateDesignation(DesignationUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateDesignation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return DesignationActionResult.success(message);
      }
      return DesignationActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationActionResult.failure(message);
    }
  }

  /// POST /salesman-designations/delete
  Future<DesignationActionResult> deleteDesignation(DesignationDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteDesignation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return DesignationActionResult.success(message);
      }
      return DesignationActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationActionResult.failure(message);
    }
  }
}