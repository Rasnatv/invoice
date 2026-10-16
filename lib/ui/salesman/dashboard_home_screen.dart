
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/models/salesmanmodels/salesman_dashboardmodel.dart'; // DashboardHomeRecentEstimate
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/salesman/widget/salesman_dashboardshimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanownerestimatestate.dart';
import '../../bloc/salemanbloc/salemandashboard/salesman_dashboardbloc.dart';
import '../../bloc/salemanbloc/salemandashboard/salesman_dashboardstate.dart';
import '../../bloc/salemanbloc/salemandashboard/salesmandashboard_event.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistbloc.dart';
import '../../bloc/salemanbloc/estimatelistview/salesmanowner_estimatelistevent.dart';
import '../../widgets/owner_widgets.dart'; // StatusBadge
import 'MONTHLYSALE.dart';
import 'my_estimates_screen.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const _DashboardHomeView();
}

// ---------------- QUICK ACTION DATA ----------------

class _ActionItem {
  const _ActionItem(this.icon, this.label, this.id);
  final IconData icon;
  final String label;
  final String id;
}

const List<_ActionItem> _quickActions = [
  _ActionItem(Icons.note_add_rounded, 'New Estimate', 'create'),
  _ActionItem(Icons.local_shipping_rounded, 'Approved Bills', 'approved'),
  _ActionItem(Icons.receipt_long_rounded, 'Quotation Bills', 'quotation'),
  _ActionItem(Icons.currency_rupee_rounded, 'Incentive', 'incentive'),
  // _ActionItem(Icons.folder_copy_rounded, 'My Estimates', 'estimates'),
];

/// How many actions show before "More" is tapped.
const int _collapsedCount = 4;

// ---------------- SCREEN ----------------

class _DashboardHomeView extends StatelessWidget {
  const _DashboardHomeView();

  void _openCreateEstimate(BuildContext context) async {
    final created = await context.push<bool>('/create-estimate');
    if (created == true && context.mounted) {
      context.read<DashboardHomeBloc>().add(const DashboardHomeRefreshed());
      context.read<EstimatesBloc>().add(const EstimatesRefreshRequested());
    }
  }

