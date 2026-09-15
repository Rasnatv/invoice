

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../ui/auth/login_screen.dart';
import '../ui/splash/splash_screen.dart';
import '../ui/onboarding/onboarding_screen.dart';

import '../ui/owner/addDesignationpage.dart';
import '../ui/owner/addfieldstaffscreen.dart';
import '../ui/owner/ownerincentivesummarypage.dart';
import '../ui/owner/report/ownerreportscreen.dart';
import '../ui/owner/salesmanincentivesetup.dart';
import '../ui/owner/fieldstaffincentivelistscreen.dart';
import '../ui/owner/owner_designationlist.dart';
import '../ui/owner/owner_driverpage.dart';
import '../ui/owner/owner_estimates_screen.dart';
import '../ui/owner/ownercreateesimatescreen.dart';
import '../ui/owner/ownerestuimatedetailscreen.dart';
import '../ui/owner/ownergetallsitevisitpage.dart';
import '../ui/owner/ownersalesmanscreen.dart';
import '../ui/owner/quotations_screen.dart';
import '../ui/owner/incentive_management_screen.dart';
import '../widgets/ownerDashboardshell.dart';

import '../ui/salesman/dashboard_shell.dart';
import '../ui/salesman/create_estimate_screen.dart';
import '../ui/salesman/my_estimates_screen.dart';
import '../ui/salesman/approvedbills.dart';
import '../ui/salesman/quatationscreen.dart';
import '../ui/salesman/estimatedetailscreen_forsalesman.dart';

import '../ui/driver_dashboard/driver_dashboard.dart';
import '../ui/fieldstaff/fieldstaff_dashboard.dart';
import '../bloc/fieldstaffbloc/sitevist/sitevisit_bloc.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

      GoRoute(path: '/owner', builder: (context, state) => const Ownerdashboardshell()),
      GoRoute(path: '/salesman', builder: (context, state) => const DashboardShell()),
      GoRoute(path: '/driver', builder: (context, state) => const DriverDashboardScreen()),
      GoRoute(
        path: '/fieldstaff',
        builder: (context, state) => BlocProvider(
          create: (context) => SiteVisitBloc(),
          child: const FieldStaffDashboardScreen(),
        ),
      ),

      GoRoute(path: '/field-staff', builder: (context, state) => const OwnerAddFieldStaffScreen()),
      GoRoute(path: '/designations', builder: (context, state) => const AddDesignationPage()),

      GoRoute(path: '/create-estimate', builder: (context, state) => const CreateEstimateScreen()),
      GoRoute(path: '/my-estimates', builder: (context, state) => const MyEstimatesScreen()),
      GoRoute(path: '/approved-bills', builder: (context, state) => const ApprovedBills()),
      GoRoute(path: '/quotation-bills', builder: (context, state) => const QuotationListScreen()),
      GoRoute(
        path: '/incentives',
        builder: (context, state) => const OwnerSalesmanIncentiveScreen(isOwner: false),
      ),
      GoRoute(
        path: '/estimate-detail/:id',
        builder: (context, state) =>
            SalesmanEstimateDetailsScreen(id: state.pathParameters['id']!),
      ),

      GoRoute(path: '/owner/create-estimate', builder: (context, state) => const OwnerCreateEstimateScreen()),
      GoRoute(path: '/owner/estimates', builder: (context, state) => const OwnerEstimatesScreen()),
      GoRoute(path: '/owner/quotations', builder: (context, state) => const OwnerQuotationsScreen()),
      GoRoute(path: '/owner/reports', builder: (context, state) => const OwnerReportsScreen()),
      GoRoute(
        path: '/owner/incentives',
        builder: (context, state) => const OwnerSalesmanIncentiveScreen(isOwner: true),
      ),
      GoRoute(path: '/owner/product-setup', builder: (context, state) => const IncentiveManagementScreen()),
      GoRoute(path: '/owner/monthly-target', builder: (context, state) => const AddIncentiveScreen()),
      GoRoute(path: '/owner/designation-list', builder: (context, state) => const DesignationListPage()),
      GoRoute(path: '/owner/salesmen', builder: (context, state) => const OwnerSalesmenScreen()),
      GoRoute(path: '/owner/drivers', builder: (context, state) => const OwnerDriverScreen()),
      GoRoute(path: '/owner/fieldstaff-incentive', builder: (context, state) => const FieldStaffIncentiveScreen()),
      GoRoute(path: '/owner/site-visits', builder: (context, state) => const OwnerGetAllSiteVisitPage()),
      GoRoute(
        path: '/owner/estimate-detail/:id',
        builder: (context, state) =>
            OwnerEstimateDetailsScreen(estimateId: state.pathParameters['id']!),
      ),
    ],
  );
}