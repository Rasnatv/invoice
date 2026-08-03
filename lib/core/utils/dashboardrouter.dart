import 'package:flutter/material.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/dashboard/driver_dashboard/driver_dashboard.dart';
import '../../features/dashboard/owner/widgets/ownerDashboardshell.dart';
import '../../features/dashboard/salesman/presentation/dashboard_shell.dart';
import '../../features/fieldstaff/fieldstaff_dashboard.dart';

/// Single source of truth for "which dashboard does this role open".
/// Used by LoginScreen (fresh login) and SplashScreen (auto-login from a
/// saved session) so both paths can never drift apart.
Widget destinationForRole(UserRole role) {
  switch (role) {
    case UserRole.owner:
      return const Ownerdashboardshell();
    case UserRole.driver:
      return const DriverDashboardScreen();
    case UserRole.salesman:
      return const DashboardShell();
    case UserRole.fieldStaff:
      return const FieldStaffDashboardScreen();
  }
}

/// Turns the string saved by TokenStorage.saveRole back into a UserRole.
UserRole? roleFromStoredString(String? value) {
  if (value == null) return null;
  for (final role in UserRole.values) {
    if (role.name == value) return role;
  }
  return null;
}