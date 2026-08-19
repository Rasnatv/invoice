
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/salesmanmodels/quotationlistmodel.dart';
import '../../bloc/salemanbloc/estimate/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/estimate/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/estimate/quotation_listdetail_bloc.dart';
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

class _QuotationListView extends StatelessWidget {
  const _QuotationListView();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Quotation deleted.')));
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            } else if (state.deleteStatus == QuotationActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.deleteError ?? 'Failed to delete quotation.'),
                backgroundColor: AppColors.error,
              ));
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            } else if (state.submitStatus == QuotationActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitMessage ?? 'Submitted for approval.')),
              );
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            } else if (state.submitStatus == QuotationActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.submitError ?? 'Failed to submit for approval.'),
                backgroundColor: AppColors.error,
              ));
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            }
          },
          child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
            buildWhen: (prev, curr) =>
            prev.listStatus != curr.listStatus ||
                prev.list != curr.list ||
                prev.deletingId != curr.deletingId,
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
                        onPressed: () =>
                            context.read<SalesmanQuotationBloc>().add(const QuotationListRequested()),
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
                      Icon(Icons.request_quote_outlined, size: 48, color: AppColors.textHint),
                      SizedBox(height: Responsive.h(10)),
                      Text('No quotations yet', style: AppTextStyles.body(color: AppColors.textHint)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SalesmanQuotationBloc>().add(const QuotationListRequested());
                  await context
                      .read<SalesmanQuotationBloc>()
                      .stream
                      .firstWhere((s) => s.listStatus != QuotationLoadStatus.loading);
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(Responsive.w(18)),
                  itemCount: state.list.length,
                  separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
                  itemBuilder: (context, index) {
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
                      style: AppTextStyles.body(),
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