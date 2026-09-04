//
// import 'package:dio/dio.dart';
// import '../core/apiclient/api_client.dart';
// import '../core/errors/apierrorhandler.dart';
// import '../models/owner_reportmodel/activecontractormodel.dart';
// import '../models/owner_reportmodel/activefieldstaffmodel.dart';
// import '../models/owner_reportmodel/contractorperformancereportmodel.dart';
// import '../models/owner_reportmodel/quotationreportmodel.dart';
// import '../models/owner_reportmodel/estimatereportmodel.dart';
// import '../models/owner_reportmodel/incentivereportmodel.dart';
// import '../models/owner_reportmodel/salesman_performancemodel.dart';
// import '../models/salesmanmodels/activeslaesman_model.dart';
//
//
// class ActiveSalesmenResult {
//   final bool success;
//   final List<ActiveSalesmanModel> salesmen;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const ActiveSalesmenResult.success(this.salesmen)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const ActiveSalesmenResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         salesmen = const [];
// }
//
// class ActiveContractorsResult {
//   final bool success;
//   final List<ActiveContractorModel> contractors;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const ActiveContractorsResult.success(this.contractors)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const ActiveContractorsResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         contractors = const [];
// }
//
// /// GET /field-staff/active
// class ActiveFieldStaffResult {
//   final bool success;
//   final List<ActiveFieldStaffModel> fieldStaff;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const ActiveFieldStaffResult.success(this.fieldStaff)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const ActiveFieldStaffResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         fieldStaff = const [];
// }
//
// class SalesmanPerformanceResult {
//   final bool success;
//   final SalesmanPerformanceReportModel? report;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const SalesmanPerformanceResult.success(this.report)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const SalesmanPerformanceResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         report = null;
// }
//
// class ContractorPerformanceResult {
//   final bool success;
//   final ContractorPerformanceReportModel? report;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const ContractorPerformanceResult.success(this.report)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const ContractorPerformanceResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         report = null;
// }
//
// /// Result of a call to /reports/quotations. `data` carries both the summary
// /// stats and the row list straight from the server — nothing here is
// /// computed or filtered on the client.
// class QuotationReportResult {
//   final bool success;
//   final QuotationReportDataModel? data;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const QuotationReportResult.success(this.data)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const QuotationReportResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         data = null;
// }
//
// /// Result of a call to /reports/estimates. `data` carries both the summary
// /// stats and the row list straight from the server — nothing here is
// /// computed or filtered on the client.
// class EstimateReportResult {
//   final bool success;
//   final EstimateReportDataModel? data;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const EstimateReportResult.success(this.data)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const EstimateReportResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         data = null;
// }
//
// /// Result of a call to /reports/incentives. `data` carries both the summary
// /// stats and the row list straight from the server — nothing here is
// /// computed or filtered on the client.
// class IncentiveReportResult {
//   final bool success;
//   final IncentiveReportDataModel? data;
//   final String? errorMessage;
//   final bool isUnauthorized;
//
//   const IncentiveReportResult.success(this.data)
//       : success = true,
//         errorMessage = null,
//         isUnauthorized = false;
//
//   const IncentiveReportResult.failure(this.errorMessage, {this.isUnauthorized = false})
//       : success = false,
//         data = null;
// }
//
// class OwnerReportsProvider {
//   final ApiClient _apiClient;
//
//   OwnerReportsProvider({ApiClient? apiClient})
//       : _apiClient = apiClient ?? ApiClient();
//
//   /// GET /salesmen/active
//   Future<ActiveSalesmenResult> getActiveSalesmen() async {
//     try {
//       final response = await _apiClient.activeSalesmen();
//       final body = response.data;
//       if (body is Map<String, dynamic>) {
//         final parsed = ActiveSalesmanResponseModel.fromJson(body);
//         if (parsed.status == '1')
//           return ActiveSalesmenResult.success(parsed.data);
//         return ActiveSalesmenResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to fetch salesmen.',
//         );
//       }
//       return ActiveSalesmenResult.failure(
//           'Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return ActiveSalesmenResult.failure(
//           unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const ActiveSalesmenResult.failure(
//           'Something went wrong. Please try again.');
//     }
//   }
//
//   /// GET /reports/contractors/active
//   Future<ActiveContractorsResult> getActiveContractors() async {
//     try {
//       final response = await _apiClient.activeContractors();
//       final body = response.data;
//       if (body is Map<String, dynamic>) {
//         final parsed = ActiveContractorResponseModel.fromJson(body);
//         if (parsed.status == '1')
//           return ActiveContractorsResult.success(parsed.data);
//         return ActiveContractorsResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to fetch contractors.',
//         );
//       }
//       return ActiveContractorsResult.failure(
//           'Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return ActiveContractorsResult.failure(
//           unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const ActiveContractorsResult.failure(
//           'Something went wrong. Please try again.');
//     }
//   }
//
//   /// GET /field-staff/active
//   Future<ActiveFieldStaffResult> getActiveFieldStaff() async {
//     try {
//       final response = await _apiClient.activeFieldStaff();
//       final body = response.data;
//       if (body is Map<String, dynamic>) {
//         final parsed = ActiveFieldStaffResponseModel.fromJson(body);
//         if (parsed.status == '1')
//           return ActiveFieldStaffResult.success(parsed.data);
//         return ActiveFieldStaffResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to fetch field staff.',
//         );
//       }
//       return ActiveFieldStaffResult.failure(
//           'Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return ActiveFieldStaffResult.failure(
//           unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const ActiveFieldStaffResult.failure(
//           'Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /reports/salesman-performance
//   Future<SalesmanPerformanceResult> getSalesmanPerformanceReport({
//     required String salesmanId,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     try {
//       final response = await _apiClient.salesmanPerformanceReport({
//         'salesman_id': salesmanId,
//         'from_date': fromDate,
//         'to_date': toDate,
//       });
//       final body = response.data;
//       if (body is Map<String, dynamic>) {
//         final parsed = SalesmanPerformanceResponseModel.fromJson(body);
//         if (parsed.status == '1' && parsed.data != null) {
//           return SalesmanPerformanceResult.success(parsed.data);
//         }
//         return SalesmanPerformanceResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to load salesman report.',
//         );
//       }
//       return SalesmanPerformanceResult.failure(
//           'Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return SalesmanPerformanceResult.failure(
//           unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const SalesmanPerformanceResult.failure(
//           'Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /reports/contractor-performance
//   Future<ContractorPerformanceResult> getContractorPerformanceReport({
//     required String contractorId,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     try {
//       final response = await _apiClient.contractorPerformanceReport({
//         'contractor_id': contractorId,
//         'from_date': fromDate,
//         'to_date': toDate,
//       });
//       final body = response.data;
//       if (body is Map<String, dynamic>) {
//         final parsed = ContractorPerformanceResponseModel.fromJson(body);
//         if (parsed.status == '1' && parsed.data != null) {
//           return ContractorPerformanceResult.success(parsed.data);
//         }
//         return ContractorPerformanceResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to load contractor report.',
//         );
//       }
//       return ContractorPerformanceResult.failure(
//           'Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return ContractorPerformanceResult.failure(
//           unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const ContractorPerformanceResult.failure(
//           'Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /reports/quotations?page=&per_page=
//   /// Body: { type, person_id, from_date, to_date, status }
//   ///
//   /// `type` must be exactly 'salesman' or 'contractor'. `status` should be
//   /// 'all' or one of the backend's own status keys — never filter the list
//   /// client-side, the server already returns the right rows for the filter.
//   Future<QuotationReportResult> getQuotationReport({
//     required String type,
//     required String personId,
//     required String fromDate,
//     required String toDate,
//     String status = 'all',
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final response = await _apiClient.quotationReport(
//         {
//           'type': type,
//           'person_id': personId,
//           'from_date': fromDate,
//           'to_date': toDate,
//           'status': status,
//         },
//         page: page,
//         perPage: perPage,
//       );
//       final body = response.data;
//       if (body is Map<String, dynamic>) {
//         final parsed = QuotationReportResponseModel.fromJson(body);
//         if (parsed.status == '1' && parsed.data != null) {
//           return QuotationReportResult.success(parsed.data);
//         }
//         return QuotationReportResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to load quotation report.',
//         );
//       }
//       return QuotationReportResult.failure(
//           'Unexpected response: ${response.statusCode}');
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//       return QuotationReportResult.failure(
//           unauthorized ? null : message, isUnauthorized: unauthorized);
//     } catch (_) {
//       return const QuotationReportResult.failure(
//           'Something went wrong. Please try again.');
//     }
//   }
//
//   /// POST /reports/estimates?page=&per_page=
//   ///
//   /// Body:
//   /// {
//   ///   type,
//   ///   person_id,
//   ///   from_date,
//   ///   to_date,
//   ///   status // only sent when a specific status is selected
//   /// }
//   ///
//   /// `type` is exactly 'salesman' or 'contractor'.
//   ///
//   /// `status == null` means "All".
//   /// In that case the status field is NOT sent to the backend.
//   ///
//   /// Specific backend status examples:
//   /// - approved
//   /// - rejected
//   /// - despatched
//   /// - draft
//   ///
//   /// The response's summary + list are returned as-is.
//   /// No client-side filtering or relabeling.
//   Future<EstimateReportResult> getEstimateReport({
//     required String type,
//     required String personId,
//     required String fromDate,
//     required String toDate,
//     String? status,
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final requestData = <String, dynamic>{
//         'type': type,
//         'person_id': personId,
//         'from_date': fromDate,
//         'to_date': toDate,
//       };
//
//       // Only send status when a real backend status is selected.
//       //
//       // When status == null:
//       // "All" is selected and the status field is completely omitted.
//       if (status != null && status
//           .trim()
//           .isNotEmpty) {
//         requestData['status'] = status;
//       }
//
//       final response = await _apiClient.estimateReport(
//         requestData,
//         page: page,
//         perPage: perPage,
//       );
//
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final parsed = EstimateReportResponseModel.fromJson(body);
//
//         if (parsed.status == '1' && parsed.data != null) {
//           return EstimateReportResult.success(parsed.data);
//         }
//
//         return EstimateReportResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to load estimate report.',
//         );
//       }
//
//       return EstimateReportResult.failure(
//         'Unexpected response: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//
//       return EstimateReportResult.failure(
//         unauthorized ? null : message,
//         isUnauthorized: unauthorized,
//       );
//     } catch (_) {
//       return const EstimateReportResult.failure(
//         'Something went wrong. Please try again.',
//       );
//     }
//   }
//
//   /// POST /reports/incentives?page=&per_page=
//   ///
//   /// Body:
//   /// {
//   ///   type,       // 'salesman' | 'field_staff'
//   ///   person_id,
//   ///   from_date,
//   ///   to_date,
//   ///   status      // only sent when a specific status is selected
//   /// }
//   ///
//   /// `status == null` (or 'all') means "All" and the field is omitted —
//   /// same convention as getEstimateReport(). The response's summary + list
//   /// are returned as-is, no client-side filtering or relabeling.
//   Future<IncentiveReportResult> getIncentiveReport({
//     required String type,
//     required String personId,
//     required String fromDate,
//     required String toDate,
//     String? status,
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final requestData = <String, dynamic>{
//         'type': type,
//         'person_id': personId,
//         'from_date': fromDate,
//         'to_date': toDate,
//       };
//
//       if (status != null &&
//           status.trim().isNotEmpty &&
//           status.toLowerCase() != 'all') {
//         requestData['status'] = status;
//       }
//
//       final response = await _apiClient.incentiveReport(
//         requestData,
//         page: page,
//         perPage: perPage,
//       );
//
//       final body = response.data;
//
//       if (body is Map<String, dynamic>) {
//         final parsed = IncentiveReportResponseModel.fromJson(body);
//
//         if (parsed.status == '1' && parsed.data != null) {
//           return IncentiveReportResult.success(parsed.data);
//         }
//
//         return IncentiveReportResult.failure(
//           parsed.message.isNotEmpty
//               ? parsed.message
//               : 'Failed to load incentive report.',
//         );
//       }
//
//       return IncentiveReportResult.failure(
//         'Unexpected response: ${response.statusCode}',
//       );
//     } on DioException catch (e) {
//       final message = await ApiErrorHandler.handleDioError(e);
//       final unauthorized = e.response?.statusCode == 401;
//
//       return IncentiveReportResult.failure(
//         unauthorized ? null : message,
//         isUnauthorized: unauthorized,
//       );
//     } catch (_) {
//       return const IncentiveReportResult.failure(
//         'Something went wrong. Please try again.',
//       );
//     }
//   }
// }
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_reportmodel/activecontractormodel.dart';
import '../models/owner_reportmodel/activefieldstaffmodel.dart';
import '../models/owner_reportmodel/contractorperformancereportmodel.dart';
import '../models/owner_reportmodel/quotationreportmodel.dart';
import '../models/owner_reportmodel/estimatereportmodel.dart';
import '../models/owner_reportmodel/incentivereportmodel.dart';
import '../models/owner_reportmodel/salesman_performancemodel.dart';
import '../models/salesmanmodels/activeslaesman_model.dart';


class ActiveSalesmenResult {
  final bool success;
  final List<ActiveSalesmanModel> salesmen;
  final String? errorMessage;

  const ActiveSalesmenResult.success(this.salesmen)
      : success = true,
        errorMessage = null;

  const ActiveSalesmenResult.failure(this.errorMessage)
      : success = false,
        salesmen = const [];
}

class ActiveContractorsResult {
  final bool success;
  final List<ActiveContractorModel> contractors;
  final String? errorMessage;

  const ActiveContractorsResult.success(this.contractors)
      : success = true,
        errorMessage = null;

  const ActiveContractorsResult.failure(this.errorMessage)
      : success = false,
        contractors = const [];
}

/// GET /field-staff/active
class ActiveFieldStaffResult {
  final bool success;
  final List<ActiveFieldStaffModel> fieldStaff;
  final String? errorMessage;

  const ActiveFieldStaffResult.success(this.fieldStaff)
      : success = true,
        errorMessage = null;

  const ActiveFieldStaffResult.failure(this.errorMessage)
      : success = false,
        fieldStaff = const [];
}

class SalesmanPerformanceResult {
  final bool success;
  final SalesmanPerformanceReportModel? report;
  final String? errorMessage;

  const SalesmanPerformanceResult.success(this.report)
      : success = true,
        errorMessage = null;

  const SalesmanPerformanceResult.failure(this.errorMessage)
      : success = false,
        report = null;
}

class ContractorPerformanceResult {
  final bool success;
  final ContractorPerformanceReportModel? report;
  final String? errorMessage;

  const ContractorPerformanceResult.success(this.report)
      : success = true,
        errorMessage = null;

  const ContractorPerformanceResult.failure(this.errorMessage)
      : success = false,
        report = null;
}

/// Result of a call to /reports/quotations. `data` carries both the summary
/// stats and the row list straight from the server — nothing here is
/// computed or filtered on the client.
class QuotationReportResult {
  final bool success;
  final QuotationReportDataModel? data;
  final String? errorMessage;

  const QuotationReportResult.success(this.data)
      : success = true,
        errorMessage = null;

  const QuotationReportResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

/// Result of a call to /reports/estimates. `data` carries both the summary
/// stats and the row list straight from the server — nothing here is
/// computed or filtered on the client.
class EstimateReportResult {
  final bool success;
  final EstimateReportDataModel? data;
  final String? errorMessage;

  const EstimateReportResult.success(this.data)
      : success = true,
        errorMessage = null;

  const EstimateReportResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

/// Result of a call to /reports/incentives. `data` carries both the summary
/// stats and the row list straight from the server — nothing here is
/// computed or filtered on the client.
class IncentiveReportResult {
  final bool success;
  final IncentiveReportDataModel? data;
  final String? errorMessage;

  const IncentiveReportResult.success(this.data)
      : success = true,
        errorMessage = null;

  const IncentiveReportResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class OwnerReportsProvider {
  final ApiClient _apiClient;

  OwnerReportsProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /salesmen/active
  Future<ActiveSalesmenResult> getActiveSalesmen() async {
    try {
      final response = await _apiClient.activeSalesmen();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ActiveSalesmanResponseModel.fromJson(response.data);
        return ActiveSalesmenResult.success(parsed.data);
      }
      return ActiveSalesmenResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ActiveSalesmenResult.failure(message);
    }
  }

  /// GET /reports/contractors/active
  Future<ActiveContractorsResult> getActiveContractors() async {
    try {
      final response = await _apiClient.activeContractors();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ActiveContractorResponseModel.fromJson(response.data);
        return ActiveContractorsResult.success(parsed.data);
      }
      return ActiveContractorsResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ActiveContractorsResult.failure(message);
    }
  }

  /// GET /field-staff/active
  Future<ActiveFieldStaffResult> getActiveFieldStaff() async {
    try {
      final response = await _apiClient.activeFieldStaff();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ActiveFieldStaffResponseModel.fromJson(response.data);
        return ActiveFieldStaffResult.success(parsed.data);
      }
      return ActiveFieldStaffResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ActiveFieldStaffResult.failure(message);
    }
  }

  /// POST /reports/salesman-performance
  Future<SalesmanPerformanceResult> getSalesmanPerformanceReport({
    required String salesmanId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await _apiClient.salesmanPerformanceReport({
        'salesman_id': salesmanId,
        'from_date': fromDate,
        'to_date': toDate,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanPerformanceResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return SalesmanPerformanceResult.success(parsed.data);
        }
        return SalesmanPerformanceResult.failure(parsed.message);
      }
      return SalesmanPerformanceResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanPerformanceResult.failure(message);
    }
  }

  /// POST /reports/contractor-performance
  Future<ContractorPerformanceResult> getContractorPerformanceReport({
    required String contractorId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await _apiClient.contractorPerformanceReport({
        'contractor_id': contractorId,
        'from_date': fromDate,
        'to_date': toDate,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ContractorPerformanceResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return ContractorPerformanceResult.success(parsed.data);
        }
        return ContractorPerformanceResult.failure(parsed.message);
      }
      return ContractorPerformanceResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ContractorPerformanceResult.failure(message);
    }
  }

  /// POST /reports/quotations?page=&per_page=
  /// Body: { type, person_id, from_date, to_date, status }
  ///
  /// `type` must be exactly 'salesman' or 'contractor'. `status` should be
  /// 'all' or one of the backend's own status keys — never filter the list
  /// client-side, the server already returns the right rows for the filter.
  Future<QuotationReportResult> getQuotationReport({
    required String type,
    required String personId,
    required String fromDate,
    required String toDate,
    String status = 'all',
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.quotationReport(
        {
          'type': type,
          'person_id': personId,
          'from_date': fromDate,
          'to_date': toDate,
          'status': status,
        },
        page: page,
        perPage: perPage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = QuotationReportResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return QuotationReportResult.success(parsed.data);
        }
        return QuotationReportResult.failure(parsed.message);
      }
      return QuotationReportResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return QuotationReportResult.failure(message);
    }
  }

  /// POST /reports/estimates?page=&per_page=
  ///
  /// Body:
  /// {
  ///   type,
  ///   person_id,
  ///   from_date,
  ///   to_date,
  ///   status // only sent when a specific status is selected
  /// }
  ///
  /// `type` is exactly 'salesman' or 'contractor'.
  ///
  /// `status == null` means "All".
  /// In that case the status field is NOT sent to the backend.
  ///
  /// Specific backend status examples:
  /// - approved
  /// - rejected
  /// - despatched
  /// - draft
  ///
  /// The response's summary + list are returned as-is.
  /// No client-side filtering or relabeling.
  Future<EstimateReportResult> getEstimateReport({
    required String type,
    required String personId,
    required String fromDate,
    required String toDate,
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'type': type,
        'person_id': personId,
        'from_date': fromDate,
        'to_date': toDate,
      };

      // Only send status when a real backend status is selected.
      //
      // When status == null:
      // "All" is selected and the status field is completely omitted.
      if (status != null && status.trim().isNotEmpty) {
        requestData['status'] = status;
      }

      final response = await _apiClient.estimateReport(
        requestData,
        page: page,
        perPage: perPage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = EstimateReportResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return EstimateReportResult.success(parsed.data);
        }
        return EstimateReportResult.failure(parsed.message);
      }
      return EstimateReportResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return EstimateReportResult.failure(message);
    }
  }

  /// POST /reports/incentives?page=&per_page=
  ///
  /// Body:
  /// {
  ///   type,       // 'salesman' | 'field_staff'
  ///   person_id,
  ///   from_date,
  ///   to_date,
  ///   status      // only sent when a specific status is selected
  /// }
  ///
  /// `status == null` (or 'all') means "All" and the field is omitted —
  /// same convention as getEstimateReport(). The response's summary + list
  /// are returned as-is, no client-side filtering or relabeling.
  Future<IncentiveReportResult> getIncentiveReport({
    required String type,
    required String personId,
    required String fromDate,
    required String toDate,
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'type': type,
        'person_id': personId,
        'from_date': fromDate,
        'to_date': toDate,
      };

      if (status != null &&
          status.trim().isNotEmpty &&
          status.toLowerCase() != 'all') {
        requestData['status'] = status;
      }

      final response = await _apiClient.incentiveReport(
        requestData,
        page: page,
        perPage: perPage,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = IncentiveReportResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return IncentiveReportResult.success(parsed.data);
        }
        return IncentiveReportResult.failure(parsed.message);
      }
      return IncentiveReportResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return IncentiveReportResult.failure(message);
    }
  }
}