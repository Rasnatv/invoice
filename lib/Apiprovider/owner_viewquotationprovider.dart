//
//
// import 'package:dio/dio.dart';
//
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
//
// import '../models/owner_models/owner_viewquotationmodel.dart';
// import '../models/salesmanmodels/quotationupdatemodel.dart';
//
//
// // =====================================================================
// // OWNER QUOTATION LIST RESULT
// // =====================================================================
//
// class OwnerviewQuotationListResult {
//   final bool success;
//
//   final List<OwnerviewQuotationModel> myQuotations;
//   final List<OwnerviewQuotationModel> salesmanQuotations;
//
//   final String? errorMessage;
//
//   const OwnerviewQuotationListResult.success(
//       this.myQuotations,
//       this.salesmanQuotations,
//       )   : success = true,
//         errorMessage = null;
//
//   const OwnerviewQuotationListResult.failure(
//       this.errorMessage,
//       )   : success = false,
//         myQuotations = const [],
//         salesmanQuotations = const [];
// }
//
//
// // =====================================================================
// // QUOTATION UPDATE RESULT
// // =====================================================================
//
// class QuotationUpdateResult {
//   final bool success;
//   final String? message;
//   final String? errorMessage;
//
//   const QuotationUpdateResult({
//     required this.success,
//     this.message,
//     this.errorMessage,
//   });
// }
//
//
// // =====================================================================
// // QUOTATION PROVIDER
// // =====================================================================
//
// class OwnerviewQuotationProvider {
//   final ApiClient _apiClient;
//
//   OwnerviewQuotationProvider({
//     ApiClient? apiClient,
//   }) : _apiClient = apiClient ?? ApiClient();
//
//
//   // ===================================================================
//   // GET ALL QUOTATIONS
//   // GET /quotations/all?page=&per_page=
//   // ===================================================================
//
//   Future<OwnerviewQuotationListResult> getQuotations({
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final response = await _apiClient.quotations(
//         page: page,
//         perPage: perPage,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final parsed = QuotationListResponseModel.fromJson(response.data);
//
//         return OwnerviewQuotationListResult.success(
//           parsed.data.myQuotations,
//           parsed.data.salesmanQuotations,
//         );
//       }
//
//       return OwnerviewQuotationListResult.failure(
//         response.statusCode.toString(),
//       );
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       return OwnerviewQuotationListResult.failure(message);
//     }
//   }
//
//
//   // ===================================================================
//   // UPDATE QUOTATION
//   // POST /quotations/update
//   // ===================================================================
//
//   Future<QuotationUpdateResult> updateQuotation(
//       QuotationUpdateRequest request,
//       ) async {
//     try {
//       final response = await _apiClient.updateQuotation(
//         request.toJson(),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final message = response.data['message']?.toString();
//
//         return QuotationUpdateResult(
//           success: true,
//           message: message,
//         );
//       }
//
//       return QuotationUpdateResult(
//         success: false,
//         errorMessage: response.statusCode.toString(),
//       );
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//
//       return QuotationUpdateResult(
//         success: false,
//         errorMessage: message,
//       );
//     }
//   }
// }
import 'package:dio/dio.dart';

import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/owner_viewquotationmodel.dart';
import '../models/salesmanmodels/quotationupdatemodel.dart';

// =====================================================================
// OWNER QUOTATION LIST RESULT
// =====================================================================

class OwnerviewQuotationListResult {
  final bool success;

  final List<OwnerviewQuotationModel> myQuotations;
  final List<OwnerviewQuotationModel> salesmanQuotations;

  final String? errorMessage;

  const OwnerviewQuotationListResult.success(
      this.myQuotations,
      this.salesmanQuotations,
      )   : success = true,
        errorMessage = null;

  const OwnerviewQuotationListResult.failure(
      this.errorMessage,
      )   : success = false,
        myQuotations = const [],
        salesmanQuotations = const [];
}

// =====================================================================
// QUOTATION UPDATE RESULT
// =====================================================================

class QuotationUpdateResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const QuotationUpdateResult({
    required this.success,
    this.message,
    this.errorMessage,
  });
}

// =====================================================================
// QUOTATION CANCEL RESULT
// =====================================================================

class QuotationCancelResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const QuotationCancelResult({
    required this.success,
    this.message,
    this.errorMessage,
  });
}

// =====================================================================
// QUOTATION PROVIDER
// =====================================================================

class OwnerviewQuotationProvider {
  final ApiClient _apiClient;

  OwnerviewQuotationProvider({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ===================================================================
  // GET ALL QUOTATIONS
  // GET /quotations/all?page=&per_page=
  // ===================================================================

  Future<OwnerviewQuotationListResult> getQuotations({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.quotations(
        page: page,
        perPage: perPage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = QuotationListResponseModel.fromJson(response.data);

        return OwnerviewQuotationListResult.success(
          parsed.data.myQuotations,
          parsed.data.salesmanQuotations,
        );
      }

      return OwnerviewQuotationListResult.failure(
        response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerviewQuotationListResult.failure(message);
    }
  }

  // ===================================================================
  // UPDATE QUOTATION
  // POST /quotations/update
  // ===================================================================

  Future<QuotationUpdateResult> updateQuotation(
      QuotationUpdateRequest request,
      ) async {
    try {
      final response = await _apiClient.updateQuotation(
        request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();

        return QuotationUpdateResult(
          success: true,
          message: message,
        );
      }

      return QuotationUpdateResult(
        success: false,
        errorMessage: response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);

      return QuotationUpdateResult(
        success: false,
        errorMessage: message,
      );
    }
  }

  // ===================================================================
  // CANCEL QUOTATION
  // POST /quotations/cancel — body: { id }
  //
  // Same success/failure shape as updateQuotation() above: checks the
  // HTTP status, pulls `message` straight off the raw response body on
  // success, and routes DioExceptions through ApiErrorHandler on failure.
  // `data` in the response is an empty object, so there's nothing else
  // to parse out of it.
  // ===================================================================

  Future<QuotationCancelResult> cancelQuotation(String id) async {
    try {
      final response = await _apiClient.cancelQuotation({'id': id});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();

        return QuotationCancelResult(
          success: true,
          message: message,
        );
      }

      return QuotationCancelResult(
        success: false,
        errorMessage: response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);

      return QuotationCancelResult(
        success: false,
        errorMessage: message,
      );
    }
  }
}