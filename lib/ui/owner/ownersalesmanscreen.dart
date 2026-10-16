
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../Apiprovider/salesmanprovider.dart';
import '../../core/utils/confirmation_dialogue.dart';
import '../../models/owner_models/salesmanmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';
import '../../bloc/ownerbloc/ownersalesman/salesman_bloc.dart';
import '../../bloc/ownerbloc/ownersalesman/salesman_event.dart';
import '../../bloc/ownerbloc/ownersalesman/salesman_state.dart';
import 'owner_designationlist.dart';
import 'owneraddsalesmanscreen.dart';


class OwnerSalesmenScreen extends StatelessWidget {
  const OwnerSalesmenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesmanBloc(
        provider: SalesmanProvider(),
      )..add(FetchSalesmen()),
      child: const _OwnerSalesmenView(),
    );
  }
}

class _OwnerSalesmenView extends StatefulWidget {
  const _OwnerSalesmenView();

  @override
  State<_OwnerSalesmenView> createState() => _OwnerSalesmenViewState();
}

class _OwnerSalesmenViewState extends State<_OwnerSalesmenView> {
  final _searchCtrl = TextEditingController();

  // Keeps the last successfully loaded list around so that a transient
  // state (e.g. SalesmanActionLoading while a delete is in flight)
  // doesn't flash "No salesmen found" before the real result arrives.
  List<HSalesmanModel> _lastKnownSalesmen = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HSalesmanModel> _apply(List<HSalesmanModel> all) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.mobile.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.designationName.toLowerCase().contains(q) ||
          s.id.toString().contains(q);
    }).toList();
  }

  Future<void> _openAddSalesman() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SalesmanBloc>(),
          child: const OwnerAddSalesmanScreen(),
        ),
      ),
    );
  }

  /// Add Designation button -> opens the Designation list page.
  Future<void> _openDesignations() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DesignationListPage()),
    );
    if (!mounted) return;
    // Refresh in case designation names changed.
    context.read<SalesmanBloc>().add(FetchSalesmen());
  }

  Future<void> _openEditSalesman(HSalesmanModel salesman) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SalesmanBloc>(),
          child: OwnerAddSalesmanScreen(salesman: salesman),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSalesman(HSalesmanModel salesman) async {
    final bloc = context.read<SalesmanBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Salesman?',
      message:
      'This will remove "${salesman.name}" from your salesman list. This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed) {
      bloc.add(DeleteSalesman(salesman.id));
    }
  }

  /// Wraps [child] in a scrollable so pull-to-refresh works even when
  /// there is nothing to scroll (empty / no-results states).
  Widget _scrollableCenter(Widget child) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SalesmanBloc>().add(FetchSalesmen());
      },
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: constraints.maxHeight, child: child),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        appBar: AppBar(
          title: Text('Salesmen', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        // No floating action button — both actions are in the top row.
        body: SafeArea(
          child: Column(
            children: [
              // ---------- Top row: Add Salesman | Add Designation ----------
              Padding(
                padding: EdgeInsets.fromLTRB(
                    Responsive.w(20), Responsive.h(14), Responsive.w(20), 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _TopActionButton(
                        icon: Icons.person_add_alt_1,
                        label: 'Add Salesman',
                        onPressed: _openAddSalesman,
                      ),
                    ),
                    SizedBox(width: Responsive.w(10)),
                    Expanded(
                      child: _TopActionButton(
                        icon: Icons.badge_outlined,
                        label: 'Add Designation',
                        onPressed: _openDesignations,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(12)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                child: _SearchField(
                  controller: _searchCtrl,
                  hint: 'Search salesman by name, phone or email',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(height: Responsive.h(12)),
              Expanded(
                child: BlocConsumer<SalesmanBloc, SalesmanState>(
                  listener: (context, state) {
                    if (state is SalesmanActionSuccess) {
                      AppSnackbar.success(state.message ?? '');
                    } else if (state is SalesmanActionFailure) {
                      AppSnackbar.error(state.message ?? '');
                    } else if (state is SalesmanError) {
                      AppSnackbar.error(state.message ?? '');
                    }
                  },
                  builder: (context, state) {
                    if (state is SalesmanLoading || state is SalesmanInitial) {
                      return ShimmerListPlaceholder(
                        itemCount: 6,
                        padding: EdgeInsets.fromLTRB(Responsive.w(20), 0,
                            Responsive.w(20), Responsive.h(24)),
                        separatorHeight: Responsive.h(10),
                        itemBuilder: (_, __) => const _SalesmanCardSkeleton(),
                      );
                    }

                    if (state is SalesmanError) {
                      return _ErrorView(
                        message: state.message ?? 'Failed to load salesmen.',
                        onRetry: () =>
                            context.read<SalesmanBloc>().add(FetchSalesmen()),
                      );
                    }

                    List<HSalesmanModel> all = _lastKnownSalesmen;
                    if (state is SalesmanLoaded) all = state.salesmen;
                    if (state is SalesmanActionSuccess) all = state.salesmen;
                    _lastKnownSalesmen = all;

                    // 1) No salesmen exist at all
                    if (all.isEmpty) {
                      return _scrollableCenter(const _EmptyStaffState());
                    }

                    final items = _apply(all);

                    // 2) Salesmen exist but search matched none
                    if (items.isEmpty) {
                      return _scrollableCenter(const _NoSearchResults());
                    }

                    // 3) Normal list
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<SalesmanBloc>().add(FetchSalesmen());
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        // FAB is gone, so no extra bottom space needed.
                        padding: EdgeInsets.fromLTRB(Responsive.w(20), 0,
                            Responsive.w(20), Responsive.h(24)),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Responsive.h(10)),
                        itemBuilder: (context, i) => _OwnerSalesmanCard(
                          salesman: items[i],
                          onEdit: () => _openEditSalesman(items[i]),
                          onDelete: () => _confirmDeleteSalesman(items[i]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- TOP ACTION BUTTON (outlined) ----------------

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyBold(color: AppColors.primary),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(Responsive.h(48)),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(8)),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ---------------- SEARCH FIELD ----------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        prefixIcon: Icon(Icons.search_rounded,
            size: 20, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(13)),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary),
      ),
    );
  }
}

// ---------------- EMPTY / ERROR STATES ----------------

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_2_outlined,
                size: 44, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(10)),
            Text(
              'Add your first salesman to get started',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 44, color: AppColors.textSecondary.withOpacity(0.4)),
            SizedBox(height: Responsive.h(10)),
            Text(
              'No salesmen match your search',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
          ],
        ),
      ),
    );
  }
}

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
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

// ---------------- SKELETON ----------------

class _SalesmanCardSkeleton extends StatelessWidget {
  const _SalesmanCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: Responsive.w(12)),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 13),
                    SizedBox(height: 8),
                    ShimmerBox(width: 90, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 56, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          const ShimmerBox(width: 110, height: 11),
          SizedBox(height: Responsive.h(6)),
          const ShimmerBox(width: 170, height: 11),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 100, height: 12),
              ShimmerBox(width: 70, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- SALESMAN CARD ----------------

class _OwnerSalesmanCard extends StatelessWidget {
  const _OwnerSalesmanCard({
    required this.salesman,
    required this.onEdit,
    required this.onDelete,
  });
  final HSalesmanModel salesman;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(11),
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final salary = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(salesman.salary);

    final statusColor =
    salesman.isActive ? AppColors.success : const Color(0xFFDC2626);
    final initial =
    salesman.name.isNotEmpty ? salesman.name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: avatar, name + designation, status, menu ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  initial,
                  style: AppTextStyles.h2(color: AppColors.primary),
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salesman.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    if (salesman.designationName.isNotEmpty) ...[
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        salesman.designationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  salesman.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: Responsive.sp(10.5),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 24,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert,
                      size: 18, color: AppColors.textSecondary),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text('Edit', style: AppTextStyles.body()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Delete',
                              style:
                              AppTextStyles.body(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ---- contact info ----
          SizedBox(height: Responsive.h(10)),
          _infoRow(Icons.phone_outlined, salesman.mobile),
          SizedBox(height: Responsive.h(6)),
          _infoRow(Icons.email_outlined, salesman.email),
          if (salesman.employeeCode.isNotEmpty) ...[
            SizedBox(height: Responsive.h(6)),
            _infoRow(Icons.badge_outlined, 'ID: ${salesman.employeeCode}'),
          ],

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: joined date, salary ----
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  salesman.joiningDate != null
                      ? 'Joined ${DateFormat('dd-MM-yyyy').format(salesman.joiningDate!)}'
                      : 'Joining date unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
              Text(
                salary,
                style: AppTextStyles.amount(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}