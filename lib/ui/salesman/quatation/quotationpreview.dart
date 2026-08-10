
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/salesman/quatation/quotation_editscreen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../widgets/primary_button.dart';
import '../../../bloc/salemanbloc/estimate/qtn_listdetail_event.dart';
import '../../../bloc/salemanbloc/estimate/qtn_listdetail_state.dart';
import '../../../bloc/salemanbloc/estimate/quotation_listdetail_bloc.dart';
import '../../../models/salesmanmodels/quotationlistdetailmodel.dart';

/// Shows the full detail of a single quotation/estimate (POST
/// /quotations/show), with Delete and Submit-for-Approval wired to the
/// live API through [SalesmanQuotationBloc].
///
/// Expects a [SalesmanQuotationBloc] to already be provided above it in
/// the tree (the list screen pushes this route with `BlocProvider.value`
/// so both screens share state and a delete/submit here is reflected back
/// on the list without an extra round trip).
class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key, required this.id});

  final String id;

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen> {
  // Captured in initState (while context is still valid) and reused in
  // dispose. Calling context.read<...>() inside dispose() is unsafe —
  // by then the widget/element is already deactivated, and looking up an
  // ancestor (the provider) through a deactivated context throws
  // "Looking up a deactivated widget's ancestor is unsafe."
  late final SalesmanQuotationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SalesmanQuotationBloc>();
    _bloc.add(QuotationDetailRequested(widget.id));
  }

  @override
  void dispose() {
    _bloc.add(const QuotationDetailCleared());
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  void _editQuotation(QuotationDetailModel estimate) {
    final bloc = context.read<SalesmanQuotationBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: QuotationEditScreen(estimate: estimate),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(QuotationDetailModel estimate) async {
    final bloc = context.read<SalesmanQuotationBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete quotation?'),
        content: Text(
          'This will permanently delete ${estimate.quotationNumber.isNotEmpty ? estimate.quotationNumber : 'this quotation'}. This action cannot be undone.',
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
      bloc.add(QuotationDeleteRequested(estimate.id));
    }
  }

  void _sendForApproval(QuotationDetailModel estimate) {
    context.read<SalesmanQuotationBloc>().add(QuotationSubmitForApprovalRequested(estimate.id));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quotation Preview', style: AppTextStyles.h6()),
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
              Navigator.of(context).pop();
            } else if (state.deleteStatus == QuotationActionStatus.failure) {
              _showError(state.deleteError ?? 'Failed to delete quotation.');
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            } else if (state.submitStatus == QuotationActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitMessage ?? 'Submitted for approval.')),
              );
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            } else if (state.submitStatus == QuotationActionStatus.failure) {
              _showError(state.submitError ?? 'Failed to submit for approval.');
              context.read<SalesmanQuotationBloc>().add(const QuotationActionResultConsumed());
            }
          },
          child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
            buildWhen: (prev, curr) =>
            prev.detailStatus != curr.detailStatus || prev.detail != curr.detail,
            builder: (context, state) {
              if (state.detailStatus == QuotationLoadStatus.loading && state.detail == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.detailStatus == QuotationLoadStatus.failure && state.detail == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: AppColors.error),
                      SizedBox(height: Responsive.h(10)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                        child: Text(
                          state.detailError ?? 'Failed to load quotation.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(color: AppColors.error),
                        ),
                      ),
                      SizedBox(height: Responsive.h(10)),
                      TextButton(
                        onPressed: () => context
                            .read<SalesmanQuotationBloc>()
                            .add(QuotationDetailRequested(widget.id)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final estimate = state.detail;
              if (estimate == null) return const SizedBox.shrink();

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        Container(
                          padding: EdgeInsets.all(Responsive.w(14)),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Estimate No.', style: AppTextStyles.caption()),
                                  Text(
                                    estimate.quotationNumber.isEmpty
                                        ? '#${estimate.id}'
                                        : estimate.quotationNumber,
                                    style: AppTextStyles.h3(),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Date', style: AppTextStyles.caption()),
                                  Text(
                                    estimate.date != null
                                        ? DateFormat('dd-MM-yyyy').format(estimate.date!)
                                        : estimate.dateRaw,
                                    style: AppTextStyles.h3(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(10)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              estimate.status.isEmpty ? '-' : estimate.status,
                              style: AppTextStyles.bodyBold(color: Colors.orange),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(16)),

                        _PreviewSection(
                          title: 'Customer Details',
                          rows: [
                            _PreviewRow('Party Name', estimate.customer.name, icon: Icons.groups_2_outlined),
                            _PreviewRow('Address', estimate.customer.address, icon: Icons.location_on_outlined),
                            _PreviewRow('Contact No.', estimate.customer.phone, icon: Icons.phone_outlined),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),

                        _PreviewSection(
                          title: 'Contractor Details',
                          rows: [
                            _PreviewRow('Contractor Name', estimate.contractor.name, icon: Icons.engineering_outlined),
                            _PreviewRow('Contact No.', estimate.contractor.mobile, icon: Icons.phone_outlined),
                          ],
                        ),
                        SizedBox(height: Responsive.h(14)),

                        _PreviewSection(
                          title: 'Salesman',
                          rows: [
                            _PreviewRow('Name', estimate.salesman.name, icon: Icons.badge_outlined),
                            _PreviewRow('Code', estimate.salesman.employeeCode, icon: Icons.badge_outlined),
                          ],
                        ),
                        SizedBox(height: Responsive.h(20)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items', style: AppTextStyles.h3()),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(4)),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Total Items: ${estimate.itemsCount}',
                                style: AppTextStyles.bodyBold(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(10)),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(AppColors.surfaceAlt),
                              headingTextStyle: AppTextStyles.bodyBold(),
                              dataTextStyle: AppTextStyles.body(),
                              columnSpacing: 18,
                              columns: const [
                                DataColumn(label: Text('Sl.No')),
                                DataColumn(label: Text('Item')),
                                DataColumn(label: Text('Size')),
                                DataColumn(label: Text('Qty'), numeric: true),
                                DataColumn(label: Text('Unit')),
                                DataColumn(label: Text('Rate'), numeric: true),
                                DataColumn(label: Text('Amount'), numeric: true),
                                DataColumn(label: Text('Incentive'), numeric: true),
                              ],
                              rows: estimate.items.asMap().entries.map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text('${i + 1}')),
                                  DataCell(Text(item.productName)),
                                  DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                                  DataCell(Text(number.format(item.quantity))),
                                  DataCell(Text(item.productUnit)),
                                  DataCell(Text(number.format(item.rate))),
                                  DataCell(Text(
                                    currency.format(item.amount),
                                    style: AppTextStyles.bodyBold(),
                                  )),
                                  DataCell(Text(
                                    item.incentiveAmount > 0 ? currency.format(item.incentiveAmount) : '-',
                                    style: AppTextStyles.bodyBold(color: AppColors.success),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(16)),

                        if (estimate.notes.isNotEmpty) ...[
                          _PreviewSection(
                            title: 'Notes',
                            rows: [_PreviewRow('', estimate.notes)],
                          ),
                          SizedBox(height: Responsive.h(14)),
                        ],

                        Container(
                          padding: EdgeInsets.all(Responsive.w(14)),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              _totalRow('Total Items', '${estimate.itemsCount}'),
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Total Qty', number.format(estimate.totalQuantity)),
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Items Total', currency.format(estimate.subtotal)),
                              SizedBox(height: Responsive.h(6)),
                              _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Grand Total', style: AppTextStyles.h3()),
                                  Text(currency.format(estimate.grandTotal), style: AppTextStyles.h2(color: AppColors.primary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),

                        // Separate, visually distinct box for incentive so it's
                        // clear this is internal/salesman info, not part of the
                        // customer's bill total above.
                        if (estimate.items.any((i) => i.incentiveAmount > 0))
                          Container(
                            padding: EdgeInsets.all(Responsive.w(14)),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.percent, size: 18, color: AppColors.success),
                                    SizedBox(width: Responsive.w(8)),
                                    Text('Incentive Total', style: AppTextStyles.bodyBold(color: AppColors.success)),
                                  ],
                                ),
                                Text(
                                  currency.format(
                                    estimate.items.fold(0.0, (s, r) => s + r.incentiveAmount),
                                  ),
                                  style: AppTextStyles.h3(color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: Responsive.h(12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
                      buildWhen: (prev, curr) =>
                      prev.deleteStatus != curr.deleteStatus || prev.submitStatus != curr.submitStatus,
                      builder: (context, state) {
                        final deleting = state.deleteStatus == QuotationActionStatus.inProgress;
                        final submitting = state.submitStatus == QuotationActionStatus.inProgress;
                        final busy = deleting || submitting;

                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: busy ? null : () => _editQuotation(estimate),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                              ),
                            ),
                            SizedBox(width: Responsive.w(10)),
                            IconButton(
                              onPressed: busy ? null : () => _confirmDelete(estimate),
                              icon: deleting
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : Icon(Icons.delete_outline, color: AppColors.error),
                              tooltip: 'Delete',
                            ),
                            SizedBox(width: Responsive.w(10)),
                            if (estimate.isDraft)
                              Expanded(
                                flex: 2,
                                child: PrimaryButton(
                                  label: submitting ? 'Submitting…' : 'Submit for Approval',
                                  height: 48,
                                  onPressed: busy ? null : () => _sendForApproval(estimate),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: AppTextStyles.body()),
      ],
    );
  }
}

class _PreviewRow {
  final String label;
  final String value;
  final IconData? icon;
  _PreviewRow(this.label, this.value, {this.icon});
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.rows});
  final String title;
  final List<_PreviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyBold(color: AppColors.primary)),
          SizedBox(height: Responsive.h(10)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                if (r.label.isNotEmpty)
                  SizedBox(
                    width: r.icon != null ? 88 : 100,
                    child: Text(r.label, style: AppTextStyles.caption()),
                  ),
                Expanded(
                  child: Text(
                    r.value.isEmpty ? '-' : r.value,
                    style: AppTextStyles.bodyBold(),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}