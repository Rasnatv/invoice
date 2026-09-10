
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
      create: (_) => DriverDashboardBloc(DriverDespatchProvider())..add(const FetchDriverDashboard()),
      child: _DriverDashboardView(
        onLogout: onLogout,
      ),
    );
  }
}

class _DriverDashboardView extends StatefulWidget {
  const _DriverDashboardView({
    this.onLogout,
  });

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

  // Was a showDialog(_ChangePasswordDialog) before — now a full screen
  // that talks to ProfileBloc directly (same bloc/event/state used by the
  // Owner change-password flow), so there's no callback to wire up here.
  void _openChangePasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DriverChangePasswordScreen()),
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

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DriverDashboardBloc, DriverDashboardState>(
        builder: (context, state) {
          if (state.status == DriverDashboardStatus.initial ||
              (state.status == DriverDashboardStatus.loading && state.dashboard == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DriverDashboardStatus.failure && state.dashboard == null) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load dashboard',
              onRetry: () => context.read<DriverDashboardBloc>().add(const FetchDriverDashboard()),
            );
          }

          final dashboard = state.dashboard!;
          final all = _filtered(dashboard.list);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<DriverDashboardBloc>().add(const RefreshDriverDashboard());
              await context
                  .read<DriverDashboardBloc>()
                  .stream
                  .firstWhere((s) =>
              s.status == DriverDashboardStatus.success ||
                  s.status == DriverDashboardStatus.failure);
            },
            child: CustomScrollView(
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
                      SizedBox(height: Responsive.h(55)),
                      _SearchField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      SizedBox(height: Responsive.h(14)),
                    ]),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: _BillList(
                    bills: all,
                    emptyIcon: Icons.receipt_long_outlined,
                    emptyLabel: 'No despatch sheets yet',
                    emptySubLabel: 'Bills assigned to you will be listed here.',
                    onTapBill: _openDetail,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ));
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
        Container(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(20),
            Responsive.w(20),
            Responsive.h(52),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.86)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAccountTap,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.4),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: Responsive.w(22),
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
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: Responsive.sp(11.5),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: Responsive.h(6)),
    ]),),
                    Material(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAccountTap,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.more_vert_rounded, color: Colors.white, size: 19),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(6)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12.5, color: Colors.white.withValues(alpha: 0.9)),
                      SizedBox(width: Responsive.w(6)),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: Responsive.sp(11.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(50),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16), horizontal: Responsive.w(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
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
    height: 37,
    color: AppColors.textSecondary.withValues(alpha: 0.12),
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
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: color),
        ),
        SizedBox(height: Responsive.h(6)),
        Text(value, style: AppTextStyles.bodyBold(color: color).copyWith(fontSize: Responsive.sp(17))),
        SizedBox(height: Responsive.h(1)),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: Responsive.sp(10.5),
            fontWeight: FontWeight.w500,
          ),
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Driver account',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14.5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.textPrimary,
                  fontSize: Responsive.sp(13.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary.withValues(alpha: 0.5)),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: Responsive.sp(13.5)),
        decoration: InputDecoration(
          hintText: 'Search by customer or DS number',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(13)),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 21),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(13)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ---------------- BILL LIST ----------------

class _BillList extends StatelessWidget {
  const _BillList({
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
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(emptyIcon, size: 32, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              ),
              SizedBox(height: Responsive.h(14)),
              Text(
                emptyLabel,
                style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14)),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                emptySubLabel,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(20),
        Responsive.h(4),
        Responsive.w(20),
        Responsive.h(24),
      ),
      itemCount: bills.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
      itemBuilder: (context, i) {
        final bill = bills[i];
        return _BillTile(
          bill: bill,
          onTap: () => onTapBill(bill),
        );
      },
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
    final statusColor = bill.isDelivered
        ? AppColors.info
        : bill.isInTransit
        ? AppColors.primary
        : AppColors.warning;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(13)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
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
                                    style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: Responsive.h(2)),
                                  Text(
                                    bill.dsNumber,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: Responsive.sp(11.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StatusChip(statusLabel: bill.statusLabel),
                          ],
                        ),
                        SizedBox(height: Responsive.h(10)),
                        Divider(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.08)),
                        SizedBox(height: Responsive.h(10)),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: Responsive.w(4)),
                            Expanded(
                              child: Text(
                                bill.address,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        SizedBox(height: Responsive.h(12)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                currency.format(bill.grandTotal),
                                style: AppTextStyles.bodyBold(color: AppColors.primary)
                                    .copyWith(fontSize: Responsive.sp(16)),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          SizedBox(width: Responsive.w(4)),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.sp(10.5),
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
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(9), vertical: Responsive.h(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SizedBox(width: Responsive.w(4)),
          Text(
            statusLabel,
            style: TextStyle(color: color, fontSize: Responsive.sp(10.5), fontWeight: FontWeight.w700),
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
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
            SizedBox(height: Responsive.h(10)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body()),
            SizedBox(height: Responsive.h(14)),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}