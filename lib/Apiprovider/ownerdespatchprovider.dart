
import 'package:dio/dio.dart';
import '../../../core/apiclient/api_client.dart';
import '../../../core/errors/apierrorhandler.dart';
import '../models/owner_models/owner_despatchdetailmodel.dart';
import '../models/owner_models/owner_despatchmodellist.dart';

class DispatchListResult {
  final bool success;
  final List<DispatchListItem> dispatches;
  final String? errorMessage;

  const DispatchListResult.success(this.dispatches)
      : success = true,
        errorMessage = null;

  const DispatchListResult.failure(this.errorMessage)
      : success = false,
        dispatches = const [];
}

class DispatchDetailResult {
  final bool success;
  final DispatchDetail? dispatch;
  final String? errorMessage;

  const DispatchDetailResult.success(this.dispatch)
      : success = true,
        errorMessage = null;

  const DispatchDetailResult.failure(this.errorMessage)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DispatchListResponseModel.fromJson(response.data);
        return DispatchListResult.success(parsed.data);
      }
      return DispatchListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DispatchListResult.failure(message);
    }
  }

  /// POST /despatches/show
  Future<DispatchDetailResult> getDispatchDetail(String id) => _detailCall(
        () => _apiClient.showDispatch({'id': id}),
  );

  /// POST /despatches/mark-in-transit — first step of the delivery flow.
  Future<DispatchDetailResult> markInTransit(String id) => _detailCall(
        () => _apiClient.markInTransit({'id': id}),
  );

  /// POST /despatches/mark-delivered — second step, only valid once the
  /// dispatch is `in_transit`. Signatures are optional: either, both, or
  /// neither may be supplied. When provided they're base64 PNG data URIs
  /// (e.g. `data:image/png;base64,...`); the server responds with hosted
  /// image URLs for whichever ones were uploaded.
  Future<DispatchDetailResult> markDelivered({
    required String id,
    String? customerSignatureBase64,
    String? driverSignatureBase64,
  }) =>
      _detailCall(
            () => _apiClient.markDelivered({
          'id': int.tryParse(id) ?? id,
          if (customerSignatureBase64 != null) 'customer_signature': customerSignatureBase64,
          if (driverSignatureBase64 != null) 'driver_signature': driverSignatureBase64,
        }),
      );

  /// Shared response handling for /show, /mark-in-transit and
  /// /mark-delivered — all three return the same envelope shape.
  Future<DispatchDetailResult> _detailCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = DispatchDetailResponseModel.fromJson(response.data);
        return DispatchDetailResult.success(parsed.data);
      }
      return DispatchDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return DispatchDetailResult.failure(message);
    }
  }
}
