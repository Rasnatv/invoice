
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
  static const String salemancretaedesignation='/salesman-designations/create';
  static const String salesmanDesignations = '/salesman-designations';
  static const String updateDesignation = '/salesman-designations/update';
  static const String deleteDesignation = '/salesman-designations/delete';

  // Salesman
  static const String salesmancreate='/salesmen/create';
  static const String salesmen = '/salesmen';
  static const String updateSalesman = '/salesmen/update';
  static const String deleteSalesman = '/salesmen/delete';

  // Field Staff
  static const String fieldstaffcreate='/field-staff/create';
  static const String fieldStaff = '/field-staff';
  static const String updateFieldStaff = '/field-staff/update';
  static const String deleteFieldStaff = '/field-staff/delete';

  // Units
  static const String unitscreate='/units/create';
  static const String units = '/units';
  static const String updateUnit = '/units/update';
  static const String deleteUnit = '/units/delete';

  // Companies
  static const String companycreate='/companies/create';
  static const String companies = '/companies';
  static const String updateCompany = '/companies/update';
  static const String deleteCompany = '/companies/delete';
}