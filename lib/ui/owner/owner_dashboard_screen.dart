
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

import 'package:tileshop/bloc/salemanbloc/salesmandashboard_event.dart';
import 'package:tileshop/bloc/salemanbloc/salesman_dashboardstate.dart';
import 'package:tileshop/models/salesmanmodels/salesman_dashboardmodel.dart';
import 'package:tileshop/bloc/salemanbloc/salesman_dashboardbloc.dart';

import '../salesman/estimates/cubit/estimates_cubit.dart';
import 'cubit/owner_cubit.dart';
import '../../widgets/monthlysale.dart';
import '../../widgets/owner_widgets.dart'; // StatusBadge
import 'addfieldstaffscreen.dart';
import 'owner_designationlist.dart';
import 'owner_driverpage.dart';
import 'owner_estimates_screen.dart';
import 'ownercreateesimatescreen.dart';
import 'ownerestuimatedetailscreen.dart';
import 'ownersalesmanreport.dart';
import 'ownersalesmanscreen.dart';
import 'quotations_screen.dart';
import 'incentive_management_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Drives the header stats / sales overview / recent estimates card.
        BlocProvider(
          create: (_) => DashboardHomeBloc()..add(const DashboardHomeRequested()),
        ),
        // Kept alive here because OwnerEstimatesScreen / OwnerQuotationsScreen
        // (pushed from Quick Actions below) still read it via context.read<OwnerCubit>().
        BlocProvider(create: (_) => OwnerCubit()),
      ],
      child: const _OwnerDashboardView(),
    );
  }
}

