
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/owner_quotataionupdateservice.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_bloc.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_event.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_state.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_bloc.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_event.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/owner_models/owner_quotationapprovemodel.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/primary_button.dart';
import 'ownerquotationeditscreen.dart';

class OwnerQuotationDetailsScreen extends StatelessWidget {
  const OwnerQuotationDetailsScreen({super.key, required this.quotationId});

  final String quotationId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OwnerQuotationDetailBloc()
            ..add(OwnerQuotationDetailRequested(quotationId)),
        ),
        BlocProvider(create: (_) => OwnerCancelQuotationBloc()),
      ],
      child: _OwnerQuotationDetailsView(quotationId: quotationId),
    );
  }
}

class _OwnerQuotationDetailsView extends StatefulWidget {
  const _OwnerQuotationDetailsView({required this.quotationId});
  final String quotationId;

  @override
  State<_OwnerQuotationDetailsView> createState() => _OwnerQuotationDetailsViewState();
}

class _OwnerQuotationDetailsViewState extends State<_OwnerQuotationDetailsView> {
  // Cache the bloc reference while context is still safely attached to
  // the tree. context.read<T>() inside dispose() is unsafe because the
  // element may already be deactivated.
  late final OwnerQuotationDetailBloc _detailBloc;

  /// Set to true whenever an edit / approve / cancel actually succeeded,
  /// so the list screen knows it must refresh when this screen pops.
  bool _didChange = false;

