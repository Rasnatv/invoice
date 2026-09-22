
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/get_activedrivermodel.dart';
import '../models/owner_models/owner_quotationapprovemodel.dart';
import '../models/salesmanmodels/cretaeestimate_quotationmodel.dart';
import '../models/salesmanmodels/estimate_activepdctmodel.dart';
import '../models/salesmanmodels/estimatesectionproductincentive.dart';
import '../models/salesmanmodels/estimatewith_activesitedropdownmodel.dart';
import '../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../models/salesmanmodels/quotationlistmodel.dart';
import '../models/salesmanmodels/quotationupdatemodel.dart';
import '../models/salesmanmodels/salesman_qtnpreviewmodel.dart';


class SiteVisitDropdownResult {
  final bool success;
  final List<SiteVisitDropdownItem> list;
  final String? errorMessage;

  const SiteVisitDropdownResult.success(this.list)
      : success = true,
        errorMessage = null;

  const SiteVisitDropdownResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

class ActiveProductResult {
  final bool success;
  final List<ActiveProductModel> list;
  final String? errorMessage;

  const ActiveProductResult.success(this.list)
      : success = true,
        errorMessage = null;

  const ActiveProductResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

class QuotationActionResult {
  final bool success;
  final String? message;

  const QuotationActionResult({
    required this.success,
    this.message,
  });
}

/// Result wrapper for POST /quotations/product-incentive.
class ProductIncentiveResult {
  final bool success;
  final ProductIncentiveModel? incentive;
  final String? errorMessage;

  const ProductIncentiveResult.success(this.incentive)
      : success = true,
        errorMessage = null;

  const ProductIncentiveResult.failure(this.errorMessage)
      : success = false,
        incentive = null;
}

/// Result wrapper for GET /quotations/my.
class QuotationListResult {
  final bool success;
  final List<QuotationListItem> list;
  final String? errorMessage;

  const QuotationListResult.success(this.list)
      : success = true,
        errorMessage = null;

  const QuotationListResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

/// Result wrapper for POST /quotations/show.
class QuotationDetailResult {
  final bool success;
  final QuotationDetailModel? detail;
  final String? errorMessage;

  const QuotationDetailResult.success(this.detail)
      : success = true,
        errorMessage = null;

  const QuotationDetailResult.failure(this.errorMessage)
      : success = false,
        detail = null;
}

/// Result wrapper for POST /quotations/preview.
class QuotationPreviewResult {
  final bool success;
  final QuotationPreviewData? preview;
  final String? errorMessage;

  const QuotationPreviewResult.success(this.preview)
      : success = true,
        errorMessage = null;

  const QuotationPreviewResult.failure(this.errorMessage)
      : success = false,
        preview = null;
}

/// Result wrapper for GET /salesmen/active.
class SalesmanListResult {
  final bool success;
  final List<SalesmanActiveModel> list;
  final String? errorMessage;

  const SalesmanListResult.success(this.list)
      : success = true,
        errorMessage = null;

  const SalesmanListResult.failure(this.errorMessage)
      : success = false,
        list = const [];
}

/// Provider for the salesman/owner estimate ("quotation") flow. Mirrors
/// DriverProvider's shape 1:1 (result classes + try/catch) so it drops
/// straight into the same Bloc/Cubit wiring style already used elsewhere.
class QuotationProvider {
  final ApiClient _apiClient;

  QuotationProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /site-visits/pending-dropdown
  Future<SiteVisitDropdownResult> getPendingSiteVisits() async {
    try {
      final response = await _apiClient.pendingSiteVisitsDropdown();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SiteVisitDropdownResponseModel.fromJson(response.data);
        return SiteVisitDropdownResult.success(parsed.list);
      }
      return SiteVisitDropdownResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SiteVisitDropdownResult.failure(message);
    }
  }

  /// GET /products/active
  Future<ActiveProductResult> getActiveProducts() async {
    try {
      final response = await _apiClient.activeProducts();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ActiveProductResponseModel.fromJson(response.data);
        return ActiveProductResult.success(parsed.list);
      }
      return ActiveProductResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ActiveProductResult.failure(message);
    }
  }

  /// GET /salesmen/active — used to populate the "Assign to Salesman"
  /// dropdown on the Owner Create Estimate screen's Preview step.
  Future<SalesmanListResult> getActiveSalesmen() async {
    try {
      final response = await _apiClient.activeSalesmen();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanActiveResponseModel.fromJson(response.data);
        return SalesmanListResult.success(parsed.list);
      }
      return SalesmanListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return SalesmanListResult.failure(message);
    }
  }

