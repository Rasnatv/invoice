
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/salesman_dashboardbloc.dart';
import '../../bloc/salemanbloc/salesman_dashboardstate.dart';
import '../../bloc/salemanbloc/salesmandashboard_event.dart';
import 'MONTHLYSALE.dart';
import 'approvedbills.dart';
import 'create_estimate_screen.dart';
import 'dashboardhomeestimatetile.dart';
import 'estimatedetailscreen_forsalesman.dart';
import 'my_estimates_screen.dart';
import 'estimates/widgets/monthlysalechart.dart';
import 'incentive/salesmanincentivescreen.dart';
import 'quatation/quatationscreen.dart';
import 'estimates/presentation/estimate_details_screen.dart';
import 'home/widgets/recent_estimate_tile.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardHomeBloc()..add(const DashboardHomeRequested()),
      child: const _DashboardHomeView(),
    );
  }
}

class _DashboardHomeView extends StatelessWidget {
  const _DashboardHomeView();

  void _openCreateEstimate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateEstimateScreen()),
    );
  }

  void _openMyEstimates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyEstimatesScreen()),
    );
  }

  void _openIncentives(BuildContext context, DashboardHomeState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SalesmanIncentiveScreen(salesmanName: state.salesmanName),
      ),
    );
  }

  void _openApprovedBills(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApprovedBills()),
    );
  }

  void _openQuotationBills(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuotationListScreen()),
    );
  }

  // Opens the estimate detail screen for a tapped recent-estimate tile.
  // Uses /estimates/show directly with the dashboard's own estimate id —
  // no id-space mismatch here (unlike QuotationPreviewScreen, which needed
  // a quotation-table id, not an estimate id). EstimateDetailsScreen
  // creates and owns its own EstimateDetailBloc internally, so no
  // BlocProvider wiring is needed at the call site.
  void _openEstimateDetail(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SalesmanEstimateDetailsScreen(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final today = DateFormat('dd MMM yyyy, EEEE').format(DateTime.now());
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardHomeBloc, DashboardHomeState>(
        builder: (context, state) {
          // Full-screen loader only on the very first load.
          if (state.status == DashboardHomeStatus.initial ||
              state.status == DashboardHomeStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Full-screen error only when we have nothing to show yet.
          if (state.status == DashboardHomeStatus.failure && state.recentEstimates.isEmpty) {
            return _ErrorState(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () => context.read<DashboardHomeBloc>().add(const DashboardHomeRequested()),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<DashboardHomeBloc>().add(const DashboardHomeRefreshed());
              // Wait for the in-flight refresh to settle so the
              // RefreshIndicator spinner doesn't stop prematurely.
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
                if (state.status == DashboardHomeStatus.failure)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: Responsive.h(80),
                        left: Responsive.w(20),
                        right: Responsive.w(20),
                      ),
                      child: _InlineErrorBanner(
                        message: state.errorMessage ?? 'Failed to refresh dashboard.',
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: Responsive.h(70)),
                      _SectionTitle(title: 'Quick Actions'),
                      SizedBox(height: Responsive.h(14)),
                      _QuickActionsRow(
                        onCreateEstimate: () => _openCreateEstimate(context),
                        onMyEstimates: () => _openMyEstimates(context),
                        onApprovedBills: () => _openApprovedBills(context),
                        onQuotationBills: () => _openQuotationBills(context),
                        onIncentives: () => _openIncentives(context, state),
                      ),
                      SizedBox(height: Responsive.h(28)),
                      _SectionTitle(title: 'Sales Overview'),
                      SizedBox(height: Responsive.h(14)),
                      _CardWrapper(
                        child: DashboardMonthlySalesChart(data: state.monthlySales),
                      ),
                      SizedBox(height: Responsive.h(28)),
                      _SectionTitle(
                        title: 'Recent Estimates',
                        actionLabel: 'View All',
                        onAction: () => _openMyEstimates(context),
                      ),
                      SizedBox(height: Responsive.h(12)),
                      if (state.recentEstimates.isEmpty)
                        _EmptyState()
                      else
                        _CardWrapper(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (int i = 0; i < state.recentEstimates.length; i++) ...[
                                DashboardRecentEstimateTile(
                                  estimate: state.recentEstimates[i],
                                  onTap: () => _openEstimateDetail(
                                    context,
                                    state.recentEstimates[i].id,
                                  ),
                                ),
                                if (i != state.recentEstimates.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: Responsive.w(16),
                                    endIndent: Responsive.w(16),
                                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                                  ),
                              ],
                            ],
                          ),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(20),
            Responsive.w(20),
            Responsive.h(46),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: Responsive.sp(12),
                            ),
                          ),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(17)),
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
                  ],
                ),
                SizedBox(height: Responsive.h(14)),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white.withValues(alpha: 0.85)),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      dateLabel,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: Responsive.sp(12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Floating stat card strip
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(60),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16), horizontal: Responsive.w(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    value: '$totalEstimates',
                    label: 'Total',
                    color: AppColors.primary,
                    icon: Icons.description_rounded,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$quotations',
                    label: 'Quotations',
                    color: const Color(0xFF16A34A), // emerald
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$pending',
                    label: 'Pending',
                    color: const Color(0xFFF59E0B), // amber
                    icon: Icons.hourglass_bottom_rounded,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$dispatchBills',
                    label: 'Dispatch',
                    color: const Color(0xFF7C3AED), // violet
                    icon: Icons.local_shipping_rounded,
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
    height: 30,
    color: AppColors.textSecondary.withValues(alpha: 0.12),
  );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        SizedBox(height: Responsive.h(6)),
        Text(
          value,
          style: AppTextStyles.bodyBold(color: AppColors.black).copyWith(fontSize: Responsive.sp(16)),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(10.5)),
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
        Text(
          title,
          style: AppTextStyles.bodyBold(color: AppColors.black).copyWith(fontSize: Responsive.sp(16)),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(color: AppColors.primary, fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onCreateEstimate,
    required this.onMyEstimates,
    required this.onApprovedBills,
    required this.onQuotationBills,
    required this.onIncentives,
  });

  final VoidCallback onCreateEstimate;
  final VoidCallback onMyEstimates;
  final VoidCallback onApprovedBills;
  final VoidCallback onQuotationBills;
  final VoidCallback onIncentives;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionData>[
      _QuickActionData(
        icon: Icons.note_add_rounded,
        label: 'New\nEstimate',
        color: AppColors.primary,
        onTap: onCreateEstimate,
      ),
      _QuickActionData(
        icon: Icons.folder_copy_rounded,
        label: 'My\nEstimates',
        color: const Color(0xFF0EA5E9), // blue
        onTap: onMyEstimates,
      ),
      _QuickActionData(
        icon: Icons.local_shipping_rounded,
        label: 'Approved\nBills',
        color: const Color(0xFF16A34A), // green
        onTap: onApprovedBills,
      ),
      _QuickActionData(
        icon: Icons.receipt_long_rounded,
        label: 'Quotation\nBills',
        color: const Color(0xFFF59E0B), // amber
        onTap: onQuotationBills,
      ),
      _QuickActionData(
        icon: Icons.currency_rupee_rounded,
        label: 'Incentive',
        color: const Color(0xFF7C3AED), // purple
        onTap: onIncentives,
      ),
    ];

    // A little extra height as headroom so text scaling / smaller devices
    // don't push the content past the card bounds.
    return SizedBox(
      height: Responsive.h(100),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(12)),
        itemBuilder: (context, i) => SizedBox(
          width: Responsive.w(84),
          child: _QuickActionCard(
            icon: actions[i].icon,
            label: actions[i].label,
            color: actions[i].color,
            onTap: actions[i].onTap,
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(10), horizontal: Responsive.w(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(height: Responsive.h(5)),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(color: AppColors.black)
                      .copyWith(fontSize: Responsive.sp(10.5), height: 1.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------- EMPTY STATE ----------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(24)),
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            SizedBox(height: Responsive.h(10)),
            Text(
              'No recent estimates yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ERROR STATES ----------------

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
            Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: Responsive.h(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
            SizedBox(height: Responsive.h(16)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
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
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(10)),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}