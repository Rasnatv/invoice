import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/owner_quotataionupdateservice.dart';
import 'package:tileshop/ui/owner/widget/ownerquoattionsdetailscreenwidget.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_bloc.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_event.dart';
import '../../bloc/ownerbloc/ownercancel_quotation/ownercancelquotation_state.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_bloc.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_event.dart';
import '../../bloc/ownerbloc/ownerquattaiondetail/ownerviewqtndetail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/owner_dashboardrefresh.dart';
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
      child: OwnerQuotationDetailsView(quotationId: quotationId),
    );
  }
}

class OwnerQuotationDetailsView extends StatefulWidget {
  const OwnerQuotationDetailsView({required this.quotationId});
  final String quotationId;

  @override
  State<OwnerQuotationDetailsView> createState() => OwnerQuotationDetailsViewState();
}

class OwnerQuotationDetailsViewState extends State<OwnerQuotationDetailsView> {
  // Cache the bloc reference while context is still safely attached to
  // the tree. context.read<T>() inside dispose() is unsafe because the
  // element may already be deactivated.
  late final OwnerQuotationDetailBloc detailBloc;


  bool didChange = false;

  /// Prevents double taps while a PDF / Excel file is being generated.
  bool exporting = false;

  @override
  void initState() {
    super.initState();
    detailBloc = context.read<OwnerQuotationDetailBloc>();
  }

  @override
  void dispose() {
    detailBloc.add(const OwnerQuotationDetailCleared());
    super.dispose();
  }

  /// Manual refresh (pull-to-refresh + app bar button).
  /// Fires a reload and waits until the bloc finishes loading so the
  /// RefreshIndicator spinner stays visible for the right duration.
  Future<void> refresh() async {
    detailBloc.add(OwnerQuotationDetailRequested(widget.quotationId));

    await detailBloc.stream
        .firstWhere(
          (s) =>
      s.detailStatus != OwnerQuotationDetailStatus.loading &&
          s.detailStatus != OwnerQuotationDetailStatus.initial,
    )
        .timeout(const Duration(seconds: 20), onTimeout: () => detailBloc.state);
  }

