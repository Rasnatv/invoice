
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/owner_quotataionupdateservice.dart';
import 'package:tileshop/ui/owner/widget/ownerquoattionsdetailscreenwidget.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_bloc.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_event.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/owner_estimateshimmer.dart';
import 'ownerquotationeditscreen.dart';

const Color _redColor = Color(0xFFDC2626);

class OwnerQuotationDetailsScreen extends StatelessWidget {
  const OwnerQuotationDetailsScreen({
    super.key,
    required this.quotationId,
    this.isSalesmanQuotation,
  });

  final String quotationId;

  /// true  = opened from "Salesman Quotations" tab -> Approve + Reject
  /// false = opened from "My Quotations" tab       -> Approve + Cancel
  /// null  = unknown, falls back to the creator's role
  final bool? isSalesmanQuotation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerQuotationDetailBloc()
        ..add(OwnerQuotationDetailRequested(quotationId)),
      child: OwnerQuotationDetailsView(
        quotationId: quotationId,
        isSalesmanQuotation: isSalesmanQuotation,
      ),
    );
  }
}

class OwnerQuotationDetailsView extends StatefulWidget {
  const OwnerQuotationDetailsView({
    super.key,
    required this.quotationId,
    this.isSalesmanQuotation,
  });
  final String quotationId;
  final bool? isSalesmanQuotation;

  @override
  State<OwnerQuotationDetailsView> createState() =>
      OwnerQuotationDetailsViewState();
}

class OwnerQuotationDetailsViewState extends State<OwnerQuotationDetailsView> {
  late final OwnerQuotationDetailBloc detailBloc;

  /// Becomes true when approve / reject / cancel / edit succeeds.
  /// It is returned via Navigator.pop so the previous screen can reload.
  bool didChange = false;

  /// Prevents double taps while a PDF / Excel file is being generated.
  bool exporting = false;

  static const _appBarSpinner = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  @override
  void initState() {
    super.initState();
    detailBloc = context.read<OwnerQuotationDetailBloc>();
  }

  @override
  void dispose() {
    if (!detailBloc.isClosed) {
      detailBloc.add(const OwnerQuotationDetailCleared());
    }
    super.dispose();
  }

  /// Manual refresh (pull-to-refresh).
  Future<void> refresh() async {
    detailBloc.add(OwnerQuotationDetailRequested(widget.quotationId));

    await detailBloc.stream
        .firstWhere(
          (s) =>
      s.detailStatus != OwnerQuotationDetailStatus.loading &&
          s.detailStatus != OwnerQuotationDetailStatus.initial,
    )
        .timeout(const Duration(seconds: 20),
        onTimeout: () => detailBloc.state);
  }

  bool checkIsOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  /// Shows whatever message the backend sent in a plain dialog.
  Future<void> showBackendMessage(String? message,
      {bool isError = false}) async {
    if (message == null || message.trim().isEmpty) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isError ? 'Error' : 'Success',
            style: AppTextStyles.bodyBold()),
        content: Text(message, style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('OK',
                style: AppTextStyles.bodyBold(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Export (PDF / Excel / Copy text)
  // ---------------------------------------------------------------------

  Future<void> exportQuotation(QuotationDetailModel q, String type) async {
    if (exporting) return;
    final showIncentive = !checkIsOwner(q);

    setState(() => exporting = true);
    try {
      if (type == 'pdf') {
        await QuotationExportService.sharePdf(q, showIncentive: showIncentive);
      } else if (type == 'excel') {
        await QuotationExportService.shareExcel(q,
            showIncentive: showIncentive);
      } else {
        await Clipboard.setData(
          ClipboardData(
            text: buildShareText(
              q,
              NumberFormat.currency(
                  locale: 'en_IN', symbol: '₹', decimalDigits: 0),
              NumberFormat.decimalPattern('en_IN'),
            ),
          ),
        );
      }
    } catch (e) {
      await showBackendMessage('Export failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  Future<void> showExportSheet(QuotationDetailModel q) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                const Icon(Icons.picture_as_pdf_rounded, color: _redColor),
                title: Text('Share as PDF', style: AppTextStyles.bodyBold()),
                onTap: () => Navigator.of(sheetContext).pop('pdf'),
              ),
              ListTile(
                leading: Icon(Icons.grid_on_rounded, color: AppColors.success),
                title: Text('Share as Excel', style: AppTextStyles.bodyBold()),
                onTap: () => Navigator.of(sheetContext).pop('excel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice != null && mounted) {
      await exportQuotation(q, choice);
    }
  }

  Future<void> openEditScreen(QuotationDetailModel q) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerQuotationEditScreen(estimate: q),
      ),
    );

    if (saved == true && mounted) {
      didChange = true;
      detailBloc.add(OwnerQuotationDetailRequested(widget.quotationId));
    }
  }

  Future<void> showApproveDialog(QuotationDetailModel q) async {
    final request =
    await showApproveQuotationDialog(context, q, widget.quotationId);
    if (request == null || !mounted) return;
    detailBloc.add(OwnerQuotationApproveRequested(request));
  }

  // ---------------------------------------------------------------------
  // Reject dialog  (POST /quotations/reject { id, rejection_notes })
  //
  // The TextEditingController lives inside _RejectDialog (a
  // StatefulWidget), so Flutter disposes it only after the dialog's
  // closing animation has finished. This avoids
  // "A TextEditingController was used after being disposed".
  // ---------------------------------------------------------------------

  Future<void> showRejectDialog() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );

    if (reason == null || reason.isEmpty || !mounted) return;
    detailBloc.add(OwnerQuotationRejectRequested(
      id: widget.quotationId,
      rejectionNotes: reason,
    ));
  }

