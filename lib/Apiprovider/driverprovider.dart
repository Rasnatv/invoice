
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/activedrivermodel.dart';
import '../models/owner_models/add_drivermodel.dart';
import '../models/owner_models/deletedrivermodel.dart';
import '../models/owner_models/get_drivermodel.dart';
import '../models/owner_models/update_drivermodel.dart';

class DriverListResult {
  final bool success;
  final List<DriverGetModel> drivers;
  final String? errorMessage;

  const DriverListResult.success(this.drivers)
      : success = true,
        errorMessage = null;

  const DriverListResult.failure(this.errorMessage)
      : success = false,
        drivers = const [];
}

class ActiveDriverListResult {
  final bool success;
  final List<ActiveDriverModel> drivers;
  final String? errorMessage;

  const ActiveDriverListResult.success(this.drivers)
      : success = true,
        errorMessage = null;

  const ActiveDriverListResult.failure(this.errorMessage)
      : success = false,
        drivers = const [];
}

class DriverActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const DriverActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const DriverActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class DriverProvider {
  final ApiClient _apiClient;

  DriverProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /drivers
  Future<DriverListResult> getDrivers() async {
    try {
      final response = await _apiClient.drivers();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DriverGetResponseModel.fromJson(response.data);
        return DriverListResult.success(parsed.data);
      }
      return DriverListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DriverListResult.failure(message);
    }
  }

  /// POST /drivers
  Future<DriverActionResult> addDriver(DriverAddRequestModel request) => _actionCall(
        () => _apiClient.addDriver(request.toJson()),
        (data) => DriverAddResponseModel.fromJson(data).message,
  );

  /// POST /drivers/update
  Future<DriverActionResult> updateDriver(DriverUpdateRequestModel request) => _actionCall(
        () => _apiClient.updateDriver(request.toJson()),
        (data) => data['message']?.toString(),
  );

  /// POST /drivers/delete
  Future<DriverActionResult> deleteDriver(DriverDeleteRequestModel request) => _actionCall(
        () => _apiClient.deleteDriver(request.toJson()),
        (data) => data['message']?.toString(),
  );

  /// Shared response handling for /drivers, /drivers/update and
  /// /drivers/delete — all three just need a status-code check and a
  /// message extracted from the body, so the only thing that varies
  /// between callers is how the message is pulled out of [data].
  Future<DriverActionResult> _actionCall(
      Future<Response> Function() request,
      String? Function(Map<String, dynamic> data) extractMessage,
      ) async {
    try {
      final response = await request();
      final body = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        return DriverActionResult.success(extractMessage(body));
      }
      return DriverActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DriverActionResult.failure(message);
    }
  }
}