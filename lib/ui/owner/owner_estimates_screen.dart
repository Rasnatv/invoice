
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/paymenthistory.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/salesmanmodels/salesmanownerestimatemodel.dart';
import '../../bloc/ownerbloc/ownerestimatelist/ownerestimatelist_bloc.dart';
import '../../bloc/ownerbloc/ownerestimatelist/ownerestimatelist_event.dart';
import '../../bloc/ownerbloc/ownerestimatelist/ownerestimatelistevent_state.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'ownerestuimatedetailscreen.dart';
import 'ownerrescorpayment.dart';

class OwnerEstimatesScreen extends StatelessWidget {
  const OwnerEstimatesScreen({
    super.key,
    this.initialFilter = 'all',
    this.refreshSignal,
  });
  final String initialFilter;

  /// Incremented by the shell every time the Estimates tab is tapped.
  final ValueListenable<int>? refreshSignal;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false, // create the bloc and fire the API call immediately
      create: (_) =>
      OwnerEstimatesBloc()..add(const OwnerEstimatesLoadRequested()),
      child: _OwnerEstimatesView(
        initialFilter: initialFilter,
        refreshSignal: refreshSignal,
      ),
    );
  }
}

class _OwnerEstimatesView extends StatefulWidget {
  const _OwnerEstimatesView({
    required this.initialFilter,
    this.refreshSignal,
  });
  final String initialFilter;
  final ValueListenable<int>? refreshSignal;

  @override
  State<_OwnerEstimatesView> createState() => _OwnerEstimatesViewState();
}

