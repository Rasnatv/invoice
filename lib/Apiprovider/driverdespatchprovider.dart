// import 'package:dio/dio.dart';
// import '../../../core/apiclient/api_client.dart';
// import '../../../core/errors/apierrorhandler.dart';
// import '../models/drivermodels/driverdashboardmodel.dart';
// import '../models/drivermodels/driverdashboarddespatchdetailscreenmodel.dart';
//
// /// Result wrapper for GET /drivers/dashboard, consumed by
// /// [DriverDashboardBloc] (`result.success` / `.dashboard` / `.errorMessage`).
// class DriverDashboardResult {
//   final bool success;
//   final DriverDashboardResponse? dashboard;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const DriverDashboardResult.success(this.dashboard)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const DriverDashboardResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         dashboard = null;
// }
//
// /// Result wrapper for /drivers/show, /despatches/mark-in-transit and
// /// /despatches/mark-delivered, consumed by [DriverDespatchDetailBloc]
// /// (`result.success` / `.detail` / `.errorMessage`).
// ///
// /// None of those three endpoints echo the despatch id back in their body,
// /// so the id is threaded through by the caller and passed explicitly into
// /// [DriverDespatchDetail.fromJson].
// class DriverDespatchDetailResult {
//   final bool success;
//   final DriverDespatchDetail? detail;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const DriverDespatchDetailResult.success(this.detail)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const DriverDespatchDetailResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         detail = null;
// }
//
// class DriverDespatchProvider {
//   final ApiClient _apiClient;
//
//   DriverDespatchProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
//
//   // ---------------- dashboard ----------------
//
//   /// GET /drivers/dashboard — counts + list for the driver home screen.
//   Future<DriverDashboardResult> getDashboard() async {
//     try {
//       final response = await _apiClient.driverDashboard();
//       final body = response.data;
//
//       if (response.statusCode == 200 && body is Map<String, dynamic>) {
//         final ok = body['status']?.toString() == '1' || body['status_code']?.toString() == '200';
//         if (ok) {
//           return DriverDashboardResult.success(DriverDashboardResponse.fromJson(body));
//         }
//         return DriverDashboardResult.failure(
//           (body['message']?.toString().isNotEmpty ?? false)
//               ? body['message'].toString()
//               : 'Failed to load dashboard.',
//         );
//       }
//       return DriverDashboardResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return DriverDashboardResult.failure(message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const DriverDashboardResult.failure('Something went wrong. Please try again.');
//     }
//   }
//
//   // ---------------- despatch detail / actions ----------------
//
//   /// POST /drivers/show — loads the full bill for the driver's detail page.
//   Future<DriverDespatchDetailResult> getDetail(String id) => _detailCall(
//     id,
//         () => _apiClient.driverShowDespatch({'id': int.tryParse(id) ?? id}),
//     fallbackError: 'Failed to load despatch bill.',
//   );
//
//   /// POST /despatches/mark-in-transit — pending -> in transit.
//   Future<DriverDespatchDetailResult> markInTransit(String id) => _detailCall(
//     id,
//         () => _apiClient.markInTransit({'id': int.tryParse(id) ?? id}),
//     fallbackError: 'Failed to mark as in transit.',
//   );
//
//   /// POST /despatches/mark-delivered — in transit -> delivered. Signatures
//   /// are optional: either, both, or neither may be supplied. When provided
//   /// they're base64 PNG data URIs (e.g. `data:image/png;base64,...`); the
//   /// server responds with hosted image URLs for whichever ones were
//   /// uploaded.
//   Future<DriverDespatchDetailResult> markDelivered({
//     required String id,
//     String? customerSignatureBase64,
//     String? driverSignatureBase64,
//   }) =>
//       _detailCall(
//         id,
//             () => _apiClient.markDelivered({
//           'id': int.tryParse(id) ?? id,
//           if (customerSignatureBase64 != null) 'customer_signature': customerSignatureBase64,
//           if (driverSignatureBase64 != null) 'driver_signature': driverSignatureBase64,
//         }),
//         fallbackError: 'Failed to mark as delivered.',
//       );
//
//   /// Shared response handling for /drivers/show, /mark-in-transit and
//   /// /mark-delivered — all three return the same envelope shape.
//   Future<DriverDespatchDetailResult> _detailCall(
//       String id,
//       Future<Response> Function() request, {
//         required String fallbackError,
//       }) async {
//     try {
//       final response = await request();
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final ok = body['status']?.toString() == '1' || body['status_code']?.toString() == '200';
//         final data = body['data'];
//
//         if (ok && data is Map<String, dynamic>) {
//           return DriverDespatchDetailResult.success(
//             DriverDespatchDetail.fromJson(data, id: id),
//           );
//         }
//         return DriverDespatchDetailResult.failure(
//           (body['message']?.toString().isNotEmpty ?? false) ? body['message'].toString() : fallbackError,
//         );
//       }
//       return DriverDespatchDetailResult.failure('Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return DriverDespatchDetailResult.failure(message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const DriverDespatchDetailResult.failure('Something went wrong. Please try again.');
//     }
//   }
// }
import 'package:dio/dio.dart';
import '../../../core/apiclient/api_client.dart';
import '../../../core/errors/apierrorhandler.dart';
import '../models/drivermodels/driverdashboardmodel.dart';
import '../models/drivermodels/driverdashboarddespatchdetailscreenmodel.dart';

