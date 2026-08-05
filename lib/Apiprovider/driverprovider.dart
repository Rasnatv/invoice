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
  final bool isUnauthorized;

  const DriverListResult.success(this.drivers)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const DriverListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        drivers = const [];
}

class ActiveDriverListResult {
  final bool success;
  final List<ActiveDriverModel> drivers;
  final String? errorMessage;
  final bool isUnauthorized;

  const ActiveDriverListResult.success(this.drivers)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ActiveDriverListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        drivers = const [];
}

class DriverActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const DriverActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const DriverActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
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
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = DriverGetResponseModel.fromJson(body);
        if (parsed.status == '1') return DriverListResult.success(parsed.data);
        return DriverListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch drivers.',
        );
      }
      return DriverListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      // This both returns a display message AND, on 401, clears the
      // token and pushes LoginScreen via AppRouter.navigatorKey.
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DriverListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DriverListResult.failure('Something went wrong. Please try again.');
    }
  }


  /// POST /drivers
  Future<DriverActionResult> addDriver(DriverAddRequestModel request) async {
    try {
      final response = await _apiClient.addDriver(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = DriverAddResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return DriverActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Driver created successfully.',
          );
        }
        return DriverActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to add driver.',
        );
      }
      return DriverActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DriverActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DriverActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /drivers/update
  Future<DriverActionResult> updateDriver(DriverUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateDriver(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return DriverActionResult.success(
            message.isNotEmpty ? message : 'Driver updated successfully.',
          );
        }
        return DriverActionResult.failure(
          message.isNotEmpty ? message : 'Failed to update driver.',
        );
      }
      return DriverActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DriverActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DriverActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /drivers/delete
  Future<DriverActionResult> deleteDriver(DriverDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteDriver(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return DriverActionResult.success(
            message.isNotEmpty ? message : 'Driver removed successfully.',
          );
        }
        return DriverActionResult.failure(
          message.isNotEmpty ? message : 'Failed to delete driver.',
        );
      }
      return DriverActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DriverActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const DriverActionResult.failure('Something went wrong. Please try again.');
    }
  }
}