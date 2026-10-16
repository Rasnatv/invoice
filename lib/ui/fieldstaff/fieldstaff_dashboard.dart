import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_bloc.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_event.dart';
import '../../bloc/fieldstaffbloc/sitevist/sitevisit_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../core/utils/logout_helper.dart';
import '../../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/fieldstaffshimmerwidget.dart';
import 'addsite.dart';
import 'fieldstaff_incentivelistscreen.dart';
import 'fieldstaffchangepasswordscreen.dart';
import 'visitdetailscreen.dart';

class FieldStaffDashboardScreen extends StatefulWidget {
  const FieldStaffDashboardScreen({super.key});

  @override
  State<FieldStaffDashboardScreen> createState() => _FieldStaffDashboardScreenState();
}

class _FieldStaffDashboardScreenState extends State<FieldStaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();

  // One CustomScrollView drives page scroll AND "All" tab pagination.
  final _scrollCtrl = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    context.read<SiteVisitBloc>().add(const FetchMySiteVisits());
    context.read<ProfileBloc>().add(const LoadProfile());

    _scrollCtrl.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_tabController.index != 1) return;

    final nearBottom =
        _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200;
    if (!nearBottom) return;

    final state = context.read<SiteVisitBloc>().state;
    if (state.isLoadingMore || !state.hasMoreAll || state.isListLoading) return;

    context.read<SiteVisitBloc>().add(
      FetchMySiteVisits(page: state.currentPage + 1, loadMore: true),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<SiteVisitListItemModel> _filtered(List<SiteVisitListItemModel> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.trim().toLowerCase();
    return source
        .where((v) =>
    v.customerName.toLowerCase().contains(q) ||
        v.siteAddress.toLowerCase().contains(q) ||
        v.customerPhone.toLowerCase().contains(q))
        .toList();
  }

  void _openDetail(SiteVisitListItemModel visit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SiteVisitBloc>(),
          child: FieldStaffVisitDetailScreen(visitId: visit.id),
        ),
      ),
    );
  }

  void _openAddVisit() {
    final staffName = context.read<ProfileBloc>().state.profile?.name ?? 'Field Staff';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SiteVisitBloc>(),
          child: AddFieldVisitScreen(staffName: staffName),
        ),
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      AppSnackbar.error('Could not start a call on this device');
    }
  }

  void _openAccountSheet() {
    final staffName = context.read<ProfileBloc>().state.profile?.name ?? 'Field Staff';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AccountSheet(
        staffName: staffName,
        onChangePassword: () {
          Navigator.of(ctx).pop();
          _openChangePassword();
        },
        onLogout: () {
          Navigator.of(ctx).pop();
          logout(context);
        },
      ),
    );
  }

  void _openIncentiveList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const IncentiveListScreen()),
    );
  }

  void _openChangePassword() {
    final profileBloc = context.read<ProfileBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileBloc,
          child: const FieldStaffChangePasswordScreen(),
        ),
      ),
    );
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddVisit,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 20),
          label: Text(
            'Add Visit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.sp(12.5),
            ),
          ),
        ),
        body: BlocBuilder<SiteVisitBloc, SiteVisitState>(
          builder: (context, state) {
            final todayVisits = state.todayVisits;
            final allVisits = state.allVisits;
            final isInitialLoading = state.isListLoading && state.totalVisitsCount == 0;
            final isRefreshing = state.isListLoading && state.totalVisitsCount > 0;

            if (isInitialLoading || isRefreshing) {
              return const FieldStaffFullShimmer();
            }

            final isTodayTab = _tabController.index == 0;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async =>
                  context.read<SiteVisitBloc>().add(const FetchMySiteVisits()),
              child: CustomScrollView(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        final name = profileState.profile?.name;
                        return _FieldStaffHeader(
                          greeting: greeting,
                          name: profileState.isLoading
                              ? 'Loading...'
                              : (name == null || name.isEmpty ? 'Field Staff' : name),
                          dateLabel: today,
                          total: state.totalVisitsCount,
                          today: state.todayVisitsCount,
                          incentive: state.totalIncentive,
                          onAccountTap: _openAccountSheet,
                          onIncentiveTap: _openIncentiveList,
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: Responsive.h(14)),
                        _SearchField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        _FieldStaffTabBar(
                          controller: _tabController,
                          todayCount: state.todayVisitsCount,
                          totalCount: state.totalVisitsCount,
                        ),
                        SizedBox(height: Responsive.h(12)),
                        if (state.listError != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: Responsive.h(10)),
                            child: _ErrorState(
                              message: state.listError!,
                              onRetry: () =>
                                  context.read<SiteVisitBloc>().add(const FetchMySiteVisits()),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  if (isTodayTab)
                    _VisitSliver(
                      visits: _filtered(todayVisits),
                      emptyIcon: Icons.today_rounded,
                      emptyLabel: 'No visits logged today',
                      emptySubLabel: 'Tap "Add Visit" once you reach a party.',
                      onTapVisit: _openDetail,
                      onCallTap: _callNumber,
                    )
                  else
                    _VisitSliver(
                      visits: _filtered(allVisits),
                      emptyIcon: Icons.map_outlined,
                      emptyLabel: 'No visits logged yet',
                      emptySubLabel: 'Every party you visit will be listed here.',
                      onTapVisit: _openDetail,
                      onCallTap: _callNumber,
                      isLoadingMore: state.isLoadingMore,
                      showEndReached: !state.hasMoreAll &&
                          allVisits.isNotEmpty &&
                          _query.trim().isEmpty,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ---------------- ERROR STATE ----------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 30, color: AppColors.textSecondary.withOpacity(0.5)),
            SizedBox(height: Responsive.h(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle().copyWith(fontSize: Responsive.sp(12)),
            ),
            SizedBox(height: Responsive.h(8)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again',
                  style: AppTextStyles.link().copyWith(fontSize: Responsive.sp(12))),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- HEADER ----------------

class _FieldStaffHeader extends StatelessWidget {
  const _FieldStaffHeader({
    required this.greeting,
    required this.name,
    required this.dateLabel,
    required this.total,
    required this.today,
    required this.incentive,
    required this.onAccountTap,
    required this.onIncentiveTap,
  });

  final String greeting;
  final String name;
  final String dateLabel;
  final int total;
  final int today;
  final double incentive;
  final VoidCallback onAccountTap;
  final VoidCallback onIncentiveTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // The stats card sits INSIDE the Stack's bounds (bottom padding below)
    // so the Incentive stat stays tappable.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Responsive.h(46)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              Responsive.w(20),
              Responsive.h(14),
              Responsive.w(20),
              Responsive.h(48),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  InkWell(
                    onTap: onAccountTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.sp(13.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTextStyles.caption(color: Colors.white.withOpacity(0.8))
                              .copyWith(fontSize: Responsive.sp(10.5)),
                        ),
                        SizedBox(height: Responsive.h(1)),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold(color: Colors.white)
                              .copyWith(fontSize: Responsive.sp(15)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colors.white.withOpacity(0.8)),
                      SizedBox(height: Responsive.h(3)),
                      Text(
                        dateLabel,
                        style: AppTextStyles.captionnew(color: Colors.white.withOpacity(0.8))
                            .copyWith(fontSize: Responsive.sp(9.5)),
                      ),
                    ],
                  ),
                  SizedBox(width: Responsive.w(4)),
                  InkWell(
                    onTap: onAccountTap,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: Responsive.h(11), horizontal: Responsive.w(6)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.map_rounded,
                    value: '$total',
                    label: 'Total Visits',
                    color: AppColors.primary,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.today_rounded,
                    value: '$today',
                    label: 'Today',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _IncentiveStat(
                    value: currency.format(incentive),
                    onTap: onIncentiveTap,
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
    height: 28,
    color: AppColors.textSecondary.withOpacity(0.14),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(height: Responsive.h(4)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyBold(color: AppColors.black)
              .copyWith(fontSize: Responsive.sp(14)),
        ),
        SizedBox(height: Responsive.h(1)),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.captionnew(color: AppColors.textSecondary)
              .copyWith(fontSize: Responsive.sp(9.5)),
        ),
      ],
    );
  }
}

class _IncentiveStat extends StatelessWidget {
  const _IncentiveStat({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;

  static const _incentiveColor = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        children: [
          const Icon(Icons.currency_rupee_rounded, size: 16, color: _incentiveColor),
          SizedBox(height: Responsive.h(4)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold(color: AppColors.black)
                .copyWith(fontSize: Responsive.sp(14)),
          ),
          SizedBox(height: Responsive.h(1)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Incentive',
                style: AppTextStyles.captionnew(color: AppColors.textSecondary)
                    .copyWith(fontSize: Responsive.sp(9.5)),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 12, color: AppColors.textSecondary.withOpacity(0.7)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- ACCOUNT SHEET ----------------

class _AccountSheet extends StatelessWidget {
  const _AccountSheet({
    required this.staffName,
    required this.onChangePassword,
    required this.onLogout,
  });

  final String staffName;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            _AccountTile(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.primary,
              label: 'Change Password',
              onTap: onChangePassword,
            ),
            _AccountTile(
              icon: Icons.logout_rounded,
              iconColor: Colors.red,
              label: 'Logout',
              labelColor: Colors.red,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.textPrimary,
                  fontSize: Responsive.sp(12.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- SEARCH ----------------

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: Responsive.sp(12.5)),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search by party, address or phone',
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 19),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.close_rounded, size: 16),
          onPressed: () {
            controller.clear();
            onChanged('');
          },
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(11)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ---------------- TAB BAR ----------------

class _FieldStaffTabBar extends StatelessWidget {
  const _FieldStaffTabBar({
    required this.controller,
    required this.todayCount,
    required this.totalCount,
  });

  final TabController controller;
  final int todayCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(11),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.w700),
        unselectedLabelStyle:
        TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(height: Responsive.h(30), text: 'Today ($todayCount)'),
          Tab(height: Responsive.h(30), text: 'All ($totalCount)'),
        ],
      ),
    );
  }
}

// ---------------- VISIT LIST (sliver) ----------------

class _VisitSliver extends StatelessWidget {
  const _VisitSliver({
    required this.visits,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.emptySubLabel,
    required this.onTapVisit,
    required this.onCallTap,
    this.isLoadingMore = false,
    this.showEndReached = false,
  });

  final List<SiteVisitListItemModel> visits;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubLabel;
  final ValueChanged<SiteVisitListItemModel> onTapVisit;
  final ValueChanged<String> onCallTap;
  final bool isLoadingMore;
  final bool showEndReached;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(20),
          0,
          Responsive.w(20),
          Responsive.h(90),
        ),
        sliver: SliverToBoxAdapter(
          child: _CardWrapper(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(18)),
              child: Column(
                children: [
                  Icon(emptyIcon,
                      size: 32, color: AppColors.textSecondary.withOpacity(0.4)),
                  SizedBox(height: Responsive.h(8)),
                  Text(
                    emptyLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(12.5)),
                  ),
                  SizedBox(height: Responsive.h(3)),
                  Text(
                    emptySubLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle().copyWith(fontSize: Responsive.sp(11)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final showFooter = isLoadingMore || showEndReached;
    final itemCount = visits.length + (showFooter ? 1 : 0);

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(20),
        0,
        Responsive.w(20),
        Responsive.h(90),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index.isOdd) return SizedBox(height: Responsive.h(10));

            final i = index ~/ 2;

            if (i >= visits.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
                child: Center(
                  child: isLoadingMore
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                      : Text(
                    "You're all caught up",
                    style: AppTextStyles.captionnew(color: AppColors.textSecondary)
                        .copyWith(fontSize: Responsive.sp(10.5)),
                  ),
                ),
              );
            }

            final visit = visits[i];
            return _VisitTile(
              visit: visit,
              onTap: () => onTapVisit(visit),
              onCallTap: () => onCallTap(visit.customerPhone),
            );
          },
          childCount: itemCount * 2 - 1,
        ),
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({required this.visit, required this.onTap, required this.onCallTap});
  final SiteVisitListItemModel visit;
  final VoidCallback onTap;
  final VoidCallback onCallTap;

  String get _initial => visit.customerName.trim().isEmpty
      ? '?'
      : visit.customerName.trim().substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final parsedDate = DateTime.tryParse(visit.visitDate);
    final dateLabel = parsedDate != null
        ? DateFormat('dd MMM, hh:mm a').format(parsedDate)
        : visit.visitDate;
    final incentive = double.tryParse(visit.incentiveEarned) ?? 0;

    final captionStyle = AppTextStyles.caption().copyWith(fontSize: Responsive.sp(10.5));

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _thumbnail(),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(12.5)),
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Text(dateLabel, style: captionStyle),
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(
                    currency.format(incentive),
                    style: AppTextStyles.bodyBold(color: AppColors.primary)
                        .copyWith(fontSize: Responsive.sp(12.5)),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(8)),
              const Divider(height: 1, color: AppColors.border),
              SizedBox(height: Responsive.h(8)),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      visit.siteAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: captionStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(6)),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(4)),
                        Text(visit.customerPhone, style: captionStyle),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: onCallTap,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(9), vertical: Responsive.h(5)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.call_rounded, size: 12, color: AppColors.primary),
                            SizedBox(width: Responsive.w(4)),
                            Text(
                              'Call',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: Responsive.sp(10.5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final thumbUrl = visit.thumbnailUrl;
    if (thumbUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          thumbUrl,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: AppTextStyles.bodyBold(color: AppColors.primary)
            .copyWith(fontSize: Responsive.sp(13)),
      ),
    );
  }
}