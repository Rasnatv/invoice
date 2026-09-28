

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