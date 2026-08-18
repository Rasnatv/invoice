import 'package:dio/dio.dart';
import '../../../core/apiclient/api_client.dart';
import '../../../core/errors/apierrorhandler.dart';
import '../models/owner_models/owner_despatchdetailmodel.dart';
import '../models/owner_models/owner_despatchmodellist.dart';

class DispatchListResult {
  final bool success;
  final List<DispatchListItem> dispatches;
  final String? errorMessage;
  final bool isUnauthorized;

  const DispatchListResult.success(this.dispatches)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const DispatchListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        dispatches = const [];
}

class DispatchDetailResult {
  final bool success;
  final DispatchDetail? dispatch;
  final String? errorMessage;
  final bool isUnauthorized;

  const DispatchDetailResult.success(this.dispatch)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const DispatchDetailResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        dispatch = null;
}

class DispatchProvider {
  final ApiClient _apiClient;

  DispatchProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /despatches/my
  Future<DispatchListResult> getMyDispatches({int page = 1, int perPage = 10}) async {
    try {
      final response = await _apiClient.myDispatches(page: page, perPage: perPage);
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = DispatchListResponseModel.fromJson(body);
        final ok = parsed.status == '1' || body['status_code']?.toString() == '200';
        if (ok) return DispatchListResult.success(parsed.data);
        return DispatchListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to load dispatch bills.',
        );
      }
      return DispatchListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      // ApiErrorHandler always returns a real message (never null) and, on
      // 401 with a valid stored token, also clears it and redirects to
      // LoginScreen. If there's no token to begin with it can't redirect,
      // so we still surface the message here instead of hiding it.
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DispatchListResult.failure(message, isUnauthorized: unauthorized);
    } catch (_) {
      return const DispatchListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /despatches/show
  Future<DispatchDetailResult> getDispatchDetail(String id) => _detailCall(
        () => _apiClient.showDispatch({'id': id}),
    fallbackError: 'Failed to load dispatch bill.',
  );

  /// POST /despatches/mark-in-transit — first step of the delivery flow.
  Future<DispatchDetailResult> markInTransit(String id) => _detailCall(
        () => _apiClient.markInTransit({'id': id}),
    fallbackError: 'Failed to mark as in transit.',
  );

  /// POST /despatches/mark-delivered — second step, only valid once the
  /// dispatch is `in_transit`. Signatures are base64 PNG data URIs
  /// (e.g. `data:image/png;base64,...`).
  Future<DispatchDetailResult> markDelivered({
    required String id,
    required String customerSignatureBase64,
    required String driverSignatureBase64,
  }) =>
      _detailCall(
            () => _apiClient.markDelivered({
          'id': int.tryParse(id) ?? id,
          'customer_signature': customerSignatureBase64,
          'driver_signature': driverSignatureBase64,
        }),
        fallbackError: 'Failed to mark as delivered.',
      );

  /// Shared response handling for /show, /mark-in-transit and
  /// /mark-delivered — all three return the same envelope shape.
  Future<DispatchDetailResult> _detailCall(
      Future<Response> Function() request, {
        required String fallbackError,
      }) async {
    try {
      final response = await request();
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = DispatchDetailResponseModel.fromJson(body);
        final ok = parsed.status == '1' || body['status_code']?.toString() == '200';
        if (ok && parsed.data != null) {
          return DispatchDetailResult.success(parsed.data);
        }
        return DispatchDetailResult.failure(
          parsed.message.isNotEmpty ? parsed.message : fallbackError,
        );
      }
      return DispatchDetailResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      // TEMP DEBUG — remove once you've confirmed this stopped firing.
      // ignore: avoid_print
      print('[Dispatch] status=${e.response?.statusCode} body=${e.response?.data}');
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return DispatchDetailResult.failure(message, isUnauthorized: unauthorized);
    } catch (_) {
      return const DispatchDetailResult.failure('Something went wrong. Please try again.');
    }
  }
}
