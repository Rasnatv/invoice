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
import '../../widgets/owner_estimateshimmer.dart';
import 'ownerquotationeditscreen.dart';

const Color _redColor = Color(0xFFDC2626);

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
  const OwnerQuotationDetailsView({super.key, required this.quotationId});
  final String quotationId;

  @override
  State<OwnerQuotationDetailsView> createState() => OwnerQuotationDetailsViewState();
}

class OwnerQuotationDetailsViewState extends State<OwnerQuotationDetailsView> {
  // Cache the bloc reference while context is still safely attached.
  late final OwnerQuotationDetailBloc detailBloc;

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
    detailBloc.add(const OwnerQuotationDetailCleared());
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
        .timeout(const Duration(seconds: 20), onTimeout: () => detailBloc.state);
  }

  bool checkIsOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  /// Shows whatever message the backend sent in a plain dialog.
  Future<void> showBackendMessage(String? message, {bool isError = false}) async {
    if (message == null || message.trim().isEmpty) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isError ? 'Error' : 'Success', style: AppTextStyles.bodyBold()),
        content: Text(message, style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('OK', style: AppTextStyles.bodyBold(color: AppColors.primary)),
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
    // Incentive column is hidden when the Owner created the quotation.
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
                leading: const Icon(Icons.picture_as_pdf_rounded, color: _redColor),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Quotation', style: AppTextStyles.bodyBold()),
        content: Text(
          'Are you sure you want to cancel this quotation? This cannot be undone.',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Yes, Cancel',
                style: AppTextStyles.bodyBold(color: Colors.white)),
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

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    // Totals / payment section shows paise, like the estimate screen.
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final number = NumberFormat.decimalPattern('en_IN');

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: PopScope(
        // Always hand `didChange` back to whoever pushed this screen.
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(didChange);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,

          // ---------- APPBAR (same as Estimate details) ----------
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

                  final status = q.status.toLowerCase();
                  // Edit hidden once approved or cancelled (final states).
                  final hideEditIcon = status == 'approved' || status == 'cancelled';

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Share as PDF',
                        icon: exporting
                            ? _appBarSpinner
                            : const Icon(Icons.picture_as_pdf_rounded),
                        onPressed: exporting ? null : () => exportQuotation(q, 'pdf'),
                      ),
                      IconButton(
                        tooltip: 'Share as Excel',
                        icon: const Icon(Icons.grid_on_rounded),
                        onPressed: exporting ? null : () => exportQuotation(q, 'excel'),
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
                    ownerDataRefresh.value++;
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
                  // ---- loading skeleton (only when nothing to show yet) ----
                  if ((state.detailStatus == OwnerQuotationDetailStatus.loading ||
                      state.detailStatus == OwnerQuotationDetailStatus.initial) &&
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
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: _ErrorView(
                              message: state.detailError ?? 'Failed to load quotation.',
                              onRetry: () => context
                                  .read<OwnerQuotationDetailBloc>()
                                  .add(OwnerQuotationDetailRequested(widget.quotationId)),
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
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: Text('No data found.',
                                  style: AppTextStyles.subtitle()),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final status = q.status.toLowerCase();
                  final isApproved = status == 'approved';
                  final isCancelled = status == 'cancelled';
                  // Approve + Cancel only for 'draft' and 'send'.
                  final showActionButtons = status == 'draft' || status == 'send';
                  final isApproving =
                      state.approveStatus == OwnerQuotationApproveStatus.inProgress;
                  // Incentive figures are salesman-facing; hide for Owner.
                  final isOwner = checkIsOwner(q);
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
                            // Pull-to-refresh works even when content is short
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
                                        q.createdBy.name.isEmpty ? '-' : q.createdBy.name,
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
                        child: BlocBuilder<OwnerCancelQuotationBloc,
                            OwnerCancelQuotationState>(
                          builder: (context, cancelState) {
                            final isCancelling = cancelState.status ==
                                OwnerCancelQuotationStatus.inProgress;
                            final buttonHeight = Responsive.h(48);
                            final buttonShape = RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14));

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    RoundIconButton(
                                      icon: Icons.share_outlined,
                                      tooltip: 'Share / Export',
                                      onPressed: exporting ? null : () => showExportSheet(q),
                                    ),
                                    SizedBox(width: Responsive.w(10)),
                                    Expanded(
                                      child: isApproved
                                          ? _StatusBanner(
                                        height: buttonHeight,
                                        icon: Icons.check_circle_rounded,
                                        label: 'Quotation Approved',
                                        color: AppColors.success,
                                      )
                                          : isCancelled
                                          ? _StatusBanner(
                                        height: buttonHeight,
                                        icon: Icons.cancel_rounded,
                                        label: 'Quotation Cancelled',
                                        color: _redColor,
                                      )
                                          : showActionButtons
                                          ? SizedBox(
                                        height: buttonHeight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: buttonShape,
                                          ),
                                          onPressed: (isApproving || isCancelling)
                                              ? null
                                              : () => showApproveDialog(q),
                                          child: Text(
                                            isApproving
                                                ? 'Approving...'
                                                : 'Approve Quotation',
                                            style: AppTextStyles.bodyBold(
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                if (showActionButtons) ...[
                                  SizedBox(height: Responsive.h(10)),
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _redColor,
                                        side: const BorderSide(color: _redColor),
                                        shape: buttonShape,
                                      ),
                                      onPressed: (isApproving || isCancelling)
                                          ? null
                                          : () => confirmAndCancel(q),
                                      icon: const Icon(Icons.cancel_outlined, size: 18),
                                      label: Text(
                                        isCancelling ? 'Cancelling...' : 'Cancel Quotation',
                                        style: AppTextStyles.bodyBold(color: _redColor),
                                      ),
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