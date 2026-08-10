//
// class ApiConstants {
//   ApiConstants._();
//
//   static const String baseUrl =
//       'https://neethu.astradevelops.in/ceramo/public/api';
//
//   static const String login = '/login';
//
//   // Driver
//   static const String driverscreate = '/drivers/create';
//   static const String driversget = '/drivers';
//   static const String updateDriver = '/drivers/update';
//   static const String deleteDriver = '/drivers/delete';
//
//   // Designation
//   static const String salemancretaedesignation =
//       '/salesman-designations/create';
//   static const String salesmanDesignations = '/salesman-designations';
//   static const String updateDesignation = '/salesman-designations/update';
//   static const String deleteDesignation = '/salesman-designations/delete';
//
//   // Salesman
//   static const String salesmancreate = '/salesmen/create';
//   static const String salesmen = '/salesmen';
//   static const String updateSalesman = '/salesmen/update';
//   static const String deleteSalesman = '/salesmen/delete';
//
//   // Field Staff
//   static const String fieldstaffcreate = '/field-staff/create';
//   static const String fieldStaff = '/field-staff';
//   static const String updateFieldStaff = '/field-staff/update';
//   static const String deleteFieldStaff = '/field-staff/delete';
//
//   // Units
//   static const String unitscreate = '/units/create';
//   static const String units = '/units';
//   static const String updateUnit = '/units/update';
//   static const String deleteUnit = '/units/delete';
//
//   // Companies
//   static const String companycreate = '/companies/create';
//   static const String companies = '/companies';
//   static const String updateCompany = '/companies/update';
//   static const String deleteCompany = '/companies/delete';
//
//   // Site Visits
//   static const String siteVisitCreate = '/site-visits/create';
//   static const String siteVisitsMy = '/site-visits/my';
//   static const String siteVisitShow = '/site-visits/show';
//   static const String siteVisitUpdate = '/site-visits/update';
//   static const String siteVisitDelete = '/site-visits/delete';
//
//   /// GET — pending site visits for the phone-number lookup on the
//   /// Create Estimate screen (salesman + owner).
//   static const String siteVisitsPendingDropdown =
//       '/site-visits/pending-dropdown';
//
//   // =================== PRODUCTS ===================
//   static const String products = '/products';
//   static const String productsCreate = '/products/create';
//   static const String productsUpdate = '/products/update';
//   static const String productsDelete = '/products/delete';
//
//   /// GET — active products for the item dropdown on the Create Estimate
//   /// screen. Returns id/name/company/size/unit only (no pricing).
//   static const String productsActive = '/products/active';
//
//   // =================== COMPANIES (dropdown) ===================
//   static const String companiesActive = '/companies/active';
//
//   // =================== UNITS (dropdown) ===================
//   static const String unitsActive = '/units/active';
//
//   // =================== QUOTATIONS / ESTIMATES ===================
//   /// POST — creates a quotation/estimate. Body's `action` field controls
//   /// what happens server-side: 'save_quotation' (draft), 'submit'
//   /// (send for approval), or 'approve' (owner-only).
//   static const String quotationsCreate = '/quotations/create';
//
//   /// POST — live incentive preview for a single line (product_id, quantity,
//   /// rate). Called while the salesman is entering an item on the Add Items
//   /// step, before it's added to the estimate.
//   static const String quotationsProductIncentive =
//       '/quotations/product-incentive';
// }
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://neethu.astradevelops.in/ceramo/public/api';

  static const String login = '/login';

  // Driver
  static const String driverscreate = '/drivers/create';
  static const String driversget = '/drivers';
  static const String updateDriver = '/drivers/update';
  static const String deleteDriver = '/drivers/delete';

  // Designation
  static const String salemancretaedesignation =
      '/salesman-designations/create';
  static const String salesmanDesignations = '/salesman-designations';
  static const String updateDesignation = '/salesman-designations/update';
  static const String deleteDesignation = '/salesman-designations/delete';

  // Salesman
  static const String salesmancreate = '/salesmen/create';
  static const String salesmen = '/salesmen';
  static const String updateSalesman = '/salesmen/update';
  static const String deleteSalesman = '/salesmen/delete';

  // Field Staff
  static const String fieldstaffcreate = '/field-staff/create';
  static const String fieldStaff = '/field-staff';
  static const String updateFieldStaff = '/field-staff/update';
  static const String deleteFieldStaff = '/field-staff/delete';

  // Units
  static const String unitscreate = '/units/create';
  static const String units = '/units';
  static const String updateUnit = '/units/update';
  static const String deleteUnit = '/units/delete';

  // Companies
  static const String companycreate = '/companies/create';
  static const String companies = '/companies';
  static const String updateCompany = '/companies/update';
  static const String deleteCompany = '/companies/delete';

  // Site Visits
  static const String siteVisitCreate = '/site-visits/create';
  static const String siteVisitsMy = '/site-visits/my';
  static const String siteVisitShow = '/site-visits/show';
  static const String siteVisitUpdate = '/site-visits/update';
  static const String siteVisitDelete = '/site-visits/delete';

  /// GET — pending site visits for the phone-number lookup on the
  /// Create Estimate screen (salesman + owner).
  static const String siteVisitsPendingDropdown =
      '/site-visits/pending-dropdown';

  // =================== PRODUCTS ===================
  static const String products = '/products';
  static const String productsCreate = '/products/create';
  static const String productsUpdate = '/products/update';
  static const String productsDelete = '/products/delete';

  /// GET — active products for the item dropdown on the Create Estimate
  /// screen. Returns id/name/company/size/unit only (no pricing).
  static const String productsActive = '/products/active';

  // =================== COMPANIES (dropdown) ===================
  static const String companiesActive = '/companies/active';

  // =================== UNITS (dropdown) ===================
  static const String unitsActive = '/units/active';

  // =================== QUOTATIONS / ESTIMATES ===================
  /// POST — creates a quotation/estimate. Body's `action` field controls
  /// what happens server-side: 'save_quotation' (draft), 'submit'
  /// (send for approval), or 'approve' (owner-only).
  static const String quotationsCreate = '/quotations/create';

  /// POST — live incentive preview for a single line (product_id, quantity,
  /// rate). Called while the salesman is entering an item on the Add Items
  /// step, before it's added to the estimate.
  static const String quotationsProductIncentive =
      '/quotations/product-incentive';

  /// GET — the logged-in salesman/owner's own quotations, newest first.
  static const String quotationsMy = '/quotations/my';

  /// POST { "id": "..." } — full detail of a single quotation/estimate,
  /// including items, customer, contractor, salesman and per-item
  /// incentive snapshot.
  static const String quotationsShow = '/quotations/show';

  /// POST — updates an existing (draft) quotation/estimate. Same body
  /// shape as /quotations/create but requires "id" and only the fields
  /// being changed need to be sent.
  static const String quotationsUpdate = '/quotations/update';

  /// POST { "id": "..." } — permanently deletes a draft quotation/estimate.
  static const String quotationsDelete = '/quotations/delete';

  /// POST { "id": "..." } — sends a saved (draft) quotation/estimate to
  /// the admin/owner for approval.
  static const String quotationsSubmit = '/quotations/submit';
}