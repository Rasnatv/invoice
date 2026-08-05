import 'package:dio/dio.dart';
import '../../../../../core/errors/apierrorhandler.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/dioclient.dart';
import '../../../../models/owner_models/addcompanymodel.dart';


/// Handles all network calls for the Companies feature (list / add /
/// update / delete). Errors are converted to a plain user-facing message
/// via [ApiErrorHandler] and re-thrown as a String, so callers (the bloc)
/// can show it directly without knowing about Dio.
class CompanyRepository {
  CompanyRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<List<CompanyModel>> fetchCompanies() async {
    try {
      final response = await _dio.get(ApiConstants.companies);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw await ApiErrorHandler.handleDioError(e);
    }
  }

  Future<CompanyModel> addCompany({
    required String name,
    required String code,
    String? website,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.companies,
        data: {'name': name, 'code': code, 'website': website ?? ''},
      );
      return CompanyModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw await ApiErrorHandler.handleDioError(e);
    }
  }

  Future<void> updateCompany({
    required String id,
    required String name,
    required String code,
    String? website,
  }) async {
    try {
      await _dio.put(
        ApiConstants.updateCompany,
        data: {'id': id, 'name': name, 'code': code, 'website': website ?? ''},
      );
    } on DioException catch (e) {
      throw await ApiErrorHandler.handleDioError(e);
    }
  }

  Future<void> deleteCompany(String id) async {
    try {
      await _dio.delete(ApiConstants.deleteCompany, data: {'id': id});
    } on DioException catch (e) {
      throw await ApiErrorHandler.handleDioError(e);
    }
  }
}