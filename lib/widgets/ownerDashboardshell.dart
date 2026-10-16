//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../Apiprovider/ownerdespatchprovider.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
// import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
// import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_bloc.dart';
// import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_event.dart';
//
// import '../core/constants/app_colors.dart';
// import '../core/constants/app_text_styles.dart';
// import '../ui/owner/owner_dashboard_screen.dart';
// import '../ui/owner/owner_estimates_screen.dart';
// import '../ui/owner/ownerdespatch_screen.dart';
// import '../ui/owner/profile.dart';
//
// /// All four tabs are built at login (IndexedStack). Tapping a tab sends a
// /// refresh so that tab's API is called again.
// class Ownerdashboardshell extends StatefulWidget {
//   const Ownerdashboardshell({super.key});
//
//   @override
//   State<Ownerdashboardshell> createState() => _OwnerdashboardshellState();
// }
//
// class _OwnerdashboardshellState extends State<Ownerdashboardshell> {
//   int _index = 0;
//
//   static const int _dashboardTabIndex = 0;
//   static const int _estimatesTabIndex = 1;
//   static const int _dispatchTabIndex = 2;
//   static const int _profileTabIndex = 3;
//
//   late final DispatchListBloc _dispatchListBloc;
//   late final OwnerDashboardBloc _ownerDashboardBloc;
//
//   final ValueNotifier<int> _estimatesRefresh = ValueNotifier<int>(0);
//   final ValueNotifier<int> _profileRefresh = ValueNotifier<int>(0);
//
//   static const _items = [
//     _NavItem(icon: Icons.home_rounded, label: 'Dashboard'),
//     _NavItem(icon: Icons.description_rounded, label: 'Estimates'),
//     _NavItem(icon: Icons.local_shipping_rounded, label: 'Dispatch'),
//     _NavItem(icon: Icons.person_rounded, label: 'Profile'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _dispatchListBloc = DispatchListBloc(DispatchProvider())
//       ..add(const FetchDispatchList());
//     _ownerDashboardBloc = OwnerDashboardBloc()
//       ..add(const OwnerDashboardRequested());
//   }
//
//   @override
//   void dispose() {
//     _estimatesRefresh.dispose();
//     _profileRefresh.dispose();
//     _dispatchListBloc.close();
//     _ownerDashboardBloc.close();
//     super.dispose();
//   }
//
//   void _onTabTapped(int i) {
//     if (i == _dispatchTabIndex) {
//       _dispatchListBloc.add(const RefreshDispatchList());
//     }
//     if (i == _dashboardTabIndex) {
//       _ownerDashboardBloc.add(const OwnerDashboardRefreshed());
//     }
//     if (i == _estimatesTabIndex) _estimatesRefresh.value++;
//     if (i == _profileTabIndex) _profileRefresh.value++;
//
//     setState(() => _index = i);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: _dispatchListBloc),
//         BlocProvider.value(value: _ownerDashboardBloc),
//       ],
//       child: Scaffold(
//         body: IndexedStack(
//           index: _index,
//           children: [
//             const OwnerDashboardScreen(),
//             OwnerEstimatesScreen(refreshSignal: _estimatesRefresh),
//             const OwnerdespatchScreen(),
//             OwnerProfileScreen(refreshSignal: _profileRefresh),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _index,
//         onTap: _onTabTapped,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: AppColors.textSecondary,
//         iconSize: 22,
//         selectedFontSize: 10,
//         unselectedFontSize: 10,
//         selectedLabelStyle: AppTextStyles.captioref(color: AppColors.primary),
//         unselectedLabelStyle:
//         AppTextStyles.captionnew(color: AppColors.textSecondary),
//         items: _items
//             .map((item) => BottomNavigationBarItem(
//           icon: Icon(item.icon),
//           label: item.label,
//         ))
//             .toList(),
//       ),
//
//       ),
//     );
//   }
// }
//
// class _NavItem {
//   final IconData icon;
//   final String label;
//   const _NavItem({required this.icon, required this.label});
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_bloc.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_event.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../ui/owner/owner_dashboard_screen.dart';
import '../ui/owner/owner_estimates_screen.dart';
import '../ui/owner/ownerdespatch_screen.dart';
import '../ui/owner/profile.dart';

class Ownerdashboardshell extends StatefulWidget {
  const Ownerdashboardshell({super.key});

  @override
  State<Ownerdashboardshell> createState() => _OwnerdashboardshellState();
}

class _OwnerdashboardshellState extends State<Ownerdashboardshell> {
  int _index = 0;

  static const int _dashboardTabIndex = 0;
  static const int _estimatesTabIndex = 1;
  static const int _dispatchTabIndex = 2;
  static const int _profileTabIndex = 3;

  late final DispatchListBloc _dispatchListBloc;
  late final OwnerDashboardBloc _ownerDashboardBloc;

  final ValueNotifier<int> _estimatesRefresh = ValueNotifier<int>(0);
  final ValueNotifier<int> _dispatchRefresh = ValueNotifier<int>(0); // NEW
  final ValueNotifier<int> _profileRefresh = ValueNotifier<int>(0);

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.description_rounded, label: 'Estimates'),
    _NavItem(icon: Icons.local_shipping_rounded, label: 'Dispatch'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _dispatchListBloc = DispatchListBloc(DispatchProvider())
      ..add(const FetchDispatchList());
    _ownerDashboardBloc = OwnerDashboardBloc()
      ..add(const OwnerDashboardRequested());
  }

  @override
  void dispose() {
    _estimatesRefresh.dispose();
    _dispatchRefresh.dispose(); // NEW
    _profileRefresh.dispose();
    _dispatchListBloc.close();
    _ownerDashboardBloc.close();
    super.dispose();
  }

  void _onTabTapped(int i) {
    if (i == _dashboardTabIndex) {
      _ownerDashboardBloc.add(const OwnerDashboardRefreshed());
    }
    if (i == _estimatesTabIndex) _estimatesRefresh.value++;
    if (i == _dispatchTabIndex) _dispatchRefresh.value++; // CHANGED
    if (i == _profileTabIndex) _profileRefresh.value++;

    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dispatchListBloc),
        BlocProvider.value(value: _ownerDashboardBloc),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const OwnerDashboardScreen(),
            OwnerEstimatesScreen(refreshSignal: _estimatesRefresh),
            OwnerdespatchScreen(refreshSignal: _dispatchRefresh), // CHANGED
            OwnerProfileScreen(refreshSignal: _profileRefresh),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          iconSize: 22,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: AppTextStyles.captioref(color: AppColors.primary),
          unselectedLabelStyle:
          AppTextStyles.captionnew(color: AppColors.textSecondary),
          items: _items
              .map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          ))
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}