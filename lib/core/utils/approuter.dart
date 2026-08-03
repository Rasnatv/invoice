import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tileshop/features/auth/presentation/login_screen.dart';
import 'package:tileshop/features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/owner/presentation/addfieldstaffscreen.dart';

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

    ],
  );
}