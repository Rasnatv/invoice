
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_event.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_state.dart';
import '../../bloc/ownerbloc/ownerdashboard/ownerdashboard_bloc.dart';
import 'package:tileshop/models/salesmanmodels/salesman_dashboardmodel.dart'; // DashboardHomeRecentEstimate etc.
import '../../widgets/monthlysale.dart';
import '../../widgets/owner_widgets.dart'; // StatusBadge
import '../../widgets/ownerdashboardscreen_shimmer.dart';
import 'ownerestuimatedetailscreen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OwnerDashboardView();
  }
}

// ---------------- ACTION DATA (grouped) ----------------
// Every action uses the app's primary color.

class _ActionItem {
  const _ActionItem(this.icon, this.label, this.route, {this.primary = false});
  final IconData icon;
  final String label;
  final String route;

  /// Primary actions are the ones visible before the user taps the arrow.
  final bool primary;
}

class _ActionGroup {
  const _ActionGroup(this.title, this.items);
  final String title;
  final List<_ActionItem> items;
}

const List<_ActionGroup> _actionGroups = [
  _ActionGroup('Sales & Billing', [
    _ActionItem(Icons.receipt_sharp, 'Create Estimate', '/owner/create-estimate',
        primary: true),
    _ActionItem(Icons.receipt_long_rounded, 'Estimates', '/owner/estimates',
        primary: true),
    _ActionItem(Icons.request_quote_outlined, 'Quotations', '/owner/quotations',
        primary: true),
    _ActionItem(
        Icons.inventory_2_outlined, 'Product Setup', '/owner/product-setup'),
  ]),
  _ActionGroup('Team', [
    _ActionItem(Icons.groups_2_outlined, 'Salesmen', '/owner/salesmen',
        primary: true),
    _ActionItem(Icons.monetization_on_outlined, 'Salesman Incentive',
        '/owner/incentives'),
    _ActionItem(Icons.calendar_month_rounded, 'Monthly Target',
        '/owner/monthly-target'),
    _ActionItem(Icons.bar_chart_rounded, 'Reports', '/owner/reports'),
  ]),
  _ActionGroup('Field Operations', [
    _ActionItem(Icons.assignment_ind_rounded, 'Field Staff', '/field-staff'),
    _ActionItem(Icons.paid_outlined, 'Field Staff Incentive',
        '/owner/fieldstaff-incentive'),
    _ActionItem(
        Icons.location_on_outlined, 'Site Visits', '/owner/site-visits'),
    _ActionItem(Icons.local_shipping_rounded, 'Driver', '/owner/drivers'),
  ]),
];

final List<_ActionItem> _allActions =
_actionGroups.expand((g) => g.items).toList();

/// Primary actions first, then the rest, so positions don't jump
/// when the panel expands.
final List<_ActionItem> _quickActions = [
  ..._allActions.where((a) => a.primary),
  ..._allActions.where((a) => !a.primary),
];

/// How many actions show before the arrow is tapped.
/// (Set to 8 if you want two rows visible.)
const int _collapsedCount = 4;

// ---------------- SCREEN ----------------

class _OwnerDashboardView extends StatefulWidget {
  const _OwnerDashboardView();

