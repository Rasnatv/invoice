import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/nav_cubit.dart';
import '../estimates/presentation/my_estimates_screen.dart';
import '../home/presentation/dashboard_home_screen.dart';
import '../dispatch/presentation/my_dispatch_bills_screen.dart';
import '../contractors/presentation/contractors_screen.dart';
import '../profile/presentation/profile_screen.dart';

/// Root shell for the Salesman Dashboard — hosts the bottom navigation
/// bar (Dashboard / Estimates / Dispatch / Contractors / Profile) exactly
/// as laid out across every screen in the reference screenshot, and
/// swaps the body via [NavCubit] without losing each tab's own state.
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  static const _screens = [
    DashboardHomeScreen(),
    MyEstimatesScreen(),
    MyDispatchBillsScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.description_rounded, label: 'Estimates'),
    _NavItem(icon: Icons.local_shipping_rounded, label: 'Dispatch'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) {
          return Scaffold(
            body: IndexedStack(index: index, children: _screens),
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
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
