
import 'package:dio/dio.dart';
import '../core/apiclient/api_client.dart';
import '../core/errors/apierrorhandler.dart';
import '../models/owner_models/activeuintmodel.dart';
import '../models/owner_models/addproductmodel.dart';
import '../models/owner_models/deleteproductmodel.dart';
import '../models/owner_models/activecompanymodel.dart';
import '../models/owner_models/getproductmodel.dart';
import '../models/owner_models/updateproductmodel.dart';

class ProductListResult {
  final bool success;
  final List<ProductModel> products;
  final String? errorMessage;

  const ProductListResult.success(this.products)
      : success = true,
        errorMessage = null;

  const ProductListResult.failure(this.errorMessage)
      : success = false,
        products = const [];
}

class ProductActionResult {
  final bool success;
  final String? message;

  const ProductActionResult({
    required this.success,
    this.message,
  });
}

class CompanyActiveListResult {
  final bool success;
  final List<CompanyActiveModel> companies;
  final String? errorMessage;

  const CompanyActiveListResult.success(this.companies)
      : success = true,
        errorMessage = null;

  const CompanyActiveListResult.failure(this.errorMessage)
      : success = false,
        companies = const [];
}

class UnitActiveListResult {
  final bool success;
  final List<UnitActiveModel> units;
  final String? errorMessage;

  const UnitActiveListResult.success(this.units)
      : success = true,
        errorMessage = null;

  const UnitActiveListResult.failure(this.errorMessage)
      : success = false,
        units = const [];
}

class ProductProvider {
  final ApiClient _apiClient;

  ProductProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// GET /products
  Future<ProductListResult> getProducts({int page = 1, int perPage = 10}) async {
    try {
      final response = await _apiClient.products(page: page, perPage: perPage);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = ProductGetResponseModel.fromJson(response.data);
        return ProductListResult.success(parsed.data);
      }
      return ProductListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProductListResult.failure(message);
    }
  }

  // ---------------- actions ----------------

  /// POST /products/create
  Future<ProductActionResult> addProduct(ProductAddRequestModel request) => _actionCall(
        () => _apiClient.addProduct(request.toJson()),
        (data) => ProductAddResponseModel.fromJson(data).message,
  );

  /// POST /products/update
  Future<ProductActionResult> updateProduct(ProductUpdateRequestModel request) => _actionCall(
        () => _apiClient.updateProduct(request.toJson()),
        (data) => ProductUpdateResponseModel.fromJson(data).message,
  );

  /// POST /products/delete
  Future<ProductActionResult> deleteProduct(ProductDeleteRequestModel request) => _actionCall(
        () => _apiClient.deleteProduct(request.toJson()),
        (data) => ProductDeleteResponseModel.fromJson(data).message,
  );

  /// Shared response handling for /products/create, /update and /delete —
  /// all three just need a status-code check and a message extracted from
  /// the body via their own response model.
  Future<ProductActionResult> _actionCall(
      Future<Response> Function() request,
      String? Function(dynamic data) extractMessage,
      ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductActionResult(success: true, message: extractMessage(response.data));
      }
      return ProductActionResult(success: false, message: response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return ProductActionResult(success: false, message: message);
    }
  }

  /// GET /companies/active — for the company dropdown.
  Future<CompanyActiveListResult> getActiveCompanies() async {
    try {
      final response = await _apiClient.activeCompanies();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = CompanyActiveListResponseModel.fromJson(response.data);
        return CompanyActiveListResult.success(parsed.data);
      }
      return CompanyActiveListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return CompanyActiveListResult.failure(message);
    }
  }

  /// GET /units/active — for the unit dropdown.
  Future<UnitActiveListResult> getActiveUnits() async {
    try {
      final response = await _apiClient.activeUnits();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = UnitActiveListResponseModel.fromJson(response.data);
        return UnitActiveListResult.success(parsed.data);
      }
      return UnitActiveListResult.failure(response.statusCode.toString());
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      return UnitActiveListResult.failure(message);
    }
  }
}
