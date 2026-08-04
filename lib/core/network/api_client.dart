import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/loginrequestmodel.dart';
import 'api_constants.dart';

import 'package:tileshop/core/network/tokenstorage.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    _initDio();
  }

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        followRedirects: true,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        client.badCertificateCallback = (_, __, ___) => true;
        return client;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  /// Adds Authorization header from the locally saved token.
  Future<Options> _authOptions() async {
    final token = await TokenStorage.readToken();
    final tokenType = await TokenStorage.readTokenType() ?? 'Bearer';
    return Options(
      headers: {
        if (token != null && token.isNotEmpty)
          "Authorization": "$tokenType $token",
      },
    );
  }

  // =================== AUTH ===================
  Future<Response> userLogin(LoginRequest request) =>
      dio.post(ApiConstants.login, data: request.toJson());

  // =================== DRIVER ===================
  Future<Response> drivers({int page = 1, int perPage = 20}) async => dio.get(
    '${ApiConstants.drivers}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> updateDriver(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateDriver,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteDriver(Map<String, dynamic> data) async => dio.post(
    ApiConstants.deleteDriver,
    data: data,
    options: await _authOptions(),
  );

  // =================== DESIGNATION ===================
  Future<Response> salesmanDesignations({int page = 1, int perPage = 20}) async =>
      dio.get(
        '${ApiConstants.salesmanDesignations}?page=$page&per_page=$perPage',
        options: await _authOptions(),
      );

  Future<Response> updateDesignation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateDesignation,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteDesignation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.deleteDesignation,
    data: data,
    options: await _authOptions(),
  );

  // =================== SALESMAN ===================
  Future<Response> salesmen({int page = 1, int perPage = 20}) async => dio.get(
    '${ApiConstants.salesmen}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> updateSalesman(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateSalesman,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteSalesman(Map<String, dynamic> data) async => dio.post(
    ApiConstants.deleteSalesman,
    data: data,
    options: await _authOptions(),
  );

  // =================== FIELD STAFF ===================
  Future<Response> fieldStaff({int page = 1, int perPage = 20}) async => dio.get(
    '${ApiConstants.fieldStaff}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> updateFieldStaff(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateFieldStaff,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteFieldStaff(Map<String, dynamic> data) async => dio.post(
    ApiConstants.deleteFieldStaff,
    data: data,
    options: await _authOptions(),
  );

  // =================== UNITS ===================
  Future<Response> units({int page = 1, int perPage = 20}) async => dio.get(
    '${ApiConstants.units}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> updateUnit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateUnit,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteUnit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.deleteUnit,
    data: data,
    options: await _authOptions(),
  );

  // =================== COMPANIES ===================
  Future<Response> companies({int page = 1, int perPage = 20}) async => dio.get(
    '${ApiConstants.companies}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> updateCompany(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateCompany,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteCompany(Map<String, dynamic> data) async => dio.post(
    ApiConstants.deleteCompany,
    data: data,
    options: await _authOptions(),
  );
}