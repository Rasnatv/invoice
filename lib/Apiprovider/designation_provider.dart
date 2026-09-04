// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
//
// import '../models/owner_models/designationmodel.dart';
//
//
// class DesignationListResult {
//   final bool success;
//   final List<DesignationModel> designations;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const DesignationListResult.success(this.designations)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const DesignationListResult.failure(this.errorMessage,
//       {this.isUnauthorized = false})
//       : success = false,
//         designations = const [];
// }
//
// class DesignationActionResult {
//   final bool success;
//   final String? message;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const DesignationActionResult.success(this.message)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const DesignationActionResult.failure(this.errorMessage,
//       {this.isUnauthorized = false})
//       : success = false,
//         message = null;
// }
//
// /// Shared shape for the one DioException-handling code path, so it isn't
// /// duplicated in every method below.
// class _Failure {
//   final String? errorMessage;
//   final bool isUnauthorized;
//   const _Failure(this.errorMessage, this.isUnauthorized);
// }
//
// class DesignationProvider {
//   final ApiClient _apiClient;
//
//   DesignationProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   /// Single shared handler — calls ApiErrorHandler exactly once per failure.
//   /// ApiErrorHandler owns the 401 -> clear token -> LoginScreen flow.
//   Future<_Failure> _handleDioException(DioException e) async {
//     final unauthorized = e.response?.statusCode == 401;
//     final message = await ApiErrorHandler.handleDioError(e);
//     return _Failure(unauthorized ? null : message, unauthorized);
//   }
//
//   /// GET /salesman-designations
//   Future<DesignationListResult> getDesignations() async {
//     try {
//       final response = await _apiClient.salesmanDesignations();
//       final body = response.data;
//
//       if (response.statusCode == 200 && body is Map<String, dynamic>) {
//         final parsed = DesignationListResponseModel.fromJson(body);
//         if (parsed.status == '1') {
//           return DesignationListResult.success(parsed.data);
//         }
//         return DesignationListResult.failure(
//           parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch designations.',
//         );
//       }
//       return DesignationListResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final f = await _handleDioException(e);
//       return DesignationListResult.failure(f.errorMessage, isUnauthorized: f.isUnauthorized);
//     } catch (_) {
//       return const DesignationListResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /salesman-designations/create
//   Future<DesignationActionResult> addDesignation(DesignationAddRequestModel request) async {
//     try {
//       final response = await _apiClient.addDesignation(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final status = body['status']?.toString() ?? '0';
//         final message = body['message']?.toString() ?? '';
//         if (status == '1') {
//           return DesignationActionResult.success(
//             message.isNotEmpty ? message : 'Designation created successfully.',
//           );
//         }
//         return DesignationActionResult.failure(
//           message.isNotEmpty ? message : 'Failed to create designation.',
//         );
//       }
//       return DesignationActionResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final f = await _handleDioException(e);
//       return DesignationActionResult.failure(f.errorMessage, isUnauthorized: f.isUnauthorized);
//     } catch (_) {
//       return const DesignationActionResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /salesman-designations/update
//   Future<DesignationActionResult> updateDesignation(DesignationUpdateRequestModel request) async {
//     try {
//       final response = await _apiClient.updateDesignation(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final status = body['status']?.toString() ?? '0';
//         final message = body['message']?.toString() ?? '';
//         if (status == '1') {
//           return DesignationActionResult.success(
//             message.isNotEmpty ? message : 'Designation updated successfully.',
//           );
//         }
//         return DesignationActionResult.failure(
//           message.isNotEmpty ? message : 'Failed to update designation.',
//         );
//       }
//       return DesignationActionResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final f = await _handleDioException(e);
//       return DesignationActionResult.failure(f.errorMessage, isUnauthorized: f.isUnauthorized);
//     } catch (_) {
//       return const DesignationActionResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /salesman-designations/delete
//   Future<DesignationActionResult> deleteDesignation(DesignationDeleteRequestModel request) async {
//     try {
//       final response = await _apiClient.deleteDesignation(request.toJson());
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final status = body['status']?.toString() ?? '0';
//         final message = body['message']?.toString() ?? '';
//         if (status == '1') {
//           return DesignationActionResult.success(
//             message.isNotEmpty ? message : 'Designation deleted successfully.',
//           );
//         }
//         return DesignationActionResult.failure(
//           message.isNotEmpty ? message : 'Failed to delete designation.',
//         );
//       }
//       return DesignationActionResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final f = await _handleDioException(e);
//       return DesignationActionResult.failure(f.errorMessage, isUnauthorized: f.isUnauthorized);
//     } catch (_) {
//       return const DesignationActionResult.failure('Something went wrong. Please try again.');
//     }
//   }
// }
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';

import '../models/owner_models/designationmodel.dart';


class DesignationListResult {
  final bool success;
  final List<DesignationModel> designations;
  final String? errorMessage;

  const DesignationListResult.success(this.designations)
      : success = true,
        errorMessage = null;

  const DesignationListResult.failure(this.errorMessage)
      : success = false,
        designations = const [];
}

class DesignationActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const DesignationActionResult.success(this.message)
      : success = true,
        errorMessage = null;

  const DesignationActionResult.failure(this.errorMessage)
      : success = false,
        message = null;
}

class DesignationProvider {
  final ApiClient _apiClient;

  DesignationProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /salesman-designations
  Future<DesignationListResult> getDesignations() async {
    try {
      final response = await _apiClient.salesmanDesignations();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DesignationListResponseModel.fromJson(response.data);
        return DesignationListResult.success(parsed.data);
      }
      return DesignationListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationListResult.failure(message);
    }
  }

  /// POST /salesman-designations/create
  Future<DesignationActionResult> addDesignation(DesignationAddRequestModel request) async {
    try {
      final response = await _apiClient.addDesignation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return DesignationActionResult.success(message);
      }
      return DesignationActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationActionResult.failure(message);
    }
  }

  /// POST /salesman-designations/update
  Future<DesignationActionResult> updateDesignation(DesignationUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateDesignation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return DesignationActionResult.success(message);
      }
      return DesignationActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationActionResult.failure(message);
    }
  }

  /// POST /salesman-designations/delete
  Future<DesignationActionResult> deleteDesignation(DesignationDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteDesignation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']?.toString();
        return DesignationActionResult.success(message);
      }
      return DesignationActionResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DesignationActionResult.failure(message);
    }
  }
}