import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/addcompanymodel.dart';

class CompanyListResult {
  final bool success;
  final List<CompanyModel> companies;
  final String? errorMessage;
  final bool isUnauthorized;

  const CompanyListResult.success(this.companies)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const CompanyListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        companies = const [];
}

class CompanyActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const CompanyActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const CompanyActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

class CompanyProvider {
  final ApiClient _apiClient;

  CompanyProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /companies
  Future<CompanyListResult> getCompanies({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.companies(page: page, perPage: perPage);
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = CompanyGetResponseModel.fromJson(body);
        if (parsed.status == '1') return CompanyListResult.success(parsed.data);
        return CompanyListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch companies.',
        );
      }
      return CompanyListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      // This both returns a display message AND, on 401, clears the
      // token and pushes LoginScreen via AppRouter.navigatorKey.
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return CompanyListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const CompanyListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /companies/create
  ///
  /// The confirmed real response returns an empty `data: {}` on success —
  /// no id or company object comes back. Callers should reload the list
  /// (e.g. dispatch LoadCompanies) after a successful add rather than try
  /// to build a CompanyModel out of this result.
  Future<CompanyActionResult> addCompany(CompanyModel company) async {
    try {
      final response = await _apiClient.addCompany(company.toCreateJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = CompanyActionResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return CompanyActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Company created successfully.',
          );
        }
        return CompanyActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to add company.',
        );
      }
      return CompanyActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return CompanyActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const CompanyActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /companies/update
  Future<CompanyActionResult> updateCompany(CompanyModel company) async {
    try {
      final response = await _apiClient.updateCompany(company.toUpdateJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = CompanyActionResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return CompanyActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Company updated successfully.',
          );
        }
        return CompanyActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to update company.',
        );
      }
      return CompanyActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return CompanyActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const CompanyActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /companies/delete
  Future<CompanyActionResult> deleteCompany(String id) async {
    try {
      final response = await _apiClient.deleteCompany({'id': id});
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = CompanyActionResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return CompanyActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Company deleted successfully.',
          );
        }
        return CompanyActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to delete company.',
        );
      }
      return CompanyActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return CompanyActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const CompanyActionResult.failure('Something went wrong. Please try again.');
    }
  }
}