
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Apiprovider/ownerdespatchprovider.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchbloc.dart';
import '../../bloc/ownerbloc/despatchlist/ownerlist_despatchevent.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_bloc.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_event.dart';

import '../ui/owner/owner_dashboard_screen.dart';
import '../ui/owner/owner_estimates_screen.dart';
import '../ui/owner/ownerdespatch_screen.dart';
import '../ui/owner/profile.dart';
import 'owner_dashboardrefresh.dart';

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

  // Tab indices — kept as constants so tap handling stays in sync.
  static const int _dashboardTabIndex = 0;
  static const int _dispatchTabIndex = 2;

  late final DispatchListBloc _dispatchListBloc;
  late final OwnerDashboardBloc _ownerDashboardBloc;

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
    // Both blocs are created ONCE here and kept alive for the whole
    // lifetime of the shell — surviving tab switches AND any pages
    // pushed on top (e.g. Estimates, Estimate Detail) and popped back.
    _dispatchListBloc = DispatchListBloc(DispatchProvider())..add(const FetchDispatchList());
    _ownerDashboardBloc = OwnerDashboardBloc()..add(const OwnerDashboardRequested());

    // NEW: listen for "data changed" signals (e.g. estimate approved).
    ownerDataRefresh.addListener(_onExternalRefresh);
  }

  @override
  void dispose() {
    ownerDataRefresh.removeListener(_onExternalRefresh); // NEW
    _dispatchListBloc.close();
    _ownerDashboardBloc.close();
    super.dispose();
  }

  /// NEW: called when the create-estimate screen finishes saving/approving.
  void _onExternalRefresh() {
    if (!mounted) return;

    // Show the Dashboard tab.
    setState(() => _index = _dashboardTabIndex);

    // Immediate refresh, plus one more shortly after in case the backend
    // had not finished saving when the first request went out.
    _ownerDashboardBloc.add(const OwnerDashboardRefreshed());
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _ownerDashboardBloc.add(const OwnerDashboardRefreshed());
    });

    // Optional: dispatch list can change after approval too.
    _dispatchListBloc.add(const RefreshDispatchList());
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
    // Silent background refresh when returning to Dashboard tab, so
    // numbers stay current without showing the full loading shimmer
    // (BlocBuilder only shows the full shimmer for the very first load).
    if (i == _dashboardTabIndex) {
      _ownerDashboardBloc.add(const OwnerDashboardRefreshed());
    }
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