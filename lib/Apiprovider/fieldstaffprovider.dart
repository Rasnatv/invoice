import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/fieldstaff_getmodel.dart';
import '../models/owner_models/fieldstaff_cretaemodel.dart';
import '../models/owner_models/fieldstaff_updatemodel.dart';
import '../models/owner_models/fieldstaff_deletemodel.dart';

class FieldStaffListResult {
  final bool success;
  final List<FieldStaffModel> staff;
  final String? errorMessage;
  final bool isUnauthorized;

  const FieldStaffListResult.success(this.staff)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const FieldStaffListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        staff = const [];
}

class FieldStaffActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const FieldStaffActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const FieldStaffActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

/// Replaces NewFieldStaffRepository. Same shape as DriverProvider: plain
/// result objects, no bloc/state logic. On 401, ApiErrorHandler.handleDioError
/// already clears the token and redirects to login, so isUnauthorized lets
/// the bloc skip showing a redundant error message.
class FieldStaffProvider {
  final ApiClient _apiClient;

  FieldStaffProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /field-staff
  Future<FieldStaffListResult> getFieldStaff({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.fieldStaff();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = FieldStaffListResponse.fromJson(body);
        if (parsed.isSuccess) return FieldStaffListResult.success(parsed.list);
        return FieldStaffListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch field staff.',
        );
      }
      return FieldStaffListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return FieldStaffListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const FieldStaffListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /field-staff
  /// NOTE: ApiClient doesn't have a create method yet — add this to it:
  ///   Future<Response> addFieldStaff(Map<String, dynamic> data) async =>
  ///       dio.post(ApiConstants.fieldStaff, data: data, options: await _authOptions());
  Future<FieldStaffActionResult> addFieldStaff(FieldStaffCreateModel request) async {
    try {
      final response = await _apiClient.addFieldStaff(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return FieldStaffActionResult.success(
            message.isNotEmpty ? message : 'Field staff added successfully.',
          );
        }
        return FieldStaffActionResult.failure(
          message.isNotEmpty ? message : 'Failed to add field staff.',
        );
      }
      return FieldStaffActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return FieldStaffActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const FieldStaffActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /field-staff/update
  Future<FieldStaffActionResult> updateFieldStaff(FieldStaffUpdateModel request) async {
    try {
      final response = await _apiClient.updateFieldStaff(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return FieldStaffActionResult.success(
            message.isNotEmpty ? message : 'Field staff updated successfully.',
          );
        }
        return FieldStaffActionResult.failure(
          message.isNotEmpty ? message : 'Failed to update field staff.',
        );
      }
      return FieldStaffActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return FieldStaffActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const FieldStaffActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /field-staff/delete
  Future<FieldStaffActionResult> deleteFieldStaff(FieldStaffDeleteModel request) async {
    try {
      final response = await _apiClient.deleteFieldStaff(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return FieldStaffActionResult.success(
            message.isNotEmpty ? message : 'Field staff removed successfully.',
          );
        }
        return FieldStaffActionResult.failure(
          message.isNotEmpty ? message : 'Failed to delete field staff.',
        );
      }
      return FieldStaffActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return FieldStaffActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const FieldStaffActionResult.failure('Something went wrong. Please try again.');
    }
  }
}