  /// POST /quotations/product-incentive — live incentive preview for the
  /// item currently being entered on the Add Items step (not yet added to
  /// the estimate).
  Future<ProductIncentiveResult> getProductIncentive(ProductIncentiveRequest request) async {
    try {
      final response = await _apiClient.productIncentive(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ProductIncentiveResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return ProductIncentiveResult.success(parsed.data);
        }
        return ProductIncentiveResult.failure(parsed.message);
      }
      return ProductIncentiveResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProductIncentiveResult.failure(message);
    }
  }

  /// POST /quotations/preview — server-calculated preview (line incentives,
  /// subtotal, handling charge, discount, grand total, balance due) for
  /// whatever has been entered so far on the estimate.
  Future<QuotationPreviewResult> previewQuotation(QuotationPreviewRequest request) async {
    try {
      final response = await _apiClient.previewQuotation(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = QuotationPreviewResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return QuotationPreviewResult.success(parsed.data);
        }
        return QuotationPreviewResult.failure(parsed.message);
      }
      return QuotationPreviewResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return QuotationPreviewResult.failure(message);
    }
  }

  /// POST /quotations/create
  /// `request.action` must be 'save_quotation' or 'submit' from the
  /// salesman screen, or 'approve' from the owner screen (in which case
  /// `salesmanId` plus any discount_*/payment_* fields are sent along).
  Future<QuotationActionResult> createQuotation(QuotationCreateRequest request) => _actionCall(
        () => _apiClient.createQuotation(request.toJson()),
        (data) {
      final parsed = QuotationCreateResponseModel.fromJson(data);
      return (status: parsed.status, message: parsed.message);
    },
  );

  /// GET /quotations/my — the logged-in salesman/owner's own quotations,
  /// newest first (server-ordered).
  Future<QuotationListResult> getMyQuotations() async {
    try {
      final response = await _apiClient.myQuotations();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = QuotationListResponseModel.fromJson(response.data);
        return QuotationListResult.success(parsed.list);
      }
      return QuotationListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return QuotationListResult.failure(message);
    }
  }

  /// POST /quotations/show — full detail of a single quotation/estimate.
  Future<QuotationDetailResult> getQuotationDetail(String id) async {
    try {
      final response = await _apiClient.showQuotation(QuotationIdRequest(id).toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = QuotationDetailResponseModel.fromJson(response.data);
        if (parsed.data != null) {
          return QuotationDetailResult.success(parsed.data);
        }
        return QuotationDetailResult.failure(parsed.message);
      }
      return QuotationDetailResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return QuotationDetailResult.failure(message);
    }
  }

  /// POST /quotations/update — updates an existing (draft) quotation.
  Future<QuotationActionResult> updateQuotation(QuotationUpdateRequest request) => _actionCall(
        () => _apiClient.updateQuotation(request.toJson()),
        (data) => (status: data['status']?.toString(), message: data['message']?.toString()),
  );

  /// POST /quotations/delete
  Future<QuotationActionResult> deleteQuotation(String id) => _actionCall(
        () => _apiClient.deleteQuotation(QuotationIdRequest(id).toJson()),
        (data) => (status: data['status']?.toString(), message: data['message']?.toString()),
  );

  /// POST /quotations/submit — sends a saved (draft) quotation for
  /// admin/owner approval.
  Future<QuotationActionResult> submitQuotationForApproval(String id) => _actionCall(
        () => _apiClient.submitQuotation(QuotationIdRequest(id).toJson()),
        (data) => (status: data['status']?.toString(), message: data['message']?.toString()),
  );

  /// POST /quotations/approve — owner-only. Approves an already-submitted
  /// quotation/estimate (separate flow from creating one directly as
  /// approved via /quotations/create with action=approve).
  Future<QuotationActionResult> approveQuotation(QuotationApproveRequest request) => _actionCall(
        () => _apiClient.approveQuotation(request.toJson()),
        (data) {
      final parsed = QuotationApproveResponseModel.fromJson(data);
      return (status: parsed.status, message: parsed.message);
    },
  );

  /// Shared response handling for every /quotations/* action endpoint
  /// (create, update, delete, submit, approve). Each one reports success
  /// via a body `status` field rather than the HTTP status code alone, so
  /// [extract] pulls out that pair however the specific endpoint's body
  /// is shaped (raw map or a dedicated response model).
  Future<QuotationActionResult> _actionCall(
  Future<Response> Function() request,
  ({String? status, String? message}) Function(dynamic data) extract,
  ) async {
  try {
  final response = await request();

  if (response.statusCode == 200 || response.statusCode == 201) {
  final result = extract(response.data);
  return QuotationActionResult(success: result.status == '1', message: result.message);
  }
  return QuotationActionResult(
  success: false,
  message: response.statusCode.toString(),
  );
  } on DioException catch (e) {
  final message = await ApiErrorHandler.handleDioError(e);
  return QuotationActionResult(success: false, message: message);
  }
  }
}