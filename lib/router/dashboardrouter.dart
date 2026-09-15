enum UserRole { owner, salesman, driver, fieldStaff }

UserRole? roleFromStoredString(String? value) {
  switch (value) {
    case '2':
      return UserRole.owner;
    case '3':
      return UserRole.salesman;
    case '4':
      return UserRole.driver;
    case '5':
      return UserRole.fieldStaff;
    default:
      return null;
  }
}

String routeForRole(UserRole role) {
  switch (role) {
    case UserRole.owner:
      return '/owner';
    case UserRole.salesman:
      return '/salesman';
    case UserRole.driver:
      return '/driver';
    case UserRole.fieldStaff:
      return '/fieldstaff';
  }
}