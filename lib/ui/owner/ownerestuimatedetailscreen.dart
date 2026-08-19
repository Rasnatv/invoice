
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';
import '../../models/owner_models/owner_estimateactionmodel.dart';
import '../../widgets/primary_button.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';
import 'ownerdespatchsheet.dart';


class OwnerEstimateDetailsScreen extends StatelessWidget {
  const OwnerEstimateDetailsScreen({super.key, required this.estimateId});
  final String estimateId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerEstimateDetailBloc()
        ..add(OwnerEstimateDetailLoadRequested(estimateId)),
      child: _OwnerEstimateDetailView(estimateId: estimateId),
    );
  }
}

class _OwnerEstimateDetailView extends StatelessWidget {
  const _OwnerEstimateDetailView({required this.estimateId});
  final String estimateId;

  final currencyFmt = const _CurrencyFmt();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final number = NumberFormat.decimalPattern('en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Owner Estimate Details', style: AppTextStyles.h6())),
      body: SafeArea(
        child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
          listener: (context, state) {
            if (state.actionStatus == OwnerEstimateActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Done')),
              );
            } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage ?? 'Action failed')),
              );
            }
          },
          builder: (context, state) {
            if (state.status == OwnerEstimateDetailStatus.loading ||
                state.status == OwnerEstimateDetailStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == OwnerEstimateDetailStatus.failure ||
                state.detail == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Failed to load estimate.'),
                    SizedBox(height: Responsive.h(10)),
                    ElevatedButton(
                      onPressed: () => context
                          .read<OwnerEstimateDetailBloc>()
                          .add(OwnerEstimateDetailLoadRequested(estimateId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final detail = state.detail!;
            final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(18)),
                    children: [
                      _buildHeader(detail),
                      SizedBox(height: Responsive.h(16)),
                      _DetailSection(title: 'Customer Details', rows: [
                        _Row('Name', detail.customerName, icon: Icons.groups_2_outlined),
                        _Row('Phone', detail.customerPhone, icon: Icons.phone_outlined),
                        if (detail.customerAddress.isNotEmpty)
                          _Row('Address', detail.customerAddress,
                              icon: Icons.location_on_outlined),
                      ]),
                      if (detail.salesman.name.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(14)),
                        _DetailSection(title: 'Salesman', rows: [
                          _Row('Name', detail.salesman.name, icon: Icons.badge_outlined),
                          if (detail.salesman.employeeCode.isNotEmpty)
                            _Row('Employee Code', detail.salesman.employeeCode,
                                icon: Icons.numbers),
                        ]),
                      ],
                      if (detail.isApproved) ...[
                        SizedBox(height: Responsive.h(14)),
                        _DetailSection(title: 'Approval', rows: [
                          _Row(
                            'Approved By',
                            detail.approvedByDetails.name.isNotEmpty
                                ? detail.approvedByDetails.name
                                : detail.approvedBy,
                            icon: Icons.check_circle_outline,
                          ),
                          if (detail.approvedAt.isNotEmpty)
                            _Row('Approved At', detail.approvedAt, icon: Icons.event_outlined),
                          if (detail.approvalNotes.isNotEmpty)
                            _Row('Notes', detail.approvalNotes, icon: Icons.info_outline),
                        ]),
                      ],
                      if (detail.quotation.exists) ...[
                        SizedBox(height: Responsive.h(14)),
                        _DetailSection(title: 'Linked Quotation', rows: [
                          _Row('Quotation No.', detail.quotation.quotationNumber,
                              icon: Icons.description_outlined),
                          _Row('Status', detail.quotation.status, icon: Icons.flag_outlined),
                        ]),
                      ],
                      SizedBox(height: Responsive.h(20)),
                      _buildItemsTable(detail, number),
                      SizedBox(height: Responsive.h(16)),
                      _buildSummary(context, detail, number),
                      if (detail.payments.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(14)),
                        _buildPayments(detail),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      Responsive.w(18), 0, Responsive.w(18), Responsive.h(18)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.share_outlined,
                            tooltip: 'Share',
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: _buildShareText(detail)));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Estimate summary copied to clipboard')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(10)),
                      _buildActionBar(context, detail, isBusy),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(EstimateDetailModel detail) {
    return Column(
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
                  Text(detail.estimateNumber, style: AppTextStyles.h3()),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Date', style: AppTextStyles.caption()),
                  Text(detail.dateRaw, style: AppTextStyles.h3()),
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
              color: _statusColor(detail.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(detail.status),
              style: AppTextStyles.bodyBold(color: _statusColor(detail.status)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable(EstimateDetailModel detail, NumberFormat number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Items', style: AppTextStyles.h3()),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(10), vertical: Responsive.h(4)),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Total Items: ${detail.items.length}',
                  style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(12)),
        if (detail.items.isEmpty)
          Container(
            padding: EdgeInsets.all(Responsive.w(14)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('No items on this estimate.', style: AppTextStyles.caption()),
          )
        else
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
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceAlt),
                headingTextStyle: AppTextStyles.bodyBold(),
                dataTextStyle: AppTextStyles.body(),
                columnSpacing: 18,
                columns: const [
                  DataColumn(label: Text('Sl.No')),
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Size')),
                  DataColumn(label: Text('Qty'), numeric: true),
                  DataColumn(label: Text('Rate'), numeric: true),
                  DataColumn(label: Text('Amount'), numeric: true),
                  DataColumn(label: Text('Incentive'), numeric: true),
                ],
                rows: detail.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return DataRow(cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(Text(item.productName)),
                    DataCell(Text(item.productSize.isEmpty ? '-' : item.productSize)),
                    DataCell(Text(number.format(item.quantity))),
                    DataCell(Text(number.format(item.rate))),
                    DataCell(Text(currencyFmt.f(item.amount),
                        style: AppTextStyles.bodyBold())),
                    DataCell(Text(
                      item.isIncentiveEligible ? currencyFmt.f(item.incentiveAmount) : '-',
                      style: AppTextStyles.bodyBold(color: AppColors.success),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }



  Widget _buildSummary(BuildContext context, EstimateDetailModel detail, NumberFormat number) {
    final canManagePayment = detail.isPendingApproval;

    return Container(
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', currencyFmt.f(detail.subtotal)),
          SizedBox(height: Responsive.h(6)),
          _summaryRow('Handling Charge', currencyFmt.f(detail.handlingCharge)),
          SizedBox(height: Responsive.h(6)),
          _summaryRow('Total Sqrft', number.format(detail.totalSquareFeet)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: AppTextStyles.h3()),
              Text(currencyFmt.f(detail.grandTotal),
                  style: AppTextStyles.h2(color: AppColors.primary)),
            ],
          ),
          if (detail.hasDiscount) ...[
            SizedBox(height: Responsive.h(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${detail.discountTypeLabel.isEmpty ? detail.discountType : detail.discountTypeLabel})',
                  style: AppTextStyles.body(),
                ),
                Text('- ${currencyFmt.f(detail.discountAmount)}',
                    style: AppTextStyles.bodyBold(color: Colors.red)),
              ],
            ),
            SizedBox(height: Responsive.h(6)),
            _summaryRow('Amount After Discount', currencyFmt.f(detail.amountAfterDiscount)),
          ],
          SizedBox(height: Responsive.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid', style: AppTextStyles.body()),
              Text(currencyFmt.f(detail.totalPaid),
                  style: AppTextStyles.bodyBold(color: AppColors.success)),
            ],
          ),
          if (canManagePayment && detail.balanceAmount > 0) ...[
            SizedBox(height: Responsive.h(6)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showAddPaymentDialog(context, detail),
                icon: const Icon(Icons.payments_outlined, size: 16),
                label: const Text('Add Payment'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Balance Amount', style: AppTextStyles.h3()),
              Text(
                currencyFmt.f(detail.balanceAmount),
                style: AppTextStyles.h2(
                    color: detail.balanceAmount > 0 ? Colors.red : AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildPayments(EstimateDetailModel detail) {
    return _DetailSection(
      title: 'Payments',
      rows: detail.payments
          .map((p) => _Row(
        p.method.isEmpty ? 'Payment' : p.method,
        '${currencyFmt.f(p.amount)}${p.date.isNotEmpty ? ' · ${p.date}' : ''}',
        icon: Icons.payments_outlined,
      ))
          .toList(),
    );
  }

  Row _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: AppTextStyles.bodyBold(color: Colors.black)),
      ],
    );
  }

  String _buildShareText(EstimateDetailModel detail) {
    final buffer = StringBuffer()
      ..writeln('Estimate ${detail.estimateNumber}')
      ..writeln('Customer: ${detail.customerName}')
      ..writeln('Phone: ${detail.customerPhone}')
      ..writeln('Date: ${detail.dateRaw}')
      ..writeln('---');
    for (final item in detail.items) {
      buffer.writeln(
          '${item.productName} x ${item.quantity.toStringAsFixed(0)} = ${currencyFmt.f(item.amount)}');
    }
    buffer
      ..writeln('---')
      ..writeln('Handling Charge: ${currencyFmt.f(detail.handlingCharge)}')
      ..writeln('Grand Total: ${currencyFmt.f(detail.grandTotal)}');
    if (detail.hasDiscount) {
      buffer.writeln(
          'Discount (${detail.discountTypeLabel.isEmpty ? detail.discountType : detail.discountTypeLabel}): - ${currencyFmt.f(detail.discountAmount)}');
      buffer.writeln('Amount After Discount: ${currencyFmt.f(detail.amountAfterDiscount)}');
    }
    buffer
      ..writeln('Total Paid: ${currencyFmt.f(detail.totalPaid)}')
      ..writeln('Balance: ${currencyFmt.f(detail.balanceAmount)}')
      ..writeln('Status: ${detail.status}');
    return buffer.toString();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return Colors.red;
      case 'despatched':
        return AppColors.primary;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }

  Future<void> _showRejectDialog(BuildContext context, EstimateDetailModel detail) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Estimate'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Why is this estimate being rejected?',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Reason is required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(reasonController.text.trim());
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      bloc.add(OwnerEstimateRejectRequested(
        OwnerRejectEstimateRequest(id: detail.id, rejectionNotes: result),
      ));
    }
  }
  Widget _buildActionBar(BuildContext context, EstimateDetailModel detail, bool isBusy) {
    if (detail.isPendingApproval) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isBusy ? null : () => _showRejectDialog(context, detail),
              child: const Text('Reject'),
            ),
          ),
          SizedBox(width: Responsive.w(10)),
          Expanded(
            child: PrimaryButton(
              label: isBusy ? 'Please wait...' : 'Approve',
              height: 48,
              onPressed: isBusy ? null : () => _showApproveDialog(context, detail),
            ),
          ),
        ],
      );
    }

    if (detail.status.toLowerCase() == 'rejected') {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: null,
        child: const Text('Rejected'),
      );
    }

    // APPROVED — not despatched yet: only the despatch button shows here.
    if (detail.status.toLowerCase() == 'approved') {
      return PrimaryButton(
        label: 'Send to Despatch',
        height: 48,
        onPressed: () => _openDespatchSheet(context, detail),
      );
    }

    // DESPATCHED (or any other status) — read-only status pill.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(_statusLabel(detail.status),
          style: AppTextStyles.bodyBold(color: AppColors.success)),
    );
  }

  /// Pushes the despatch-sheet creation screen for [detail.id]. That screen
  /// pops with `true` once a despatch is successfully created, so on return
  /// we reload the estimate detail to pick up the new status.
  Future<void> _openDespatchSheet(BuildContext context, EstimateDetailModel detail) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(estimateId: detail.id),
      ),
    );

    if (created == true) {
      bloc.add(OwnerEstimateDetailLoadRequested(detail.id));
    }
  }
  Future<void> _showApproveDialog(BuildContext context, EstimateDetailModel detail) async {
    final bloc = context.read<OwnerEstimateDetailBloc>();
    final formKey = GlobalKey<FormState>();

    final handlingCtrl =
    TextEditingController(text: detail.handlingCharge > 0 ? detail.handlingCharge.toStringAsFixed(0) : '');
    final notesCtrl = TextEditingController();
    String discountType = 'none'; // none | percentage | flat
    final discountValueCtrl = TextEditingController();
    final discountNotesCtrl = TextEditingController();
    final paymentAmountCtrl = TextEditingController();
    String paymentMethod = 'cash'; // cash | online | cheque | bank_transfer
    final paymentRefCtrl = TextEditingController();
    DateTime? paymentDate;
    final paymentNotesCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return AlertDialog(
              title: const Text('Approve Estimate'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: handlingCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Handling Charge (optional)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Approval Notes (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Discount', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: discountType,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'none', child: Text('No discount')),
                            DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                            DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                          ],
                          onChanged: (v) => setLocal(() => discountType = v ?? 'none'),
                        ),
                        if (discountType != 'none') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: discountValueCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              labelText: discountType == 'percentage'
                                  ? 'Discount %'
                                  : 'Discount Amount',
                              prefixText: discountType == 'flat' ? '₹ ' : null,
                              suffixText: discountType == 'percentage' ? '%' : null,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (discountType == 'none') return null;
                              if (v == null || v.trim().isEmpty) return 'Required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: discountNotesCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Discount Notes (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text('Initial Payment (optional)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: paymentAmountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Amount Received',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'cash', child: Text('Cash')),
                            DropdownMenuItem(value: 'online', child: Text('Online')),
                            DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                            DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                          ],
                          onChanged: (v) => setLocal(() => paymentMethod = v ?? 'cash'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: paymentRefCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Payment Reference (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setLocal(() => paymentDate = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Payment Date (optional)',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(paymentDate == null
                                ? 'Select date'
                                : DateFormat('yyyy-MM-dd').format(paymentDate!)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: paymentNotesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Payment Notes (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final request = OwnerApproveEstimateRequest(
                      estimateId: detail.id,
                      handlingCharge: handlingCtrl.text.trim().isEmpty
                          ? null
                          : double.tryParse(handlingCtrl.text.trim()),
                      approvalNotes:
                      notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      discountType: discountType == 'none' ? null : discountType,
                      discountValue: discountType == 'none'
                          ? null
                          : double.tryParse(discountValueCtrl.text.trim()),
                      discountNotes: discountNotesCtrl.text.trim().isEmpty
                          ? null
                          : discountNotesCtrl.text.trim(),
                      paymentAmount: paymentAmountCtrl.text.trim().isEmpty
                          ? null
                          : double.tryParse(paymentAmountCtrl.text.trim()),
                      paymentMethod:
                      paymentAmountCtrl.text.trim().isEmpty ? null : paymentMethod,
                      paymentReference: paymentRefCtrl.text.trim().isEmpty
                          ? null
                          : paymentRefCtrl.text.trim(),
                      paymentDate: paymentDate == null
                          ? null
                          : DateFormat('yyyy-MM-dd').format(paymentDate!),
                      paymentNotes: paymentNotesCtrl.text.trim().isEmpty
                          ? null
                          : paymentNotesCtrl.text.trim(),
                    );

                    Navigator.of(dialogContext).pop();
                    bloc.add(OwnerEstimateApproveRequested(request));
                  },
                  child: const Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _Row {
  final String label;
  final String value;
  final IconData? icon;
  _Row(this.label, this.value, {this.icon});
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

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

class _CurrencyFmt {
  const _CurrencyFmt();
  String f(double v) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
      .format(v);
}
/// Records a payment against this bill (pending or approved). Reuses the
/// same POST /estimates/approve endpoint as discount/approve — only
/// estimateId + payment fields are set, so every other field (handling
/// charge, discount, approval notes) is left untouched server-side,
/// PROVIDED your backend doesn't treat any call to this endpoint as an
/// implicit approval. Verify that before relying on this for pending bills.
Future<void> _showAddPaymentDialog(BuildContext context, EstimateDetailModel detail) async {
  const currencyFmt = _CurrencyFmt(); //
  final bloc = context.read<OwnerEstimateDetailBloc>();
  final formKey = GlobalKey<FormState>();

  final amountCtrl = TextEditingController();
  String paymentMethod = 'cash'; // cash | online | cheque | bank_transfer
  final refCtrl = TextEditingController();
  DateTime? paymentDate;
  final notesCtrl = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setLocal) {
          return AlertDialog(
            title: const Text('Add Payment'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Due: ${currencyFmt.f(detail.balanceAmount)}',
                      style: AppTextStyles.bodyBold(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Amount Received',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'online', child: Text('Online')),
                        DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                        DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                      ],
                      onChanged: (v) => setLocal(() => paymentMethod = v ?? 'cash'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: refCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Payment Reference (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setLocal(() => paymentDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Payment Date (optional)',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(paymentDate == null
                            ? 'Select date'
                            : DateFormat('yyyy-MM-dd').format(paymentDate!)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  // Only estimateId + payment fields are set — handling
                  // charge, discount, and approval notes stay untouched.
                  final request = OwnerApproveEstimateRequest(
                    estimateId: detail.id,
                    paymentAmount: double.parse(amountCtrl.text.trim()),
                    paymentMethod: paymentMethod,
                    paymentReference: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
                    paymentDate: paymentDate == null
                        ? null
                        : DateFormat('yyyy-MM-dd').format(paymentDate!),
                    paymentNotes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );
                  Navigator.of(dialogContext).pop();
                  bloc.add(OwnerEstimateApproveRequested(request));
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}