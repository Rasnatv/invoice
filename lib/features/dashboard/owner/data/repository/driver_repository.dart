import 'package:dio/dio.dart';

import '../../../../../core/errors/apierrorhandler.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/dioclient.dart';
import '../model/add_drivermodel.dart';
import '../model/deletedrivermodel.dart';
import '../model/get_drivermodel.dart';
import '../model/update_drivermodel.dart';

class DriverException implements Exception {
  final String message;

  /// True when this came from a silent case (e.g. 401 redirect) and the
  /// UI should NOT show a snackbar for it.
  final bool silent;

  const DriverException(this.message, {this.silent = false});

  @override
  String toString() => message;
}

class DriverRepository {
  DriverRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _baseUrl = ApiConstants.baseUrl + '/drivers';

  Future<String> _errorFrom(DioException e) => ApiErrorHandler.handleDioError(e);

  /// GET /drivers
  Future<List<DriverGetModel>> getDrivers() async {
    try {
      final response = await _dio.get(_baseUrl);

      final body = response.data as Map<String, dynamic>;

      if (body['status'].toString() != '1') {
        throw DriverException(body['message'] ?? 'Failed to fetch drivers');
      }

      final data = body['data'] as List<dynamic>? ?? [];

      return data
          .map((e) => DriverGetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = await _errorFrom(e);
      throw DriverException(message, silent: message.isEmpty);
    }
  }

  /// POST /drivers
  Future<DriverAddResponseModel> addDriver(
      DriverAddRequestModel request,
      ) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: request.toJson(),
      );

      final body = response.data as Map<String, dynamic>;

      if (body['status'].toString() != '1') {
        throw DriverException(body['message'] ?? 'Failed to add driver');
      }

      return DriverAddResponseModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final message = await _errorFrom(e);
      throw DriverException(message, silent: message.isEmpty);
    }
  }

  /// PUT /drivers/update
  Future<void> updateDriver(
      DriverUpdateRequestModel request,
      ) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/update',
        data: request.toJson(),
      );

      final body = response.data as Map<String, dynamic>;

      if (body['status'].toString() != '1') {
        throw DriverException(body['message'] ?? 'Failed to update driver');
      }
    } on DioException catch (e) {
      final message = await _errorFrom(e);
      throw DriverException(message, silent: message.isEmpty);
    }
  }

  /// DELETE /drivers/delete
  Future<void> deleteDriver(
      DriverDeleteRequestModel request,
      ) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/delete',
        data: request.toJson(),
      );

      final body = response.data as Map<String, dynamic>;

      if (body['status'].toString() != '1') {
        throw DriverException(body['message'] ?? 'Failed to delete driver');
      }
    } on DioException catch (e) {
      final message = await _errorFrom(e);
      throw DriverException(message, silent: message.isEmpty);
    }
  }
}