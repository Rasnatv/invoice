import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/uintmodel.dart';

class UnitListResult {
  final bool success;
  final List<UnitModel> units;
  final String? errorMessage;
  final bool isUnauthorized;

  const UnitListResult.success(this.units)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const UnitListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        units = const [];
}

class UnitActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const UnitActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const UnitActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

class UnitProvider {
  final ApiClient _apiClient;

  UnitProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /units
  Future<UnitListResult> getUnits() async {
    try {
      final response = await _apiClient.units();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = UnitGetResponseModel.fromJson(body);
        if (parsed.status == '1') return UnitListResult.success(parsed.data);
        return UnitListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch units.',
        );
      }
      return UnitListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return UnitListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const UnitListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /units — data comes back empty, so only status/message are used.
  Future<UnitActionResult> addUnit(UnitAddRequestModel request) async {
    try {
      final response = await _apiClient.addUnit(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = UnitAddResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return UnitActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Unit created successfully.',
          );
        }
        return UnitActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to add unit.',
        );
      }
      return UnitActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return UnitActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const UnitActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /units/update
  Future<UnitActionResult> updateUnit(UnitUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateUnit(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return UnitActionResult.success(
            message.isNotEmpty ? message : 'Unit updated successfully.',
          );
        }
        return UnitActionResult.failure(
          message.isNotEmpty ? message : 'Failed to update unit.',
        );
      }
      return UnitActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return UnitActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const UnitActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /units/delete
  Future<UnitActionResult> deleteUnit(UnitDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteUnit(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return UnitActionResult.success(
            message.isNotEmpty ? message : 'Unit deleted successfully.',
          );
        }
        return UnitActionResult.failure(
          message.isNotEmpty ? message : 'Failed to delete unit.',
        );
      }
      return UnitActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return UnitActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const UnitActionResult.failure('Something went wrong. Please try again.');
    }
  }
}