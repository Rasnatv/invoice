
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../auth/login_screen.dart';
import 'despatchrepository.dart';
import 'driverdespatchbillmodel.dart';
import 'driverdetailscreen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({
    super.key,
    this.driverName = 'Rajesh',
    this.onLogout,
    this.onChangePassword,
  });

  final String driverName;
  final VoidCallback? onLogout;
  final Future<void> Function(String currentPassword, String newPassword)? onChangePassword;

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}
class _DriverDashboardScreenState extends State<DriverDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Bills despatched to this driver_features specifically.
  /// TODO(backend): filter server-side once despatch sheets carry a real
  /// driver_features ID instead of a plain name match.
  List<DriverDespatchedBillModel> _myBills(List<DriverDespatchedBillModel> all) =>
      all.where((b) => b.driverName == widget.driverName).toList();

  List<DriverDespatchedBillModel> _filtered(List<DriverDespatchedBillModel> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.trim().toLowerCase();
    return source
        .where((b) =>
    b.contractorName.toLowerCase().contains(q) ||
        b.dsNumber.toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q))
        .toList();
  }

  void _markDelivered(DriverDespatchedBillModel bill) {
    DespatchRepository.instance.markDelivered(bill.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${bill.contractorName} marked as delivered')),
          ],
        ),
      ),
    );
  }

  void _openDetail(DriverDespatchedBillModel bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverBillDetailScreen(
          billId: bill.id,
          onDelivered: () => _markDelivered(bill),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      // TODO(auth): clear session/token here once real auth exists.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  /// Opens the account sheet (tap on avatar / overflow icon) with
  /// "Change Password" and "Logout" actions.
  void _openAccountSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AccountSheet(
        driverName: widget.driverName,
        onChangePassword: () {
          Navigator.of(ctx).pop();
          _openChangePasswordDialog();
        },
        onLogout: () {
          Navigator.of(ctx).pop();
          _confirmLogout();
        },
      ),
    );
  }

  Future<void> _openChangePasswordDialog() async {
    await showDialog(
      context: context,
      builder: (_) => _ChangePasswordDialog(
        onSubmit: (current, next) async {
          if (widget.onChangePassword != null) {
            await widget.onChangePassword!(current, next);
          } else {
            // TODO(auth): replace with a real API call once auth exists.
            await Future.delayed(const Duration(milliseconds: 600));
          }
        },
      ),
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
      body: AnimatedBuilder(
        animation: DespatchRepository.instance,
        builder: (context, _) {
          final myBills = _myBills(DespatchRepository.instance.bills);
          final pending = myBills.where((b) => !b.isDelivered).toList();
          final delivered = myBills.where((b) => b.isDelivered).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => setState(() {}),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _DriverHeader(
                    greeting: greeting,
                    name: widget.driverName,
                    dateLabel: today,
                    total: myBills.length,
                    pending: pending.length,
                    delivered: delivered.length,
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
                      SizedBox(height: Responsive.h(16)),
                      _DriverTabBar(
                        controller: _tabController,
                        pendingCount: pending.length,
                        deliveredCount: delivered.length,
                        totalCount: myBills.length,
                      ),
                      SizedBox(height: Responsive.h(14)),
                    ]),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _BillList(
                        bills: _filtered(pending),
                        emptyIcon: Icons.inventory_2_outlined,
                        emptyLabel: 'No pending deliveries',
                        emptySubLabel: 'All caught up! New despatches will appear here.',
                        onTapBill: _openDetail,
                        onDeliverTap: _markDelivered,
                      ),
                      _BillList(
                        bills: _filtered(delivered),
                        emptyIcon: Icons.local_shipping_outlined,
                        emptyLabel: 'No delivered bills yet',
                        emptySubLabel: 'Completed deliveries will show up here.',
                        onTapBill: _openDetail,
                        onDeliverTap: null,
                      ),
                      _BillList(
                        bills: _filtered(myBills),
                        emptyIcon: Icons.receipt_long_outlined,
                        emptyLabel: 'No despatch sheets yet',
                        emptySubLabel: 'Bills assigned to you will be listed here.',
                        onTapBill: _openDetail,
                        onDeliverTap: _markDelivered,
                      ),
                    ],
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

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({
    required this.greeting,
    required this.name,
    required this.dateLabel,
    required this.total,
    required this.pending,
    required this.delivered,
    required this.onAccountTap,
  });

  final String greeting;
  final String name;
  final String dateLabel;
  final int total;
  final int pending;
  final int delivered;
  final VoidCallback onAccountTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

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
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.86)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
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
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: Responsive.sp(16),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
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
                              color: Colors.white.withOpacity(0.78),
                              fontSize: Responsive.sp(11.5),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(color: Colors.white)
                                .copyWith(fontSize: Responsive.sp(18), letterSpacing: 0.2),
                          ),
                          SizedBox(height: Responsive.h(4)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(8),
                              vertical: Responsive.h(2),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DRIVER',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: Responsive.sp(9.5),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white.withOpacity(0.16),
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
                SizedBox(height: Responsive.h(16)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(6)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12.5, color: Colors.white.withOpacity(0.9)),
                      SizedBox(width: Responsive.w(6)),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
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
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
    color: AppColors.textSecondary.withOpacity(0.12),
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
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
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

/// Bottom sheet shown when the avatar / overflow icon in the header is
/// tapped. Houses account-level actions: change password and logout.
class _AccountSheet extends StatelessWidget {
  const _AccountSheet({
    required this.driverName,
    required this.onChangePassword,
    required this.onLogout,
  });

  final String driverName;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  String get _initials {
    final parts = driverName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

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
              color: Colors.black.withOpacity(0.12),
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
                color: AppColors.textSecondary.withOpacity(0.2),
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
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials,
                      style: AppTextStyles.bodyBold(color: AppColors.primary)
                          .copyWith(fontSize: Responsive.sp(15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14.5)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Driver account',
                          style: TextStyle(
                            color: AppColors.textSecondary,
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
                  color: iconColor.withOpacity(0.1),
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
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- CHANGE PASSWORD DIALOG ----------------

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.onSubmit});

  /// Called with (currentPassword, newPassword) once the form validates.
  final Future<void> Function(String current, String next) onSubmit;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.info,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Password updated successfully')),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Could not update password. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.lock_outline_rounded, size: 19, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Change Password',
                      style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PasswordField(
                label: 'Current Password',
                controller: _currentCtrl,
                obscure: _obscureCurrent,
                onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter your current password' : null,
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: 'New Password',
                controller: _newCtrl,
                obscure: _obscureNew,
                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a new password';
                  if (v.length < 6) return 'Must be at least 6 characters';
                  if (v == _currentCtrl.text) return 'Must differ from current password';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: 'Confirm New Password',
                controller: _confirmCtrl,
                obscure: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirm your new password';
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade600, fontSize: Responsive.sp(12), fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _submitting ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Center(
                            child: _submitting
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                                : Text(
                              'Update Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.sp(13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(fontSize: Responsive.sp(13.5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: Responsive.sp(12.5), color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 19),
          onPressed: onToggleObscure,
        ),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(fontSize: Responsive.sp(11)),
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
            color: Colors.black.withOpacity(0.04),
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

// ---------------- TAB BAR ----------------

class _DriverTabBar extends StatelessWidget {
  const _DriverTabBar({
    required this.controller,
    required this.pendingCount,
    required this.deliveredCount,
    required this.totalCount,
  });

  final TabController controller;
  final int pendingCount;
  final int deliveredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: Responsive.sp(12.5), fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Pending ($pendingCount)'),
          Tab(text: 'Delivered ($deliveredCount)'),
          Tab(text: 'All ($totalCount)'),
        ],
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
    required this.onDeliverTap,
  });

  final List<DriverDespatchedBillModel> bills;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubLabel;
  final ValueChanged<DriverDespatchedBillModel> onTapBill;
  final ValueChanged<DriverDespatchedBillModel>? onDeliverTap;

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
                  color: AppColors.textSecondary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(emptyIcon, size: 32, color: AppColors.textSecondary.withOpacity(0.5)),
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
          onDeliverTap: onDeliverTap == null ? null : () => onDeliverTap!(bill),
        );
      },
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({required this.bill, required this.onTap, required this.onDeliverTap});
  final DriverDespatchedBillModel bill;
  final VoidCallback onTap;
  final VoidCallback? onDeliverTap;

  String get _initial => bill.contractorName.trim().isEmpty
      ? '?'
      : bill.contractorName.trim().substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final delivered = bill.isDelivered;
    final statusColor = delivered ? AppColors.info : AppColors.warning;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // status accent bar
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
                                color: AppColors.primary.withOpacity(0.1),
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
                                    bill.contractorName,
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
                            _StatusChip(delivered: delivered),
                          ],
                        ),
                        SizedBox(height: Responsive.h(10)),
                        Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.08)),
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
                            _MetaChip(icon: Icons.inventory_2_outlined, label: '${bill.itemCount} items'),
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
                            _DeliverButton(delivered: delivered, onTap: onDeliverTap),
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
  const _StatusChip({required this.delivered});
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    final color = delivered ? AppColors.info : AppColors.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(9), vertical: Responsive.h(4)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            delivered ? Icons.check_circle_rounded : Icons.access_time_filled_rounded,
            size: 11,
            color: color,
          ),
          SizedBox(width: Responsive.w(4)),
          Text(
            delivered ? 'Delivered' : 'Pending',
            style: TextStyle(color: color, fontSize: Responsive.sp(10.5), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Full-width "Mark Delivered" pill for pending bills. Renders as a static,
/// muted "Delivered" pill once the bill is complete.
class _DeliverButton extends StatelessWidget {
  const _DeliverButton({required this.delivered, required this.onTap});
  final bool delivered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (delivered) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(8)),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.info, size: 15),
            SizedBox(width: Responsive.w(5)),
            Text(
              'Done',
              style: TextStyle(color: AppColors.info, fontSize: Responsive.sp(11.5), fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(12), vertical: Responsive.h(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 15),
              SizedBox(width: Responsive.w(5)),
              Text(
                'Deliver',
                style: TextStyle(color: Colors.white, fontSize: Responsive.sp(11.5), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}