  bool checkIsOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  /// Shows whatever message the backend sent — success or error — in a
  /// plain dialog. No frontend-authored copy, no SnackBar.
  Future<void> showBackendMessage(String? message, {bool isError = false}) async {
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

  Future<void> exportQuotation(QuotationDetailModel q, String type) async {
    if (exporting) return;
    // Incentive column is hidden when the Owner created the quotation,
    // same rule as the on-screen table.
    final showIncentive = !checkIsOwner(q);

    setState(() => exporting = true);
    try {
      if (type == 'pdf') {
        await QuotationExportService.sharePdf(q, showIncentive: showIncentive);
      } else if (type == 'excel') {
        await QuotationExportService.shareExcel(q, showIncentive: showIncentive);
      } else {
        await Clipboard.setData(
          ClipboardData(
            text: buildShareText(
              q,
              NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0),
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

  /// Bottom sheet used by the Share button in the bottom bar.
  Future<void> showExportSheet(QuotationDetailModel q) async {
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
      context
          .read<OwnerQuotationDetailBloc>()
          .add(OwnerQuotationDetailRequested(widget.quotationId));
    }
  }

  Future<void> showApproveDialog(QuotationDetailModel q) async {
    final request = await showApproveQuotationDialog(context, q, widget.quotationId);
    if (request == null || !mounted) return;
    context.read<OwnerQuotationDetailBloc>().add(OwnerQuotationApproveRequested(request));
  }

  Future<void> confirmAndCancel(QuotationDetailModel q) async {
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
        // AppBar back arrow) so we can always hand `didChange` back to
        // whoever pushed this screen.
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(didChange);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Owner Quotation Details', style: AppTextStyles.h6()),
            actions: [
              // Manual refresh — always visible, even while loading / on error.
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
                        icon: exporting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.file_download_outlined),
                        tooltip: 'Export',
                        enabled: !exporting,
                        onSelected: (v) => exportQuotation(q, v),
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
                          onPressed: () => openEditScreen(q),
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
                  didChange = true;
                  await showBackendMessage(cancelState.message);
                  if (mounted) Navigator.of(context).pop(true);
                } else if (cancelState.status == OwnerCancelQuotationStatus.failure) {
                  await showBackendMessage(cancelState.errorMessage, isError: true);
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
                    didChange = true;
                    ownerDataRefresh.value++;   // <-- ADD THIS LINE
                    await showBackendMessage(state.approveMessage);
                    if (mounted) {
                      context
                          .read<OwnerQuotationDetailBloc>()
                          .add(const OwnerQuotationApproveResultConsumed());
                    }
                  } else if (state.approveStatus == OwnerQuotationApproveStatus.failure) {
                    await showBackendMessage(state.approveError, isError: true);
                    if (mounted) {
                      context
                          .read<OwnerQuotationDetailBloc>()
                          .add(const OwnerQuotationApproveResultConsumed());
                    }
                  }
                },
                builder: (context, state) {
                  // Full-screen loader only when there is nothing to show yet.
                  // During a refresh the old data stays on screen (as long as
                  // the bloc keeps `detail` while emitting `loading`).
                  if ((state.detailStatus == OwnerQuotationDetailStatus.loading ||
                      state.detailStatus == OwnerQuotationDetailStatus.initial) &&
                      state.detail == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.detailStatus == OwnerQuotationDetailStatus.failure) {
                    return RefreshIndicator(
                      onRefresh: refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: Responsive.h(160)),
                          Center(
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
                          ),
                        ],
                      ),
                    );
                  }

                  final q = state.detail;
                  if (q == null) {
                    return RefreshIndicator(
                      onRefresh: refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: Responsive.h(200)),
                          const Center(child: Text('No data found.')),
                        ],
                      ),
                    );
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
                  final isOwner = checkIsOwner(q);
                  final hasAnyMrp = q.items.any((i) => i.mrp > 0);
                  final hasAnyCompany = q.items.any((i) => i.companyName.trim().isNotEmpty);
                  final hasBoxQty = q.items.any((i) => i.boxQuantity > 0);
                  final hasPieceQty = q.items.any((i) => i.pieceQuantity > 0);

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          child: ListView(
                            // Needed so pull-to-refresh works even when content is short
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                    color: statusColor(q.status).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    q.status.isEmpty ? '-' : q.status,
                                    style: AppTextStyles.bodyBold(color: statusColor(q.status)),
                                  ),
                                ),
                              ),
                              SizedBox(height: Responsive.h(16)),

                              DetailSection(
                                title: 'Customer Details',
                                rows: [
                                  DetailRow('Name', q.customer.name, icon: Icons.groups_2_outlined),
                                  DetailRow('Address', q.customer.address, icon: Icons.location_on_outlined),
                                  DetailRow('Phone', q.customer.phone, icon: Icons.phone_outlined),
                                  DetailRow('Email', q.customer.email, icon: Icons.email_outlined),
                                ],
                              ),
                              SizedBox(height: Responsive.h(14)),
                              DetailSection(
                                title: 'Contractor Details',
                                rows: [
                                  DetailRow('Name', q.contractor.name, icon: Icons.engineering_outlined),
                                  DetailRow('Mobile', q.contractor.mobile, icon: Icons.phone_outlined),
                                  DetailRow('Email', q.contractor.email, icon: Icons.email),
                                ],
                              ),
                              if (q.salesman.employeeCode.isNotEmpty) ...[
                                SizedBox(height: Responsive.h(14)),
                                DetailSection(
                                  title: 'Salesman',
                                  rows: [
                                    DetailRow('Created By', q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
                                        icon: Icons.person_outline),
                                  ],
                                ),
                              ],
                              if (q.notes.isNotEmpty) ...[
                                SizedBox(height: Responsive.h(14)),
                                DetailSection(
                                  title: 'Notes',
                                  rows: [DetailRow('Notes', q.notes, icon: Icons.notes_outlined)],
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
                              SizedBox(height: Responsive.h(16)),

                              // Totals card
                              TotalsCard(q: q, money: money, number: number),

                              // Payments received (only when the API returns them).
                              if (q.payments.isNotEmpty) ...[
                                SizedBox(height: Responsive.h(14)),
                                PaymentsCard(q: q, money: money),
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
                                    RoundIconButton(
                                      icon: Icons.share_outlined,
                                      tooltip: 'Share / Export',
                                      onPressed: exporting ? null : () => showExportSheet(q),
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
                                            : () => showApproveDialog(q),
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
                                          : () => confirmAndCancel(q),
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
}