  @override
  State<_OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<_OwnerDashboardView> {
  /// Opens a widget screen and reloads the dashboard when it is closed.
  Future<void> _openAndRefresh(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (!mounted) return;
    context.read<OwnerDashboardBloc>().add(const OwnerDashboardRefreshed());
  }

  /// Opens a go_router route and reloads the dashboard when the user
  /// comes back (used by Quick Actions and "View all").
  Future<void> _pushAndRefresh(String route) async {
    await context.push(route);
    if (!mounted) return;
    context.read<OwnerDashboardBloc>().add(const OwnerDashboardRefreshed());
  }

  bool _hasSalesData(List<dynamic> monthlySales) {
    if (monthlySales.isEmpty) return false;
    return monthlySales.any((m) => (m.total as num) > 0);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final today = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
          builder: (context, state) {
            if (state.status == OwnerDashboardStatus.loading) {
              return const OwnerDashboardFullShimmer();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OwnerDashboardBloc>()
                    .add(const OwnerDashboardRefreshed());
                await context.read<OwnerDashboardBloc>().stream.firstWhere(
                      (s) => s.status != OwnerDashboardStatus.refreshing,
                );
              },
              child: state.status == OwnerDashboardStatus.refreshing
                  ? const OwnerDashboardRefreshShimmer()
                  : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _OwnerHeader(
                      greeting: greeting,
                      dateLabel: today,
                      userName: state.userName,
                      totalEstimates: state.totalEstimates,
                      dispatched: state.dispatchBills,
                      quotations: state.quotations,
                      pending: state.pending,
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: SizedBox(height: Responsive.h(76))),

                  // ---------- QUICK ACTIONS ----------
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      Responsive.w(20),
                      0,
                      Responsive.w(20),
                      Responsive.h(6),
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Quick Actions'),
                          SizedBox(height: Responsive.h(10)),
                          _QuickAccessPanel(onOpen: _pushAndRefresh),
                          SizedBox(height: Responsive.h(14)),
                        ],
                      ),
                    ),
                  ),

                  // ---------- SALES + RECENT ----------
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(20)),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: Responsive.h(6)),
                        const _SectionTitle(title: 'Sales Overview'),
                        SizedBox(height: Responsive.h(12)),
                        if (!_hasSalesData(state.monthlySales))
                          const _EmptyState(
                            icon: Icons.bar_chart_rounded,
                            message: 'No sales yet this year',
                          )
                        else
                          _CardWrapper(
                            child: MonthlySalesSection(
                              monthlySales: state.monthlySales
                                  .map((m) => MonthlySales(
                                monthLabel: m.month,
                                amount: m.total.toDouble(),
                              ))
                                  .toList(),
                              currency: currency,
                            ),
                          ),
                        SizedBox(height: Responsive.h(26)),
                        _SectionTitle(
                          title: 'Recent Estimates',
                          actionLabel: 'View all',
                          onAction: () =>
                              _pushAndRefresh('/owner/estimates'),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        if (state.status == OwnerDashboardStatus.failure)
                          _ErrorState(
                            message: state.errorMessage ??
                                'Could not load the dashboard.',
                            onRetry: () => context
                                .read<OwnerDashboardBloc>()
                                .add(const OwnerDashboardRequested()),
                          )
                        else if (state.recentEstimates.isEmpty)
                          const _EmptyState(
                            icon: Icons.description_outlined,
                            message:
                            'No estimates yet. Create your first one.',
                          )
                        else
                          Column(
                            children: [
                              for (int i = 0;
                              i < state.recentEstimates.length;
                              i++) ...[
                                _RecentEstimateCard(
                                  estimate: state.recentEstimates[i],
                                  onTap: () => _openAndRefresh(
                                    OwnerEstimateDetailsScreen(
                                      estimateId: state
                                          .recentEstimates[i].id
                                          .toString(),
                                    ),
                                  ),
                                ),
                                if (i !=
                                    state.recentEstimates.length - 1)
                                  SizedBox(height: Responsive.h(10)),
                              ],
                            ],
                          ),
                        SizedBox(height: Responsive.h(30)),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- HEADER ----------------

class _OwnerHeader extends StatelessWidget {
  const _OwnerHeader({
    required this.greeting,
    required this.dateLabel,
    required this.userName,
    required this.totalEstimates,
    required this.dispatched,
    required this.quotations,
    required this.pending,
  });

  final String greeting;
  final String dateLabel;
  final String userName;
  final int totalEstimates;
  final int dispatched;
  final int quotations;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(18),
            Responsive.w(20),
            Responsive.h(54),
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 24),
                ),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting (12 / w400)
                      Text(
                        greeting,
                        style: AppTextStyles.caption(
                            color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        userName.isNotEmpty ? userName : 'Owner Dashboard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyBold(color: Colors.white)
                            .copyWith(fontSize: Responsive.sp(18)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.white.withOpacity(0.8)),
                    SizedBox(height: Responsive.h(4)),
                    // Date (10.5 / w400)
                    Text(
                      dateLabel,
                      style: AppTextStyles.captionnew(
                          color: Colors.white.withOpacity(0.8))
                          .copyWith(fontSize: Responsive.sp(10.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(52),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: Responsive.h(14), horizontal: Responsive.w(6)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    value: '$totalEstimates',
                    label: 'Total',
                    icon: Icons.description_rounded,
                    color: AppColors.primary,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$dispatched',
                    label: 'Dispatched',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF520B95),
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$quotations',
                    label: 'Quotations',
                    icon: Icons.request_quote_rounded,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$pending',
                    label: 'Pending',
                    icon: Icons.hourglass_bottom_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 34,
    color: AppColors.textSecondary.withOpacity(0.14),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(height: Responsive.h(6)),
        Text(
          value,
          style: AppTextStyles.bodyBold(color: AppColors.black)
              .copyWith(fontSize: Responsive.sp(17)),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.captionnew(color: AppColors.textSecondary)
              .copyWith(fontSize: Responsive.sp(10.5)),
        ),
      ],
    );
  }
}

