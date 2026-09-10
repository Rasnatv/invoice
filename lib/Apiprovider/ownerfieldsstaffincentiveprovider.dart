import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/activefieldstaffmodel.dart';
import '../models/owner_models/fieldstaffincentivemodel.dart';
import '../models/owner_models/incentivesummarymodel.dart';

/// Result of POST /field-staff-incentives/summary.
///
/// NOTE: the real endpoint returns BOTH the summary counts AND the
/// (query-param paginated) incentive list in one payload — see
/// FieldStaffIncentiveSummaryResponse for the combined shape.
class IncentiveSummaryResult {
  final bool success;
  final FieldStaffIncentiveSummaryResponse? data;
  final String? errorMessage;

  const IncentiveSummaryResult.success(this.data)
      : success = true,
        errorMessage = null;

  const IncentiveSummaryResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

/// Result of /field-staff-incentives/show and /mark-paid — both return the
/// same single-record envelope.
class IncentiveDetailResult {
  final bool success;
  final FieldStaffIncentiveModel? incentive;
  final String? errorMessage;

  const IncentiveDetailResult.success(this.incentive)
      : success = true,
        errorMessage = null;

  const IncentiveDetailResult.failure(this.errorMessage)
      : success = false,
        incentive = null;
}

/// Result of GET /field-staff/active.
class ActiveFieldStaffResult {
  final bool success;
  final List<ActiveFieldStaffModel> list;
  final String? errorMessage;

  const ActiveFieldStaffResult.success(this.list)
      : success = true,
        errorMessage = null;

  const ActiveFieldStaffResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

class IncentiveProvider {
  final ApiClient _apiClient;

  IncentiveProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ---------------- summary (+ embedded paged list) ----------------

  /// POST /field-staff-incentives/summary?page=&per_page=
  /// body: { date_from, date_to, field_staff_id?, status? }
  ///
  /// Confirmed real response shape:
  /// {
  ///   "data": {
  ///     "field_staff_id": "",
  ///     "summary": { "total_incentive": "165.50", "pending_count": "0",
  ///                  "approved_count": "0", "paid_count": "1" },
  ///     "list": [ {...incentive...} ]
  ///   }
  /// }
  ///
  /// IMPORTANT: this requires `_apiClient.fieldStaffIncentiveSummary` to
  /// accept `page` and `perPage` as query parameters, e.g.:
  ///
  ///   Future<Response> fieldStaffIncentiveSummary(
  ///     Map<String, dynamic> body, {
  ///     int page = 1,
  ///     int perPage = 20,
  ///   }) {
  ///     return _dio.post(
  ///       '/field-staff-incentives/summary',
  ///       queryParameters: {'page': page, 'per_page': perPage},
  ///       data: body,
  ///     );
  ///   }
  ///
  /// If your ApiClient's current signature only takes the body, update it
  /// to match the above before this compiles/runs correctly.
  Future<IncentiveSummaryResult> getSummary({
    required String dateFrom,
    required String dateTo,
    String? fieldStaffId, // omit for "all field staff"
    String? status, // pending | approved | paid — omit/pass 'all' to skip
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final body = <String, dynamic>{
        'date_from': dateFrom,
        'date_to': dateTo,
        if (fieldStaffId != null && fieldStaffId.isNotEmpty) 'field_staff_id': fieldStaffId,
        if (status != null && status.isNotEmpty && status != 'all') 'status': status,
      };

      final response = await _apiClient.fieldStaffIncentiveSummary(
        body,
        page: page,
        perPage: perPage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IncentiveSummaryResult.success(
          FieldStaffIncentiveSummaryResponse.fromJson(
            response.data['data'] as Map<String, dynamic>,
          ),
        );
      }
      return IncentiveSummaryResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return IncentiveSummaryResult.failure(message);
    }
  }

  // ---------------- detail / mark-paid ----------------

  /// POST /field-staff-incentives/show — body: { id }
  Future<IncentiveDetailResult> getDetail(String id) => _detailCall(
        () => _apiClient.fieldStaffIncentiveShow({'id': int.tryParse(id) ?? id}),
  );

  /// POST /field-staff-incentives/mark-paid
  /// body: { id, payment_reference, payment_date, notes }
  Future<IncentiveDetailResult> markPaid({
    required String id,
    required String paymentReference,
    required String paymentDate,
    String? notes,
  }) =>
      _detailCall(
            () => _apiClient.fieldStaffIncentiveMarkPaid({
          'id': int.tryParse(id) ?? id,
          'payment_reference': paymentReference,
          'payment_date': paymentDate,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }),
      );

  Future<IncentiveDetailResult> _detailCall(
      Future<Response> Function() request,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IncentiveDetailResult.success(
          FieldStaffIncentiveModel.fromJson(response.data['data']),
        );
      }
      return IncentiveDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return IncentiveDetailResult.failure(message);
    }
  }

  // ---------------- active field staff (dropdown) ----------------

  /// GET /field-staff/active
  Future<ActiveFieldStaffResult> getActiveFieldStaff() async {
    try {
      final response = await _apiClient.activeFieldStaff();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawList = (response.data['data']?['list'] as List?) ?? [];
        return ActiveFieldStaffResult.success(
          rawList
              .map((e) => ActiveFieldStaffModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return ActiveFieldStaffResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ActiveFieldStaffResult.failure(message);
    }
  }
}