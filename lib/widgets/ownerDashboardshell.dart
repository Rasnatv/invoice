// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../cubit/nav_cubit.dart';
// import '../../reports/presentation/reports_screen.dart';
// import '../presentation/owner_dashboard_screen.dart';
// import '../presentation/owner_estimates_screen.dart';
// import '../presentation/ownerdespatch_screen.dart';
// import '../presentation/profile.dart';
//
//
// /// Root shell for the Salesman Dashboard — hosts the bottom navigation
// /// bar (Dashboard / Estimates / Dispatch / Contractors / Profile) exactly
// /// as laid out across every screen in the reference screenshot, and
// /// swaps the body via [NavCubit] without losing each tab's own state.
// class Ownerdashboardshell extends StatelessWidget {
//   const Ownerdashboardshell({super.key});
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
//     return BlocProvider(
//       create: (_) => NavCubit(),
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

import '../ui/owner/owner_dashboard_screen.dart';
import '../ui/owner/owner_estimates_screen.dart';
import '../ui/owner/ownerdespatch_screen.dart';
import '../ui/owner/profile.dart';

/// Root shell for the Owner Dashboard — hosts the bottom navigation
/// bar (Dashboard / Estimates / Dispatch / Profile) and swaps the body
/// via local state, without losing each tab's own state (IndexedStack).
class Ownerdashboardshell extends StatefulWidget {
  const Ownerdashboardshell({super.key});

  @override
  State<Ownerdashboardshell> createState() => _OwnerdashboardshellState();
}

class _OwnerdashboardshellState extends State<Ownerdashboardshell> {
  int _index = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: _items
            .map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}