import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/auth/login_screen.dart';
import '../ui/owner/addDesignationpage.dart';
import '../ui/owner/addfieldstaffscreen.dart';
import '../ui/splash/splash_screen.dart';


class AppRouter {
  AppRouter._();

  /// Gives direct access to the underlying Navigator, so we can force-clear
  /// the stack even for screens pushed with plain Navigator.push (not
  /// through a GoRoute) — e.g. on a 401 from ApiErrorHandler.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/field-staff',
        builder: (context, state) => const OwnerAddFieldStaffScreen(),
      ),
      GoRoute(
        path: '/designations',
        builder: (context, state) => const AddDesignationPage(),
      ),
    ],
  );
}