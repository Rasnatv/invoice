//
// import 'package:flutter/material.dart';
// import 'package:tileshop/ui/driver_dashboard/driver_dashboard.dart';
// import 'package:tileshop/ui/fieldstaff/fieldstaff_dashboard.dart';
// import '../widgets/ownerDashboardshell.dart';
// import '../ui/salesman/presentation/dashboard_shell.dart';
//
// enum UserRole { owner, salesman, driver, fieldStaff }
//
// UserRole? roleFromStoredString(String? value) {
//   switch (value) {
//     case '2':
//       return UserRole.owner;
//     case '3':
//       return UserRole.salesman;
//     case '4':
//       return UserRole.driver;
//     case '5':
//       return UserRole.fieldStaff;
//     default:
//       return null;
//   }
// }
//
//
// Widget destinationForRole(UserRole role) {
//   switch (role) {
//     case UserRole.owner:
//       return const  Ownerdashboardshell();
//     case UserRole.salesman:
//       return const DashboardShell();
//     case UserRole.driver:
//       return const  DriverDashboardScreen();
//     case UserRole.fieldStaff:
//       return const FieldStaffDashboardScreen();
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/driver_dashboard/driver_dashboard.dart';
import 'package:tileshop/ui/fieldstaff/fieldstaff_dashboard.dart';
import '../bloc/fieldstaffbloc/sitevist/sitevisit_bloc.dart';
import '../widgets/ownerDashboardshell.dart';
import '../ui/salesman/dashboard_shell.dart';

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
      return const Ownerdashboardshell();
    case UserRole.salesman:
      return const DashboardShell();
    case UserRole.driver:
      return const DriverDashboardScreen();
    case UserRole.fieldStaff:
    // ✅ FIX: Wrap with BlocProvider
      return BlocProvider(
        create: (context) => SiteVisitBloc(),
        child: const FieldStaffDashboardScreen(),
      );
  }
}