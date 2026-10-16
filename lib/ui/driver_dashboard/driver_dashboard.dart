import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../Apiprovider/driverdespatchprovider.dart';
import '../../bloc/driverbloc/driverdashboard/driverdashboard_bloc.dart';
import '../../bloc/driverbloc/driverdashboard/driverdashboard_event.dart';
import '../../bloc/driverbloc/driverdashboard/driverdashboard_state.dart';
import '../../core/utils/logout_helper.dart';
import '../../models/drivermodels/driverdashboardmodel.dart';

import '../../widgets/driverdashbaordshimmer.dart';
import 'driverchangepswdscreen.dart';
import 'driverdetailscreen.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({
    super.key,
    this.onLogout,
  });

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      DriverDashboardBloc(DriverDespatchProvider())..add(const FetchDriverDashboard()),
      child: _DriverDashboardView(onLogout: onLogout),
    );
  }
}

class _DriverDashboardView extends StatefulWidget {
  const _DriverDashboardView({this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<_DriverDashboardView> createState() => _DriverDashboardViewState();
}

class _DriverDashboardViewState extends State<_DriverDashboardView> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DriverDespatchListItem> _filtered(List<DriverDespatchListItem> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.trim().toLowerCase();
    return source
        .where((b) =>
    b.partyName.toLowerCase().contains(q) ||
        b.dsNumber.toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q))
        .toList();
  }

