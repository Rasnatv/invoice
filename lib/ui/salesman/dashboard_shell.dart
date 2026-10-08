//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tileshop/ui/salesman/salman_despatchlistscreen.dart';
// import '../owner/ownerdespatch_screen.dart';
// import 'cubit/nav_cubit.dart';
// import 'my_estimates_screen.dart';
// import 'dashboard_home_screen.dart';
// import 'profile_screen.dart';
// import '../../bloc/salemanbloc/salemandashboard/salesman_dashboardbloc.dart';
// import '../../bloc/salemanbloc/salemandashboard/salesmandashboard_event.dart';
// import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistbloc.dart';
// import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistevent.dart';
//
// class DashboardShell extends StatelessWidget {
//   const DashboardShell({super.key});
//
//   static const _screens = [
//     DashboardHomeScreen(),
//     MyEstimatesScreen(),
//     SalesmanDispatchListScreen(),
//     ProfileScreen(),
//   ];
//
//   static const _items = [
//     _NavItem(icon: Icons.home_rounded, label: 'Dashboard'),
//     _NavItem(icon: Icons.description_rounded, label: 'Estimates'),
//     _NavItem(icon: Icons.local_shipping_rounded, label: 'Dispatch'),
//     _NavItem(icon: Icons.person_rounded, label: 'Profile'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => NavCubit()),
//         BlocProvider(create: (_) => DashboardHomeBloc()..add(const DashboardHomeRequested())),
//         BlocProvider(create: (_) => EstimatesBloc()..add(const EstimatesLoadRequested())),
//       ],
//       child: BlocBuilder<NavCubit, int>(
//         builder: (context, index) {
//           return Scaffold(
//             body: IndexedStack(index: index, children: _screens),
//             bottomNavigationBar: BottomNavigationBar(
//               currentIndex: index,
//               onTap: (i) => context.read<NavCubit>().changeTab(i),
//               items: _items
//                   .map((item) => BottomNavigationBarItem(
//                 icon: Icon(item.icon),
//                 label: item.label,
//               ))
//                   .toList(),
//             ),
//           );
//         },
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
import 'package:tileshop/ui/salesman/salman_despatchlistscreen.dart';
import 'cubit/nav_cubit.dart';
import 'my_estimates_screen.dart';
import 'dashboard_home_screen.dart';
import 'profile_screen.dart';
import '../../bloc/salemanbloc/salemandashboard/salesman_dashboardbloc.dart';
import '../../bloc/salemanbloc/salemandashboard/salesmandashboard_event.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistbloc.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistevent.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanownerestimatestate.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.description_rounded, label: 'Estimates'),
    _NavItem(icon: Icons.local_shipping_rounded, label: 'Dispatch'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  /// Bumped every time the Dispatch tab is opened. Changing the key makes
  /// Flutter rebuild that screen from scratch, so it loads fresh data
  /// (IndexedStack otherwise keeps the old screen alive and never reloads).
  int _dispatchVersion = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(
          create: (_) => DashboardHomeBloc()..add(const DashboardHomeRequested()),
        ),
        BlocProvider(
          lazy: false,
          create: (_) => EstimatesBloc()..add(const EstimatesLoadRequested()),
        ),
      ],
      child: BlocListener<NavCubit, int>(
        // Only when the tab actually changes.
        listenWhen: (prev, curr) => prev != curr,
        listener: (context, index) {
          // Estimates tab -> reload its list from page 1.
          if (index == 1) {
            final bloc = context.read<EstimatesBloc>();
            if (bloc.state.status != EstimatesStatus.loading) {
              bloc.add(const EstimatesRefreshRequested());
            }
          }
          // Dispatch tab -> rebuild the screen so it reloads.
          if (index == 2) {
            setState(() => _dispatchVersion++);
          }
        },
        child: BlocBuilder<NavCubit, int>(
          builder: (context, index) {
            final screens = <Widget>[
              const DashboardHomeScreen(),
              const MyEstimatesScreen(),
              KeyedSubtree(
                key: ValueKey('dispatch-$_dispatchVersion'),
                child: const SalesmanDispatchListScreen(),
              ),
              const ProfileScreen(),
            ];

            return Scaffold(
              body: IndexedStack(index: index, children: screens),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: index,
                onTap: (i) => context.read<NavCubit>().changeTab(i),
                items: _items
                    .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
                    .toList(),
              ),
            );
          },
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