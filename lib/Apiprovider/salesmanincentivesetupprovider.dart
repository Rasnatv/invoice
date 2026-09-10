
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/owner_incentivesetupmodel.dart';


class SalesmanIncentiveListResult {
  final bool success;
  final List<SalesmanIncentiveListItem> list;
  final String? errorMessage;

  const SalesmanIncentiveListResult.success(this.list)
      : success = true,
        errorMessage = null;

  const SalesmanIncentiveListResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

class SalesmanIncentiveSetupDetailResult {
  final bool success;
  final SalesmanIncentiveSetupDetail? detail;
  final String? errorMessage;

  const SalesmanIncentiveSetupDetailResult.success(this.detail)
      : success = true,
        errorMessage = null;

  const SalesmanIncentiveSetupDetailResult.failure(this.errorMessage)
      : success = false,
        detail = null;
}

class SalesmanIncentiveActionResult {
  final bool success;
  final String? message;

  const SalesmanIncentiveActionResult({
    required this.success,
    this.message,
  });
}

/// Mirrors DriverProvider / QuotationProvider 1:1 (result wrappers +
/// try/catch + ApiErrorHandler) so it drops straight into your existing
/// Bloc wiring.
class SalesmanIncentiveSetupProvider {
  final ApiClient _apiClient;

  SalesmanIncentiveSetupProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /salesman-incentive-setup
  Future<SalesmanIncentiveListResult> getList() async {
    try {
      final response = await _apiClient.salesmanIncentiveSetupList();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanIncentiveListResponseModel.fromJson(response.data);
        return SalesmanIncentiveListResult.success(parsed.list);
      }
      return SalesmanIncentiveListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanIncentiveListResult.failure(message);
    }
  }

  /// POST /salesman-incentive-setup/get
  Future<SalesmanIncentiveSetupDetailResult> getSetup(SalesmanIncentiveSetupQueryRequest request) async {
    try {
      final response = await _apiClient.salesmanIncentiveSetupGet(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanIncentiveSetupGetResponseModel.fromJson(response.data);
        return SalesmanIncentiveSetupDetailResult.success(parsed.data);
      }
      return SalesmanIncentiveSetupDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanIncentiveSetupDetailResult.failure(message);
    }
  }

  /// POST /salesman-incentive-setup/save
  Future<SalesmanIncentiveActionResult> saveSetup(SalesmanIncentiveSetupSaveRequest request) => _actionCall(
        () => _apiClient.salesmanIncentiveSetupSave(request.toJson()),
  );

  /// POST /salesman-incentive-setup/delete
  Future<SalesmanIncentiveActionResult> deleteSetup(SalesmanIncentiveSetupQueryRequest request) => _actionCall(
        () => _apiClient.salesmanIncentiveSetupDelete(request.toJson()),
  );

  /// Shared response handling for /salesman-incentive-setup/save and
  /// /delete — both parsed via [SalesmanIncentiveActionResponseModel].
  Future<SalesmanIncentiveActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanIncentiveActionResponseModel.fromJson(response.data);
        return SalesmanIncentiveActionResult(success: parsed.status == '1', message: parsed.message);
      }
      return SalesmanIncentiveActionResult(
        success: false,
        message: response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanIncentiveActionResult(success: false, message: message);
    }
  }
}