import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/designationmodel.dart';


class DesignationListResult {
  final bool success;
  final List<DesignationModel> designations;
  final String? errorMessage;
  final bool isUnauthorized;

  const DesignationListResult.success(this.designations)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const DesignationListResult.failure(this.errorMessage,
      {this.isUnauthorized = false})
      : success = false,
        designations = const [];
}

class DesignationActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const DesignationActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const DesignationActionResult.failure(this.errorMessage,
      {this.isUnauthorized = false})
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
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = DesignationListResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return DesignationListResult.success(parsed.data);
        }
        return DesignationListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch designations.',
        );
      }
      return DesignationListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DesignationListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DesignationListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /salesman-designations/create
  Future<DesignationActionResult> addDesignation(DesignationAddRequestModel request) async {
    try {
      final response = await _apiClient.addDesignation(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return DesignationActionResult.success(
            message.isNotEmpty ? message : 'Designation created successfully.',
          );
        }
        return DesignationActionResult.failure(
          message.isNotEmpty ? message : 'Failed to create designation.',
        );
      }
      return DesignationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DesignationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DesignationActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /salesman-designations/update
  Future<DesignationActionResult> updateDesignation(DesignationUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateDesignation(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return DesignationActionResult.success(
            message.isNotEmpty ? message : 'Designation updated successfully.',
          );
        }
        return DesignationActionResult.failure(
          message.isNotEmpty ? message : 'Failed to update designation.',
        );
      }
      return DesignationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DesignationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DesignationActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /salesman-designations/delete
  Future<DesignationActionResult> deleteDesignation(DesignationDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteDesignation(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return DesignationActionResult.success(
            message.isNotEmpty ? message : 'Designation deleted successfully.',
          );
        }
        return DesignationActionResult.failure(
          message.isNotEmpty ? message : 'Failed to delete designation.',
        );
      }
      return DesignationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DesignationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DesignationActionResult.failure('Something went wrong. Please try again.');
    }
  }
}