  Future<void> _openMyEstimates(BuildContext context) async {
    final estimatesBloc = context.read<EstimatesBloc>();

    if (estimatesBloc.state.status != EstimatesStatus.loading) {
      estimatesBloc.add(const EstimatesRefreshRequested());
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: estimatesBloc,
          child: const MyEstimatesScreen(),
        ),
      ),
    );
    if (context.mounted) {
      context.read<DashboardHomeBloc>().add(const DashboardHomeRefreshed());
    }
  }

  Future<void> _openApprovedBills(BuildContext context) async {
    await context.push('/approved-bills');
    if (context.mounted) {
      context.read<DashboardHomeBloc>().add(const DashboardHomeRefreshed());
    }
  }

  void _onAction(BuildContext context, String id) {
    switch (id) {
      case 'create':
        _openCreateEstimate(context);
        break;
      case 'approved':
        _openApprovedBills(context);
        break;
      case 'quotation':
        context.push('/quotation-bills');
        break;
      case 'incentive':
        context.push('/incentives');
        break;
      case 'estimates':
        _openMyEstimates(context);
        break;
    }
  }

  bool _hasSalesData(List<dynamic> monthlySales) {
    if (monthlySales.isEmpty) return false;
    return monthlySales.any((m) => (m.total as num) > 0);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
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
        body: BlocBuilder<DashboardHomeBloc, DashboardHomeState>(
          builder: (context, state) {
            if (state.status == DashboardHomeStatus.initial ||
                state.status == DashboardHomeStatus.loading ||
                state.status == DashboardHomeStatus.refreshing) {
              return const SalesmanDashboardShimmer();
            }

            if (state.status == DashboardHomeStatus.failure &&
                state.recentEstimates.isEmpty) {
              return _ErrorState(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () => context
                    .read<DashboardHomeBloc>()
                    .add(const DashboardHomeRequested()),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context
                    .read<DashboardHomeBloc>()
                    .add(const DashboardHomeRefreshed());
                await context.read<DashboardHomeBloc>().stream.firstWhere(
                      (s) => s.status != DashboardHomeStatus.refreshing,
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _DashboardHeader(
                      greeting: greeting,
                      name: state.salesmanName,
                      dateLabel: today,
                      totalEstimates: state.totalEstimates,
                      quotations: state.quotations,
                      pending: state.pending,
                      dispatchBills: state.dispatchBills,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: Responsive.h(76))),

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
                          if (state.status == DashboardHomeStatus.failure) ...[
                            _InlineErrorBanner(
                              message: state.errorMessage ??
                                  'Failed to refresh dashboard.',
                            ),
                            SizedBox(height: Responsive.h(14)),
                          ],
                          const _SectionTitle(title: 'Quick Actions'),
                          SizedBox(height: Responsive.h(10)),
                          _QuickAccessPanel(
                            onAction: (id) => _onAction(context, id),
                          ),
                          SizedBox(height: Responsive.h(14)),
                        ],
                      ),
                    ),
                  ),

                  // ---------- SALES + RECENT ----------
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
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
                            child: DashboardMonthlySalesChart(
                              data: state.monthlySales,
                            ),
                          ),
                        SizedBox(height: Responsive.h(26)),
                        _SectionTitle(
                          title: 'Recent Estimates',
                          actionLabel: 'View all',
                          onAction: () => _openMyEstimates(context),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        if (state.recentEstimates.isEmpty)
                          const _EmptyState(
                            icon: Icons.description_outlined,
                            message: 'No estimates yet. Create your first one.',
                          )
                        else
                          Column(
                            children: [
                              for (int i = 0;
                              i < state.recentEstimates.length;
                              i++) ...[
                                _RecentEstimateCard(
                                  estimate: state.recentEstimates[i],
                                  onTap: () => context.push(
                                    '/estimate-detail/${state.recentEstimates[i].id}',
                                  ),
                                ),
                                if (i != state.recentEstimates.length - 1)
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.dateLabel,
    required this.totalEstimates,
    required this.quotations,
    required this.pending,
    required this.dispatchBills,
  });

  final String greeting;
  final String name;
  final String dateLabel;
  final int totalEstimates;
  final int quotations;
  final int pending;
  final int dispatchBills;

  @override
  Widget build(BuildContext context) {
    final softWhite = Colors.white.withValues(alpha: 0.8);

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
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
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
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.bodyBold(color: Colors.white)
                        .copyWith(fontSize: Responsive.sp(18)),
                  ),
                ),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting (12 / w400)
                      Text(greeting, style: AppTextStyles.caption(color: softWhite)),
                      SizedBox(height: Responsive.h(2)),
                      // Name (18 / w600)
                      Text(
                        name.isNotEmpty ? name : 'Salesman',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyBold(color: Colors.white)
                            .copyWith(fontSize: Responsive.sp(18)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: softWhite),
                    SizedBox(height: Responsive.h(4)),
                    // Date (10.5 / w400)
                    Text(
                      dateLabel,
                      style: AppTextStyles.captionnew(color: softWhite)
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
              vertical: Responsive.h(14),
              horizontal: Responsive.w(6),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
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
                    value: '$quotations',
                    label: 'Quotations',
                    icon: Icons.receipt_long_rounded,
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
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$dispatchBills',
                    label: 'Dispatch',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF7C3AED),
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
    color: AppColors.textSecondary.withValues(alpha: 0.14),
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
        // Stat value (17 / w600)
        Text(
          value,
          style: AppTextStyles.bodyBold(color: AppColors.black)
              .copyWith(fontSize: Responsive.sp(17)),
        ),
        SizedBox(height: Responsive.h(2)),
        // Stat label (10.5 / w400)
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

// ---------------- SECTION TITLE ----------------

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
        // Section title (16 / w600)
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
  const _QuickAccessPanel({required this.onAction});
  final ValueChanged<String> onAction;

  @override
  State<_QuickAccessPanel> createState() => _QuickAccessPanelState();
}

class _QuickAccessPanelState extends State<_QuickAccessPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final canExpand = _quickActions.length > _collapsedCount;
    final visible =
    _expanded ? _quickActions : _quickActions.take(_collapsedCount).toList();

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
                    onTap: () => widget.onAction(a.id),
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
                color: AppColors.primary.withValues(alpha: 0.08),
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
                size: 38,
                color: AppColors.textSecondary.withValues(alpha: 0.4)),
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
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: Responsive.w(40)),
            SizedBox(height: Responsive.h(12)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(16)),
            OutlinedButton(
              onPressed: onRetry,
              child: Text('Retry',
                  style: AppTextStyles.button(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(14),
        vertical: Responsive.h(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Color(0xFFDC2626)),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.subtitle(color: const Color(0xFFDC2626)),
            ),
          ),
        ],
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
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined,
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
                    Text(estimate.dateFormatted, style: AppTextStyles.caption()),
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