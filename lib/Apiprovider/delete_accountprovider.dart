import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/deleteaccountmodel.dart';

class DeleteAccountResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const DeleteAccountResult.success(this.message)
      : success = true,
        errorMessage = null;

  const DeleteAccountResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class DeleteAccountProvider {
  final ApiClient _apiClient;

  DeleteAccountProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// DELETE /delete-account — body: { "password": "..." }
  Future<DeleteAccountResult> deleteAccount(DeleteAccountRequest request) async {
    try {
      final response = await _apiClient.DeleteAccount(request.toJson());
      final body = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        final parsed = DeleteAccountResponse.fromJson(body);
        if (parsed.isSuccess) {
          return DeleteAccountResult.success(parsed.message);
        }
        // e.g. wrong password returned as HTTP 200 with status "0"
        return DeleteAccountResult.failure(parsed.message);
      }
      return DeleteAccountResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DeleteAccountResult.failure(message);
    }
  }
}