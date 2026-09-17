
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_bloc.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_event.dart';
import '../../bloc/ownerbloc/estimatedetail/ownerviewestimatedetail_state.dart';
import '../../models/owner_models/owner_estimateactionmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/primary_button.dart';
import '../../../models/salesmanmodels/estimatedetail.model.dart';
import 'owner_estimateupdation.dart';
import 'ownerdespatchsheet.dart';

// PDF generation + native share sheet (WhatsApp, Email, Drive, etc.)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Noto Sans -> has the ₹ glyph
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Excel export
import 'package:excel/excel.dart' as xls;

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

Future<void> _openUpdateScreen(BuildContext context, EstimateDetailModel detail) async {
  final bloc = context.read<OwnerEstimateDetailBloc>();
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: OwnerEstimateUpdateScreen(detail: detail),
      ),
    ),
  );
}

class _OwnerEstimateDetailView extends StatefulWidget {
  const _OwnerEstimateDetailView({required this.estimateId});
  final String estimateId;

  @override
  State<_OwnerEstimateDetailView> createState() => _OwnerEstimateDetailViewState();
}

class _OwnerEstimateDetailViewState extends State<_OwnerEstimateDetailView> {
  final currencyFmt = const _CurrencyFmt();

  // spinner state while PDF / Excel is being built + handed to the share sheet.
  bool _isGeneratingPdf = false;
  bool _isGeneratingExcel = false;

  bool _isOwner(EstimateDetailModel detail) {
    return detail.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Owner Estimate Details', style: AppTextStyles.h6()),
          actions: [
            // Share as PDF -> native share sheet -> WhatsApp/etc.
            Builder(builder: (context) {
              return IconButton(
                tooltip: 'Share as PDF',
                icon: _isGeneratingPdf
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.picture_as_pdf_rounded),
                onPressed: _isGeneratingPdf
                    ? null
                    : () {
                  final detail = context.read<OwnerEstimateDetailBloc>().state.detail;
                  if (detail == null) {
                    AppSnackbar.error('Estimate data not loaded yet');
                    return;
                  }
                  _generateAndSharePdf(detail, _isOwner(detail));
                },
              );
            }),
            // Share as Excel -> native share sheet -> WhatsApp/etc.
            Builder(builder: (context) {
              return IconButton(
                tooltip: 'Share as Excel',
                icon: _isGeneratingExcel
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.grid_on_rounded),
                onPressed: _isGeneratingExcel
                    ? null
                    : () {
                  final detail = context.read<OwnerEstimateDetailBloc>().state.detail;
                  if (detail == null) {
                    AppSnackbar.error('Estimate data not loaded yet');
                    return;
                  }
                  _generateAndShareExcel(detail, _isOwner(detail));
                },
              );
            }),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<OwnerEstimateDetailBloc, OwnerEstimateDetailState>(
            listener: (context, state) {
              if (state.actionStatus == OwnerEstimateActionStatus.success) {
                AppSnackbar.success(state.actionMessage ?? 'Done');
              } else if (state.actionStatus == OwnerEstimateActionStatus.failure) {
                AppSnackbar.error(state.actionMessage ?? 'Action failed');
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
                            .add(OwnerEstimateDetailLoadRequested(widget.estimateId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final detail = state.detail!;
              final isBusy = state.actionStatus == OwnerEstimateActionStatus.inProgress;
              final isOwner = _isOwner(detail);

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(Responsive.w(18)),
                      children: [
                        _buildHeader(detail),
                        SizedBox(height: Responsive.h(16)),
                        if (detail.notes.isNotEmpty) ...[
                          _DetailSection(
                            title: 'Notes',
                            icon: Icons.sticky_note_2_outlined,
                            rows: [
                              _Row('Notes', detail.notes, icon: Icons.sticky_note_2_outlined),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),
                        ],
                        _DetailSection(
                          title: 'Customer Details',
                          icon: Icons.groups_2_outlined,
                          rows: [
                            _Row('Name', detail.customerName, icon: Icons.groups_2_outlined),
                            _Row('Phone', detail.customerPhone, icon: Icons.phone_outlined),
                            if (detail.customerEmail.isNotEmpty)
                              _Row('Email', detail.customerEmail, icon: Icons.email_outlined),
                            if (detail.customerAddress.isNotEmpty)
                              _Row('Address', detail.customerAddress,
                                  icon: Icons.location_on_outlined),
                          ],
                        ),
                        if (detail.customer.name.isNotEmpty) ...[
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Contractor Details',
                            icon: Icons.person_outline,
                            rows: [
                              _Row('Name', detail.customer.name, icon: Icons.person_outline),
                              _Row('Phone', detail.customer.phone, icon: Icons.phone_outlined),
                              if (detail.customer.email.isNotEmpty)
                                _Row('Email', detail.customer.email, icon: Icons.email_outlined),
                              if (detail.customer.address.isNotEmpty)
                                _Row('Address', detail.customer.address,
                                    icon: Icons.location_on_outlined),
                            ],
                          ),
                        ],
                        if (detail.salesman.name.isNotEmpty) ...[
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Salesman',
                            icon: Icons.badge_outlined,
                            rows: [
                              _Row('Name', detail.salesman.name, icon: Icons.badge_outlined),
                            ],
                          ),
                        ],
                        if (detail.isApproved) ...[
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Approval',
                            icon: Icons.check_circle_outline,
                            rows: [
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
                            ],
                          ),
                        ],
                        if (detail.quotation.exists) ...[
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Linked Quotation',
                            icon: Icons.description_outlined,
                            rows: [
                              _Row('Quotation No.', detail.quotation.quotationNumber,
                                  icon: Icons.description_outlined),
                              _Row('Status', detail.quotation.status, icon: Icons.flag_outlined),
                            ],
                          ),
                        ],
                        SizedBox(height: Responsive.h(20)),
                        _buildItemsTable(detail, number, isOwner),
                        SizedBox(height: Responsive.h(16)),
                        _buildSummary(context, detail, number),
                        if (detail.payments.isNotEmpty) ...[
                          SizedBox(height: Responsive.h(14)),
                          _buildPayments(detail),
                        ],
                        SizedBox(height: Responsive.h(8)),
                      ],
                    ),
                  ),
                  _buildBottomBar(context, detail, isBusy),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------

