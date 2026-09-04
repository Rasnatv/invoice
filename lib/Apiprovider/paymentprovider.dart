// // lib/providers/payment_provider.dart
//
// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
// import '../models/owner_models/paymentmodel.dart';
//
// /// ===================== RESULT WRAPPERS =====================
//
// class PaymentActionResult {
//   final bool success;
//   final String? message;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const PaymentActionResult.success(this.message)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const PaymentActionResult.failure(this.errorMessage,
//       {this.isUnauthorized = false})
//       : success = false,
//         message = null;
// }
//
// class PaymentDetailsResult {
//   final bool success;
//   final PaymentDetailsData? data;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const PaymentDetailsResult.success(this.data)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const PaymentDetailsResult.failure(this.errorMessage,
//       {this.isUnauthorized = false})
//       : success = false,
//         data = null;
// }
//
// /// ===================== PROVIDER =====================
//
// class PaymentProvider {
//   final ApiClient _apiClient;
//
//   PaymentProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   /// POST /payments — record a new payment against an estimate.
//   Future<PaymentActionResult> addPayment(AddPaymentRequest request) async {
//     try {
//       final response = await _apiClient.addPayment(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final status = body['status']?.toString() ?? '0';
//         final message = body['message']?.toString() ?? '';
//         if (status == '1') {
//           return PaymentActionResult.success(
//             message.isNotEmpty ? message : 'Payment added successfully',
//           );
//         }
//         return PaymentActionResult.failure(
//           message.isNotEmpty ? message : 'Failed to add payment.',
//         );
//       }
//       return PaymentActionResult.failure(
//         'Unexpected response: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       // This both returns a display message AND, on 401, clears the
//       // token and pushes LoginScreen via AppRouter.navigatorKey.
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return PaymentActionResult.failure(
//         unauthorized ? null : message,
//         isUnauthorized: unauthorized,
//       );
//     } catch (_) {
//       return const PaymentActionResult.failure(
//         'Something went wrong. Please try again.',
//       );
//     }
//   }
//
//   /// POST /payments/details { estimate_id } — full payment history +
//   /// financial/payment summary for one estimate.
//   Future<PaymentDetailsResult> getPaymentDetails(int estimateId) async {
//     try {
//       final response =
//       await _apiClient.paymentDetails({'estimate_id': estimateId});
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final parsed = PaymentDetailsResponse.fromJson(body);
//         if (parsed.status == '1') {
//           return PaymentDetailsResult.success(parsed.data);
//         }
//         return PaymentDetailsResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to fetch payment details.',
//         );
//       }
//       return PaymentDetailsResult.failure(
//         'Unexpected response: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return PaymentDetailsResult.failure(
//         unauthorized ? null : message,
//         isUnauthorized: unauthorized,
//       );
//     } catch (_) {
//       return const PaymentDetailsResult.failure(
//         'Something went wrong. Please try again.',
//       );
//     }
//   }
//
//   /// POST /payments/delete { id } — deletes a payment, balance is
//   /// recalculated server-side.
//   Future<PaymentActionResult> deletePayment(int paymentId) async {
//     try {
//       final response = await _apiClient
//           .deletePayment(DeletePaymentRequest(paymentId).toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final status = body['status']?.toString() ?? '0';
//         final message = body['message']?.toString() ?? '';
//         if (status == '1') {
//           return PaymentActionResult.success(
//             message.isNotEmpty ? message : 'Payment deleted successfully.',
//           );
//         }
//         return PaymentActionResult.failure(
//           message.isNotEmpty ? message : 'Failed to delete payment.',
//         );
//       }
//       return PaymentActionResult.failure(
//         'Unexpected response: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return PaymentActionResult.failure(
//         unauthorized ? null : message,
//         isUnauthorized: unauthorized,
//       );
//     } catch (_) {
//       return const PaymentActionResult.failure(
//         'Something went wrong. Please try again.',
//       );
//     }
//   }
// }
// lib/providers/payment_provider.dart

import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/paymentmodel.dart';

/// ===================== RESULT WRAPPERS =====================

class PaymentActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const PaymentActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const PaymentActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class PaymentDetailsResult {
  final bool success;
  final PaymentDetailsData? data;
  final String? errorMessage;

  const PaymentDetailsResult.success(this.data)
      : success = true,
        errorMessage = null;

  const PaymentDetailsResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

/// ===================== PROVIDER =====================

class PaymentProvider {
  final ApiClient _apiClient;

  PaymentProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /payments — record a new payment against an estimate.
  Future<PaymentActionResult> addPayment(AddPaymentRequest request) => _actionCall(
        () => _apiClient.addPayment(request.toJson()),
  );

  /// POST /payments/details { estimate_id } — full payment history +
  /// financial/payment summary for one estimate.
  Future<PaymentDetailsResult> getPaymentDetails(int estimateId) async {
    try {
      final response =
      await _apiClient.paymentDetails({'estimate_id': estimateId});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = PaymentDetailsResponse.fromJson(response.data);
        return PaymentDetailsResult.success(parsed.data);
      }
      return PaymentDetailsResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return PaymentDetailsResult.failure(message);
    }
  }

  /// POST /payments/delete { id } — deletes a payment, balance is
  /// recalculated server-side.
  Future<PaymentActionResult> deletePayment(int paymentId) => _actionCall(
        () => _apiClient.deletePayment(DeletePaymentRequest(paymentId).toJson()),
  );

  /// Shared response handling for /payments and /payments/delete — both
  /// return `{ status, message }`.
  Future<PaymentActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        final status = body['status']?.toString();
        final message = body['message']?.toString();
        return status == '1'
            ? PaymentActionResult.success(message)
            : PaymentActionResult.failure(message);
      }
      return PaymentActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return PaymentActionResult.failure(message);
    }
  }
}