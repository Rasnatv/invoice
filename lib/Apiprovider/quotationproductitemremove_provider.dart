import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/quotationitemremovemodel.dart';

class QuotationItemActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const QuotationItemActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const QuotationItemActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class QuotationItemProvider {
  final ApiClient _apiClient;

  QuotationItemProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /quotations/remove-item
  ///
  /// The confirmed real response returns an empty `data: {}` on success —
  /// nothing to parse out of it beyond status/message. Callers should
  /// remove the item from their local item list themselves after a
  /// successful call rather than expect anything back in the result.
  Future<QuotationItemActionResult> removeItem({
    required String quotationId,
    required String quotationItemId,
  }) async {
    try {
      final response = await _apiClient.removeQuotationItem(
        QuotationRemoveItemRequest(
          quotationId: quotationId,
          quotationItemId: quotationItemId,
        ).toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = QuotationRemoveItemResponseModel.fromJson(response.data);
        return QuotationItemActionResult.success(parsed.message);
      }
      return QuotationItemActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return QuotationItemActionResult.failure(message);
    }
  }
}