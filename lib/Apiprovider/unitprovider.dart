
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/uintmodel.dart';

class UnitListResult {
  final bool success;
  final UnitGetResponseModel? data;
  final String? errorMessage;

  const UnitListResult.success(this.data)
      : success = true,
        errorMessage = null;

  const UnitListResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class UnitActionResult {
  final bool success;
  final String? message;

  const UnitActionResult({
    required this.success,
    this.message,
  });
}

class UnitProvider {
  final ApiClient _apiClient;

  UnitProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /units
  Future<UnitListResult> getUnitsProvider() async {
    try {
      final response = await _apiClient.units();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = UnitGetResponseModel.fromJson(response.data);
        return UnitListResult.success(parsed);
      }
      return UnitListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return UnitListResult.failure(message);
    }
  }

  /// POST /units
  Future<UnitActionResult> addUnitProvider(UnitAddRequestModel request) => _actionCall(
        () => _apiClient.addUnit(request.toJson()),
  );

  /// POST /units/update — response only has status/message, reuse
  /// UnitAddResponseModel's shape since it's the exact same {status, message}.
  Future<UnitActionResult> updateUnitProvider(UnitUpdateRequestModel request) => _actionCall(
        () => _apiClient.updateUnit(request.toJson()),
  );

  /// POST /units/delete — same {status, message}-only shape.
  Future<UnitActionResult> deleteUnitProvider(UnitDeleteRequestModel request) => _actionCall(
        () => _apiClient.deleteUnit(request.toJson()),
  );

  /// Shared response handling for /units, /units/update and /units/delete
  /// — all three return the same {status, message} envelope, parsed via
  /// [UnitAddResponseModel].
  Future<UnitActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = UnitAddResponseModel.fromJson(response.data);
        return UnitActionResult(success: parsed.status == '1', message: parsed.message);
      }
      return UnitActionResult(success: false, message: response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return UnitActionResult(success: false, message: message);
    }
  }
}