  void _openDetail(DriverDespatchListItem bill) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => DriverBillDetailScreen(billId: bill.id),
      ),
    )
        .then((_) {
      // Refresh counts/status once the user returns from the detail
      // screen, in case they marked it in-transit or delivered there.
      if (mounted) {
        context.read<DriverDashboardBloc>().add(const RefreshDriverDashboard());
      }
    });
  }

  void _openAccountSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AccountSheet(
        onChangePassword: () {
          Navigator.of(ctx).pop();
          _openChangePasswordScreen();
        },
        onLogout: () {
          Navigator.of(ctx).pop();
          if (widget.onLogout != null) {
            widget.onLogout!();
          } else {
            logout(context);
          }
        },
      ),
    );
  }

  void _openChangePasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DriverChangePasswordScreen()),
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
        body: BlocBuilder<DriverDashboardBloc, DriverDashboardState>(
          builder: (context, state) {
            // First load: full-screen shimmer skeleton.
            if (state.status == DriverDashboardStatus.initial ||
                (state.status == DriverDashboardStatus.loading && state.dashboard == null)) {
              return const DriverDashboardShimmer();
            }

            if (state.status == DriverDashboardStatus.failure && state.dashboard == null) {
              return _ErrorView(
                message: state.errorMessage ?? 'Failed to load dashboard',
                onRetry: () =>
                    context.read<DriverDashboardBloc>().add(const FetchDriverDashboard()),
              );
            }

            final dashboard = state.dashboard!;
            final all = _filtered(dashboard.list);
            // Pull-to-refresh in flight, with cached data already on screen.
            final isRefreshing = state.status == DriverDashboardStatus.loading;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<DriverDashboardBloc>().add(const RefreshDriverDashboard());
                await context.read<DriverDashboardBloc>().stream.firstWhere((s) =>
                s.status == DriverDashboardStatus.success ||
                    s.status == DriverDashboardStatus.failure);
              },
              child: isRefreshing
                  ? const DriverDashboardRefreshShimmer()
                  : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _DriverHeader(
                      greeting: greeting,
                      dateLabel: today,
                      total: dashboard.total,
                      pending: dashboard.pending + dashboard.inTransit,
                      delivered: dashboard.delivered,
                      onAccountTap: _openAccountSheet,
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
                      ]),
                    ),
                  ),
                  // The list lives in the SAME scroll view as the
                  // header, so scrolling up always brings it back.
                  _BillSliver(
                    bills: all,
                    emptyIcon: Icons.receipt_long_outlined,
                    emptyLabel: 'No despatch sheets yet',
                    emptySubLabel: 'Bills assigned to you will be listed here.',
                    onTapBill: _openDetail,
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

// ---------------- HEADER ----------------

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({
    required this.greeting,
    required this.dateLabel,
    required this.total,
    required this.pending,
    required this.delivered,
    required this.onAccountTap,
  });

  final String greeting;
  final String dateLabel;
  final int total;
  final int pending;
  final int delivered;
  final VoidCallback onAccountTap;

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTextStyles.caption(
                              color: Colors.white.withValues(alpha: 0.8))
                              .copyWith(fontSize: Responsive.sp(10.5)),
                        ),
                        SizedBox(height: Responsive.h(1)),
                        Text(
                          'Driver Dashboard',
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
                          size: 12, color: Colors.white.withValues(alpha: 0.8)),
                      SizedBox(height: Responsive.h(3)),
                      Text(
                        dateLabel,
                        style: AppTextStyles.captionnew(
                            color: Colors.white.withValues(alpha: 0.8))
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
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.receipt_long_rounded,
                    value: '$total',
                    label: 'Total',
                    color: AppColors.primary,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.access_time_filled_rounded,
                    value: '$pending',
                    label: 'Pending',
                    color: AppColors.warning,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.check_circle_rounded,
                    value: '$delivered',
                    label: 'Delivered',
                    color: AppColors.info,
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
    color: AppColors.textSecondary.withValues(alpha: 0.14),
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

// ---------------- ACCOUNT SHEET ----------------

class _AccountSheet extends StatelessWidget {
  const _AccountSheet({
    required this.onChangePassword,
    required this.onLogout,
  });

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
                color: AppColors.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.local_shipping_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Driver account',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(13)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                  color: iconColor.withValues(alpha: 0.1),
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
                  size: 18, color: AppColors.textSecondary.withValues(alpha: 0.5)),
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
        hintText: 'Search by customer or DS number',
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

// ---------------- BILL LIST (sliver) ----------------

class _BillSliver extends StatelessWidget {
  const _BillSliver({
    required this.bills,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.emptySubLabel,
    required this.onTapBill,
  });

  final List<DriverDespatchListItem> bills;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubLabel;
  final ValueChanged<DriverDespatchListItem> onTapBill;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(20),
          0,
          Responsive.w(20),
          Responsive.h(24),
        ),
        sliver: SliverToBoxAdapter(
          child: _CardWrapper(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(18)),
              child: Column(
                children: [
                  Icon(emptyIcon,
                      size: 32, color: AppColors.textSecondary.withValues(alpha: 0.4)),
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

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(20),
        0,
        Responsive.w(20),
        Responsive.h(24),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index.isOdd) return SizedBox(height: Responsive.h(10));
            final bill = bills[index ~/ 2];
            return _BillTile(bill: bill, onTap: () => onTapBill(bill));
          },
          childCount: bills.length * 2 - 1,
        ),
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({required this.bill, required this.onTap});
  final DriverDespatchListItem bill;
  final VoidCallback onTap;

  String get _initial => bill.partyName.trim().isEmpty
      ? '?'
      : bill.partyName.trim().substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final captionStyle = AppTextStyles.caption().copyWith(fontSize: Responsive.sp(10.5));

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initial,
                      style: AppTextStyles.bodyBold(color: AppColors.primary)
                          .copyWith(fontSize: Responsive.sp(13)),
                    ),
                  ),
                  SizedBox(width: Responsive.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.partyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(12.5)),
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Text(bill.dsNumber, style: captionStyle),
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  _StatusChip(statusLabel: bill.statusLabel),
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
                      bill.address,
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
                  _MetaChip(icon: Icons.inventory_2_outlined, label: '${bill.itemsCount} items'),
                  SizedBox(width: Responsive.w(6)),
                  Expanded(
                    child: _MetaChip(icon: Icons.person_outline, label: bill.salesmanName),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(10)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      currency.format(bill.grandTotal),
                      style: AppTextStyles.bodyBold(color: AppColors.primary)
                          .copyWith(fontSize: Responsive.sp(13.5)),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(4)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          SizedBox(width: Responsive.w(4)),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.sp(10),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statusLabel});
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final lower = statusLabel.toLowerCase();
    final Color color = lower == 'delivered'
        ? AppColors.info
        : lower == 'in transit'
        ? AppColors.primary
        : AppColors.warning;
    final IconData icon = lower == 'delivered'
        ? Icons.check_circle_rounded
        : lower == 'in transit'
        ? Icons.local_shipping_rounded
        : Icons.access_time_filled_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: Responsive.w(4)),
          Text(
            statusLabel,
            style: TextStyle(
              color: color,
              fontSize: Responsive.sp(10),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- ERROR VIEW ----------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
        child: _CardWrapper(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 30, color: AppColors.textSecondary.withValues(alpha: 0.5)),
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
        ),
      ),
    );
  }
}