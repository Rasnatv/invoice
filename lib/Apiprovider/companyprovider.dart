//
// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
//
// import '../models/owner_models/addcompanymodel.dart';
//
// class CompanyListResult {
//   final bool success;
//   final List<CompanyModel> companies;
//   final String? errorMessage;
//
//   const CompanyListResult.success(this.companies)
//       : success = true,
//         errorMessage = null;
//
//   const CompanyListResult.failure(this.errorMessage)
//       : success = false,
//         companies = const [];
// }
//
// class CompanyActionResult {
//   final bool success;
//   final String? message;
//   final String? errorMessage;
//
//   const CompanyActionResult.success(this.message)
//       : success = true,
//         errorMessage = null;
//
//   const CompanyActionResult.failure(this.errorMessage)
//       : success = false,
//         message = null;
// }
//
// class CompanyProvider {
//   final ApiClient _apiClient;
//
//   CompanyProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   /// GET /companies
//   Future<CompanyListResult> getCompanies({int page = 1, int perPage = 20}) async {
//     try {
//       final response = await _apiClient.companies(page: page, perPage: perPage);
//       final body = response.data;
//
//       if ((response.statusCode == 200 || response.statusCode == 201) &&
//           body is Map<String, dynamic>) {
//         final parsed = CompanyGetResponseModel.fromJson(body);
//         return CompanyListResult.success(parsed.data);
//       }
//       return CompanyListResult.failure(response.statusCode.toString());
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       return CompanyListResult.failure(message);
//     }
//   }
//
//   /// POST /companies/create
//   ///
//   /// The confirmed real response returns an empty `data: {}` on success —
//   /// no id or company object comes back. Callers should reload the list
//   /// (e.g. dispatch LoadCompanies) after a successful add rather than try
//   /// to build a CompanyModel out of this result.
//   Future<CompanyActionResult> addCompany(CompanyModel company) async {
//     try {
//       final response = await _apiClient.addCompany(company.toCreateJson());
//       final body = response.data;
//
//       if ((response.statusCode == 200 || response.statusCode == 201) &&
//           body is Map<String, dynamic>) {
//         final parsed = CompanyActionResponseModel.fromJson(body);
//         return CompanyActionResult.success(parsed.message);
//       }
//       return CompanyActionResult.failure(response.statusCode.toString());
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       return CompanyActionResult.failure(message);
//     }
//   }
//
//   /// POST /companies/update
//   Future<CompanyActionResult> updateCompany(CompanyModel company) async {
//     try {
//       final response = await _apiClient.updateCompany(company.toUpdateJson());
//       final body = response.data;
//
//       if ((response.statusCode == 200 || response.statusCode == 201) &&
//           body is Map<String, dynamic>) {
//         final parsed = CompanyActionResponseModel.fromJson(body);
//         return CompanyActionResult.success(parsed.message);
//       }
//       return CompanyActionResult.failure(response.statusCode.toString());
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       return CompanyActionResult.failure(message);
//     }
//   }
//
//   /// POST /companies/delete
//   Future<CompanyActionResult> deleteCompany(String id) async {
//     try {
//       final response = await _apiClient.deleteCompany({'id': id});
//       final body = response.data;
//
//       if ((response.statusCode == 200 || response.statusCode == 201) &&
//           body is Map<String, dynamic>) {
//         final parsed = CompanyActionResponseModel.fromJson(body);
//         return CompanyActionResult.success(parsed.message);
//       }
//       return CompanyActionResult.failure(response.statusCode.toString());
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       return CompanyActionResult.failure(message);
//     }
//   }
// }

import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/addcompanymodel.dart';

class CompanyListResult {
  final bool success;
  final List<CompanyModel> companies;
  final String? errorMessage;

  const CompanyListResult.success(this.companies)
      : success = true,
        errorMessage = null;

  const CompanyListResult.failure(this.errorMessage)
      : success = false,
        companies = const [];
}

class CompanyActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const CompanyActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const CompanyActionResult.failure(this.errorMessage)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = CompanyGetResponseModel.fromJson(response.data);
        return CompanyListResult.success(parsed.data);
      }
      return CompanyListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return CompanyListResult.failure(message);
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = CompanyActionResponseModel.fromJson(response.data);
        return CompanyActionResult.success(parsed.message);
      }
      return CompanyActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return CompanyActionResult.failure(message);
    }
  }

  /// POST /companies/update
  Future<CompanyActionResult> updateCompany(CompanyModel company) async {
    try {
      final response = await _apiClient.updateCompany(company.toUpdateJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = CompanyActionResponseModel.fromJson(response.data);
        return CompanyActionResult.success(parsed.message);
      }
      return CompanyActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return CompanyActionResult.failure(message);
    }
  }

  /// POST /companies/delete
  Future<CompanyActionResult> deleteCompany(String id) async {
    try {
      final response = await _apiClient.deleteCompany({'id': id});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = CompanyActionResponseModel.fromJson(response.data);
        return CompanyActionResult.success(parsed.message);
      }
      return CompanyActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return CompanyActionResult.failure(message);
    }
  }
}