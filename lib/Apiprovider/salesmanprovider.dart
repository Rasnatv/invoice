

import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/salesmanmodel.dart';

class SalesmanListResult {
  final bool success;
  final List<HSalesmanModel> salesmen;
  final String? errorMessage;
  final bool isUnauthorized;

  const SalesmanListResult.success(this.salesmen)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SalesmanListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        salesmen = const [];
}

class SalesmanActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const SalesmanActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SalesmanActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

class SalesmanProvider {
  final ApiClient _apiClient;

  SalesmanProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SalesmanListResult> getSalesmen() async {
    try {
      final response = await _apiClient.salesmen();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = SalesmanGetResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return SalesmanListResult.success(parsed.data);
        }
        return SalesmanListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch salesmen.',
        );
      }
      return SalesmanListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SalesmanListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SalesmanListResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<SalesmanActionResult> addSalesman(SalesmanAddRequestModel request) async {
    try {
      final response = await _apiClient.addSalesman(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return SalesmanActionResult.success(
            message.isNotEmpty ? message : 'Salesman added successfully.',
          );
        }
        return SalesmanActionResult.failure(
          message.isNotEmpty ? message : 'Failed to add salesman.',
        );
      }
      return SalesmanActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SalesmanActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SalesmanActionResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<SalesmanActionResult> updateSalesman(SalesmanUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateSalesman(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return SalesmanActionResult.success(
            message.isNotEmpty ? message : 'Salesman updated successfully.',
          );
        }
        return SalesmanActionResult.failure(
          message.isNotEmpty ? message : 'Failed to update salesman.',
        );
      }
      return SalesmanActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SalesmanActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SalesmanActionResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<SalesmanActionResult> deleteSalesman(SalesmanDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteSalesman(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString() ?? '0';
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return SalesmanActionResult.success(
            message.isNotEmpty ? message : 'Salesman removed successfully.',
          );
        }
        return SalesmanActionResult.failure(
          message.isNotEmpty ? message : 'Failed to delete salesman.',
        );
      }
      return SalesmanActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SalesmanActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SalesmanActionResult.failure('Something went wrong. Please try again.');
    }
  }
}