class _OwnerEstimatesViewState extends State<_OwnerEstimatesView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController(); // pagination

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);

    // Refresh whenever the Estimates tab is tapped.
    widget.refreshSignal?.addListener(_onTabSelected);

    if (widget.initialFilter != 'all') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OwnerEstimatesBloc>().add(
          OwnerEstimatesFilterChanged(widget.initialFilter),
        );
      });
    }
  }

  void _refresh() {
    if (!mounted) return;
    context
        .read<OwnerEstimatesBloc>()
        .add(const OwnerEstimatesRefreshRequested());
  }

  void _onTabSelected() => _refresh();

  /// Load the next page when the user is near the bottom.
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context
          .read<OwnerEstimatesBloc>()
          .add(const OwnerEstimatesLoadMoreRequested());
    }
  }

  /// Filters/search are client-side, so a filtered list can be too short
  /// to scroll. Keep loading pages until it fills or the server runs out.
  void _maybeLoadMore(OwnerEstimatesState state) {
    if (!state.hasMore || state.isLoadingMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final short =
          !_scrollCtrl.hasClients || _scrollCtrl.position.maxScrollExtent <= 0;
      if (short) {
        context
            .read<OwnerEstimatesBloc>()
            .add(const OwnerEstimatesLoadMoreRequested());
      }
    });
  }

  @override
  void dispose() {
    widget.refreshSignal?.removeListener(_onTabSelected);
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCardTap(SalesmanowrEstimateModel estimate) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerEstimateDetailsScreen(estimateId: estimate.id),
      ),
    );
    _refresh();
  }

  Future<void> _onCreateEstimateTap() async {
    await context.push('/owner/create-estimate');
    _refresh();
  }

  Future<void> _onPayNowTap(SalesmanowrEstimateModel estimate) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecordPaymentScreen(
          estimateId: int.tryParse(estimate.id) ?? 0,
          contractorName: estimate.contractorName.isNotEmpty
              ? estimate.contractorName
              : estimate.customerName,
          estimateNumber: estimate.estimateNumber,
          totalAmount: estimate.grandTotalValue,
          amountPaid: estimate.amountPaidValue,
        ),
      ),
    );
    if (result == true) _refresh();
  }

  Future<void> _onPaymentHistoryTap(SalesmanowrEstimateModel estimate) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentHistoryScreen(
          estimateId: int.tryParse(estimate.id) ?? 0,
          contractorName: estimate.contractorName.isNotEmpty
              ? estimate.contractorName
              : estimate.customerName,
          estimateNumber: estimate.estimateNumber,
        ),
      ),
    );
    // A payment may have been recorded inside the history screen.
    if (result == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (unchanged) ----------
        appBar: AppBar(
          title: Text('Estimates', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocBuilder<OwnerEstimatesBloc, OwnerEstimatesState>(
            builder: (context, state) {
              final bool isLoadingChips =
                  state.status == OwnerEstimatesStatus.loading;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(Responsive.w(20),
                        Responsive.h(14), Responsive.w(20), 0),
                    child: _SearchField(
                      controller: _searchCtrl,
                      hint: 'Search salesman, contractor or phone',
                      onChanged: (v) => context
                          .read<OwnerEstimatesBloc>()
                          .add(OwnerEstimatesSearchQueryChanged(v)),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  if (isLoadingChips)
                    _buildFilterChipsSkeleton(
                      chipCount:
                      state.filters.isNotEmpty ? state.filters.length : 4,
                    )
                  else if (state.allEstimates.isNotEmpty &&
                      state.filters.isNotEmpty)
                    _buildFilterChips(context, state),
                  SizedBox(height: Responsive.h(12)),
                  Expanded(child: _buildBody(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, OwnerEstimatesState state) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
        itemCount: state.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = state.filters[i];
          return _FilterChip(
            label: f.label,
            selected: f.key == state.activeFilter,
            onTap: () => context
                .read<OwnerEstimatesBloc>()
                .add(OwnerEstimatesFilterChanged(f.key)),
          );
        },
      ),
    );
  }

  Widget _buildFilterChipsSkeleton({int chipCount = 4}) {
    const widths = [70.0, 90.0, 80.0, 100.0, 85.0, 75.0];

    return ShimmerLoading(
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
          itemCount: chipCount,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) => ShimmerBox(
            width: widths[i % widths.length],
            height: 30,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OwnerEstimatesState state) {
    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), 0, Responsive.w(20), Responsive.h(24));

    if (state.status == OwnerEstimatesStatus.loading) {
      final int skeletonCount = state.filteredEstimates.isNotEmpty
          ? state.filteredEstimates.length.clamp(1, 8)
          : 6;

      return ShimmerListPlaceholder(
        itemCount: skeletonCount,
        padding: listPadding,
        separatorHeight: Responsive.h(10),
        itemBuilder: (context, i) => const _OwnerEstimateCardSkeleton(),
      );
    }

    if (state.status == OwnerEstimatesStatus.failure) {
      return _ErrorView(
        message: state.errorMessage ?? 'Failed to load estimates.',
        onRetry: _refresh,
      );
    }

    // Keep fetching while the (filtered) list is too short to scroll.
    _maybeLoadMore(state);

    if (state.filteredEstimates.isEmpty) {
      // Still fetching more pages for this filter/search: show a loader.
      if (state.hasMore || state.isLoadingMore) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 44,
                      color: AppColors.textSecondary.withOpacity(0.4),
                    ),
                    SizedBox(height: Responsive.h(10)),
                    Text('No estimates found', style: AppTextStyles.subtitle()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: listPadding,
        itemCount:
        state.filteredEstimates.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, i) {
          // Bottom loader while the next page is being fetched.
          if (i >= state.filteredEstimates.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final e = state.filteredEstimates[i];
          return _OwnerEstimateCard(
            key: ValueKey(e.id),
            estimate: e,
            onTap: () => _onCardTap(e),
            onPayNow: () => _onPayNowTap(e),
            onHistoryTap: () => _onPaymentHistoryTap(e),
          );
        },
      ),
    );
  }
}


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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12), vertical: Responsive.h(6)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: Responsive.sp(11.5),
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: Responsive.w(6)),



          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(11),
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _BalanceBar extends StatelessWidget {
  const _BalanceBar({required this.amountText, required this.onPressed});
  final String amountText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFDC2626);
    return Container(
      padding: EdgeInsets.fromLTRB(
          Responsive.w(10), Responsive.h(6), Responsive.w(6), Responsive.h(6)),
      decoration: BoxDecoration(
        color: red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 16, color: red),
          SizedBox(width: Responsive.w(6)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance due',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: Responsive.sp(10),
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  amountText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(color: red),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: Responsive.sp(11),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ERROR / SKELETON
// =====================================================================

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

class _OwnerEstimateCardSkeleton extends StatelessWidget {
  const _OwnerEstimateCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
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
                    ShimmerBox(width: 160, height: 11),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 20, borderRadius: 20),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ESTIMATE CARD
// =====================================================================

class _OwnerEstimateCard extends StatelessWidget {
  const _OwnerEstimateCard({
    super.key,
    required this.estimate,
    required this.onTap,
    required this.onPayNow,
    required this.onHistoryTap,
  });

  final SalesmanowrEstimateModel estimate;
  final VoidCallback onTap;
  final VoidCallback onPayNow;
  final VoidCallback onHistoryTap;

  Color get _statusColor {
    switch (estimate.statusKey) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'dispatched':
        return AppColors.primary;
      case 'pending_approval':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: icon, number + customer, status ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.description_outlined),
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
                      style:
                      AppTextStyles.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(label: estimate.statusLabel, color: _statusColor),
            ],
          ),

          // ---- contractor / approved ----
          if (estimate.contractorName.isNotEmpty) ...[
            SizedBox(height: Responsive.h(10)),
            _InfoRow(
              icon: Icons.engineering_outlined,
              text: 'Contractor: ${estimate.contractorName}',
            ),
          ],
          if (estimate.isApproved) ...[
            SizedBox(height: Responsive.h(6)),
            _InfoRow(
              icon: Icons.verified_outlined,
              color: AppColors.primary,
              text: 'Approved by ${estimate.approvedBy}'
                  '${estimate.approvedAt.isNotEmpty ? ' · ${estimate.approvedAt}' : ''}',
            ),
          ],

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: date, history, total ----
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  estimate.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
              InkWell(
                onTap: onHistoryTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.history_rounded,
                      size: 25, color: AppColors.textSecondary),
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              Text(
                estimate.grandTotalFormatted,
                style: AppTextStyles.amount(color: AppColors.primary),
              ),
            ],
          ),

          // ---- balance ----
          if (estimate.hasBalance) ...[
            SizedBox(height: Responsive.h(10)),
            _BalanceBar(
              amountText: estimate.balanceAmountFormatted,
              onPressed: onPayNow,
            ),
          ],
        ],
      ),
    );
  }
}