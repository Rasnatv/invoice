
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
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
  final bool isUnauthorized;

  const SiteVisitDropdownResult.success(this.list)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const SiteVisitDropdownResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        list = const [];
}

class ActiveProductResult {
  final bool success;
  final List<ActiveProductModel> list;
  final String? errorMessage;
  final bool isUnauthorized;

  const ActiveProductResult.success(this.list)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ActiveProductResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        list = const [];
}

class QuotationActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const QuotationActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const QuotationActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

/// Result wrapper for POST /quotations/product-incentive.
class ProductIncentiveResult {
  final bool success;
  final ProductIncentiveModel? incentive;
  final String? errorMessage;
  final bool isUnauthorized;

  const ProductIncentiveResult.success(this.incentive)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ProductIncentiveResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        incentive = null;
}

/// Result wrapper for GET /quotations/my.
class QuotationListResult {
  final bool success;
  final List<QuotationListItem> list;
  final String? errorMessage;
  final bool isUnauthorized;

  const QuotationListResult.success(this.list)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const QuotationListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        list = const [];
}

/// Result wrapper for POST /quotations/show.
class QuotationDetailResult {
  final bool success;
  final QuotationDetailModel? detail;
  final String? errorMessage;
  final bool isUnauthorized;

  const QuotationDetailResult.success(this.detail)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const QuotationDetailResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        detail = null;
}

/// Result wrapper for POST /quotations/preview.
class QuotationPreviewResult {
  final bool success;
  final QuotationPreviewData? preview;
  final String? errorMessage;
  final bool isUnauthorized;

  const QuotationPreviewResult.success(this.preview)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const QuotationPreviewResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        preview = null;
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
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = SiteVisitDropdownResponseModel.fromJson(body);
        if (parsed.status == '1') return SiteVisitDropdownResult.success(parsed.list);
        return SiteVisitDropdownResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch site visits.',
        );
      }
      return SiteVisitDropdownResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return SiteVisitDropdownResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const SiteVisitDropdownResult.failure('Something went wrong. Please try again.');
    }
  }

  /// GET /products/active
  Future<ActiveProductResult> getActiveProducts() async {
    try {
      final response = await _apiClient.activeProducts();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = ActiveProductResponseModel.fromJson(body);
        if (parsed.status == '1') return ActiveProductResult.success(parsed.list);
        return ActiveProductResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch products.',
        );
      }
      return ActiveProductResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ActiveProductResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ActiveProductResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/product-incentive — live incentive preview for the
  /// item currently being entered on the Add Items step (not yet added to
  /// the estimate).
  Future<ProductIncentiveResult> getProductIncentive(ProductIncentiveRequest request) async {
    try {
      final response = await _apiClient.productIncentive(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = ProductIncentiveResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return ProductIncentiveResult.success(parsed.data);
        }
        return ProductIncentiveResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch incentive.',
        );
      }
      return ProductIncentiveResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ProductIncentiveResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ProductIncentiveResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/preview — server-calculated preview (line incentives,
  /// subtotal, handling charge, discount, grand total, balance due) for
  /// whatever the salesman has entered so far on the estimate. Only fields
  /// actually captured on screen are sent — no discount/payment, since
  /// this flow doesn't collect those.
  Future<QuotationPreviewResult> previewQuotation(QuotationPreviewRequest request) async {
    try {
      final response = await _apiClient.previewQuotation(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = QuotationPreviewResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return QuotationPreviewResult.success(parsed.data);
        }
        return QuotationPreviewResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to calculate preview.',
        );
      }
      return QuotationPreviewResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationPreviewResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationPreviewResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/create
  /// `request.action` must be 'save_quotation' or 'submit' when called from
  /// the salesman screen.
  Future<QuotationActionResult> createQuotation(QuotationCreateRequest request) async {
    try {
      final response = await _apiClient.createQuotation(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = QuotationCreateResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return QuotationActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Estimate saved successfully.',
          );
        }
        return QuotationActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to save estimate.',
        );
      }
      return QuotationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// GET /quotations/my — the logged-in salesman/owner's own quotations,
  /// newest first (server-ordered).
  Future<QuotationListResult> getMyQuotations() async {
    try {
      final response = await _apiClient.myQuotations();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = QuotationListResponseModel.fromJson(body);
        if (parsed.status == '1') return QuotationListResult.success(parsed.list);
        return QuotationListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch quotations.',
        );
      }
      return QuotationListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/show — full detail of a single quotation/estimate.
  Future<QuotationDetailResult> getQuotationDetail(String id) async {
    try {
      final response = await _apiClient.showQuotation(QuotationIdRequest(id).toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = QuotationDetailResponseModel.fromJson(body);
        if (parsed.status == '1' && parsed.data != null) {
          return QuotationDetailResult.success(parsed.data);
        }
        return QuotationDetailResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch quotation.',
        );
      }
      return QuotationDetailResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationDetailResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationDetailResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/update — updates an existing (draft) quotation.
  Future<QuotationActionResult> updateQuotation(QuotationUpdateRequest request) async {
    try {
      final response = await _apiClient.updateQuotation(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString();
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return QuotationActionResult.success(
            message.isNotEmpty ? message : 'Quotation updated successfully.',
          );
        }
        return QuotationActionResult.failure(
          message.isNotEmpty ? message : 'Failed to update quotation.',
        );
      }
      return QuotationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/delete
  Future<QuotationActionResult> deleteQuotation(String id) async {
    try {
      final response = await _apiClient.deleteQuotation(QuotationIdRequest(id).toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString();
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return QuotationActionResult.success(
            message.isNotEmpty ? message : 'Quotation deleted successfully.',
          );
        }
        return QuotationActionResult.failure(
          message.isNotEmpty ? message : 'Failed to delete quotation.',
        );
      }
      return QuotationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /quotations/submit — sends a saved (draft) quotation for
  /// admin/owner approval.
  Future<QuotationActionResult> submitQuotationForApproval(String id) async {
    try {
      final response = await _apiClient.submitQuotation(QuotationIdRequest(id).toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final status = body['status']?.toString();
        final message = body['message']?.toString() ?? '';
        if (status == '1') {
          return QuotationActionResult.success(
            message.isNotEmpty ? message : 'Quotation sent for approval successfully.',
          );
        }
        return QuotationActionResult.failure(
          message.isNotEmpty ? message : 'Failed to submit for approval.',
        );
      }
      return QuotationActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return QuotationActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const QuotationActionResult.failure('Something went wrong. Please try again.');
    }
  }
}