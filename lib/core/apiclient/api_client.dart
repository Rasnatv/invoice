//
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import '../../models/loginrequestmodel.dart';
// import '../network/api_constants.dart';
// import 'package:tileshop/core/network/tokenstorage.dart';
//
// class ApiClient {
//   late Dio dio;
//
//   ApiClient() {
//     _initDio();
//   }
//
//   void _initDio() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConstants.baseUrl,
//         connectTimeout: const Duration(seconds: 15),
//         receiveTimeout: const Duration(seconds: 15),
//         followRedirects: true,
//         headers: {
//           HttpHeaders.contentTypeHeader: 'application/json',
//           HttpHeaders.acceptHeader: 'application/json',
//         },
//         responseType: ResponseType.json,
//         receiveDataWhenStatusError: true,
//       ),
//     );
//
//     dio.httpClientAdapter = IOHttpClientAdapter(
//       createHttpClient: () {
//         final client = HttpClient(
//           context: SecurityContext(withTrustedRoots: false),
//         );
//         client.badCertificateCallback = (_, __, ___) => true;
//         return client;
//       },
//     );
//
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) => handler.next(options),
//         onError: (error, handler) => handler.next(error),
//       ),
//     );
//   }
//
//   /// Adds Authorization header from the locally saved token.
//   Future<Options> _authOptions() async {
//     final token = await TokenStorage.readToken();
//     final tokenType = await TokenStorage.readTokenType() ?? 'Bearer';
//     return Options(
//       headers: {
//         if (token != null && token.isNotEmpty)
//           "Authorization": "$tokenType $token",
//       },
//     );
//   }
//
//   // =================== AUTH ===================
//   Future<Response> userLogin(LoginRequest request) =>
//       dio.post(ApiConstants.login, data: request.toJson());
//
//
//
//   /// GET /profile
//   Future<Response> getProfile() async => dio.get(
//     ApiConstants.profile,
//     options: await _authOptions(),
//   );
//
//   /// PUT /profile
//   Future<Response> updateProfile(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.profileUpdate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /change-password
//   /// Body: { current_password, new_password, new_password_confirmation }
//   Future<Response> changePassword(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.changePassword,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== FORGOT PASSWORD ===================
//   // Requires two new entries in ApiConstants (mirroring `login` above):
//   //   static const String forgotPassword = 'forgot-password';
//   //   static const String verifyOtp = 'verify-otp';
//   //   static const String resetPassword = 'reset-password';
//   //
//   // These three run before the user is authenticated, so — unlike almost
//   // everything else in this file — they deliberately do NOT pass
//   // `options: await _authOptions()`.
//
//   /// POST /forgot-password — body: { email }
//   Future<Response> forgotPassword(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.forgotPassword,
//     data: data,
//   );
//
//   /// POST /verify-otp — body: { email, otp }
//   Future<Response> verifyOtp(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.verifyOtp,
//     data: data,
//   );
//
//   /// POST /reset-password — body: { email, otp, password, password_confirmation }
//   Future<Response> resetPassword(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.resetPassword,
//     data: data,
//   );
//
//   // =================== DRIVER ===================
//   Future<Response> drivers() async => dio.get(
//     ApiConstants.driversget,
//     options: await _authOptions(),
//   );
//
//   Future<Response> addDriver(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.driverscreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateDriver(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.updateDriver,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteDriver(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.deleteDriver,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== DESIGNATION ===================
//   Future<Response> salesmanDesignations() async => dio.get(
//     ApiConstants.salesmanDesignations,
//     options: await _authOptions(),
//   );
//
//   Future<Response> addDesignation(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salemancretaedesignation,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateDesignation(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.updateDesignation,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteDesignation(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.deleteDesignation,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== SALESMAN ===================
//   Future<Response> salesmen() async => dio.get(
//     ApiConstants.salesmen,
//     options: await _authOptions(),
//   );
//
//   Future<Response> addSalesman(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salesmancreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateSalesman(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.updateSalesman,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteSalesman(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.deleteSalesman,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// GET /salesmen/active — id/name/designation_display list, used to
//   /// populate the "Assign to Salesman" dropdown on the Owner Create
//   /// Estimate screen when approving an estimate, and the salesman picker
//   /// on the Owner Salesman Incentives / Reports screens.
//   Future<Response> activeSalesmen() async => dio.get(
//     ApiConstants.salesmenActive,
//     options: await _authOptions(),
//   );
//
//   // =================== FIELD STAFF ===================
//   Future<Response> addFieldStaff(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.fieldstaffcreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> fieldStaff() async => dio.get(
//     ApiConstants.fieldStaff,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateFieldStaff(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.updateFieldStaff,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteFieldStaff(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.deleteFieldStaff,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// GET /field-staff/active — id/name list, used to populate the "Select
//   /// Field Staff" dropdown on the Owner Incentive Report Filter screen.
//   Future<Response> activeFieldStaff() async => dio.get(
//     ApiConstants.fieldStaffActive,
//     options: await _authOptions(),
//   );
//
//   // =================== UNITS ===================
//   Future<Response> units() async => dio.get(
//     ApiConstants.units,
//     options: await _authOptions(),
//   );
//
//   Future<Response> addUnit(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.unitscreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateUnit(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.updateUnit,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteUnit(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.deleteUnit,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== COMPANIES ===================
//   Future<Response> companies({int page = 1, int perPage = 20}) async => dio.get(
//     '${ApiConstants.companies}?page=$page&per_page=$perPage',
//     options: await _authOptions(),
//   );
//
//   Future<Response> addCompany(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.companycreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateCompany(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.updateCompany,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteCompany(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.deleteCompany,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== SITE VISITS ===================
//   Future<Response> createSiteVisit(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.siteVisitCreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> mySiteVisits() async => dio.get(
//     ApiConstants.siteVisitsMy,
//     options: await _authOptions(),
//   );
//
//   Future<Response> showSiteVisit(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.siteVisitShow,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateSiteVisit(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.siteVisitUpdate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteSiteVisit(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.siteVisitDelete,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// GET /site-visits/pending-dropdown
//   Future<Response> pendingSiteVisitsDropdown() async => dio.get(
//     ApiConstants.siteVisitsPendingDropdown,
//     options: await _authOptions(),
//   );
//
//   // =================== PRODUCTS ===================
//   Future<Response> products({int page = 1, int perPage = 10}) async => dio.get(
//     '${ApiConstants.products}?page=$page&per_page=$perPage',
//     options: await _authOptions(),
//   );
//
//   Future<Response> addProduct(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.productsCreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateProduct(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.productsUpdate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteProduct(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.productsDelete,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// GET /products/active
//   Future<Response> activeProducts() async => dio.get(
//     ApiConstants.productsActive,
//     options: await _authOptions(),
//   );
//
//   // =================== COMPANIES (active — for dropdown) ===================
//   Future<Response> activeCompanies() async => dio.get(
//     ApiConstants.companiesActive,
//     options: await _authOptions(),
//   );
//
//   // =================== UNITS (active — for dropdown) ===================
//   Future<Response> activeUnits() async => dio.get(
//     ApiConstants.unitsActive,
//     options: await _authOptions(),
//   );
//
//   // =================== CONTRACTORS ===================
//
//   /// GET /reports/contractors/active — id/name/mobile list, used to
//   /// populate the "Select Contractor" dropdown on the Owner Report
//   /// Filter screen.
//   Future<Response> activeContractors() async => dio.get(
//     ApiConstants.contractorsActive,
//     options: await _authOptions(),
//   );
//
//   // =================== QUOTATIONS / ESTIMATES ===================
//
//   /// POST /quotations/create — used by both the salesman and owner Create
//   /// Estimate screens. `data['action']` drives server-side behavior:
//   ///   - 'save_quotation' -> saved as a draft
//   ///   - 'submit'          -> submitted for admin/owner approval
//   ///   - 'approve'         -> owner-only, creates AND finalizes the
//   ///                          estimate in one call. The owner screen sends
//   ///                          `salesman_id` plus optional discount_*/
//   ///                          payment_* fields along with this action.
//   Future<Response> createQuotation(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.quotationsCreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> productIncentive(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.quotationsProductIncentive,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> myQuotations() async => dio.get(
//     ApiConstants.quotationsMy,
//     options: await _authOptions(),
//   );
//
//   Future<Response> showQuotation(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.quotationsShow,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> updateQuotation(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.quotationsUpdate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> deleteQuotation(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.quotationsDelete,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> submitQuotation(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.quotationsSubmit,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /quotations/approve — owner-only. Approves an already-submitted
//   /// quotation (separate flow from /quotations/create with action=approve).
//   Future<Response> approveQuotation(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.quotationsApprove,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== DASHBOARD ===================
//   Future<Response> dashboard() async => dio.get(
//     ApiConstants.dashboard,
//     options: await _authOptions(),
//   );
//
//   Future<Response> previewQuotation(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.qtnpreview,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== ESTIMATES ===================
//   Future<Response> showEstimate(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.estimatesShow,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /estimates/update — body: { id, ...only the fields you want to
//   /// change }. Fields left out of [data] keep their existing server-side
//   /// values, EXCEPT `items`: if present at all it fully replaces the
//   /// estimate's item list. Discount/payment fields cannot be changed
//   /// through this endpoint — use approveEstimate() or the payments
//   /// endpoints instead.
//   Future<Response> updateEstimate(Map<String, dynamic> data) async => dio.put(
//     ApiConstants.estimatesUpdate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> myApprovedEstimates({int page = 1, int perPage = 10}) async => dio.get(
//     '${ApiConstants.estimatesMyApproved}?page=$page&per_page=$perPage',
//     options: await _authOptions(),
//   );
//
//   Future<Response> estimates({int page = 1, int perPage = 100}) async => dio.get(
//     '${ApiConstants.estimatesAll}?page=$page&per_page=$perPage',
//     options: await _authOptions(),
//   );
//
//   Future<Response> quotations({int page = 1, int perPage = 10}) async => dio.get(
//     ApiConstants.quotationsAll,
//     queryParameters: {'page': page, 'per_page': perPage},
//     options: await _authOptions(),
//   );
//
//   Future<Response> rejectQuotation() async => dio.get(
//     ApiConstants.reject,
//     options: await _authOptions(),
//   );
//
//   //estimatesection
//   // =================== ESTIMATES (owner actions) ===================
//
//   /// POST /estimates/approve
//   Future<Response> approveEstimate(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.estimatesApprove,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /quotations/reject — body: { id, rejection_notes }
//   /// Replaces the old `rejectQuotation()` which incorrectly used GET.
//   Future<Response> rejectEstimate(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.reject,
//     data: data,
//     options: await _authOptions(),
//   );
//
//
//
//   /// despatch section
// // Add these methods to your existing ApiClient class
//
//   Future<Response> despatchSuggest(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.despatchesSuggest,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// GET /drivers/active — id/name list, used to populate the "Assign
//   /// Driver" dropdown when creating a despatch sheet.
//   Future<Response> activeDrivers() async => dio.get(
//
//     ApiConstants.driversActive,
//     options: await _authOptions(),
//   );
//
//   /// POST /despatches/create
//   Future<Response> createDespatch(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.despatchesCreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//
//   //despatchlistingsection
//   /// POST /despatches/show
//   /// GET /despatches/my?page=&per_page=
//   Future<Response> myDispatches({int page = 1, int perPage = 10}) async => dio.get(
//     ApiConstants.despatchesMy,
//     queryParameters: {'page': page, 'per_page': perPage},
//     options: await _authOptions(),
//   );
//
//   /// POST /despatches/show
//   Future<Response> showDispatch(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.despatchesShow,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /despatches/mark-in-transit
//   Future<Response> markInTransit(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.despatchesMarkInTransit,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /despatches/mark-delivered
//   Future<Response> markDelivered(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.despatchesMarkDelivered,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== PAYMENTS ===================
//
//   /// POST /payments — records a new payment against an estimate.
//   Future<Response> addPayment(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.paymentsCreate,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /payments/details — full payment history + financial/payment
//   /// summary for a single estimate. Body: { estimate_id }
//   Future<Response> paymentDetails(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.paymentsDetails,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /payments/delete — body: { id }
//   Future<Response> deletePayment(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.paymentsDelete,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== SALESMAN INCENTIVES ===================
//
//   /// POST /salesman-incentives/summary
//   /// Body: { salesman_id (owner only), year, month }
//   Future<Response> salesmanIncentiveSummary(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salesmanIncentiveSummary,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /salesman-incentives/products?page=&per_page= — full paginated
//   /// product list for the "View All" screen.
//   /// Body: { salesman_id (owner only), year, month, page, per_page }
//   Future<Response> salesmanIncentiveProducts(
//       Map<String, dynamic> data, {
//         int page = 1,
//         int perPage = 10,
//       }) async => dio.post(
//     '${ApiConstants.salesmanIncentiveProducts}?page=$page&per_page=$perPage',
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /salesman-incentives/product-bills?page=&per_page= — dispatched
//   /// bills for a single product, shown on the product detail page.
//   /// Body: { salesman_id (owner only), product_id, year, month }
//   Future<Response> salesmanIncentiveProductBills(
//       Map<String, dynamic> data, {
//         int page = 1,
//         int perPage = 10,
//       }) async => dio.post(
//     '${ApiConstants.salesmanIncentiveProductBills}?page=$page&per_page=$perPage',
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /salesman-incentives/mark-paid — owner-only. Marks a salesman's
//   /// incentive for a given month as paid.
//   /// Body: { salesman_id (owner only), year, month, payment_reference,
//   ///          payment_date, notes }
//   Future<Response> markSalesmanIncentivePaid(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salesmanIncentiveMarkPaid,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== REPORTS ===================
//
//   /// POST /reports/salesman-performance
//   /// Body: { salesman_id, from_date, to_date }
//   Future<Response> salesmanPerformanceReport(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salesmanPerformanceReport,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /reports/contractor-performance
//   /// Body: { contractor_id, from_date, to_date }
//   Future<Response> contractorPerformanceReport(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.contractorPerformanceReport,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /reports/quotations?page=&per_page=
//   /// Body: { type: 'salesman' | 'contractor', person_id, from_date, to_date, status }
//   /// Requires ApiConstants.quotationsReport = 'reports/quotations'.
//   Future<Response> quotationReport(
//       Map<String, dynamic> data, {
//         int page = 1,
//         int perPage = 10,
//       }) async => dio.post(
//     '${ApiConstants.quotationsReport}?page=$page&per_page=$perPage',
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /reports/estimates?page=&per_page=
//   /// Body: { type: 'salesman' | 'contractor', person_id, from_date, to_date, status }
//   /// Requires ApiConstants.estimatesReport = 'reports/estimates'.
//   Future<Response> estimateReport(
//       Map<String, dynamic> data, {
//         int page = 1,
//         int perPage = 10,
//       }) async => dio.post(
//     '${ApiConstants.estimatesReport}?page=$page&per_page=$perPage',
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// POST /reports/incentives?page=&per_page=
//   /// Body: { type: 'salesman' | 'field_staff', person_id, from_date, to_date, status }
//   /// Requires ApiConstants.incentivesReport = 'reports/incentives'.
//   Future<Response> incentiveReport(
//       Map<String, dynamic> data, {
//         int page = 1,
//         int perPage = 10,
//       }) async => dio.post(
//     '${ApiConstants.incentivesReport}?page=$page&per_page=$perPage',
//     data: data,
//     options: await _authOptions(),
//   );
//
//
//
//   //
// // incentivesetup
//   Future<Response> salesmanIncentiveSetupList() async => dio.get(
//     ApiConstants.salesmanIncentiveSetupList,
//     options: await _authOptions(),
//   );
//
//   Future<Response> salesmanIncentiveSetupGet(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salesmanIncentiveSetupGet,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> salesmanIncentiveSetupSave(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.salesmanIncentiveSetupSave,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> salesmanIncentiveSetupDelete(Map<String, dynamic> data) async => dio.delete(
//     ApiConstants.salesmanIncentiveSetupDelete,
//     data: data,
//     options: await _authOptions(),
//   );
//   // =================== DRIVER DASHBOARD ===================
//   Future<Response> driverDashboard() async => dio.get(
//     ApiConstants.driversDashboard,
//     options: await _authOptions(),
//   );
//
//   Future<Response> driverShowDespatch(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.driversShow,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   // =================== FIELD STAFF INCENTIVES ===================
//
//   /// POST /field-staff-incentives/summary?page=&per_page=
//   /// Body: { date_from, date_to, field_staff_id?, status? }
//   ///
//   /// Real response combines the summary counts AND the paginated incentive
//   /// list in one payload — `page`/`per_page` control that embedded list,
//   /// matching the pattern used by salesmanIncentiveProducts/quotationReport
//   /// above (page/per_page appended to the URL, filters in the body).
//   Future<Response> fieldStaffIncentiveSummary(
//       Map<String, dynamic> data, {
//         int page = 1,
//         int perPage = 20,
//       }) async => dio.post(
//     '${ApiConstants.fieldStaffIncentivesSummary}?page=$page&per_page=$perPage',
//     data: data,
//     options: await _authOptions(),
//   );
//
//   /// GET /field-staff-incentives — kept for backward compatibility, but no
//   /// longer called by IncentiveProvider: the real API returns the list
//   /// embedded in fieldStaffIncentiveSummary()'s response instead of via a
//   /// separate paginated endpoint.
//   Future<Response> fieldStaffIncentiveList(
//       Map<String, dynamic> filters, {
//         int page = 1,
//         int perPage = 20,
//       }) async => dio.get(
//     ApiConstants.fieldStaffIncentivesList,
//     queryParameters: {'page': page, 'per_page': perPage, ...filters},
//     options: await _authOptions(),
//   );
//
//   Future<Response> fieldStaffIncentiveShow(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.fieldStaffIncentivesShow,
//     data: data,
//     options: await _authOptions(),
//   );
//
//   Future<Response> fieldStaffIncentiveMarkPaid(Map<String, dynamic> data) async => dio.post(
//     ApiConstants.fieldStaffIncentivesMarkPaid,
//     data: data,
//     options: await _authOptions(),
//   );
//
// }
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



  /// GET /profile
  Future<Response> getProfile() async => dio.get(
    ApiConstants.profile,
    options: await _authOptions(),
  );

  /// PUT /profile
  Future<Response> updateProfile(Map<String, dynamic> data) async => dio.put(
    ApiConstants.profileUpdate,
    data: data,
    options: await _authOptions(),
  );

  /// POST /change-password
  /// Body: { current_password, new_password, new_password_confirmation }
  Future<Response> changePassword(Map<String, dynamic> data) async => dio.post(
    ApiConstants.changePassword,
    data: data,
    options: await _authOptions(),
  );

  // =================== FORGOT PASSWORD ===================
  // Requires two new entries in ApiConstants (mirroring `login` above):
  //   static const String forgotPassword = 'forgot-password';
  //   static const String verifyOtp = 'verify-otp';
  //   static const String resetPassword = 'reset-password';
  //
  // These three run before the user is authenticated, so — unlike almost
  // everything else in this file — they deliberately do NOT pass
  // `options: await _authOptions()`.

  /// POST /forgot-password — body: { email }
  Future<Response> forgotPassword(Map<String, dynamic> data) async => dio.post(
    ApiConstants.forgotPassword,
    data: data,
  );

  /// POST /verify-otp — body: { email, otp }
  Future<Response> verifyOtp(Map<String, dynamic> data) async => dio.post(
    ApiConstants.verifyOtp,
    data: data,
  );

  /// POST /reset-password — body: { email, otp, password, password_confirmation }
  Future<Response> resetPassword(Map<String, dynamic> data) async => dio.post(
    ApiConstants.resetPassword,
    data: data,
  );

  // =================== DRIVER ===================
  Future<Response> drivers() async => dio.get(
    ApiConstants.driversget,
    options: await _authOptions(),
  );

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

  /// GET /salesmen/active — id/name/designation_display list, used to
  /// populate the "Assign to Salesman" dropdown on the Owner Create
  /// Estimate screen when approving an estimate, and the salesman picker
  /// on the Owner Salesman Incentives / Reports screens.
  Future<Response> activeSalesmen() async => dio.get(
    ApiConstants.salesmenActive,
    options: await _authOptions(),
  );

  // =================== FIELD STAFF ===================
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

  /// GET /field-staff/active — id/name list, used to populate the "Select
  /// Field Staff" dropdown on the Owner Incentive Report Filter screen.
  Future<Response> activeFieldStaff() async => dio.get(
    ApiConstants.fieldStaffActive,
    options: await _authOptions(),
  );

  // =================== UNITS ===================
  Future<Response> units() async => dio.get(
    ApiConstants.units,
    options: await _authOptions(),
  );

  Future<Response> addUnit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.unitscreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateUnit(Map<String, dynamic> data) async => dio.put(
    ApiConstants.updateUnit,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteUnit(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.deleteUnit,
    data: data,
    options: await _authOptions(),
  );

  // =================== COMPANIES ===================
  Future<Response> companies({int page = 1, int perPage = 20}) async => dio.get(
    '${ApiConstants.companies}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

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

  // =================== SITE VISITS ===================
  Future<Response> createSiteVisit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.siteVisitCreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> mySiteVisits() async => dio.get(
    ApiConstants.siteVisitsMy,
    options: await _authOptions(),
  );

  Future<Response> showSiteVisit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.siteVisitShow,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateSiteVisit(Map<String, dynamic> data) async => dio.put(
    ApiConstants.siteVisitUpdate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteSiteVisit(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.siteVisitDelete,
    data: data,
    options: await _authOptions(),
  );

  /// GET /site-visits/pending-dropdown
  Future<Response> pendingSiteVisitsDropdown() async => dio.get(
    ApiConstants.siteVisitsPendingDropdown,
    options: await _authOptions(),
  );

  // =================== PRODUCTS ===================
  Future<Response> products({int page = 1, int perPage = 10}) async => dio.get(
    '${ApiConstants.products}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> addProduct(Map<String, dynamic> data) async => dio.post(
    ApiConstants.productsCreate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateProduct(Map<String, dynamic> data) async => dio.put(
    ApiConstants.productsUpdate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteProduct(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.productsDelete,
    data: data,
    options: await _authOptions(),
  );

  /// GET /products/active
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

  // =================== CONTRACTORS ===================

  /// GET /reports/contractors/active — id/name/mobile list, used to
  /// populate the "Select Contractor" dropdown on the Owner Report
  /// Filter screen.
  Future<Response> activeContractors() async => dio.get(
    ApiConstants.contractorsActive,
    options: await _authOptions(),
  );

  // =================== QUOTATIONS / ESTIMATES ===================

  /// POST /quotations/create — used by both the salesman and owner Create
  /// Estimate screens. `data['action']` drives server-side behavior:
  ///   - 'save_quotation' -> saved as a draft
  ///   - 'submit'          -> submitted for admin/owner approval
  ///   - 'approve'         -> owner-only, creates AND finalizes the
  ///                          estimate in one call. The owner screen sends
  ///                          `salesman_id` plus optional discount_*/
  ///                          payment_* fields along with this action.
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

  Future<Response> myQuotations() async => dio.get(
    ApiConstants.quotationsMy,
    options: await _authOptions(),
  );

  Future<Response> showQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsShow,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> updateQuotation(Map<String, dynamic> data) async => dio.put(
    ApiConstants.quotationsUpdate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> deleteQuotation(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.quotationsDelete,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> submitQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsSubmit,
    data: data,
    options: await _authOptions(),
  );

  /// POST /quotations/approve — owner-only. Approves an already-submitted
  /// quotation (separate flow from /quotations/create with action=approve).
  Future<Response> approveQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsApprove,
    data: data,
    options: await _authOptions(),
  );

  /// POST /quotations/cancel — body: { id }. Cancels a quotation/estimate
  /// (any of the API's normal statuses can transition to cancelled). Per
  /// the API's own message, this also reverts a linked site visit back to
  /// pending if one exists.
  ///
  /// Requires a new entry in ApiConstants (mirroring quotationsApprove
  /// above):
  ///   static const String quotationsCancel = 'quotations/cancel';
  Future<Response> cancelQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.quotationsCancel,
    data: data,
    options: await _authOptions(),
  );

  // =================== DASHBOARD ===================
  Future<Response> dashboard() async => dio.get(
    ApiConstants.dashboard,
    options: await _authOptions(),
  );

  Future<Response> previewQuotation(Map<String, dynamic> data) async => dio.post(
    ApiConstants.qtnpreview,
    data: data,
    options: await _authOptions(),
  );

  // =================== ESTIMATES ===================
  Future<Response> showEstimate(Map<String, dynamic> data) async => dio.post(
    ApiConstants.estimatesShow,
    data: data,
    options: await _authOptions(),
  );

  /// POST /estimates/update — body: { id, ...only the fields you want to
  /// change }. Fields left out of [data] keep their existing server-side
  /// values, EXCEPT `items`: if present at all it fully replaces the
  /// estimate's item list. Discount/payment fields cannot be changed
  /// through this endpoint — use approveEstimate() or the payments
  /// endpoints instead.
  Future<Response> updateEstimate(Map<String, dynamic> data) async => dio.put(
    ApiConstants.estimatesUpdate,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> myApprovedEstimates({int page = 1, int perPage = 10}) async => dio.get(
    '${ApiConstants.estimatesMyApproved}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> estimates({int page = 1, int perPage = 100}) async => dio.get(
    '${ApiConstants.estimatesAll}?page=$page&per_page=$perPage',
    options: await _authOptions(),
  );

  Future<Response> quotations({int page = 1, int perPage = 10}) async => dio.get(
    ApiConstants.quotationsAll,
    queryParameters: {'page': page, 'per_page': perPage},
    options: await _authOptions(),
  );

  Future<Response> rejectQuotation() async => dio.get(
    ApiConstants.reject,
    options: await _authOptions(),
  );

  //estimatesection
  // =================== ESTIMATES (owner actions) ===================

  /// POST /estimates/approve
  Future<Response> approveEstimate(Map<String, dynamic> data) async => dio.post(
    ApiConstants.estimatesApprove,
    data: data,
    options: await _authOptions(),
  );

  /// POST /quotations/reject — body: { id, rejection_notes }
  /// Replaces the old `rejectQuotation()` which incorrectly used GET.
  Future<Response> rejectEstimate(Map<String, dynamic> data) async => dio.post(
    ApiConstants.reject,
    data: data,
    options: await _authOptions(),
  );



  /// despatch section
// Add these methods to your existing ApiClient class

  Future<Response> despatchSuggest(Map<String, dynamic> data) async => dio.post(
    ApiConstants.despatchesSuggest,
    data: data,
    options: await _authOptions(),
  );

  /// GET /drivers/active — id/name list, used to populate the "Assign
  /// Driver" dropdown when creating a despatch sheet.
  Future<Response> activeDrivers() async => dio.get(

    ApiConstants.driversActive,
    options: await _authOptions(),
  );

  /// POST /despatches/create
  Future<Response> createDespatch(Map<String, dynamic> data) async => dio.post(
    ApiConstants.despatchesCreate,
    data: data,
    options: await _authOptions(),
  );


  //despatchlistingsection
  /// POST /despatches/show
  /// GET /despatches/my?page=&per_page=
  Future<Response> myDispatches({int page = 1, int perPage = 10}) async => dio.get(
    ApiConstants.despatchesMy,
    queryParameters: {'page': page, 'per_page': perPage},
    options: await _authOptions(),
  );

  /// POST /despatches/show
  Future<Response> showDispatch(Map<String, dynamic> data) async => dio.post(
    ApiConstants.despatchesShow,
    data: data,
    options: await _authOptions(),
  );

  /// POST /despatches/mark-in-transit
  Future<Response> markInTransit(Map<String, dynamic> data) async => dio.post(
    ApiConstants.despatchesMarkInTransit,
    data: data,
    options: await _authOptions(),
  );

  /// POST /despatches/mark-delivered
  Future<Response> markDelivered(Map<String, dynamic> data) async => dio.post(
    ApiConstants.despatchesMarkDelivered,
    data: data,
    options: await _authOptions(),
  );

  // =================== PAYMENTS ===================

  /// POST /payments — records a new payment against an estimate.
  Future<Response> addPayment(Map<String, dynamic> data) async => dio.post(
    ApiConstants.paymentsCreate,
    data: data,
    options: await _authOptions(),
  );

  /// POST /payments/details — full payment history + financial/payment
  /// summary for a single estimate. Body: { estimate_id }
  Future<Response> paymentDetails(Map<String, dynamic> data) async => dio.post(
    ApiConstants.paymentsDetails,
    data: data,
    options: await _authOptions(),
  );

  /// POST /payments/delete — body: { id }
  Future<Response> deletePayment(Map<String, dynamic> data) async => dio.post(
    ApiConstants.paymentsDelete,
    data: data,
    options: await _authOptions(),
  );

  // =================== SALESMAN INCENTIVES ===================

  /// POST /salesman-incentives/summary
  /// Body: { salesman_id (owner only), year, month }
  Future<Response> salesmanIncentiveSummary(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salesmanIncentiveSummary,
    data: data,
    options: await _authOptions(),
  );

  /// POST /salesman-incentives/products?page=&per_page= — full paginated
  /// product list for the "View All" screen.
  /// Body: { salesman_id (owner only), year, month, page, per_page }
  Future<Response> salesmanIncentiveProducts(
      Map<String, dynamic> data, {
        int page = 1,
        int perPage = 10,
      }) async => dio.post(
    '${ApiConstants.salesmanIncentiveProducts}?page=$page&per_page=$perPage',
    data: data,
    options: await _authOptions(),
  );

  /// POST /salesman-incentives/product-bills?page=&per_page= — dispatched
  /// bills for a single product, shown on the product detail page.
  /// Body: { salesman_id (owner only), product_id, year, month }
  Future<Response> salesmanIncentiveProductBills(
      Map<String, dynamic> data, {
        int page = 1,
        int perPage = 10,
      }) async => dio.post(
    '${ApiConstants.salesmanIncentiveProductBills}?page=$page&per_page=$perPage',
    data: data,
    options: await _authOptions(),
  );

  /// POST /salesman-incentives/mark-paid — owner-only. Marks a salesman's
  /// incentive for a given month as paid.
  /// Body: { salesman_id (owner only), year, month, payment_reference,
  ///          payment_date, notes }
  Future<Response> markSalesmanIncentivePaid(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salesmanIncentiveMarkPaid,
    data: data,
    options: await _authOptions(),
  );

  // =================== REPORTS ===================

  /// POST /reports/salesman-performance
  /// Body: { salesman_id, from_date, to_date }
  Future<Response> salesmanPerformanceReport(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salesmanPerformanceReport,
    data: data,
    options: await _authOptions(),
  );

  /// POST /reports/contractor-performance
  /// Body: { contractor_id, from_date, to_date }
  Future<Response> contractorPerformanceReport(Map<String, dynamic> data) async => dio.post(
    ApiConstants.contractorPerformanceReport,
    data: data,
    options: await _authOptions(),
  );

  /// POST /reports/quotations?page=&per_page=
  /// Body: { type: 'salesman' | 'contractor', person_id, from_date, to_date, status }
  /// Requires ApiConstants.quotationsReport = 'reports/quotations'.
  Future<Response> quotationReport(
      Map<String, dynamic> data, {
        int page = 1,
        int perPage = 10,
      }) async => dio.post(
    '${ApiConstants.quotationsReport}?page=$page&per_page=$perPage',
    data: data,
    options: await _authOptions(),
  );

  /// POST /reports/estimates?page=&per_page=
  /// Body: { type: 'salesman' | 'contractor', person_id, from_date, to_date, status }
  /// Requires ApiConstants.estimatesReport = 'reports/estimates'.
  Future<Response> estimateReport(
      Map<String, dynamic> data, {
        int page = 1,
        int perPage = 10,
      }) async => dio.post(
    '${ApiConstants.estimatesReport}?page=$page&per_page=$perPage',
    data: data,
    options: await _authOptions(),
  );

  /// POST /reports/incentives?page=&per_page=
  /// Body: { type: 'salesman' | 'field_staff', person_id, from_date, to_date, status }
  /// Requires ApiConstants.incentivesReport = 'reports/incentives'.
  Future<Response> incentiveReport(
      Map<String, dynamic> data, {
        int page = 1,
        int perPage = 10,
      }) async => dio.post(
    '${ApiConstants.incentivesReport}?page=$page&per_page=$perPage',
    data: data,
    options: await _authOptions(),
  );



  //
// incentivesetup
  Future<Response> salesmanIncentiveSetupList() async => dio.get(
    ApiConstants.salesmanIncentiveSetupList,
    options: await _authOptions(),
  );

  Future<Response> salesmanIncentiveSetupGet(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salesmanIncentiveSetupGet,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> salesmanIncentiveSetupSave(Map<String, dynamic> data) async => dio.post(
    ApiConstants.salesmanIncentiveSetupSave,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> salesmanIncentiveSetupDelete(Map<String, dynamic> data) async => dio.delete(
    ApiConstants.salesmanIncentiveSetupDelete,
    data: data,
    options: await _authOptions(),
  );
  // =================== DRIVER DASHBOARD ===================
  Future<Response> driverDashboard() async => dio.get(
    ApiConstants.driversDashboard,
    options: await _authOptions(),
  );

  Future<Response> driverShowDespatch(Map<String, dynamic> data) async => dio.post(
    ApiConstants.driversShow,
    data: data,
    options: await _authOptions(),
  );

  // =================== FIELD STAFF INCENTIVES ===================

  /// POST /field-staff-incentives/summary?page=&per_page=
  /// Body: { date_from, date_to, field_staff_id?, status? }
  ///
  /// Real response combines the summary counts AND the paginated incentive
  /// list in one payload — `page`/`per_page` control that embedded list,
  /// matching the pattern used by salesmanIncentiveProducts/quotationReport
  /// above (page/per_page appended to the URL, filters in the body).
  Future<Response> fieldStaffIncentiveSummary(
      Map<String, dynamic> data, {
        int page = 1,
        int perPage = 20,
      }) async => dio.post(
    '${ApiConstants.fieldStaffIncentivesSummary}?page=$page&per_page=$perPage',
    data: data,
    options: await _authOptions(),
  );

  /// GET /field-staff-incentives — kept for backward compatibility, but no
  /// longer called by IncentiveProvider: the real API returns the list
  /// embedded in fieldStaffIncentiveSummary()'s response instead of via a
  /// separate paginated endpoint.
  Future<Response> fieldStaffIncentiveList(
      Map<String, dynamic> filters, {
        int page = 1,
        int perPage = 20,
      }) async => dio.get(
    ApiConstants.fieldStaffIncentivesList,
    queryParameters: {'page': page, 'per_page': perPage, ...filters},
    options: await _authOptions(),
  );

  Future<Response> fieldStaffIncentiveShow(Map<String, dynamic> data) async => dio.post(
    ApiConstants.fieldStaffIncentivesShow,
    data: data,
    options: await _authOptions(),
  );

  Future<Response> fieldStaffIncentiveMarkPaid(Map<String, dynamic> data) async => dio.post(
    ApiConstants.fieldStaffIncentivesMarkPaid,
    data: data,
    options: await _authOptions(),
  );

}