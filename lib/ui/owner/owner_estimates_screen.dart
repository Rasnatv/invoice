
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/owner/paymenthistory.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/salesmanmodels/salesmanownerestimatemodel.dart';
import '../../bloc/ownerbloc/ownerestimatelist/ownerestimatelist_bloc.dart';
import '../../bloc/ownerbloc/ownerestimatelist/ownerestimatelist_event.dart';
import '../../bloc/ownerbloc/ownerestimatelist/ownerestimatelistevent_state.dart';
import 'ownerestuimatedetailscreen.dart';
import 'ownerrescorpayment.dart';

class OwnerEstimatesScreen extends StatelessWidget {
  const OwnerEstimatesScreen({super.key, this.initialFilter = 'all'});
  final String initialFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerEstimatesBloc()..add(const OwnerEstimatesLoadRequested()),
      child: _OwnerEstimatesView(initialFilter: initialFilter),
    );
  }
}

class _OwnerEstimatesView extends StatefulWidget {
  const _OwnerEstimatesView({required this.initialFilter});
  final String initialFilter;

  @override
  State<_OwnerEstimatesView> createState() => _OwnerEstimatesViewState();
}

class _OwnerEstimatesViewState extends State<_OwnerEstimatesView> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != 'all') {
      // Applied once the first load lands filters/state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OwnerEstimatesBloc>().add(
          OwnerEstimatesFilterChanged(widget.initialFilter),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onCardTap(SalesmanowrEstimateModel estimate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerEstimateDetailsScreen(estimateId: estimate.id),
      ),
    );
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

    if (result == true && mounted) {
      context.read<OwnerEstimatesBloc>().add(const OwnerEstimatesRefreshRequested());
    }
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

    // A payment could have been recorded from inside the history screen
    // (via its own "record payment" FAB), so refresh the list balances too.
    if (result == true && mounted) {
      context.read<OwnerEstimatesBloc>().add(const OwnerEstimatesRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estimates', style: AppTextStyles.h6()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocBuilder<OwnerEstimatesBloc, OwnerEstimatesState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(16), Responsive.h(14), Responsive.w(16), 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => context
                        .read<OwnerEstimatesBloc>()
                        .add(OwnerEstimatesSearchQueryChanged(v)),
                    decoration: const InputDecoration(
                      hintText: 'Search salesman, contractor or phone',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                if (state.filters.isNotEmpty)
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
                      itemCount: state.filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final f = state.filters[i];
                        final selected = f.key == state.activeFilter;
                        return ChoiceChip(
                          label: Text('${f.label} (${f.count})'),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: AppTextStyles.bodyBold(
                              color: selected ? Colors.white : AppColors.textPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: selected ? AppColors.primary : AppColors.border),
                          ),
                          onSelected: (_) => context
                              .read<OwnerEstimatesBloc>()
                              .add(OwnerEstimatesFilterChanged(f.key)),
                        );
                      },
                    ),
                  ),
                SizedBox(height: Responsive.h(12)),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OwnerEstimatesState state) {
    if (state.status == OwnerEstimatesStatus.loading &&
        state.allEstimates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == OwnerEstimatesStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Failed to load estimates.',
                style: AppTextStyles.subtitle()),
            SizedBox(height: Responsive.h(10)),
            ElevatedButton(
              onPressed: () => context
                  .read<OwnerEstimatesBloc>()
                  .add(const OwnerEstimatesRefreshRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.filteredEstimates.isEmpty) {
      return Center(child: Text('No estimates found', style: AppTextStyles.subtitle()));
    }

    return RefreshIndicator(
      onRefresh: () async => context
          .read<OwnerEstimatesBloc>()
          .add(const OwnerEstimatesRefreshRequested()),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(16), 0, Responsive.w(16), Responsive.h(20)),
        itemCount: state.filteredEstimates.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, i) {
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

  @override
  Widget build(BuildContext context) {
    final bool showBalance = estimate.hasBalance;

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
                    estimate.contractorName.isNotEmpty
                        ? estimate.contractorName
                        : estimate.customerName,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onHistoryTap,
                  icon: const Icon(Icons.history, size: 20),
                  color: AppColors.textSecondary,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Payment History',
                ),
                SizedBox(width: Responsive.w(6)),
                _StatusChip(label: estimate.statusLabel, statusKey: estimate.statusKey),
              ],
            ),
            SizedBox(height: Responsive.h(4)),
            Text('Estimate No: ${estimate.estimateNumber}', style: AppTextStyles.caption()),
            SizedBox(height: Responsive.h(4)),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(4)),
                Expanded(
                  child: Text(
                    estimate.salesmanName.isEmpty
                        ? estimate.customerName
                        : '${estimate.salesmanName} · ${estimate.customerName}',
                    style: AppTextStyles.caption(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (estimate.isApproved) ...[
              SizedBox(height: Responsive.h(4)),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      'Approved by ${estimate.approvedBy}'
                          '${estimate.approvedAt.isNotEmpty ? ' · ${estimate.approvedAt}' : ''}',
                      style: AppTextStyles.caption(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: Responsive.h(8)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(estimate.date, style: AppTextStyles.caption()),
                Text(estimate.grandTotalFormatted,
                    style: AppTextStyles.bodyBold(color: AppColors.primary)),
              ],
            ),
            if (showBalance) ...[
              SizedBox(height: Responsive.h(6)),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: Colors.red),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      'Balance: ${estimate.balanceAmountFormatted}',
                      style: AppTextStyles.bodyBold(color: Colors.red),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onPayNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Pay Now',
                        style: AppTextStyles.caption(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.statusKey});
  final String label;
  final String statusKey;

  Color get _color {
    switch (statusKey) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return Colors.red;
      case 'despatched':
        return AppColors.primary;
      case 'pending_approval':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.caption(color: _color)),
    );
  }
}