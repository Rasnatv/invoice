// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
//
// import '../models/owner_models/owner_viewquotationmodel.dart';
//
//
// class ownerviewQuotationListResult {
//   final bool success;
//   final List<OwnerviewQuotationModel> myQuotations;
//   final List<OwnerviewQuotationModel> salesmanQuotations;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const ownerviewQuotationListResult .success(this.myQuotations, this.salesmanQuotations)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const ownerviewQuotationListResult .failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         myQuotations = const [],
//         salesmanQuotations = const [];
// }
//
// class OwnerviewQuotationProvider {
//   final ApiClient _apiClient;
//
//   OwnerviewQuotationProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   /// GET /quotations/all?page=&per_page=
//   ///
//   /// NOTE: this assumes ApiClient exposes a `quotations` method, e.g.:
//   ///
//   ///   Future<Response> quotations({int page = 1, int perPage = 10}) {
//   ///     return _dio.get(
//   ///       ApiConstants.quotationsAll,
//   ///       queryParameters: {'page': page, 'per_page': perPage},
//   ///     );
//   ///   }
//   ///
//   /// Add that to your ApiClient/ApiConstants once you send those files -
//   /// happy to wire it exactly to match once I see them.
//   Future<ownerviewQuotationListResult > getQuotations({int page = 1, int perPage = 10}) async {
//     try {
//       final response = await _apiClient.quotations(page: page, perPage: perPage);
//       final body = response.data;
//
//       if (response.statusCode == 200 && body is Map<String, dynamic>) {
//         final parsed = QuotationListResponseModel.fromJson(body);
//         if (parsed.status == '1') {
//           return ownerviewQuotationListResult .success(
//             parsed.data.myQuotations,
//             parsed.data.salesmanQuotations,
//           );
//         }
//         return ownerviewQuotationListResult .failure(
//           parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch quotations.',
//         );
//       }
//       return ownerviewQuotationListResult .failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       // This both returns a display message AND, on 401, clears the
//       // token and pushes LoginScreen via AppRouter.navigatorKey.
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return ownerviewQuotationListResult .failure(
//         unauthorized ? null : message,
//         isUnauthorized: unauthorized,
//       );
//     } catch (_) {
//       return const ownerviewQuotationListResult .failure('Something went wrong. Please try again.');
//     }
//   }
//
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
  final bool isUnauthorized;

  const OwnerviewQuotationListResult.success(
      this.myQuotations,
      this.salesmanQuotations,
      )   : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const OwnerviewQuotationListResult.failure(
      this.errorMessage, {
        this.isUnauthorized = false,
      })  : success = false,
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
  final bool isUnauthorized;

  const QuotationUpdateResult({
    required this.success,
    this.message,
    this.errorMessage,
    this.isUnauthorized = false,
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

      final body = response.data;

      if (response.statusCode == 200 &&
          body is Map<String, dynamic>) {
        final parsed = QuotationListResponseModel.fromJson(body);

        if (parsed.status == '1') {
          return OwnerviewQuotationListResult.success(
            parsed.data.myQuotations,
            parsed.data.salesmanQuotations,
          );
        }

        return OwnerviewQuotationListResult.failure(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to fetch quotations.',
        );
      }

      return OwnerviewQuotationListResult.failure(
        'Unexpected response: ${response.statusCode}',
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);

      final unauthorized =
          e.response?.statusCode == 401;

      return OwnerviewQuotationListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const OwnerviewQuotationListResult.failure(
        'Something went wrong. Please try again.',
      );
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

      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status =
            body['status']?.toString() ?? '0';

        final message =
            body['message']?.toString() ?? '';

        // -------------------------------------------------------------
        // SUCCESS
        // -------------------------------------------------------------

        if (status == '1') {
          return QuotationUpdateResult(
            success: true,
            message: message.isNotEmpty
                ? message
                : 'Quotation updated successfully.',
          );
        }

        // -------------------------------------------------------------
        // API FAILURE
        // -------------------------------------------------------------

        return QuotationUpdateResult(
          success: false,
          errorMessage: message.isNotEmpty
              ? message
              : 'Failed to update quotation.',
        );
      }

      // ---------------------------------------------------------------
      // INVALID RESPONSE
      // ---------------------------------------------------------------

      return const QuotationUpdateResult(
        success: false,
        errorMessage: 'Unexpected response from server.',
      );
    } on DioException catch (e) {
      final message =
      await ApiErrorHandler.handleDioError(e);

      final unauthorized =
          e.response?.statusCode == 401;

      return QuotationUpdateResult(
        success: false,
        errorMessage: unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationUpdateResult(
        success: false,
        errorMessage:
        'Something went wrong. Please try again.',
      );
    }
  }
}