
import 'package:flutter/material.dart';

import '../ui/owner/owner_dashboard_screen.dart';
import '../ui/owner/owner_estimates_screen.dart';
import '../ui/owner/ownerdespatch_screen.dart';
import '../ui/owner/profile.dart';
//
// /// Root shell for the Owner Dashboard — hosts the bottom navigation
// /// bar (Dashboard / Estimates / Dispatch / Profile) and swaps the body
// /// via local state, without losing each tab's own state (IndexedStack).
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
//   static const _screens = [
//     OwnerDashboardScreen(),
//     OwnerEstimatesScreen(),
//     OwnerdespatchScreen(),
//     OwnerProfileScreen(),
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
//     return Scaffold(
//       body: IndexedStack(index: _index, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _index,
//         onTap: (i) => setState(() => _index = i),
//         type: BottomNavigationBarType.fixed,
//         items: _items
//             .map((item) => BottomNavigationBarItem(
//           icon: Icon(item.icon),
//           label: item.label,
//         ))
//             .toList(),
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

class Ownerdashboardshell extends StatefulWidget {
  const Ownerdashboardshell({super.key});

  @override
  State<Ownerdashboardshell> createState() => _OwnerdashboardshellState();
}

class _OwnerdashboardshellState extends State<Ownerdashboardshell> {
  int _index = 0;

  // Index of the Dispatch tab in _screens/_items below — kept as a
  // constant so the tap handler and this stay in sync.
  static const int _dispatchTabIndex = 2;

  late final DispatchListBloc _dispatchListBloc;

  static const _screens = [
    OwnerDashboardScreen(),
    OwnerEstimatesScreen(),
    OwnerdespatchScreen(),
    OwnerProfileScreen(),
  ];

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.description_rounded, label: 'Estimates'),
    _NavItem(icon: Icons.local_shipping_rounded, label: 'Dispatch'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _dispatchListBloc = DispatchListBloc(DispatchProvider())..add(const FetchDispatchList());
  }

  @override
  void dispose() {
    _dispatchListBloc.close();
    super.dispose();
  }

  void _onTabTapped(int i) {
    // Every time the Dispatch tab is (re)selected — including tapping
    // back onto it after dispatching a bill from another tab/screen —
    // force a fresh fetch. IndexedStack keeps OwnerdespatchScreen alive
    // in memory, so without this its bloc would otherwise only ever
    // fetch once, the very first time the tab was built.
    if (i == _dispatchTabIndex) {
      _dispatchListBloc.add(const RefreshDispatchList());
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dispatchListBloc,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
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