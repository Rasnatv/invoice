// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
// import '../models/owner_models/owner_incentivesetupmodel.dart';
//
//
// class SalesmanIncentiveListResult {
//   final bool success;
//   final List<SalesmanIncentiveListItem> list;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const SalesmanIncentiveListResult.success(this.list)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const SalesmanIncentiveListResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         list = const [];
// }
//
// class SalesmanIncentiveSetupDetailResult {
//   final bool success;
//   final SalesmanIncentiveSetupDetail? detail;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const SalesmanIncentiveSetupDetailResult.success(this.detail)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const SalesmanIncentiveSetupDetailResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         detail = null;
// }
//
// class SalesmanIncentiveActionResult {
//   final bool success;
//   final String? message;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const SalesmanIncentiveActionResult.success(this.message)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const SalesmanIncentiveActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         message = null;
// }
//
// /// Mirrors DriverProvider / QuotationProvider 1:1 (result wrappers +
// /// try/catch + ApiErrorHandler) so it drops straight into your existing
// /// Bloc wiring.
// class SalesmanIncentiveSetupProvider {
//   final ApiClient _apiClient;
//
//   SalesmanIncentiveSetupProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   /// GET /salesman-incentive-setup
//   Future<SalesmanIncentiveListResult> getList() async {
//     try {
//       final response = await _apiClient.salesmanIncentiveSetupList();
//       final body = response.data;
//
//       if (response.statusCode == 200 && body is Map<String, dynamic>) {
//         final parsed = SalesmanIncentiveListResponseModel.fromJson(body);
//         if (parsed.status == '1') return SalesmanIncentiveListResult.success(parsed.list);
//         return SalesmanIncentiveListResult.failure(
//           parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch salesmen.',
//         );
//       }
//       return SalesmanIncentiveListResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return SalesmanIncentiveListResult.failure(unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const SalesmanIncentiveListResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /salesman-incentive-setup/get
//   Future<SalesmanIncentiveSetupDetailResult> getSetup(SalesmanIncentiveSetupQueryRequest request) async {
//     try {
//       final response = await _apiClient.salesmanIncentiveSetupGet(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final parsed = SalesmanIncentiveSetupGetResponseModel.fromJson(body);
//         if (parsed.status == '1') return SalesmanIncentiveSetupDetailResult.success(parsed.data);
//         return SalesmanIncentiveSetupDetailResult.failure(
//           parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch incentive setup.',
//         );
//       }
//       return SalesmanIncentiveSetupDetailResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return SalesmanIncentiveSetupDetailResult.failure(unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const SalesmanIncentiveSetupDetailResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /salesman-incentive-setup/save
//   Future<SalesmanIncentiveActionResult> saveSetup(SalesmanIncentiveSetupSaveRequest request) async {
//     try {
//       final response = await _apiClient.salesmanIncentiveSetupSave(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final parsed = SalesmanIncentiveActionResponseModel.fromJson(body);
//         if (parsed.status == '1') {
//           return SalesmanIncentiveActionResult.success(
//             parsed.message.isNotEmpty ? parsed.message : 'Incentive setup saved successfully.',
//           );
//         }
//         return SalesmanIncentiveActionResult.failure(
//           parsed.message.isNotEmpty ? parsed.message : 'Failed to save incentive setup.',
//         );
//       }
//       return SalesmanIncentiveActionResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return SalesmanIncentiveActionResult.failure(unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const SalesmanIncentiveActionResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /salesman-incentive-setup/delete
//   Future<SalesmanIncentiveActionResult> deleteSetup(SalesmanIncentiveSetupQueryRequest request) async {
//     try {
//       final response = await _apiClient.salesmanIncentiveSetupDelete(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final parsed = SalesmanIncentiveActionResponseModel.fromJson(body);
//         if (parsed.status == '1') {
//           return SalesmanIncentiveActionResult.success(
//             parsed.message.isNotEmpty ? parsed.message : 'Incentive setup deleted successfully.',
//           );
//         }
//         return SalesmanIncentiveActionResult.failure(
//           parsed.message.isNotEmpty ? parsed.message : 'Failed to delete incentive setup.',
//         );
//       }
//       return SalesmanIncentiveActionResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return SalesmanIncentiveActionResult.failure(unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const SalesmanIncentiveActionResult.failure('Something went wrong. Please try again.');
//     }
//   }
// }
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