  // ---------------------------------------------------------------------
  // Cancel confirmation  (POST /quotations/cancel { id })
  // ---------------------------------------------------------------------

  Future<void> showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Quotation', style: AppTextStyles.bodyBold()),
        content: Text(
          'Are you sure you want to cancel this quotation?',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('No',
                style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _redColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Yes, Cancel',
                style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    detailBloc.add(OwnerQuotationCancelRequested(widget.quotationId));
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final money =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final number = NumberFormat.decimalPattern('en_IN');

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(didChange);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Owner Quotation Details', style: AppTextStyles.h6()),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              BlocBuilder<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
                buildWhen: (prev, curr) => prev.detail != curr.detail,
                builder: (context, state) {
                  final q = state.detail;
                  if (q == null) return const SizedBox.shrink();

                  final status = q.status.toLowerCase().trim();
                  final hideEditIcon = status.contains('approv') ||
                      status.contains('cancel') ||
                      status.contains('reject');

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Share as PDF',
                        icon: exporting
                            ? _appBarSpinner
                            : const Icon(Icons.picture_as_pdf_rounded),
                        onPressed:
                        exporting ? null : () => exportQuotation(q, 'pdf'),
                      ),
                      IconButton(
                        tooltip: 'Share as Excel',
                        icon: const Icon(Icons.grid_on_rounded),
                        onPressed: exporting
                            ? null
                            : () => exportQuotation(q, 'excel'),
                      ),
                      if (!hideEditIcon)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit Quotation',
                          onPressed: () => openEditScreen(q),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child:
            BlocConsumer<OwnerQuotationDetailBloc, OwnerQuotationDetailState>(
              listenWhen: (previous, current) =>
              previous.approveStatus != current.approveStatus ||
                  previous.actionStatus != current.actionStatus,
              listener: (context, state) async {
                // ---- approve result ----
                if (state.approveStatus ==
                    OwnerQuotationApproveStatus.success) {
                  didChange = true;
                  await showBackendMessage(state.approveMessage);
                  if (mounted) {
                    detailBloc.add(const OwnerQuotationApproveResultConsumed());
                  }
                } else if (state.approveStatus ==
                    OwnerQuotationApproveStatus.failure) {
                  await showBackendMessage(state.approveError, isError: true);
                  if (mounted) {
                    detailBloc.add(const OwnerQuotationApproveResultConsumed());
                  }
                }

                // ---- reject / cancel result ----
                if (state.actionStatus == OwnerQuotationActionStatus.success) {
                  didChange = true;
                  await showBackendMessage(state.actionMessage);
                  if (mounted) {
                    detailBloc.add(const OwnerQuotationActionResultConsumed());
                  }
                } else if (state.actionStatus ==
                    OwnerQuotationActionStatus.failure) {
                  await showBackendMessage(state.actionError, isError: true);
                  if (mounted) {
                    detailBloc.add(const OwnerQuotationActionResultConsumed());
                  }
                }
              },
              builder: (context, state) {
                // ---- loading skeleton ----
                if ((state.detailStatus == OwnerQuotationDetailStatus.loading ||
                    state.detailStatus ==
                        OwnerQuotationDetailStatus.initial) &&
                    state.detail == null) {
                  return ShimmerListPlaceholder(
                    itemCount: 5,
                    padding: listPadding,
                    separatorHeight: Responsive.h(10),
                    itemBuilder: (context, i) => const _DetailCardSkeleton(),
                  );
                }

                // ---- error ----
                if (state.detailStatus == OwnerQuotationDetailStatus.failure) {
                  return RefreshIndicator(
                    onRefresh: refresh,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                          child: _ErrorView(
                            message:
                            state.detailError ?? 'Failed to load quotation.',
                            onRetry: () => detailBloc.add(
                                OwnerQuotationDetailRequested(
                                    widget.quotationId)),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final q = state.detail;
                if (q == null) {
                  return RefreshIndicator(
                    onRefresh: refresh,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: Text('No data found.',
                                style: AppTextStyles.subtitle()),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // ---------------- status logic ----------------
                final status = q.status.toLowerCase().trim();

                // Used for hiding incentive figures on owner-created quotations.
                final isOwner = checkIsOwner(q);

                // Which tab was it opened from? Falls back to creator's role.
                final isSalesmanQuotation =
                    widget.isSalesmanQuotation ?? !isOwner;

                final isApproved = status.contains('approv');
                final isCancelled = status.contains('cancel');
                final isRejected = status.contains('reject');
                final isFinal = isApproved || isCancelled || isRejected;

                // Adjust to the exact status strings your API returns.
                const approvableStatuses = {
                  'draft',
                  'send',
                  'sent',
                  'submitted',
                  'pending',
                };
                final showApproveButton =
                    !isFinal && approvableStatuses.contains(status);

                // Salesman's quotation -> owner can REJECT it.
                final showRejectButton = isSalesmanQuotation && !isFinal;

                // Owner's own quotation -> owner can CANCEL it.
                final showCancelButton = !isSalesmanQuotation && !isFinal;

                final isApproving = state.approveStatus ==
                    OwnerQuotationApproveStatus.inProgress;
                final isRejecting =
                    state.actionStatus == OwnerQuotationActionStatus.inProgress &&
                        state.actionType == OwnerQuotationActionType.reject;
                final isCancelling =
                    state.actionStatus == OwnerQuotationActionStatus.inProgress &&
                        state.actionType == OwnerQuotationActionType.cancel;
                final isBusy = isApproving || isRejecting || isCancelling;

                final hasAnyMrp = q.items.any((i) => i.mrp > 0);
                final hasAnyCompany =
                q.items.any((i) => i.companyName.trim().isNotEmpty);
                final hasBoxQty = q.items.any((i) => i.boxQuantity > 0);
                final hasPieceQty = q.items.any((i) => i.pieceQuantity > 0);

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: listPadding,
                          children: [
                            QuotationHeader(q: q),
                            SizedBox(height: Responsive.h(14)),

                            if (q.notes.isNotEmpty) ...[
                              DetailSection(
                                title: 'Notes',
                                icon: Icons.sticky_note_2_outlined,
                                rows: [
                                  DetailRow('Notes', q.notes,
                                      icon: Icons.sticky_note_2_outlined),
                                ],
                              ),
                              SizedBox(height: Responsive.h(14)),
                            ],

                            DetailSection(
                              title: 'Customer Details',
                              icon: Icons.groups_2_outlined,
                              rows: [
                                DetailRow('Name', q.customer.name,
                                    icon: Icons.groups_2_outlined),
                                DetailRow('Phone', q.customer.phone,
                                    icon: Icons.phone_outlined),
                                DetailRow('Email', q.customer.email,
                                    icon: Icons.email_outlined),
                                DetailRow('Address', q.customer.address,
                                    icon: Icons.location_on_outlined),
                              ],
                            ),
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Contractor Details',
                              icon: Icons.engineering_outlined,
                              rows: [
                                DetailRow('Name', q.contractor.name,
                                    icon: Icons.person_outline),
                                DetailRow('Mobile', q.contractor.mobile,
                                    icon: Icons.phone_outlined),
                                DetailRow('Email', q.contractor.email,
                                    icon: Icons.email_outlined),
                              ],
                            ),
                            if (q.salesman.employeeCode.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(14)),
                              DetailSection(
                                title: 'Salesman',
                                icon: Icons.badge_outlined,
                                rows: [
                                  DetailRow(
                                      'Created By',
                                      q.createdBy.name.isEmpty
                                          ? '-'
                                          : q.createdBy.name,
                                      icon: Icons.badge_outlined),
                                ],
                              ),
                            ],
                            SizedBox(height: Responsive.h(18)),

                            // ---- Items ----
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const QSectionHeader('Items'),
                                QStatusPill(
                                  label:
                                  '${q.itemsCount} ${q.itemsCount == 1 ? 'item' : 'items'}',
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.h(10)),
                            InvoiceTable(
                              items: q.items,
                              showCompany: hasAnyCompany,
                              showMrp: hasAnyMrp,
                              showBox: hasBoxQty,
                              showPiece: hasPieceQty,
                              showIncentive: !isOwner,
                              currency: currency,
                              number: number,
                            ),
                            SizedBox(height: Responsive.h(14)),

                            // ---- Summary ----
                            TotalsCard(q: q, money: money, number: number),

                            // ---- Payments ----
                            if (q.payments.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(14)),
                              PaymentsCard(q: q, money: money),
                            ],

                            // ---- Total incentive (hidden for Owner) ----
                            if (!isOwner) ...[
                              SizedBox(height: Responsive.h(14)),
                              IncentiveCard(
                                amountText: currency.format(
                                  q.items.fold<double>(
                                      0, (s, i) => s + i.incentiveAmount),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ---- Bottom action bar ----
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      padding: EdgeInsets.fromLTRB(Responsive.w(20),
                          Responsive.h(10), Responsive.w(20), Responsive.h(14)),
                      child: Builder(
                        builder: (context) {
                          final buttonHeight = Responsive.h(48);
                          final buttonShape = RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14));

                          Widget primaryArea() {
                            if (isApproved) {
                              return _StatusBanner(
                                height: buttonHeight,
                                icon: Icons.check_circle_rounded,
                                label: 'Quotation Approved',
                                color: AppColors.success,
                              );
                            }
                            if (isCancelled) {
                              return _StatusBanner(
                                height: buttonHeight,
                                icon: Icons.cancel_rounded,
                                label: 'Quotation Cancelled',
                                color: _redColor,
                              );
                            }
                            if (isRejected) {
                              return _StatusBanner(
                                height: buttonHeight,
                                icon: Icons.block_rounded,
                                label: 'Quotation Rejected',
                                color: _redColor,
                              );
                            }
                            if (showApproveButton) {
                              return SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: buttonShape,
                                  ),
                                  onPressed:
                                  isBusy ? null : () => showApproveDialog(q),
                                  child: Text(
                                    isApproving
                                        ? 'Approving...'
                                        : 'Approve Quotation',
                                    style: AppTextStyles.bodyBold(
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final hasSecondaryRow =
                              showRejectButton || showCancelButton;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  RoundIconButton(
                                    icon: Icons.share_outlined,
                                    tooltip: 'Share / Export',
                                    onPressed: exporting
                                        ? null
                                        : () => showExportSheet(q),
                                  ),
                                  SizedBox(width: Responsive.w(10)),
                                  Expanded(child: primaryArea()),
                                ],
                              ),
                              if (hasSecondaryRow) ...[
                                SizedBox(height: Responsive.h(10)),
                                Row(
                                  children: [
                                    // Salesman quotation -> Reject
                                    if (showRejectButton)
                                      Expanded(
                                        child: SizedBox(
                                          height: buttonHeight,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _redColor,
                                              side: const BorderSide(
                                                  color: _redColor),
                                              shape: buttonShape,
                                            ),
                                            onPressed: isBusy
                                                ? null
                                                : showRejectDialog,
                                            child: Text(
                                              isRejecting
                                                  ? 'Rejecting...'
                                                  : 'Reject Quotation',
                                              style: AppTextStyles.bodyBold(
                                                  color: _redColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Owner's own quotation -> Cancel
                                    if (showCancelButton)
                                      Expanded(
                                        child: SizedBox(
                                          height: buttonHeight,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _redColor,
                                              side: const BorderSide(
                                                  color: _redColor),
                                              shape: buttonShape,
                                            ),
                                            onPressed: isBusy
                                                ? null
                                                : showCancelDialog,
                                            child: Text(
                                              isCancelling
                                                  ? 'Cancelling...'
                                                  : 'Cancel Quotation',
                                              style: AppTextStyles.bodyBold(
                                                  color: _redColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
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
    );
  }
}

// =====================================================================
// REJECT DIALOG (owns its own TextEditingController)
// =====================================================================

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Flutter calls this only after the dialog is fully removed from the
    // tree, so the TextFormField can never touch a disposed controller.
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Reject Quotation', style: AppTextStyles.bodyBold()),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _reasonController,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            hintText: 'Why is this quotation being rejected?',
            hintStyle: AppTextStyles.body(color: AppColors.textHint),
            errorStyle: AppTextStyles.caption(color: AppColors.error),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(14),
              vertical: Responsive.h(14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Reason is required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel',
              style: AppTextStyles.bodyBold(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _redColor,
            elevation: 0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_reasonController.text.trim());
            }
          },
          child: Text('Reject',
              style: AppTextStyles.bodyBold(color: Colors.white)),
        ),
      ],
    );
  }
}

// =====================================================================
// STATUS BANNER / ERROR / SKELETON (private to this file)
// =====================================================================

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.height,
    required this.icon,
    required this.label,
    required this.color,
  });
  final double height;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: Responsive.w(6)),
          Text(label, style: AppTextStyles.bodyBold(color: color)),
        ],
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
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCardSkeleton extends StatelessWidget {
  const _DetailCardSkeleton();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 13),
          SizedBox(height: 10),
          ShimmerBox(width: 200, height: 11),
          SizedBox(height: 10),
          ShimmerBox(width: 160, height: 11),
        ],
      ),
    );
  }
}