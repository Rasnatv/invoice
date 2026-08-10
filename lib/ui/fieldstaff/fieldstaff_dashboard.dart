
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/sitevist/sitevisit_bloc.dart';
import '../../bloc/sitevist/sitevisit_event.dart';
import '../../bloc/sitevist/sitevisit_state.dart';
import '../../core/utils/logout_helper.dart';
import '../../core/validator/validationfile.dart';
import '../../models/fieldstaffmodels/fieldstaffsitevisitmodel.dart';
import '../../widgets/appsnackbar.dart';
import 'addsite.dart';
import 'visitdetailscreen.dart';

class FieldStaffDashboardScreen extends StatefulWidget {
  const FieldStaffDashboardScreen({
    super.key,
    this.staffName = 'Raju',
    this.onChangePassword,
  });

  final String staffName;

  final Future<void> Function(String currentPassword, String newPassword)? onChangePassword;

  @override
  State<FieldStaffDashboardScreen> createState() => _FieldStaffDashboardScreenState();
}

class _FieldStaffDashboardScreenState extends State<FieldStaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<SiteVisitBloc>().add(const FetchMySiteVisits());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SiteVisitBloc>(),
          child: AddFieldVisitScreen(staffName: widget.staffName),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AccountSheet(
        staffName: widget.staffName,
        onChangePassword: () {
          Navigator.of(ctx).pop();
          _openChangePasswordDialog();
        },
        onLogout: () {
          Navigator.of(ctx).pop();
          // Shared helper already confirms, clears the token, and
          // navigates back to LoginScreen — nothing else needed here.
          logout(context);
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

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddVisit,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add Visit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<SiteVisitBloc, SiteVisitState>(
        builder: (context, state) {
          final todayVisits = state.todayVisits;
          final allVisits = state.allVisits;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context.read<SiteVisitBloc>().add(const FetchMySiteVisits()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _FieldStaffHeader(
                    greeting: greeting,
                    name: widget.staffName,
                    dateLabel: today,
                    total: state.totalVisitsCount,
                    today: state.todayVisitsCount,
                    incentive: state.totalIncentive,
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
                      _FieldStaffTabBar(
                        controller: _tabController,
                        todayCount: state.todayVisitsCount,
                        totalCount: state.totalVisitsCount,
                      ),
                      SizedBox(height: Responsive.h(14)),
                      if (state.listError != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: Responsive.h(10)),
                          child: _ListErrorBanner(
                            message: state.listError!,
                            onRetry: () => context.read<SiteVisitBloc>().add(const FetchMySiteVisits()),
                          ),
                        ),
                    ]),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: state.isListLoading && state.totalVisitsCount == 0
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                    controller: _tabController,
                    children: [
                      _VisitList(
                        visits: _filtered(todayVisits),
                        emptyIcon: Icons.today_rounded,
                        emptyLabel: 'No visits logged today',
                        emptySubLabel: 'Tap "Add Visit" once you reach a party.',
                        onTapVisit: _openDetail,
                        onCallTap: _callNumber,
                      ),
                      _VisitList(
                        visits: _filtered(allVisits),
                        emptyIcon: Icons.map_outlined,
                        emptyLabel: 'No visits logged yet',
                        emptySubLabel: 'Every party you visit will be listed here.',
                        onTapVisit: _openDetail,
                        onCallTap: _callNumber,
                      ),
                    ],
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

class _ListErrorBanner extends StatelessWidget {
  const _ListErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade700, fontSize: Responsive.sp(12))),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}


class _FieldStaffHeader extends StatelessWidget {
  const _FieldStaffHeader({
    required this.greeting,
    required this.name,
    required this.dateLabel,
    required this.total,
    required this.today,
    required this.incentive,
    required this.onAccountTap,
  });

  final String greeting;
  final String name;
  final String dateLabel;
  final int total;
  final int today;
  final double incentive;
  final VoidCallback onAccountTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
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

                    ]),),
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
                    color: AppColors.warning,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.workspace_premium_rounded,
                    value: currency.format(incentive),
                    label: 'Incentive',
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
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyBold(color: color).copyWith(fontSize: Responsive.sp(15)),
        ),
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
    required this.staffName,
    required this.onChangePassword,
    required this.onLogout,
  });

  final String staffName;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  String get _initials {
    final parts = staffName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
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

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success('Password updated successfully');
    } catch (e) {
      AppSnackbar.error('Could not update password. Please try again.');
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
                validator: (v) => DValidator.validateRequired(v, message: 'Enter your current password'),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: 'New Password',
                controller: _newCtrl,
                obscure: _obscureNew,
                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  final base = DValidator.validatePassword(v);
                  if (base != null) return base;
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
          hintText: 'Search by party, address or phone',
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
          Tab(text: 'Today ($todayCount)'),
          Tab(text: 'All ($totalCount)'),
        ],
      ),
    );
  }
}

// ---------------- VISIT LIST ----------------

class _VisitList extends StatelessWidget {
  const _VisitList({
    required this.visits,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.emptySubLabel,
    required this.onTapVisit,
    required this.onCallTap,
  });

  final List<SiteVisitListItemModel> visits;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubLabel;
  final ValueChanged<SiteVisitListItemModel> onTapVisit;
  final ValueChanged<String> onCallTap;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
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
        Responsive.h(90),
      ),
      itemCount: visits.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(12)),
      itemBuilder: (context, i) {
        final visit = visits[i];
        return _VisitTile(
          visit: visit,
          onTap: () => onTapVisit(visit),
          onCallTap: () => onCallTap(visit.customerPhone),
        );
      },
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

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(Responsive.w(13)),
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
                          style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(14)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                            SizedBox(width: Responsive.w(4)),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.sp(11),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(9), vertical: Responsive.h(4)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currency.format(incentive),
                      style: TextStyle(color: AppColors.primary, fontSize: Responsive.sp(11.5), fontWeight: FontWeight.w700),
                    ),
                  ),
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
                      visit.siteAddress,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(8)),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 13, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(4)),
                        Text(
                          visit.customerPhone,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(12), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.info.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onCallTap,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.call_rounded, size: 13, color: AppColors.info),
                            SizedBox(width: Responsive.w(4)),
                            Text('Call', style: TextStyle(color: AppColors.info, fontSize: Responsive.sp(11), fontWeight: FontWeight.w700)),
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
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          thumbUrl,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(fontSize: Responsive.sp(15)),
      ),
    );
  }
}