
import 'package:dio/dio.dart';
import '../../core/apiclient/api_client.dart';
import '../../core/errors/apierrorhandler.dart';

import '../models/salesmanmodels/activeslaesman_model.dart';
import '../models/salesmanmodels/salesmanowner_incentivemodel.dart';

class OwnerIncentiveSummaryResult {
  final bool success;
  final SalesmanIncentiveSummaryData? data;
  final String? errorMessage;

  const OwnerIncentiveSummaryResult.success(this.data)
      : success = true,
        errorMessage = null;

  const OwnerIncentiveSummaryResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

class IncentiveProductListResult {
  final bool success;
  final List<IncentiveProductModel> products;
  final int total;
  final String? errorMessage;

  const IncentiveProductListResult.success(this.products, this.total)
      : success = true,
        errorMessage = null;

  const IncentiveProductListResult.failure(this.errorMessage)
      : success = false,
        products = const [],
        total = 0;
}

class ProductBillListResult {
  final bool success;
  final List<ProductBillModel> bills;
  final int total;
  final String? errorMessage;

  const ProductBillListResult.success(this.bills, this.total)
      : success = true,
        errorMessage = null;

  const ProductBillListResult.failure(this.errorMessage)
      : success = false,
        bills = const [],
        total = 0;
}

class MarkPaidResult {
  final bool success;
  final MarkPaidModel? data;
  final String? message;
  final String? errorMessage;

  const MarkPaidResult.success(this.data, this.message)
      : success = true,
        errorMessage = null;

  const MarkPaidResult.failure(this.errorMessage)
      : success = false,
        data = null,
        message = null;
}

class ActiveSalesmanListResult {
  final bool success;
  final List<ActiveSalesmanModel> salesmen;
  final String? errorMessage;

  const ActiveSalesmanListResult.success(this.salesmen)
      : success = true,
        errorMessage = null;

  const ActiveSalesmanListResult.failure(this.errorMessage)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = SalesmanIncentiveSummaryResponseModel.fromJson(response.data);
        return OwnerIncentiveSummaryResult.success(parsed.data);
      }
      return OwnerIncentiveSummaryResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return OwnerIncentiveSummaryResult.failure(message);
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = IncentiveProductListResponseModel.fromJson(response.data);
        final total = int.tryParse(parsed.data?.total ?? '0') ?? 0;
        return IncentiveProductListResult.success(parsed.data?.list ?? const [], total);
      }
      return IncentiveProductListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return IncentiveProductListResult.failure(message);
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ProductBillListResponseModel.fromJson(response.data);
        final total = int.tryParse(parsed.data?.total ?? '0') ?? 0;
        return ProductBillListResult.success(parsed.data?.list ?? const [], total);
      }
      return ProductBillListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProductBillListResult.failure(message);
    }
  }

  /// POST /salesman-incentives/mark-paid
  Future<MarkPaidResult> markPaid(MarkIncentivePaidRequest request) async {
    try {
      final response = await _apiClient.markSalesmanIncentivePaid(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = MarkPaidResponseModel.fromJson(response.data);
        return MarkPaidResult.success(parsed.data, parsed.message);
      }
      return MarkPaidResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return MarkPaidResult.failure(message);
    }
  }

  /// GET /salesmen/active — used for the owner's "select salesman" dropdown.
  Future<ActiveSalesmanListResult> getActiveSalesmen() async {
    try {
      final response = await _apiClient.activeSalesmen();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ActiveSalesmanResponseModel.fromJson(response.data);
        return ActiveSalesmanListResult.success(parsed.data);
      }
      return ActiveSalesmanListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ActiveSalesmanListResult.failure(message);
    }
  }
}