/// Result wrapper for GET /drivers/dashboard, consumed by
/// [DriverDashboardBloc] (`result.success` / `.dashboard` / `.errorMessage`).
class DriverDashboardResult {
  final bool success;
  final DriverDashboardResponse? dashboard;
  final String? errorMessage;

  const DriverDashboardResult.success(this.dashboard)
      : success = true,
        errorMessage = null;

  const DriverDashboardResult.failure(this.errorMessage)
      : success = false,
        dashboard = null;
}

/// Result wrapper for /drivers/show, /despatches/mark-in-transit and
/// /despatches/mark-delivered, consumed by [DriverDespatchDetailBloc]
/// (`result.success` / `.detail` / `.errorMessage`).
///
/// None of those three endpoints echo the despatch id back in their body,
/// so the id is threaded through by the caller and passed explicitly into
/// [DriverDespatchDetail.fromJson].
class DriverDespatchDetailResult {
  final bool success;
  final DriverDespatchDetail? detail;
  final String? errorMessage;

  const DriverDespatchDetailResult.success(this.detail)
      : success = true,
        errorMessage = null;

  const DriverDespatchDetailResult.failure(this.errorMessage)
      : success = false,
        detail = null;
}

class DriverDespatchProvider {
  final ApiClient _apiClient;

  DriverDespatchProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ---------------- dashboard ----------------

  /// GET /drivers/dashboard — counts + list for the driver home screen.
  Future<DriverDashboardResult> getDashboard() async {
    try {
      final response = await _apiClient.driverDashboard();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DriverDashboardResult.success(DriverDashboardResponse.fromJson(response.data));
      }
      return DriverDashboardResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DriverDashboardResult.failure(message);
    }
  }

  // ---------------- despatch detail / actions ----------------

  /// POST /drivers/show — loads the full bill for the driver's detail page.
  Future<DriverDespatchDetailResult> getDetail(String id) => _detailCall(
    id,
        () => _apiClient.driverShowDespatch({'id': int.tryParse(id) ?? id}),
  );

  /// POST /despatches/mark-in-transit — pending -> in transit.
  Future<DriverDespatchDetailResult> markInTransit(String id) => _detailCall(
    id,
        () => _apiClient.markInTransit({'id': int.tryParse(id) ?? id}),
  );

  /// POST /despatches/mark-delivered — in transit -> delivered. Signatures
  /// are optional: either, both, or neither may be supplied. When provided
  /// they're base64 PNG data URIs (e.g. `data:image/png;base64,...`); the
  /// server responds with hosted image URLs for whichever ones were
  /// uploaded.
  Future<DriverDespatchDetailResult> markDelivered({
    required String id,
    String? customerSignatureBase64,
    String? driverSignatureBase64,
  }) =>
      _detailCall(
        id,
            () => _apiClient.markDelivered({
          'id': int.tryParse(id) ?? id,
          if (customerSignatureBase64 != null) 'customer_signature': customerSignatureBase64,
          if (driverSignatureBase64 != null) 'driver_signature': driverSignatureBase64,
        }),
      );

  /// Shared response handling for /drivers/show, /mark-in-transit and
  /// /mark-delivered — all three return the same envelope shape.
  Future<DriverDespatchDetailResult> _detailCall(
      String id,
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return DriverDespatchDetailResult.success(
          DriverDespatchDetail.fromJson(data, id: id),
        );
      }
      return DriverDespatchDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DriverDespatchDetailResult.failure(message);
    }
  }
}