  /// Prevents double taps while a PDF / Excel file is being generated.
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _detailBloc = context.read<OwnerQuotationDetailBloc>();
  }

  @override
  void dispose() {
    _detailBloc.add(const OwnerQuotationDetailCleared());
    super.dispose();
  }

  bool _isOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'send':
      case 'submitted':
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      case 'draft':
        return Colors.blueGrey;
      default:
        return AppColors.primary;
    }
  }

  /// paid -> green, partial -> orange, unpaid -> red.
  Color _balanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _buildShareText(
      QuotationDetailModel q,
      NumberFormat currency,
      NumberFormat number,
      ) {
    final buffer = StringBuffer()
      ..writeln('Quotation ${q.quotationNumber}')
      ..writeln('Customer: ${q.customer.name}')
      ..writeln('Address: ${q.customer.address}')
      ..writeln('Contractor: ${q.contractor.name}')
      ..writeln(
          'Date: ${q.date != null ? DateFormat('dd MMM yyyy').format(q.date!) : q.dateRaw}')
      ..writeln('---');
    for (final item in q.items) {
      buffer.writeln(
        '${item.productName} (${item.productSize}) x ${number.format(item.quantity)} ${item.productUnit} = ${currency.format(item.amount)}',
      );
    }
    buffer
      ..writeln('---')
      ..writeln('Handling Charge: ${currency.format(q.handlingCharge)}');
    if (q.hasDiscount) {
      buffer
        ..writeln('Total: ${currency.format(q.grandTotal)}')
        ..writeln('${q.discountLabel}: - ${currency.format(q.discountAmount)}')
        ..writeln('Amount After Discount: ${currency.format(q.amountAfterDiscount)}');
    }
    buffer.writeln('Grand Total: ${currency.format(q.amountAfterDiscount)}');
    if (q.showPaymentSummary) {
      buffer
        ..writeln('Total Paid: ${currency.format(q.totalPaid)}')
        ..writeln('Balance Amount: ${currency.format(q.balanceAmount)}');
    }
    if (q.salesman.name.isNotEmpty) {
      buffer.writeln('Salesman: ${q.salesman.name}');
    }
    buffer.writeln('Total Sqft: ${number.format(q.totalSquareFeet)}');
    return buffer.toString();
  }

  /// Shows whatever message the backend sent — success or error — in a
  /// plain dialog. No frontend-authored copy, no SnackBar.
  Future<void> _showBackendMessage(String? message, {bool isError = false}) async {
    if (message == null || message.trim().isEmpty) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isError ? 'Error' : 'Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Export (PDF / Excel / Copy text)  — NEW
  // ---------------------------------------------------------------------

  Future<void> _export(QuotationDetailModel q, String type) async {
    if (_exporting) return;
    // Incentive column is hidden when the Owner created the quotation,
    // same rule as the on-screen table.
    final showIncentive = !_isOwner(q);

    setState(() => _exporting = true);
    try {
      if (type == 'pdf') {
        await QuotationExportService.sharePdf(q, showIncentive: showIncentive);
      } else if (type == 'excel') {
        await QuotationExportService.shareExcel(q, showIncentive: showIncentive);
      } else {
        await Clipboard.setData(
          ClipboardData(
            text: _buildShareText(
              q,
              NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0),
              NumberFormat.decimalPattern('en_IN'),
            ),
          ),
        );
      }
    } catch (e) {
      await _showBackendMessage('Export failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Bottom sheet used by the Share button in the bottom bar.
  Future<void> _showExportSheet(QuotationDetailModel q) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
                title: const Text('Download PDF'),
                onTap: () => Navigator.of(sheetContext).pop('pdf'),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined, color: Colors.green),
                title: const Text('Download Excel'),
                onTap: () => Navigator.of(sheetContext).pop('excel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice != null && mounted) {
      await _export(q, choice);
    }
  }

  Future<void> _openEditScreen(QuotationDetailModel q) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationEditScreen(estimate: q),
      ),
    );

    if (saved == true && mounted) {
      _didChange = true;
      context
          .read<OwnerQuotationDetailBloc>()
          .add(OwnerQuotationDetailRequested(widget.quotationId));
    }
  }

  Future<void> _showApproveDialog(QuotationDetailModel q) async {
    final formKey = GlobalKey<FormState>();
    final handlingCtrl = TextEditingController(
      text: q.handlingCharge > 0 ? q.handlingCharge.toStringAsFixed(2) : '',
    );

    String? discountType; // null | 'percentage' | 'fixed'
    final discountValueCtrl = TextEditingController();
    final discountNotesCtrl = TextEditingController();

    final paymentAmountCtrl = TextEditingController();
    String? paymentMethod; // 'cash' | 'online' | 'cheque' | 'credit' | 'bank_transfer'
    final paymentReferenceCtrl = TextEditingController();
    DateTime? paymentDate;
    final paymentNotesCtrl = TextEditingController();

    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    // Pure calculation — no API call. Runs on every keystroke via setDialogState.
    // subtotal + handling - discount = grand total; grand total - payment = balance.
    ({double handling, double discount, double grandTotal, double payment, double balance})
    _calcPreview() {
      final handling = double.tryParse(handlingCtrl.text.trim()) ?? 0;
      final discountValue = double.tryParse(discountValueCtrl.text.trim()) ?? 0;
      final beforeDiscount = q.subtotal + handling;

      double discount = 0;
      if (discountType == 'percentage') {
        discount = beforeDiscount * (discountValue / 100);
      } else if (discountType == 'fixed') {
        discount = discountValue;
      }
      // Never let discount exceed the payable amount.
      if (discount > beforeDiscount) discount = beforeDiscount;

      final grandTotal = beforeDiscount - discount;
      final payment = double.tryParse(paymentAmountCtrl.text.trim()) ?? 0;
      final balance = (grandTotal - payment).clamp(0, double.infinity).toDouble();

      return (handling: handling, discount: discount, grandTotal: grandTotal, payment: payment, balance: balance);
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final preview = _calcPreview();

            return AlertDialog(
              title: const Text('Approve Quotation'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: handlingCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Handling Charge (optional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      // ---- Discount ----
                      const Divider(height: 28),
                      Text('Discount (optional)', style: AppTextStyles.bodyBold()),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: discountType,
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('None')),
                          DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                          DropdownMenuItem(value: 'fixed', child: Text('Flat Amount')),
                        ],
                        onChanged: (v) => setDialogState(() => discountType = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: discountValueCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        enabled: discountType != null,
                        decoration: const InputDecoration(
                          labelText: 'Discount Value',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),

                      // ---- LIVE PREVIEW (above Initial Payment) ----
                      const Divider(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preview', style: AppTextStyles.bodyBold(color: AppColors.primary)),
                            const SizedBox(height: 8),
                            _previewRow('Subtotal', currency.format(q.subtotal)),
                            _previewRow('Handling Charge', currency.format(preview.handling)),
                            if (discountType != null)
                              _previewRow('Discount', '- ${currency.format(preview.discount)}',
                                  color: Colors.red),
                            const Divider(height: 16),
                            _previewRow('Grand Total', currency.format(preview.grandTotal), bold: true),
                            _previewRow('Amount Received', currency.format(preview.payment)),
                            _previewRow(
                              'Balance Due',
                              currency.format(preview.balance),
                              bold: true,
                              color: preview.balance > 0 ? Colors.red : AppColors.success,
                            ),
                          ],
                        ),
                      ),

                      // ---- Initial Payment ----
                      const Divider(height: 28),
                      Text('Initial Payment (optional)', style: AppTextStyles.bodyBold()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: paymentAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Payment Amount',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Select')),
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'online', child: Text('Online')),
                          DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                          DropdownMenuItem(value: 'credit', child: Text('Credit')),
                          DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                        ],
                        onChanged: paymentAmountCtrl.text.trim().isEmpty
                            ? null
                            : (v) => setDialogState(() => paymentMethod = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentReferenceCtrl,
                        enabled: paymentAmountCtrl.text.trim().isNotEmpty,
                        decoration: const InputDecoration(
                          labelText: 'Payment Reference (e.g. TXN No.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: paymentAmountCtrl.text.trim().isEmpty
                            ? null
                            : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: paymentDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() => paymentDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Payment Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            paymentDate == null
                                ? 'Select date'
                                : DateFormat('dd-MM-yyyy').format(paymentDate!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: paymentNotesCtrl,
                        enabled: paymentAmountCtrl.text.trim().isNotEmpty,
                        decoration: const InputDecoration(
                          labelText: 'Payment Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final handlingCharge = double.tryParse(handlingCtrl.text.trim());
    final discountValue = double.tryParse(discountValueCtrl.text.trim());
    final paymentAmount = double.tryParse(paymentAmountCtrl.text.trim());

    final request = QuotationApproveRequest(
      id: widget.quotationId,
      handlingCharge: handlingCharge,
      discountType: discountType,
      discountValue: discountType != null ? discountValue : null,
      discountNotes: discountType != null ? discountNotesCtrl.text : null,
      paymentAmount: paymentAmount,
      paymentMethod: paymentAmount != null ? paymentMethod : null,
      paymentReference: paymentAmount != null ? paymentReferenceCtrl.text : null,
      paymentDate: paymentAmount != null && paymentDate != null
          ? DateFormat('yyyy-MM-dd').format(paymentDate!)
          : null,
      paymentNotes: paymentAmount != null ? paymentNotesCtrl.text : null,
    );

    context.read<OwnerQuotationDetailBloc>().add(OwnerQuotationApproveRequested(request));
  }

  Widget _previewRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body()),
          Text(
            value,
            style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndCancel(QuotationDetailModel q) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Quotation'),
        content: const Text(
          'Are you sure you want to cancel this quotation? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<OwnerCancelQuotationBloc>().add(
        OwnerCancelQuotationRequested(widget.quotationId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    // Totals / payment section shows paise, like the estimate screen.
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(
      child: PopScope(
        // We intercept every pop attempt (system back button, gesture,
        // AppBar back arrow) so we can always hand `_didChange` back to
        // whoever pushed this screen.
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(_didChange);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Owner Quotation Details', style: AppTextStyles.h6()),
            actions: [
              BlocBuilder<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
                buildWhen: (prev, curr) => prev.detail != curr.detail,
                builder: (context, state) {
                  final q = state.detail;
                  if (q == null) return const SizedBox.shrink();

                  final status = q.status.toLowerCase();
                  // Edit icon hidden once a quotation is approved or
                  // cancelled — both are final states.
                  final hideEditIcon = status == 'approved' || status == 'cancelled';

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ---- Export menu (PDF / Excel / Copy) ----
                      PopupMenuButton<String>(
                        icon: _exporting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.file_download_outlined),
                        tooltip: 'Export',
                        enabled: !_exporting,
                        onSelected: (v) => _export(q, v),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'pdf',
                            child: ListTile(
                              leading: Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
                              title: Text('Download PDF'),
                              dense: true,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'excel',
                            child: ListTile(
                              leading: Icon(Icons.table_chart_outlined, color: Colors.green),
                              title: Text('Download Excel'),
                              dense: true,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'copy',
                            child: ListTile(
                              leading: Icon(Icons.copy_outlined),
                              title: Text('Copy as text'),
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                      if (!hideEditIcon)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit Quotation',
                          onPressed: () => _openEditScreen(q),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: BlocListener<OwnerCancelQuotationBloc, OwnerCancelQuotationState>(
              listenWhen: (previous, current) => previous.status != current.status,
              listener: (context, cancelState) async {
                if (cancelState.status == OwnerCancelQuotationStatus.success) {
                  _didChange = true;
                  await _showBackendMessage(cancelState.message);
                  if (mounted) Navigator.of(context).pop(true);
                } else if (cancelState.status == OwnerCancelQuotationStatus.failure) {
                  await _showBackendMessage(cancelState.errorMessage, isError: true);
                  if (mounted) {
                    context
                        .read<OwnerCancelQuotationBloc>()
                        .add(const OwnerCancelQuotationResultConsumed());
                  }
                }
              },
              child: BlocConsumer<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
                listenWhen: (previous, current) =>
                previous.approveStatus != current.approveStatus,
                listener: (context, state) async {
                  if (state.approveStatus == OwnerQuotationApproveStatus.success) {
                    _didChange = true;
                    await _showBackendMessage(state.approveMessage);
                    if (mounted) {
                      context
                          .read<OwnerQuotationDetailBloc>()
                          .add(const OwnerQuotationApproveResultConsumed());
                    }
                  } else if (state.approveStatus == OwnerQuotationApproveStatus.failure) {
                    await _showBackendMessage(state.approveError, isError: true);
                    if (mounted) {
                      context
                          .read<OwnerQuotationDetailBloc>()
                          .add(const OwnerQuotationApproveResultConsumed());
                    }
                  }
                },
                builder: (context, state) {
                  if (state.detailStatus == OwnerQuotationDetailStatus.loading ||
                      state.detailStatus == OwnerQuotationDetailStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.detailStatus == OwnerQuotationDetailStatus.failure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 40, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              state.detailError ?? 'Failed to load quotation.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: 'Retry',
                              height: 44,
                              onPressed: () => context
                                  .read<OwnerQuotationDetailBloc>()
                                  .add(OwnerQuotationDetailRequested(widget.quotationId)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final q = state.detail;
                  if (q == null) {
                    return const Center(child: Text('No data found.'));
                  }

                  final status = q.status.toLowerCase();
                  final isApproved = status == 'approved';
                  final isCancelled = status == 'cancelled';
                  // Approve + Cancel are only meaningful actions for 'draft'
                  // and 'send'.
                  final showActionButtons = status == 'draft' || status == 'send';
                  final isApproving = state.approveStatus == OwnerQuotationApproveStatus.inProgress;
                  // Derived from created_by.role_label / role in the response.
                  // Incentive figures are salesman-facing, so hide them when
                  // the creator is the Owner.
                  final isOwner = _isOwner(q);
                  final hasAnyMrp = q.items.any((i) => i.mrp > 0);
                  final hasAnyCompany = q.items.any((i) => i.companyName.trim().isNotEmpty);
                  final hasBoxQty = q.items.any((i) => i.boxQuantity > 0);
                  final hasPieceQty = q.items.any((i) => i.pieceQuantity > 0);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(Responsive.w(18)),
                          children: [
                            Container(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Quotation No.', style: AppTextStyles.caption()),
                                      Text(q.quotationNumber, style: AppTextStyles.h3()),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Date', style: AppTextStyles.caption()),
                                      Text(
                                        q.date != null
                                            ? DateFormat('dd-MM-yyyy').format(q.date!)
                                            : q.dateRaw,
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
                                  color: _statusColor(q.status).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  q.status.isEmpty ? '-' : q.status,
                                  style: AppTextStyles.bodyBold(color: _statusColor(q.status)),
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.h(16)),

                            _DetailSection(
                              title: 'Customer Details',
                              rows: [
                                _Row('Name', q.customer.name, icon: Icons.groups_2_outlined),
                                _Row('Address', q.customer.address, icon: Icons.location_on_outlined),
                                _Row('Phone', q.customer.phone, icon: Icons.phone_outlined),
                                _Row('Email', q.customer.email, icon: Icons.email_outlined),
                              ],
                            ),
                            SizedBox(height: Responsive.h(14)),
                            _DetailSection(
                              title: 'Contractor Details',
                              rows: [
                                _Row('Name', q.contractor.name, icon: Icons.engineering_outlined),
                                _Row('Mobile', q.contractor.mobile, icon: Icons.phone_outlined),
                                _Row('Email', q.contractor.email, icon: Icons.email),
                              ],
                            ),
                            if (q.salesman.employeeCode.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(14)),
                              _DetailSection(
                                title: 'Salesman',
                                rows: [
                                  _Row('Created By', q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
                                      icon: Icons.person_outline),
                                ],
                              ),
                            ],
                            if (q.notes.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(14)),
                              _DetailSection(
                                title: 'Notes',
                                rows: [_Row('Notes', q.notes, icon: Icons.notes_outlined)],
                              ),
                            ],
                            SizedBox(height: Responsive.h(20)),

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
                                  child: Text(
                                    'Total Items: ${q.itemsCount}',
                                    style: AppTextStyles.bodyBold(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.h(10)),

                            // ---- Excel-style bordered items table ----
                            _InvoiceTable(
                              items: q.items,
                              showCompany: hasAnyCompany,
                              showMrp: hasAnyMrp,
                              showBox: hasBoxQty,
                              showPiece: hasPieceQty,
                              showIncentive: !isOwner,
                              currency: currency,
                              number: number,
                            ),
                            SizedBox(height: Responsive.h(16)),

                            // Totals card
                            _buildTotalsCard(q, money, number),

                            // Payments received (only when the API returns them).
                            if (q.payments.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(14)),
                              _buildPaymentsCard(q, money),
                            ],
                            SizedBox(height: Responsive.h(12)),

                            // Total incentive — hidden when the Owner created it.
                            if (!isOwner)
                              Container(
                                padding: EdgeInsets.all(Responsive.w(14)),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.percent, size: 18, color: AppColors.success),
                                        SizedBox(width: Responsive.w(8)),
                                        Text('Total Incentive', style: AppTextStyles.bodyBold(color: AppColors.success)),
                                      ],
                                    ),
                                    Text(
                                      currency.format(
                                        q.items.fold<double>(0, (s, i) => s + i.incentiveAmount),
                                      ),
                                      style: AppTextStyles.h3(color: AppColors.success),
                                    ),
                                  ],
                                ),
                              ),
                            if (!isOwner) SizedBox(height: Responsive.h(12)),
                          ],
                        ),
                      ),

                      // Bottom action bar.
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            Responsive.w(18), Responsive.h(10), Responsive.w(18), Responsive.h(14)),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          border: Border(top: BorderSide(color: AppColors.border)),
                        ),
                        child: BlocBuilder<OwnerCancelQuotationBloc, OwnerCancelQuotationState>(
                          builder: (context, cancelState) {
                            final isCancelling =
                                cancelState.status == OwnerCancelQuotationStatus.inProgress;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    // Share -> bottom sheet: PDF / Excel / Copy text
                                    _RoundIconButton(
                                      icon: Icons.share_outlined,
                                      tooltip: 'Share / Export',
                                      onPressed: _exporting ? null : () => _showExportSheet(q),
                                    ),
                                    SizedBox(width: Responsive.w(10)),
                                    Expanded(
                                      child: isApproved
                                          ? Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.success.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          'Quotation Approved',
                                          style: AppTextStyles.bodyBold(color: AppColors.success),
                                        ),
                                      )
                                          : isCancelled
                                          ? Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.red.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          'Quotation Cancelled',
                                          style: AppTextStyles.bodyBold(color: Colors.red),
                                        ),
                                      )
                                          : showActionButtons
                                          ? PrimaryButton(
                                        label: isApproving
                                            ? 'Approving...'
                                            : 'Approve Quotation',
                                        height: 48,
                                        onPressed: (isApproving || isCancelling)
                                            ? null
                                            : () => _showApproveDialog(q),
                                      )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                if (showActionButtons) ...[
                                  SizedBox(height: Responsive.h(10)),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: (isApproving || isCancelling)
                                          ? null
                                          : () => _confirmAndCancel(q),
                                      icon: const Icon(Icons.cancel_outlined, size: 18),
                                      label: Text(isCancelling ? 'Cancelling...' : 'Cancel Quotation'),
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }

  /// Totals card:
  ///   Mrp Total / Total Sqft / Subtotal / Handling Charge
  ///   [Total Before Discount / Discount / Amount After Discount]  (only if a discount exists)
  ///   [Total Paid]                                                (only once payments are tracked)
  ///   ── Balance Amount band                                      (only once payments are tracked)
  Widget _buildTotalsCard(QuotationDetailModel q, NumberFormat money, NumberFormat number) {
    final gap = SizedBox(height: Responsive.h(6));
    final balanceColor = q.balanceAmount > 0 ? Colors.red : AppColors.success;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                _totalRow('Mrp Total', number.format(q.mrp)),
                gap,
                _totalRow('Total Sqft', number.format(q.totalSquareFeet)),
                gap,
                _totalRow('Subtotal', money.format(q.subtotal)),
                gap,
                _totalRow('Handling Charge', money.format(q.handlingCharge)),
                if (q.hasDiscount) ...[
                  gap,
                  _totalRow('Total Before Discount', money.format(q.grandTotal)),
                  gap,
                  _totalRow(
                    q.discountLabel,
                    '- ${money.format(q.discountAmount)}',
                    bold: true,
                    valueColor: Colors.red,
                  ),
                  gap,
                  _totalRow(
                    'Grand Total',
                    money.format(q.amountAfterDiscount),
                    bold: true,
                  ),
                ],
                if (q.showPaymentSummary) ...[
                  gap,
                  _totalRow(
                    'Total Paid',
                    money.format(q.totalPaid),
                    bold: true,
                    valueColor: AppColors.success,
                  ),
                ],
              ],
            ),
          ),

          // Balance band — red while money is due, green when fully paid.
          if (q.showPaymentSummary)
            Container(
              width: double.infinity,
              color: balanceColor.withValues(alpha: 0.06),
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text('Balance Amount',
                              style: AppTextStyles.h3(), overflow: TextOverflow.ellipsis),
                        ),
                        if (q.balanceStatus.isNotEmpty) ...[
                          SizedBox(width: Responsive.w(8)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _balanceStatusColor(q.balanceStatus).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _capitalize(q.balanceStatus),
                              style: AppTextStyles.caption(
                                  color: _balanceStatusColor(q.balanceStatus)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(
                    money.format(q.balanceAmount),
                    style: AppTextStyles.h2(color: balanceColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// "Payments" card listing each payment: method, amount · date (+ reference).
  Widget _buildPaymentsCard(QuotationDetailModel q, NumberFormat money) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
              ),
              SizedBox(width: Responsive.w(10)),
              Text('Payments', style: AppTextStyles.bodyBold(color: AppColors.primary)),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          ...q.payments.map((p) {
            final parsed = DateTime.tryParse(p.date);
            final dateText = parsed != null
                ? DateFormat('yyyy-MM-dd').format(parsed)
                : p.date;

            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.h(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textHint),
                  SizedBox(width: Responsive.w(8)),
                  SizedBox(
                    width: 96,
                    child: Text(p.methodLabel, style: AppTextStyles.caption()),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText.isEmpty
                              ? money.format(p.amount)
                              : '${money.format(p.amount)} · $dateText',
                          style: AppTextStyles.bodyBold(),
                        ),
                        if (p.reference.isNotEmpty)
                          Text('Ref: ${p.reference}', style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _totalRow(
      String label,
      String value, {
        bool bold = false,
        Color? valueColor,
      }) {
    final valueStyle = (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
        .copyWith(color: valueColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body()),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

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

// =======================================================================
// Excel-style bordered items table with a Total row
// =======================================================================

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({
    required this.items,
    required this.showCompany,
    required this.showMrp,
    required this.showBox,
    required this.showPiece,
    required this.showIncentive,
    required this.currency,
    required this.number,
  });

  final List<QuotationDetailItem> items;
  final bool showCompany, showMrp, showBox, showPiece, showIncentive;
  final NumberFormat currency;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('No items on this quotation.',
            style: AppTextStyles.caption()),
      );
    }

    // label, width, alignment
    final cols = <(String, double, TextAlign)>[
      ('Sl.No', 50, TextAlign.center),
      ('Item', 170, TextAlign.left),
      if (showCompany) ('Company', 110, TextAlign.left),
      ('Size', 90, TextAlign.center),
      ('Qty', 70, TextAlign.right),
      ('Unit', 60, TextAlign.center),
      if (showBox) ('Box Qty', 70, TextAlign.right),
      if (showPiece) ('Piece Qty', 80, TextAlign.right),
      if (showMrp) ('MRP', 80, TextAlign.right),
      ('Rate', 80, TextAlign.right),
      ('Amount', 100, TextAlign.right),
      if (showIncentive) ('Incentive', 90, TextAlign.right),
    ];

    final amountCol = cols.indexWhere((c) => c.$1 == 'Amount');
    final qtyCol = cols.indexWhere((c) => c.$1 == 'Qty');
    final incentiveCol = cols.indexWhere((c) => c.$1 == 'Incentive');

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive =
    items.fold<double>(0, (s, i) => s + i.incentiveAmount);

    Alignment alignOf(int c) => switch (cols[c].$3) {
      TextAlign.right => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      _ => Alignment.centerLeft,
    };

    Widget headerCell(int c) => Container(
      alignment: alignOf(c),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(8), vertical: Responsive.h(11)),
      child: Text(
        cols[c].$1,
        textAlign: cols[c].$3,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.captionnew().copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );

    Widget dataCell(String text, int c, {bool bold = false, Color? color}) =>
        Container(
          alignment: alignOf(c),
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(8), vertical: Responsive.h(9)),
          child: Text(
            text,
            textAlign: cols[c].$3,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
                .copyWith(color: color),
          ),
        );

    TableRow itemRow(int i, QuotationDetailItem it) {
      final values = <String>[
        '${i + 1}',
        it.productName.isEmpty ? '-' : it.productName,
        if (showCompany) it.companyName.isEmpty ? '-' : it.companyName,
        it.productSize.isEmpty ? '-' : it.productSize,
        number.format(it.quantity),
        it.productUnit,
        if (showBox) it.boxQuantity > 0 ? number.format(it.boxQuantity) : '-',
        if (showPiece)
          it.pieceQuantity > 0 ? number.format(it.pieceQuantity) : '-',
        if (showMrp) it.mrp > 0 ? number.format(it.mrp) : '-',
        number.format(it.rate),
        currency.format(it.amount),
        if (showIncentive)
          it.isIncentiveEligible ? currency.format(it.incentiveAmount) : '-',
      ];
      return TableRow(
        decoration: BoxDecoration(
          color: i.isEven
              ? AppColors.surface
              : AppColors.surfaceAlt.withOpacity(0.4),
        ),
        children: [
          for (var c = 0; c < values.length; c++)
            dataCell(
              values[c],
              c,
              bold: c == amountCol || (showIncentive && c == incentiveCol),
              color: (showIncentive && c == incentiveCol)
                  ? AppColors.success
                  : null,
            ),
        ],
      );
    }

    TableRow totalRow() {
      final values = List<String>.filled(cols.length, '');
      values[1] = 'Total';
      values[qtyCol] = number.format(totalQty);
      values[amountCol] = currency.format(totalAmount);
      if (showIncentive) values[incentiveCol] = currency.format(totalIncentive);
      return TableRow(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          border: Border(
            top: BorderSide(
                color: AppColors.primary.withOpacity(0.3), width: 1.2),
          ),
        ),
        children: [
          for (var c = 0; c < values.length; c++)
            dataCell(
              values[c],
              c,
              bold: true,
              color: c == amountCol
                  ? AppColors.primary
                  : (showIncentive && c == incentiveCol)
                  ? AppColors.success
                  : null,
            ),
        ],
      );
    }

    return Container(
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
          border: TableBorder.all(color: AppColors.border, width: 0.8),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            for (var c = 0; c < cols.length; c++)
              c: FixedColumnWidth(cols[c].$2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.3), width: 1.4),
                ),
              ),
              children: [for (var c = 0; c < cols.length; c++) headerCell(c)],
            ),
            for (var i = 0; i < items.length; i++) itemRow(i, items[i]),
            totalRow(),
          ],
        ),
      ),
    );
  }
}