  Widget _buildHeader(EstimateDetailModel detail) {
    final statusColor = _statusColor(detail.status);
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.07),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rerference NO.',
                        style: AppTextStyles.captionnew().copyWith(letterSpacing: 0.6)),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      detail.estimateNumber,
                      style: AppTextStyles.bodyBold(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DATE', style: AppTextStyles.caption().copyWith(letterSpacing: 0.6)),
                  SizedBox(height: Responsive.h(4)),
                  Text(detail.dateRaw, style: AppTextStyles.bodyBold()),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(detail.status), size: 14, color: statusColor),
                SizedBox(width: Responsive.w(6)),
                Text(
                  _statusLabel(detail.status),
                  style: AppTextStyles.bodyBold(color: statusColor)
                      .copyWith(fontSize: Responsive.sp(12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'despatched':
        return Icons.local_shipping_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  // ---------------------------------------------------------------------
  // Items table (bill-style)
  // ---------------------------------------------------------------------

  Widget _buildItemsTable(EstimateDetailModel detail, NumberFormat number, bool isOwner) {
    final totalQty = detail.items.fold<double>(0, (sum, i) => sum + i.quantity);
    final totalAmount = detail.items.fold<double>(0, (sum, i) => sum + i.amount);
    final totalIncentive = detail.items.fold<double>(
        0, (sum, i) => sum + (i.isIncentiveEligible ? i.incentiveAmount : 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.list_alt_rounded, size: 15, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(8)),
                Text('Items', style: AppTextStyles.h3()),
              ],
            ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  verticalInside: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  bottom: BorderSide(color: AppColors.border),
                ),
                columnWidths: {
                  0: const FixedColumnWidth(36), // Sl.No
                  1: const FixedColumnWidth(160), // Item
                  2: const FixedColumnWidth(130), // Company
                  3: const FixedColumnWidth(90), // Size
                  4: const FixedColumnWidth(70), // Unit
                  5: const FixedColumnWidth(60), // Qty
                  6: const FixedColumnWidth(80), // MRP
                  7: const FixedColumnWidth(80), // Rate
                  8: const FixedColumnWidth(100), // Amount
                  if (!isOwner) 9: const FixedColumnWidth(100), // Incentive
                },
                children: [
                  // ---- Header row ----
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      border: Border(
                        bottom: BorderSide(
                            color: AppColors.primary.withOpacity(0.3), width: 1.4),
                      ),
                    ),
                    children: [
                      _estHeaderCell('Sl.No', align: TextAlign.center),
                      _estHeaderCell('Item'),
                      _estHeaderCell('Company'),
                      _estHeaderCell('Size'),
                      _estHeaderCell('Unit'),
                      _estHeaderCell('Qty', align: TextAlign.right),
                      _estHeaderCell('MRP', align: TextAlign.right),
                      _estHeaderCell('Rate', align: TextAlign.right),
                      _estHeaderCell('Amount', align: TextAlign.right),
                      if (!isOwner) _estHeaderCell('Incentive', align: TextAlign.right),
                    ],
                  ),
                  // ---- Data rows ----
                  for (var i = 0; i < detail.items.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? AppColors.surface
                            : AppColors.surfaceAlt.withOpacity(0.4),
                      ),
                      children: [
                        _estDataCell('${i + 1}', align: TextAlign.center),
                        _estDataCell(detail.items[i].productName),
                        _estDataCell(detail.items[i].companyName.isEmpty
                            ? '-'
                            : detail.items[i].companyName),
                        _estDataCell(detail.items[i].productSize.isEmpty
                            ? '-'
                            : detail.items[i].productSize),
                        _estDataCell(detail.items[i].unitName.isEmpty
                            ? '-'
                            : detail.items[i].unitName),
                        _estDataCell(number.format(detail.items[i].quantity),
                            align: TextAlign.right),
                        _estDataCell(
                            detail.items[i].mrp > 0
                                ? number.format(detail.items[i].mrp)
                                : '-',
                            align: TextAlign.right),
                        _estDataCell(number.format(detail.items[i].rate),
                            align: TextAlign.right),
                        _estDataCell(currencyFmt.f(detail.items[i].amount),
                            align: TextAlign.right, bold: true),
                        if (!isOwner)
                          _estDataCell(
                            detail.items[i].isIncentiveEligible
                                ? currencyFmt.f(detail.items[i].incentiveAmount)
                                : '-',
                            align: TextAlign.right,
                            bold: true,
                            color: AppColors.success,
                          ),
                      ],
                    ),
                  // ---- Totals footer row ----
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      border: Border(
                        top: BorderSide(
                            color: AppColors.primary.withOpacity(0.3), width: 1.2),
                      ),
                    ),
                    children: [
                      _estDataCell(''),
                      _estDataCell('Total', bold: true),
                      _estDataCell(''),
                      _estDataCell(''),
                      _estDataCell(''),
                      _estDataCell(number.format(totalQty),
                          align: TextAlign.right, bold: true),
                      _estDataCell(''),
                      _estDataCell(''),
                      _estDataCell(currencyFmt.f(totalAmount),
                          align: TextAlign.right, bold: true, color: AppColors.primary),
                      if (!isOwner)
                        _estDataCell(currencyFmt.f(totalIncentive),
                            align: TextAlign.right, bold: true, color: AppColors.success),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _estHeaderCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(11)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.captionnew().copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _estDataCell(
      String text, {
        TextAlign align = TextAlign.left,
        bool bold = false,
        Color? color,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(9)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(color: color),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Summary card
  // ---------------------------------------------------------------------

  Widget _buildSummary(BuildContext context, EstimateDetailModel detail, NumberFormat number) {
    final canManagePayment = detail.isPendingApproval;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Column(
              children: [
                _summaryRow('Total Sqrft', number.format(detail.totalSquareFeet)),
                SizedBox(height: Responsive.h(8)),
                _summaryRow('Subtotal', currencyFmt.f(detail.subtotal)),
                SizedBox(height: Responsive.h(8)),
                _summaryRow('Handling Charge', currencyFmt.f(detail.handlingCharge)),
                SizedBox(height: Responsive.h(8)),

                if (detail.hasDiscount) ...[
                  SizedBox(height: Responsive.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Discount (${detail.discountTypeLabel.isEmpty ? detail.discountType : detail.discountTypeLabel})',
                          style: AppTextStyles.body(),
                        ),
                      ),
                      Text('- ${currencyFmt.f(detail.discountAmount)}',
                          style: AppTextStyles.bodyBold(color: Colors.red)),
                    ],
                  ),
                  SizedBox(height: Responsive.h(8)),
                  _summaryRow(
                      'Amount After Discount', currencyFmt.f(detail.amountAfterDiscount)),
                ],
                SizedBox(height: Responsive.h(8)),
                _summaryRow('Total Paid', currencyFmt.f(detail.totalPaid),
                    valueColor: AppColors.success),
                if (canManagePayment && detail.balanceAmount > 0) ...[
                  SizedBox(height: Responsive.h(8)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showAddPaymentDialog(context, detail),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                      label: const Text('Add Payment'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Grand Total strip
          Container(
            width: double.infinity,
            padding:
            EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total', style: AppTextStyles.bodyBold()),
                Text(currencyFmt.f(detail.grandTotal),
                    style: AppTextStyles.h3(color: AppColors.primary)),
              ],
            ),
          ),
          // Balance strip
          Container(
            width: double.infinity,
            padding:
            EdgeInsets.symmetric(horizontal: Responsive.w(16), vertical: Responsive.h(14)),
            decoration: BoxDecoration(
              color: detail.balanceAmount > 0
                  ? Colors.red.withOpacity(0.06)
                  : AppColors.success.withOpacity(0.08),
            ),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPayments(EstimateDetailModel detail) {
    return _DetailSection(
      title: 'Payments',
      icon: Icons.payments_outlined,
      rows: detail.payments
          .map((p) => _Row(
        p.method.isEmpty ? 'Payment' : p.method,
        '${currencyFmt.f(p.amount)}${p.date.isNotEmpty ? ' · ${p.date}' : ''}',
        icon: Icons.receipt_long_outlined,
      ))
          .toList(),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value,
            style: AppTextStyles.bodyBold(color: valueColor ?? Colors.black)),
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
      final companyPart = item.companyName.isNotEmpty ? ' (${item.companyName})' : '';
      final unitPart = item.unitName.isNotEmpty ? ' ${item.unitName}' : '';
      buffer.writeln(
          '${item.productName}$companyPart x ${item.quantity.toStringAsFixed(0)}$unitPart = ${currencyFmt.f(item.amount)}');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Reason is required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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

  // ---------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------

  Widget _buildBottomBar(BuildContext context, EstimateDetailModel detail, bool isBusy) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(18), Responsive.h(14), Responsive.w(18), Responsive.h(18)),
        child: Column(
          children: [
            Row(
              children: [

                if (detail.isPendingApproval) ...[
                  SizedBox(width: Responsive.w(10)),
                  _RoundIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Update',
                    onPressed: () => _openUpdateScreen(context, detail),
                  ),
                ],
              ],
            ),
            SizedBox(height: Responsive.h(10)),
            _buildActionBar(context, detail, isBusy),
          ],
        ),
      ),
    );
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_rounded, size: 18, color: Colors.red),
            SizedBox(width: Responsive.w(6)),
            Text('Rejected', style: AppTextStyles.bodyBold(color: Colors.red)),
          ],
        ),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_statusIcon(detail.status), size: 18, color: AppColors.success),
          SizedBox(width: Responsive.w(6)),
          Text(_statusLabel(detail.status),
              style: AppTextStyles.bodyBold(color: AppColors.success)),
        ],
      ),
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

    final handlingCtrl = TextEditingController(
        text: detail.handlingCharge > 0 ? detail.handlingCharge.toStringAsFixed(0) : '');
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              labelText:
                              discountType == 'percentage' ? 'Discount %' : 'Discount Amount',
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
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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

  // ---------------------------------------------------------------------
  // PDF export + share
  // ---------------------------------------------------------------------

  Future<void> _generateAndSharePdf(EstimateDetailModel d, bool isOwner) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final baseFont = await PdfGoogleFonts.notoSansRegular();
      final boldFont = await PdfGoogleFonts.notoSansBold();

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Estimate Details',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColors.grey400),
            ],
          ),
          build: (context) => [
            _pdfInfoSection(d),
            pw.SizedBox(height: 18),
            pw.Text('Items', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _pdfItemsTable(d, isOwner),
            pw.SizedBox(height: 14),
            _pdfSummarySection(d),
            if (d.payments.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text('Payments',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _pdfPaymentsTable(d),
            ],
          ],
        ),
      );

      final bytes = await pdf.save();

      final safeRef = d.estimateNumber.isNotEmpty
          ? d.estimateNumber.replaceAll(RegExp(r'[^\w\-]'), '_')
          : d.id;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Estimate_$safeRef.pdf');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Estimate - ${d.estimateNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate PDF: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _pdfInfoSection(EstimateDetailModel d) {
    final rows = <List<String>>[
      ['Reference No.', d.estimateNumber],
      ['Date', d.dateRaw],
      ['Status', _statusLabel(d.status)],
      ['Customer Name', d.customerName],
      ['Customer Phone', d.customerPhone],
      if (d.customerEmail.isNotEmpty) ['Customer Email', d.customerEmail],
      if (d.customerAddress.isNotEmpty) ['Customer Address', d.customerAddress],
      if (d.customer.name.isNotEmpty) ['Contractor Name', d.customer.name],
      if (d.customer.phone.isNotEmpty) ['Contractor Phone', d.customer.phone],
      if (d.salesman.name.isNotEmpty) ['Salesman', d.salesman.name],
      if (d.notes.isNotEmpty) ['Notes', d.notes],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows
          .map((r) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 130,
              child: pw.Text(r[0],
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ),
            pw.Expanded(
              child: pw.Text(
                r[1].isEmpty ? '-' : r[1],
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }

  pw.Widget _pdfItemsTable(EstimateDetailModel d, bool isOwner) {
    final headers = [
      '#',
      'Item',
      'Company',
      'Size',
      'Unit',
      'Qty',
      'MRP',
      'Rate',
      'Amount',
      if (!isOwner) 'Incentive',
    ];
    final data = <List<String>>[
      for (var i = 0; i < d.items.length; i++)
        [
          '${i + 1}',
          d.items[i].productName,
          d.items[i].companyName.isEmpty ? '-' : d.items[i].companyName,
          d.items[i].productSize.isEmpty ? '-' : d.items[i].productSize,
          d.items[i].unitName.isEmpty ? '-' : d.items[i].unitName,
          d.items[i].quantity.toStringAsFixed(0),
          d.items[i].mrp > 0 ? d.items[i].mrp.toStringAsFixed(0) : '-',
          d.items[i].rate.toStringAsFixed(0),
          currencyFmt.f(d.items[i].amount),
          if (!isOwner)
            d.items[i].isIncentiveEligible ? currencyFmt.f(d.items[i].incentiveAmount) : '-',
        ],
    ];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle:
      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.centerRight,
        if (!isOwner) 9: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  pw.Widget _pdfSummarySection(EstimateDetailModel d) {
    final rows = <List<String>>[
      ['Subtotal', currencyFmt.f(d.subtotal)],
      ['Handling Charge', currencyFmt.f(d.handlingCharge)],
      if (d.hasDiscount) ...[
        [
          'Discount (${d.discountTypeLabel.isEmpty ? d.discountType : d.discountTypeLabel})',
          '- ${currencyFmt.f(d.discountAmount)}'
        ],
        ['Amount After Discount', currencyFmt.f(d.amountAfterDiscount)],
      ],
      ['Grand Total', currencyFmt.f(d.grandTotal)],
      ['Total Paid', currencyFmt.f(d.totalPaid)],
      ['Balance Amount', currencyFmt.f(d.balanceAmount)],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: rows
          .map((r) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('${r[0]}: ', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(r[1], style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ))
          .toList(),
    );
  }

  pw.Widget _pdfPaymentsTable(EstimateDetailModel d) {
    final headers = ['Method', 'Amount', 'Date'];
    final data = d.payments
        .map((p) => [
      p.method.isEmpty ? 'Payment' : p.method,
      currencyFmt.f(p.amount),
      p.date.isEmpty ? '-' : p.date,
    ])
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle:
      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  // ---------------------------------------------------------------------
  // Excel export + share
  // ---------------------------------------------------------------------

  Future<void> _generateAndShareExcel(EstimateDetailModel d, bool isOwner) async {
    setState(() => _isGeneratingExcel = true);
    try {
      final excelFile = xls.Excel.createExcel();
      const sheetName = 'Estimate';
      final sheet = excelFile[sheetName];
      excelFile.setDefaultSheet(sheetName);

      void addRow(List<dynamic> values) {
        sheet.appendRow(values.map((v) => xls.TextCellValue(v.toString())).toList());
      }

      addRow(['Estimate Details']);
      addRow([]);
      addRow(['Reference No.', d.estimateNumber]);
      addRow(['Date', d.dateRaw]);
      addRow(['Status', _statusLabel(d.status)]);
      addRow(['Customer Name', d.customerName]);
      addRow(['Customer Phone', d.customerPhone]);
      if (d.customerEmail.isNotEmpty) addRow(['Customer Email', d.customerEmail]);
      if (d.customerAddress.isNotEmpty) addRow(['Customer Address', d.customerAddress]);
      if (d.customer.name.isNotEmpty) addRow(['Contractor Name', d.customer.name]);
      if (d.customer.phone.isNotEmpty) addRow(['Contractor Phone', d.customer.phone]);
      if (d.salesman.name.isNotEmpty) addRow(['Salesman', d.salesman.name]);
      if (d.notes.isNotEmpty) addRow(['Notes', d.notes]);
      addRow([]);

      final headers = [
        '#',
        'Item',
        'Company',
        'Size',
        'Unit',
        'Qty',
        'MRP',
        'Rate',
        'Amount',
        if (!isOwner) 'Incentive',
      ];
      addRow(headers);
      for (var i = 0; i < d.items.length; i++) {
        final item = d.items[i];
        addRow([
          i + 1,
          item.productName,
          item.companyName.isEmpty ? '-' : item.companyName,
          item.productSize.isEmpty ? '-' : item.productSize,
          item.unitName.isEmpty ? '-' : item.unitName,
          item.quantity.toStringAsFixed(0),
          item.mrp > 0 ? item.mrp.toStringAsFixed(0) : '-',
          item.rate.toStringAsFixed(0),
          currencyFmt.f(item.amount),
          if (!isOwner) (item.isIncentiveEligible ? currencyFmt.f(item.incentiveAmount) : '-'),
        ]);
      }
      addRow([]);
      addRow(['Subtotal', currencyFmt.f(d.subtotal)]);
      addRow(['Handling Charge', currencyFmt.f(d.handlingCharge)]);
      if (d.hasDiscount) {
        addRow([
          'Discount (${d.discountTypeLabel.isEmpty ? d.discountType : d.discountTypeLabel})',
          '- ${currencyFmt.f(d.discountAmount)}'
        ]);
        addRow(['Amount After Discount', currencyFmt.f(d.amountAfterDiscount)]);
      }
      addRow(['Grand Total', currencyFmt.f(d.grandTotal)]);
      addRow(['Total Paid', currencyFmt.f(d.totalPaid)]);
      addRow(['Balance Amount', currencyFmt.f(d.balanceAmount)]);

      if (d.payments.isNotEmpty) {
        addRow([]);
        addRow(['Payments']);
        addRow(['Method', 'Amount', 'Date']);
        for (final p in d.payments) {
          addRow([
            p.method.isEmpty ? 'Payment' : p.method,
            currencyFmt.f(p.amount),
            p.date.isEmpty ? '-' : p.date,
          ]);
        }
      }

      final bytes = excelFile.save();
      if (bytes == null) throw Exception('Could not generate Excel file');

      final safeRef = d.estimateNumber.isNotEmpty
          ? d.estimateNumber.replaceAll(RegExp(r'[^\w\-]'), '_')
          : d.id;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Estimate_$safeRef.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        text: 'Estimate - ${d.estimateNumber}',
      );
    } catch (e) {
      if (mounted) AppSnackbar.error('Failed to generate Excel file: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingExcel = false);
    }
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
  const _DetailSection({required this.title, required this.rows, this.icon});
  final String title;
  final List<_Row> rows;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(8)),
              ],
              Text(title,
                  style: AppTextStyles.bodyBold(color: AppColors.primary)
                      .copyWith(fontSize: Responsive.sp(13.5))),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          ...rows.map((r) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.icon != null) ...[
                  Icon(r.icon, size: 15, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                ],
                SizedBox(
                  width: r.icon != null ? 86 : 100,
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
  String f(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(v);
}

/// Records a payment against this bill (pending or approved). Reuses the
/// same POST /estimates/approve endpoint as discount/approve — only
/// estimateId + payment fields are set, so every other field (handling
/// charge, discount, approval notes) is left untouched server-side,
/// PROVIDED your backend doesn't treat any call to this endpoint as an
/// implicit approval. Verify that before relying on this for pending bills.
Future<void> _showAddPaymentDialog(BuildContext context, EstimateDetailModel detail) async {
  const currencyFmt = _CurrencyFmt();
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
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