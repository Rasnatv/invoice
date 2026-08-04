
import 'package:flutter/material.dart';
import 'package:tileshop/ui/driver_dashboard/driver_dashboard.dart';
import 'package:tileshop/ui/fieldstaff/fieldstaff_dashboard.dart';

import '../../ui/auth/owner/widgets/ownerDashboardshell.dart';
import '../../ui/salesman/presentation/dashboard_shell.dart';

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


Widget destinationForRole(UserRole role) {
  switch (role) {
    case UserRole.owner:
      return const  Ownerdashboardshell();
    case UserRole.salesman:
      return const DashboardShell();
    case UserRole.driver:
      return const  DriverDashboardScreen();
    case UserRole.fieldStaff:
      return const FieldStaffDashboardScreen();
  }
}

// TEMP — swap this out for your actual dashboard widgets.
class _PlaceholderDashboard extends StatelessWidget {
  final String title;
  const _PlaceholderDashboard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}