// ---------------- SECTION TITLES ----------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyBold(color: AppColors.black)
              .copyWith(fontSize: Responsive.sp(16)),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                actionLabel!,
                style: AppTextStyles.link()
                    .copyWith(fontSize: Responsive.sp(12.5)),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------- QUICK ACCESS (collapsible grid) ----------------

class _QuickAccessPanel extends StatefulWidget {
  const _QuickAccessPanel({required this.onOpen});

  /// Called with the route to open; the dashboard pushes it and
  /// refreshes itself when the user returns.
  final Future<void> Function(String route) onOpen;

  @override
  State<_QuickAccessPanel> createState() => _QuickAccessPanelState();
}

class _QuickAccessPanelState extends State<_QuickAccessPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final canExpand = _quickActions.length > _collapsedCount;
    final visible = _expanded
        ? _quickActions
        : _quickActions.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(6), vertical: Responsive.h(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 0.9,
              children: [
                for (final a in visible)
                  _ActionTile(
                    icon: a.icon,
                    label: a.label,
                    onTap: () => widget.onOpen(a.route),
                  ),
              ],
            ),
          ),
          if (canExpand) ...[
            const Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'More',
                      style: AppTextStyles.link(),
                    ),
                    SizedBox(width: Responsive.w(4)),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(2), vertical: Responsive.h(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            SizedBox(height: Responsive.h(5)),
            // Quick action label (10 / w500 / height 1.15)
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tabLabel(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- SHARED CARD WRAPPER ----------------

class _CardWrapper extends StatelessWidget {
  const _CardWrapper({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ---------------- EMPTY / ERROR STATES ----------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(22)),
        child: Column(
          children: [
            Icon(icon,
                size: 38, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(18)),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 36, color: AppColors.textSecondary.withOpacity(0.5)),
            SizedBox(height: Responsive.h(10)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.link()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- RECENT ESTIMATE ----------------

class _RecentEstimateCard extends StatelessWidget {
  const _RecentEstimateCard({required this.estimate, required this.onTap});

  final DashboardHomeRecentEstimate estimate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description_outlined,
                    color: AppColors.primary, size: 20),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estimate.estimateNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      estimate.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(estimate.dateFormatted,
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    estimate.grandTotalFormatted,
                    style: AppTextStyles.bodyBold(color: AppColors.primary),
                  ),
                  SizedBox(height: Responsive.h(6)),
                  StatusBadge(status: estimate.statusLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}