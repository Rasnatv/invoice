
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/salesmanmodels/quotationlistmodel.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
import '../../widgets/appsnackbar.dart';
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

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Quotations', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
            listenWhen: (prev, curr) =>
            prev.deleteStatus != curr.deleteStatus || prev.submitStatus != curr.submitStatus,
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
                if (state.listStatus == QuotationLoadStatus.loading && state.list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.listStatus == QuotationLoadStatus.failure && state.list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 40, color: AppColors.error),
                        SizedBox(height: Responsive.h(10)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                          child: Text(
                            state.listError ?? 'Failed to load quotations.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(color: AppColors.error),
                          ),
                        ),
                        SizedBox(height: Responsive.h(10)),
                        TextButton(
                          onPressed: () => context
                              .read<SalesmanQuotationBloc>()
                              .add(const QuotationListRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_rounded, size: 48, color: AppColors.textHint),
                        SizedBox(height: Responsive.h(10)),
                        Text('No quotations yet',
                            style: AppTextStyles.body(color: AppColors.textHint)),
                      ],
                    ),
                  );
                }

                _scheduleAutoLoadMore(state);

                final showFooter =
                    state.listHasMore || state.isLoadingMore || state.loadMoreFailed;

                return RefreshIndicator(
                  onRefresh: () async {
                    final bloc = context.read<SalesmanQuotationBloc>();
                    bloc.add(const QuotationListRequested());
                    await bloc.stream
                        .firstWhere((s) => s.listStatus != QuotationLoadStatus.loading);
                  },
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(Responsive.w(18)),
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
                              child: const Text('Failed to load more. Tap to retry'),
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete quotation?'),
        content: Text(
          'This will permanently delete ${quotation.quotationNumber.isNotEmpty ? quotation.quotationNumber : 'this quotation'}. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(QuotationDeleteRequested(quotation.id));
    }
  }
}

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

  Color _statusColor() {
    switch (quotation.status.toLowerCase()) {
      case 'draft':
        return AppColors.textHint;
      case 'sent':
        return Colors.orange;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Opacity(
      opacity: isDeleting ? 0.5 : 1,
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(14)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.request_quote_outlined, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quotation.quotationNumber.isEmpty
                                ? '#${quotation.id}'
                                : quotation.quotationNumber,
                            style: AppTextStyles.bodyBold(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            quotation.status.isEmpty ? '-' : quotation.status,
                            style: AppTextStyles.caption(color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      quotation.customerName.isEmpty ? 'No party name' : quotation.customerName,
                      style: AppTextStyles.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      '${quotation.date != null ? DateFormat('dd-MM-yyyy').format(quotation.date!) : '-'}  •  ${quotation.totalItems} items',
                      style: AppTextStyles.caption(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(quotation.grandTotal),
                      style: AppTextStyles.bodyBold(color: AppColors.primary)),
                  SizedBox(height: Responsive.h(4)),
                  isDeleting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : InkWell(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
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