class _OwnerDashboardView extends StatelessWidget {
  const _OwnerDashboardView();

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardHomeBloc>().add(const DashboardHomeRefreshed());
              // Wait until the bloc leaves the refreshing state so the indicator
              // doesn't spin forever.
              await context.read<DashboardHomeBloc>().stream.firstWhere(
                    (s) => s.status != DashboardHomeStatus.refreshing,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _OwnerHeader(
                    greeting: greeting,
                    dateLabel: today,
                    userName: state.data.user.name,
                    totalEstimates: state.totalEstimates,
                    dispatched: state.dispatchBills,
                    quotations: state.quotations,
                    pending: state.pending,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: Responsive.h(70)),
                      const _SectionTitle(title: 'Quick Actions'),
                      SizedBox(height: Responsive.h(14)),
                      SizedBox(
                        height: Responsive.h(100),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 9,
                          separatorBuilder: (_, __) => SizedBox(width: Responsive.w(12)),
                          itemBuilder: (context, i) {
                            final actions = <_QuickActionData>[
                              _QuickActionData(
                                icon: Icons.note_add_rounded,
                                label: 'Create\nEstimate',
                                color: AppColors.primary,
                                onTap: () => _open(
                                  context,
                                  BlocProvider(
                                    create: (_) => EstimatesCubit(),
                                    child: const OwnerCreateEstimateScreen(),
                                  ),
                                ),
                              ),
                              _QuickActionData(
                                icon: Icons.receipt_long_rounded,
                                label: 'Estimates',
                                color: const Color(0xFF0EA5E9),
                                onTap: () => _open(
                                  context,
                                  BlocProvider.value(
                                    value: context.read<OwnerCubit>(),
                                    child: const OwnerEstimatesScreen(),
                                  ),
                                ),
                              ),
                              _QuickActionData(
                                icon: Icons.request_quote_outlined,
                                label: 'Quotations',
                                color: const Color(0xFFF59E0B),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<OwnerCubit>(),
                                      child: const OwnerQuotationsScreen(),
                                    ),
                                  ),
                                ),
                              ),
                              _QuickActionData(
                                icon: Icons.bar_chart_rounded,
                                label: 'Reports',
                                color: const Color(0xFF16A34A),
                                onTap: () => _open(context, const ReportsScreen()),
                              ),
                              _QuickActionData(
                                icon: Icons.inventory_2_outlined,
                                label: 'Product &Incentive\nSetup',
                                color: const Color(0xFF7C3AED),
                                onTap: () => _open(context, const IncentiveManagementScreen()),
                              ),
                              _QuickActionData(
                                icon: Icons.badge_outlined,
                                label: 'Designations',
                                color: const Color(0xFF0EA5E9),
                                onTap: () => _open(context, const DesignationListPage()),
                              ),
                              _QuickActionData(
                                icon: Icons.groups_2_outlined,
                                label: 'Salesmen',
                                color: const Color(0xFFEC4899),
                                onTap: () => _open(context, const OwnerSalesmenScreen()),
                              ),
                              _QuickActionData(
                                icon: Icons.local_shipping_rounded,
                                label: 'Driver',
                                color: const Color(0xFF06B6D4),
                                onTap: () => _open(context, const OwnerDriverScreen()),
                              ),
                              _QuickActionData(
                                icon: Icons.assignment_ind_rounded,
                                label: 'Field Staff',
                                color: const Color(0xFF0B4718),
                                onTap: () => _open(context, const OwnerAddFieldStaffScreen()),
                              ),
                            ];
                            final a = actions[i];
                            return SizedBox(
                              width: Responsive.w(84),
                              child: _QuickActionCard(
                                icon: a.icon,
                                label: a.label,
                                color: a.color,
                                onTap: a.onTap,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: Responsive.h(28)),
                      const _SectionTitle(title: 'Sales Overview'),
                      SizedBox(height: Responsive.h(14)),
                      _CardWrapper(
                        child: state.status == DashboardHomeStatus.loading
                            ? const _InlineLoader()
                            : MonthlySalesSection(
                          monthlySales: state.monthlySales
                              .map(
                                (m) => MonthlySales(
                              monthLabel: m.month,
                              amount: m.total.toDouble(),
                            ),
                          )
                              .toList(),
                          currency: currency,
                        ),
                      ),
                      SizedBox(height: Responsive.h(28)),
                      _SectionTitle(
                        title: 'Recent Estimates',
                        actionLabel: 'View All',
                        onAction: () => _open(
                          context,
                          BlocProvider.value(
                            value: context.read<OwnerCubit>(),
                            child: const OwnerEstimatesScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(14)),
                      if (state.status == DashboardHomeStatus.loading)
                        const _InlineLoader()
                      else if (state.status == DashboardHomeStatus.failure)
                        _ErrorState(
                          message: state.errorMessage ?? 'Failed to load dashboard.',
                          onRetry: () => context
                              .read<DashboardHomeBloc>()
                              .add(const DashboardHomeRequested()),
                        )
                      else if (state.recentEstimates.isEmpty)
                          const _EmptyState()
                        else
                          Column(
                            children: [
                              for (int i = 0; i < state.recentEstimates.length; i++) ...[
                                _RecentEstimateCard(
                                  estimate: state.recentEstimates[i],
                                  onTap: () => _open(
                                    context,
                                    OwnerEstimateDetailsScreen(
                                      initialStatus: state.recentEstimates[i].statusLabel,
                                    ),
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
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
            ),
            borderRadius: const BorderRadius.only(
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
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: Responsive.sp(12),
                            ),
                          ),
                          Text(
                            userName.isNotEmpty ? userName : 'Owner Dashboard',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(color: Colors.white)
                                .copyWith(fontSize: Responsive.sp(17)),
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
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white.withOpacity(0.85)),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      dateLabel,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: Responsive.sp(12)),
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
          bottom: -Responsive.h(60),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16), horizontal: Responsive.w(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
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
                    value: '$dispatched',
                    label: 'Dispatched',
                    color: const Color(0xFF0EA5E9),
                    icon: Icons.local_shipping_rounded,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$quotations',
                    label: 'Quotations',
                    color: const Color(0xFFF59E0B),
                    icon: Icons.request_quote_rounded,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    value: '$pending',
                    label: 'Pending',
                    color: const Color(0xFFEF4444),
                    icon: Icons.hourglass_bottom_rounded,
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
    color: AppColors.textSecondary.withOpacity(0.12),
  );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
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
            color: color.withOpacity(0.12),
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

// ---------------- QUICK ACTIONS ----------------

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
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(height: Responsive.h(5)),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 3,
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------- LOADING / EMPTY / ERROR STATES ----------------

class _InlineLoader extends StatelessWidget {
  const _InlineLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(24)),
      child: const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(24)),
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 40, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(10)),
            Text(
              'No estimates yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
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
        padding: EdgeInsets.symmetric(vertical: Responsive.h(20)),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 36, color: AppColors.textSecondary.withOpacity(0.5)),
            SizedBox(height: Responsive.h(10)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
            ),
            SizedBox(height: Responsive.h(12)),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- RECENT ESTIMATE CARD (bound to real API model) ----------------

class _RecentEstimateCard extends StatelessWidget {
  const _RecentEstimateCard({
    required this.estimate,
    required this.onTap,
  });

  final DashboardHomeRecentEstimate estimate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    estimate.customerName,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: estimate.statusLabel),
              ],
            ),
            SizedBox(height: Responsive.h(4)),
            Text('Estimate No: ${estimate.estimateNumber}', style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(estimate.dateFormatted, style: AppTextStyles.caption()),
                Text(
                  estimate.grandTotalFormatted,
                  style: AppTextStyles.bodyBold(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}