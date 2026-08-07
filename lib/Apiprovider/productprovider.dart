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
  final bool isUnauthorized;

  const ProductListResult.success(this.products)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ProductListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        products = const [];
}

class ProductActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  final bool isUnauthorized;

  const ProductActionResult.success(this.message)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const ProductActionResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        message = null;
}

class CompanyActiveListResult {
  final bool success;
  final List<CompanyActiveModel> companies;
  final String? errorMessage;
  final bool isUnauthorized;

  const CompanyActiveListResult.success(this.companies)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const CompanyActiveListResult.failure(this.errorMessage, {this.isUnauthorized = false})
      : success = false,
        companies = const [];
}

class UnitActiveListResult {
  final bool success;
  final List<UnitActiveModel> units;
  final String? errorMessage;
  final bool isUnauthorized;

  const UnitActiveListResult.success(this.units)
      : success = true,
        errorMessage = null,
        isUnauthorized = false;

  const UnitActiveListResult.failure(this.errorMessage, {this.isUnauthorized = false})
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
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = ProductGetResponseModel.fromJson(body);
        if (parsed.status == '1') return ProductListResult.success(parsed.data);
        return ProductListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch products.',
        );
      }
      return ProductListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ProductListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ProductListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /products/create
  Future<ProductActionResult> addProduct(ProductAddRequestModel request) async {
    try {
      final response = await _apiClient.addProduct(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = ProductAddResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return ProductActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Product created successfully.',
          );
        }
        return ProductActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to add product.',
        );
      }
      return ProductActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ProductActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ProductActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /products/update
  Future<ProductActionResult> updateProduct(ProductUpdateRequestModel request) async {
    try {
      final response = await _apiClient.updateProduct(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = ProductUpdateResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return ProductActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Product updated successfully.',
          );
        }
        return ProductActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to update product.',
        );
      }
      return ProductActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ProductActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ProductActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// POST /products/delete
  Future<ProductActionResult> deleteProduct(ProductDeleteRequestModel request) async {
    try {
      final response = await _apiClient.deleteProduct(request.toJson());
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final parsed = ProductDeleteResponseModel.fromJson(body);
        if (parsed.status == '1') {
          return ProductActionResult.success(
            parsed.message.isNotEmpty ? parsed.message : 'Product deleted successfully.',
          );
        }
        return ProductActionResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to delete product.',
        );
      }
      return ProductActionResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return ProductActionResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const ProductActionResult.failure('Something went wrong. Please try again.');
    }
  }

  /// GET /companies/active — for the company dropdown.
  Future<CompanyActiveListResult> getActiveCompanies() async {
    try {
      final response = await _apiClient.activeCompanies();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = CompanyActiveListResponseModel.fromJson(body);
        if (parsed.status == '1') return CompanyActiveListResult.success(parsed.data);
        return CompanyActiveListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch companies.',
        );
      }
      return CompanyActiveListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return CompanyActiveListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const CompanyActiveListResult.failure('Something went wrong. Please try again.');
    }
  }

  /// GET /units/active — for the unit dropdown.
  Future<UnitActiveListResult> getActiveUnits() async {
    try {
      final response = await _apiClient.activeUnits();
      final body = response.data;

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final parsed = UnitActiveListResponseModel.fromJson(body);
        if (parsed.status == '1') return UnitActiveListResult.success(parsed.data);
        return UnitActiveListResult.failure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch units.',
        );
      }
      return UnitActiveListResult.failure('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final message = await ApiErrorHandler.handleDioError(e);
      final unauthorized = e.response?.statusCode == 401;
      return UnitActiveListResult.failure(
        unauthorized ? null : message,
        isUnauthorized: unauthorized,
      );
    } catch (_) {
      return const UnitActiveListResult.failure('Something went wrong. Please try again.');
    }
  }
}
