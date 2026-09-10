import 'package:dio/dio.dart';
import '../../../core/apiclient/api_client.dart';
import '../../../core/errors/apierrorhandler.dart';
import '../models/fieldstaffmodels/fieldstaffincentiveviewingmodel.dart';

/// Result wrapper for GET /field-staff-incentives, consumed by
/// [FieldStaffIncentivesBloc] (`result.success` / `.response` / `.errorMessage`).
class FieldStaffIncentivesResult {
  final bool success;
  final FieldStaffIncentivesResponse? response;
  final String? errorMessage;

  const FieldStaffIncentivesResult.success(this.response)
      : success = true,
        errorMessage = null;

  const FieldStaffIncentivesResult.failure(this.errorMessage)
      : success = false,
        response = null;
}

/// Generic result wrapper for /field-staff-incentives/summary,
/// /field-staff-incentives/show and /field-staff-incentives/mark-paid.
///
/// These three don't have a shared JSON sample yet, so [data] is left as
/// the raw decoded body. Once you share the actual response shapes for
/// each, this can be split into proper typed models the way
/// [FieldStaffIncentive] wraps the list endpoint.
class FieldStaffIncentiveActionResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const FieldStaffIncentiveActionResult.success(this.data)
      : success = true,
        errorMessage = null;

  const FieldStaffIncentiveActionResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class FieldStaffIncentivesProvider {
  final ApiClient _apiClient;

  FieldStaffIncentivesProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /field-staff-incentives?page={page}&per_page={perPage}
  /// [filters] is optional — pass things like {'status': 'pending',
  /// 'field_staff_id': 12} to filter the list; merged into the query
  /// params by ApiClient.fieldStaffIncentiveList.
  Future<FieldStaffIncentivesResult> getIncentives({
    int page = 1,
    int perPage = 10,
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      final response = await _apiClient.fieldStaffIncentiveList(
        filters,
        page: page,
        perPage: perPage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FieldStaffIncentivesResult.success(
          FieldStaffIncentivesResponse.fromJson(response.data),
        );
      }
      return FieldStaffIncentivesResult.failure(
        response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return FieldStaffIncentivesResult.failure(message);
    }
  }

  /// POST /field-staff-incentives/summary
  /// [filters] — e.g. {'field_staff_id': 27, 'year': 2026, 'month': 9}.
  Future<FieldStaffIncentiveActionResult> getSummary(
      Map<String, dynamic> filters,
      ) =>
      _actionCall(() => _apiClient.fieldStaffIncentiveSummary(filters));

  /// POST /field-staff-incentives/show — body: { id }
  Future<FieldStaffIncentiveActionResult> getDetail(String id) =>
      _actionCall(() => _apiClient.fieldStaffIncentiveShow({'id': int.tryParse(id) ?? id}));

  /// POST /field-staff-incentives/mark-paid
  /// body: { id, payment_reference, payment_date, notes } — match whatever
  /// fields your backend actually expects here.
  Future<FieldStaffIncentiveActionResult> markPaid(
      Map<String, dynamic> data,
      ) =>
      _actionCall(() => _apiClient.fieldStaffIncentiveMarkPaid(data));

  /// Shared response handling for the summary/show/mark-paid endpoints.
  Future<FieldStaffIncentiveActionResult> _actionCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{'data': response.data};
        return FieldStaffIncentiveActionResult.success(data);
      }
      return FieldStaffIncentiveActionResult.failure(
        response.statusCode.toString(),
      );
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return FieldStaffIncentiveActionResult.failure(message);
    }
  }
}