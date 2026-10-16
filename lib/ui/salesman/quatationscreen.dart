import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatedetailscreenwidget.dart'; // StatusPill, statusLabel
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/salesmanmodels/quotationlistmodel.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'quotationpreview.dart';

class QuotationListScreen extends StatelessWidget {
  const QuotationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesmanQuotationBloc()..add(const QuotationListRequested()),
      child: const _QuotationListView(),
    );
  }
}

class _QuotationListView extends StatefulWidget {
  const _QuotationListView();

  @override
  State<_QuotationListView> createState() => _QuotationListViewState();
}

class _QuotationListViewState extends State<_QuotationListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<SalesmanQuotationBloc>().add(const QuotationLoadMoreRequested());
    }
  }

  /// If the list is too short to scroll (e.g. after deleting items), the
  /// scroll listener never fires - so fetch the next page ourselves until
  /// the list fills the screen or there is nothing more to load.
  void _scheduleAutoLoadMore(SalesmanQuotationState state) {
    if (!state.listHasMore || state.isLoadingMore || state.loadMoreFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        context.read<SalesmanQuotationBloc>().add(const QuotationLoadMoreRequested());
      }
    });
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<SalesmanQuotationBloc>();
    bloc.add(const QuotationListRequested());
    await bloc.stream.firstWhere((s) => s.listStatus != QuotationLoadStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as owner) ----------
        appBar: AppBar(
          title: Text('Quotations', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
            listenWhen: (prev, curr) =>
            prev.deleteStatus != curr.deleteStatus ||
                prev.submitStatus != curr.submitStatus,
            listener: (context, state) {
              if (state.deleteStatus == QuotationActionStatus.success) {
                AppSnackbar.success('Quotation deleted.');
                context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
              } else if (state.deleteStatus == QuotationActionStatus.failure) {
                AppSnackbar.error(state.deleteError ?? 'Failed to delete quotation.');
                context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
              } else if (state.submitStatus == QuotationActionStatus.success) {
                AppSnackbar.success(state.submitMessage ?? 'Submitted for approval.');
                context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
              } else if (state.submitStatus == QuotationActionStatus.failure) {
                AppSnackbar.error(state.submitError ?? 'Failed to submit for approval.');
                context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
              }
            },
            child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
              buildWhen: (prev, curr) =>
              prev.listStatus != curr.listStatus ||
                  prev.list != curr.list ||
                  prev.deletingId != curr.deletingId ||
                  prev.deleteStatus != curr.deleteStatus ||
                  prev.listHasMore != curr.listHasMore ||
                  prev.isLoadingMore != curr.isLoadingMore ||
                  prev.loadMoreFailed != curr.loadMoreFailed,
              builder: (context, state) {
                // ---- loading skeleton ----
                if (state.listStatus == QuotationLoadStatus.loading && state.list.isEmpty) {
                  return ShimmerListPlaceholder(
                    itemCount: 6,
                    padding: listPadding,
                    separatorHeight: Responsive.h(10),
                    itemBuilder: (context, i) => const _QuotationCardSkeleton(),
                  );
                }

                // ---- error ----
                if (state.listStatus == QuotationLoadStatus.failure && state.list.isEmpty) {
                  return _ErrorView(
                    message: state.listError ?? 'Failed to load quotations.',
                    onRetry: () => context
                        .read<SalesmanQuotationBloc>()
                        .add(const QuotationListRequested()),
                  );
                }

                // ---- empty (still pull-to-refresh) ----
                if (state.list.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => _refresh(context),
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
                                  Icons.request_quote_outlined,
                                  size: 44,
                                  color: AppColors.textSecondary.withOpacity(0.4),
                                ),
                                SizedBox(height: Responsive.h(10)),
                                Text('No quotations yet', style: AppTextStyles.subtitle()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                _scheduleAutoLoadMore(state);

                final showFooter =
                    state.listHasMore || state.isLoadingMore || state.loadMoreFailed;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => _refresh(context),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: listPadding,
                    itemCount: state.list.length + (showFooter ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                    itemBuilder: (context, index) {
                      // Footer: spinner or retry button.
                      if (index >= state.list.length) {
                        if (state.loadMoreFailed) {
                          return Center(
                            child: TextButton(
                              onPressed: () => context
                                  .read<SalesmanQuotationBloc>()
                                  .add(const QuotationLoadMoreRequested()),
                              child: Text('Failed to load more. Tap to retry',
                                  style: AppTextStyles.link()),
                            ),
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final quotation = state.list[index];
                      final isDeleting = state.deletingId == quotation.id &&
                          state.deleteStatus == QuotationActionStatus.inProgress;

                      return _QuotationTile(
                        quotation: quotation,
                        currency: currency,
                        isDeleting: isDeleting,
                        onTap: () {
                          final bloc = context.read<SalesmanQuotationBloc>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: QuotationPreviewScreen(id: quotation.id),
                              ),
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(context, quotation),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, QuotationListItem quotation) async {
    final bloc = context.read<SalesmanQuotationBloc>();
    const red = Color(0xFFDC2626);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete quotation?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will permanently delete ${quotation.quotationNumber.isNotEmpty ? quotation.quotationNumber : 'this quotation'}. This action cannot be undone.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel',
                style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete', style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(QuotationDeleteRequested(quotation.id));
    }
  }
}

// =====================================================================
// CARD
// =====================================================================

class _QuotationTile extends StatelessWidget {
  const _QuotationTile({
    required this.quotation,
    required this.currency,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
  });

  final QuotationListItem quotation;
  final NumberFormat currency;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;

  Color get _statusColor {
    switch (quotation.status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'sent':
        return const Color(0xFFF59E0B);
      case 'draft':
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = quotation.date != null
        ? DateFormat('dd-MM-yyyy').format(quotation.date!)
        : '-';

    return Opacity(
      opacity: isDeleting ? 0.5 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isDeleting ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- top: icon, number + customer, status ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _IconTile(icon: Icons.request_quote_outlined),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quotation.quotationNumber.isEmpty
                                ? '#${quotation.id}'
                                : quotation.quotationNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold(),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            quotation.customerName.isEmpty
                                ? 'No party name'
                                : quotation.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    StatusPill(
                      label: quotation.status.isEmpty ? '-' : statusLabel(quotation.status),
                      color: _statusColor,
                    ),
                  ],
                ),

                SizedBox(height: Responsive.h(12)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(10)),

                // ---- bottom: date + items, delete, total ----
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: AppColors.textSecondary),
                    SizedBox(width: Responsive.w(6)),
                    Expanded(
                      child: Text(
                        '$dateText  •  ${quotation.totalItems} items',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(color: AppColors.textSecondary),
                      ),
                    ),
                    isDeleting
                        ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.delete_outline,
                            size: 19, color: AppColors.error),
                      ),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      currency.format(quotation.grandTotal),
                      style: AppTextStyles.amount(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.link()),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotationCardSkeleton extends StatelessWidget {
  const _QuotationCardSkeleton();

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
              ShimmerBox(width: 100, height: 12),
              ShimmerBox(width: 90, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}