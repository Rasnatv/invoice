
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

  const FieldStaffListResult.success(this.staff)
      : success = true,
        errorMessage = null;

  const FieldStaffListResult.failure(this.errorMessage)
      : success = false,
        staff = const [];
}

class FieldStaffActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const FieldStaffActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const FieldStaffActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

/// Replaces NewFieldStaffRepository. Same shape as DriverProvider: plain
/// result objects, no bloc/state logic.
class FieldStaffProvider {
  final ApiClient _apiClient;

  FieldStaffProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /field-staff
  Future<FieldStaffListResult> getFieldStaff({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.fieldStaff();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = FieldStaffListResponse.fromJson(response.data);
        return FieldStaffListResult.success(parsed.list);
      }
      return FieldStaffListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return FieldStaffListResult.failure(message);
    }
  }

  // ---------------- actions ----------------

  /// POST /field-staff
  /// NOTE: ApiClient doesn't have a create method yet — add this to it:
  ///   Future<Response> addFieldStaff(Map<String, dynamic> data) async =>
  ///       dio.post(ApiConstants.fieldStaff, data: data, options: await _authOptions());
  Future<FieldStaffActionResult> addFieldStaff(FieldStaffCreateModel request) => _actionCall(
        () => _apiClient.addFieldStaff(request.toJson()),
  );

  /// POST /field-staff/update
  Future<FieldStaffActionResult> updateFieldStaff(FieldStaffUpdateModel request) => _actionCall(
        () => _apiClient.updateFieldStaff(request.toJson()),
  );

  /// POST /field-staff/delete
  Future<FieldStaffActionResult> deleteFieldStaff(FieldStaffDeleteModel request) => _actionCall(
        () => _apiClient.deleteFieldStaff(request.toJson()),
  );

  /// Shared response handling for /field-staff, /field-staff/update and
  /// /field-staff/delete — all three just need a status-code check and the
  /// `message` field pulled off the body.
  Future<FieldStaffActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return FieldStaffActionResult.success(message);
      }
      return FieldStaffActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return FieldStaffActionResult.failure(message);
    }
  }
}