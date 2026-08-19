import 'package:dio/dio.dart';
import '../../core/apiclient/api_client.dart';
import '../../core/errors/apierrorhandler.dart';

import '../models/salesmanmodels/activeslaesman_model.dart';
import '../models/salesmanmodels/salesmanowner_incentivemodel.dart';

class OwnerIncentiveSummaryResult {
  final bool success;
  final SalesmanIncentiveSummaryData? data;
  final String? errorMessage;
  final bool isUnauthorized;

  const OwnerIncentiveSummaryResult.success(this.data)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const OwnerIncentiveSummaryResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        data = null;
}

class IncentiveProductListResult {
  final bool success;
  final List<IncentiveProductModel> products;
  final int total;
  final String? errorMessage;
  final bool isUnauthorized;

  const IncentiveProductListResult.success(this.products, this.total)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const IncentiveProductListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        products = const [],
        total = 0;
}

class ProductBillListResult {
  final bool success;
  final List<ProductBillModel> bills;
  final int total;
  final String? errorMessage;
  final bool isUnauthorized;

  const ProductBillListResult.success(this.bills, this.total)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ProductBillListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        bills = const [],
        total = 0;
}

class MarkPaidResult {
  final bool success;
  final MarkPaidModel? data;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const MarkPaidResult.success(this.data, this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const MarkPaidResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        data = null,
        message = null;
}

class ActiveSalesmanListResult {
  final bool success;
  final List<ActiveSalesmanModel> salesmen;
  final String? errorMessage;
  final bool isUnauthorized;

  const ActiveSalesmanListResult.success(this.salesmen)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ActiveSalesmanListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        salesmen = const [];
}

class OwnerIncentiveProvider {
  final ApiClient _apiClient;

  OwnerIncentiveProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// POST /salesman-incentives/summary
  Future<OwnerIncentiveSummaryResult> getSummary(SalesmanIncentiveSummaryRequest request) async {
    try {
      final response = await _apiClient.salesmanIncentiveSummary(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = SalesmanIncentiveSummaryResponseModel.fromJson(body);
        if (parsed.status == '1') return OwnerIncentiveSummaryResult.success(parsed.data);
        return OwnerIncentiveSummaryResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch incentive summary.',
        );
      }
      return OwnerIncentiveSummaryResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return OwnerIncentiveSummaryResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const OwnerIncentiveSummaryResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /salesman-incentives/products?page=&per_page=
  Future<IncentiveProductListResult> getProducts(IncentiveProductsRequest request) async {
    try {
      final response = await _apiClient.salesmanIncentiveProducts(
        request.toJson(),
        page: request.page,
        perPage: request.perPage,
      );
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = IncentiveProductListResponseModel.fromJson(body);
        if (parsed.status == '1') {
          final total = int.tryParse(parsed.data?.total ?? '0') ?? 0;
          return IncentiveProductListResult.success(parsed.data?.list ?? const [], total);
        }
        return IncentiveProductListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch product list.',
        );
      }
      return IncentiveProductListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return IncentiveProductListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const IncentiveProductListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /salesman-incentives/product-bills?page=&per_page=
  Future<ProductBillListResult> getProductBills(ProductBillsRequest request) async {
    try {
      final response = await _apiClient.salesmanIncentiveProductBills(
        request.toJson(),
        page: request.page,
        perPage: request.perPage,
      );
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = ProductBillListResponseModel.fromJson(body);
        if (parsed.status == '1') {
          final total = int.tryParse(parsed.data?.total ?? '0') ?? 0;
          return ProductBillListResult.success(parsed.data?.list ?? const [], total);
        }
        return ProductBillListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch bills.',
        );
      }
      return ProductBillListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ProductBillListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ProductBillListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /salesman-incentives/mark-paid
  Future<MarkPaidResult> markPaid(MarkIncentivePaidRequest request) async {
    try {
      final response = await _apiClient.markSalesmanIncentivePaid(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = MarkPaidResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return MarkPaidResult.success(
            parsed.data,
            parsed.message.isNotEmpty ? parsed.message : 'Incentive marked as paid.',
          );
        }
        return MarkPaidResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to mark incentive as paid.',
        );
      }
      return MarkPaidResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return MarkPaidResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const MarkPaidResult.failure('Something went wrong. Please try again.');
    }
  }

  /// GET /salesmen/active — used for the owner's "select salesman" dropdown.
  Future<ActiveSalesmanListResult> getActiveSalesmen() async {
    try {
      final response = await _apiClient.activeSalesmen();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = ActiveSalesmanResponseModel.fromJson(body);
        if (parsed.status == '1') return ActiveSalesmanListResult.success(parsed.data);
        return ActiveSalesmanListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch salesmen.',
        );
      }
      return ActiveSalesmanListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ActiveSalesmanListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ActiveSalesmanListResult.failure('Something went wrong. Please try again.');
    }
  }
}