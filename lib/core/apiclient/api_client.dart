
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../models/loginrequestmodel.dart';
import '../network/api_constants.dart';
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
  Future<Response> drivers() async => dio.get(
    ApiConstants.driversget,
    options: await _authOptions(),
  );

  /// POST /drivers/create — unconfirmed against a real response; if your
  /// backend actually creates drivers at the same URL as the list (like
  /// units/designations do), point this at ApiConstants.driversget instead.
  Future<Response> addDriver(Map<String, dynamic> data) async => dio.post(
    ApiConstants.driverscreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateDriver(Map<String, dynamic> data) async => dio.put(
    ApiConstants.updateDriver,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteDriver(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.deleteDriver,
    data: data,
    options: await _authOptions(),
  );

  // =================== DESIGNATION ===================
  Future<Response> salesmanDesignations() async => dio.get(
    ApiConstants.salesmanDesignations,
    options: await _authOptions(),
  );

  /// POST /salesman-designations — kept on the SAME path as the list, not
  /// ApiConstants.salemancretae ('/salesman-designations/create'), because
  /// your confirmed real response showed create hitting this exact URL.
  Future<Response> addDesignation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salemancretaedesignation,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateDesignation(Map<String, dynamic> data) async => dio.put(
    ApiConstants.updateDesignation,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteDesignation(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.deleteDesignation,
    data: data,
    options: await _authOptions(),
  );

  // =================== SALESMAN ===================
  Future<Response> salesmen() async => dio.get(
    ApiConstants.salesmen,
    options: await _authOptions(),
  );

  /// POST /salesmen/create — unconfirmed against a real response; verify
  /// this is actually a separate endpoint and not the same URL as `salesmen`.
  Future<Response> addSalesman(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salesmancreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateSalesman(Map<String, dynamic> data) async => dio.put(
    ApiConstants.updateSalesman,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteSalesman(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.deleteSalesman,
    data: data,
    options: await _authOptions(),
  );

  // =================== FIELD STAFF ===================
  /// POST /field-staff/create — unconfirmed against a real response; verify
  /// this is actually a separate endpoint and not the same URL as `fieldStaff`.
  Future<Response> addFieldStaff(Map<String, dynamic> data) async => dio.post(
    ApiConstants.fieldstaffcreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> fieldStaff() async => dio.get(
    ApiConstants.fieldStaff,
    options: await _authOptions(),
  );

  Future<Response> updateFieldStaff(Map<String, dynamic> data) async => dio.put(
    ApiConstants.updateFieldStaff,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteFieldStaff(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.deleteFieldStaff,
    data: data,
    options: await _authOptions(),
  );

  // =================== UNITS ===================
  Future<Response> units() async => dio.get(
    ApiConstants.units,
    options: await _authOptions(),
  );

  Future<Response> addUnit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.units,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateUnit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.updateUnit,
    data: data,
    options: await _authOptions(),
  );

  /// Fixed back to POST — your confirmed real response showed
  /// /units/delete working via POST, not DELETE.
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

  /// POST /companies/create — unconfirmed against a real response; verify
  /// this is actually a separate endpoint and not the same URL as `companies`.
  Future<Response> addCompany(Map<String, dynamic> data) async => dio.post(
    ApiConstants.companycreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateCompany(Map<String, dynamic> data) async => dio.put(
    ApiConstants.updateCompany,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteCompany(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.deleteCompany,
    data: data,
    options: await _authOptions(),
  );

  //--------------------------------------FieldstaffSection---------------------

  // =================== SITE VISITS ===================

  /// POST /site-visits/create
  Future<Response> createSiteVisit(Map<String, dynamic> data,) async => dio.post(
    ApiConstants.siteVisitCreate,
    data: data,
    options: await _authOptions(),
  );

  /// GET /site-visits/my
  Future<Response> mySiteVisits() async => dio.get(
    ApiConstants.siteVisitsMy,
    options: await _authOptions(),
  );

  /// POST /site-visits/show
  Future<Response> showSiteVisit(Map<String, dynamic> data,) async => dio.post(
    ApiConstants.siteVisitShow,
    data: data,
    options: await _authOptions(),
  );

  /// POST /site-visits/update
  Future<Response> updateSiteVisit(Map<String, dynamic> data,
      ) async => dio.put(
    ApiConstants.siteVisitUpdate,
    data: data,
    options: await _authOptions(),
  );

  /// POST /site-visits/delete
  Future<Response> deleteSiteVisit(Map<String, dynamic> data,) async => dio.delete(
    ApiConstants.siteVisitDelete,
    data: data,
    options: await _authOptions(),
  );

  /// GET /site-visits/pending-dropdown — pending site visits for the
  /// phone-number lookup on the Create Estimate screen. Returns the full
  /// pending list; filtering by phone digits happens client-side.
  Future<Response> pendingSiteVisitsDropdown() async => dio.get(
    ApiConstants.siteVisitsPendingDropdown,
    options: await _authOptions(),
  );

  // =================== PRODUCTS ===================
  Future<Response> products({int page = 1, int perPage = 10}) async => dio.get(
    '${ApiConstants.products}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  /// POST /products/create
  Future<Response> addProduct(Map<String, dynamic> data) async => dio.post(
    ApiConstants.productsCreate,
    data: data,
    options: await _authOptions(),
  );

  /// POST /products/update
  Future<Response> updateProduct(Map<String, dynamic> data) async => dio.put(
    ApiConstants.productsUpdate,
    data: data,
    options: await _authOptions(),
  );

  /// POST /products/delete
  Future<Response> deleteProduct(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.productsDelete,
    data: data,
    options: await _authOptions(),
  );

  /// GET /products/active — active products for the item dropdown on the
  /// Create Estimate screen (id/name/company/size/unit only, no pricing).
  Future<Response> activeProducts() async => dio.get(
    ApiConstants.productsActive,
    options: await _authOptions(),
  );

  // =================== COMPANIES (active — for dropdown) ===================
  Future<Response> activeCompanies() async => dio.get(
    ApiConstants.companiesActive,
    options: await _authOptions(),
  );

  // =================== UNITS (active — for dropdown) ===================
  Future<Response> activeUnits() async => dio.get(
    ApiConstants.unitsActive,
    options: await _authOptions(),
  );

  // =================== QUOTATIONS / ESTIMATES ===================

  /// POST /quotations/create — used by both the salesman and owner Create
  /// Estimate screens. `data['action']` drives server-side behavior:
  ///   - 'save_quotation' -> saved as a draft
  ///   - 'submit'          -> submitted for admin/owner approval
  ///   - 'approve'         -> owner-only, finalizes the estimate
  Future<Response> createQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsCreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> productIncentive(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsProductIncentive,
    data: data,
    options: await _authOptions(),
  );

  /// GET /quotations/my — the logged-in salesman/owner's own quotations.
  Future<Response> myQuotations() async => dio.get(
    ApiConstants.quotationsMy,
    options: await _authOptions(),
  );

  /// POST /quotations/show — full detail of a single quotation. Body: { "id": "..." }
  Future<Response> showQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsShow,
    data: data,
    options: await _authOptions(),
  );

  /// POST /quotations/update — updates an existing (draft) quotation.
  Future<Response> updateQuotation(Map<String, dynamic> data) async => dio.put(
    ApiConstants.quotationsUpdate,
    data: data,
    options: await _authOptions(),
  );

  /// POST /quotations/delete — deletes a quotation. Body: { "id": "..." }
  Future<Response> deleteQuotation(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.quotationsDelete,
    data: data,
    options: await _authOptions(),
  );

  /// POST /quotations/submit — sends a saved (draft) quotation for
  /// admin/owner approval. Body: { "id": "..." }
  Future<Response> submitQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsSubmit,
    data: data,
    options: await _authOptions(),
  );
  // =================== DASHBOARD ===================
  Future<Response> dashboard() async => dio.get(
    ApiConstants.dashboard,
    options: await _authOptions(),
  );
  /// POST /quotations/preview
  ///
  Future<Response> previewQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.qtnpreview,
    data: data,
    options: await _authOptions(),
  );
  // =================== ESTIMATES ===================

  /// POST /estimates/show — full detail of a single estimate. Body: { "id": "..." }
  Future<Response> showEstimate(Map<String, dynamic> data) async => dio.post(
    ApiConstants.estimatesShow,
    data: data,
    options: await _authOptions(),
  );
  /// GET /estimates/myapproved — the logged-in salesman/owner's approved
  /// estimates, paginated.
  Future<Response> myApprovedEstimates({int page = 1, int perPage = 10}) async => dio.get(
    '${ApiConstants.estimatesMyApproved}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

}