import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatedetailscreenwidget.dart';
import 'package:tileshop/ui/salesman/quotation_editscreen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_event.dart';
import '../../bloc/salemanbloc/quatation/qtn_listdetail_state.dart';
import '../../bloc/salemanbloc/quatation/quotation_listdetail_bloc.dart';
import '../../models/salesmanmodels/quotationlistdetailmodel.dart';
import '../../widgets/appsnackbar.dart';
import '../../widgets/owner_estimateshimmer.dart';

const Color _redColor = Color(0xFFDC2626);

class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key, required this.id});

  final String id;

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen>
    with WidgetsBindingObserver {
  late final SalesmanQuotationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SalesmanQuotationBloc>();
    _bloc.add(QuotationDetailRequested(widget.id));
    // Auto refresh when the app returns to the foreground.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.add(const QuotationDetailCleared());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only when this screen is the visible one (not while Edit is open).
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      _bloc.add(QuotationDetailRequested(widget.id));
    }
  }

  /// Pull-to-refresh. Waits until loading finishes so the RefreshIndicator
  /// spinner stays visible for the right duration.
  Future<void> _refresh() async {
    _bloc.add(QuotationDetailRequested(widget.id));
    await _bloc.stream
        .firstWhere((s) => s.detailStatus != QuotationLoadStatus.loading)
        .timeout(const Duration(seconds: 20), onTimeout: () => _bloc.state);
  }

  /// Whether the quotation's `created_by` is an Owner, derived straight
  /// from the response. Incentive figures are salesman-facing, so they're
  /// hidden for Owner-created ones.
  bool _isOwner(QuotationDetailModel q) {
    final label = q.createdBy.roleLabel.trim().toLowerCase();
    if (label.isNotEmpty) return label == 'owner';
    return q.createdBy.role.trim().toLowerCase() == 'owner';
  }

  bool _isApproved(QuotationDetailModel q) =>
      q.status.trim().toLowerCase() == 'approved';

  Color _quotationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return _redColor;
      case 'draft':
        return AppColors.textSecondary;
      default:
        return const Color(0xFFF59E0B); // send / submitted / pending
    }
  }

  void _showError(String msg) => AppSnackbar.error(msg);

  void _editQuotation(QuotationDetailModel estimate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _bloc,
          child: QuotationEditScreen(estimate: estimate),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(QuotationDetailModel estimate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete quotation?', style: AppTextStyles.bodyBold()),
        content: Text(
          'This will permanently delete ${estimate.quotationNumber.isNotEmpty ? estimate.quotationNumber : 'this quotation'}. This action cannot be undone.',
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
              backgroundColor: _redColor,
              elevation: 0,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete',
                style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _bloc.add(QuotationDeleteRequested(estimate.id));
    }
  }

  void _sendForApproval(QuotationDetailModel estimate) {
    _bloc.add(QuotationSubmitForApprovalRequested(estimate.id));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    // Approved bills show paise in the totals, like the owner screens.
    final money =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final number = NumberFormat.decimalPattern('en_IN');

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as owner) ----------
        appBar: AppBar(
          title: Text('Quotation Preview', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocListener<SalesmanQuotationBloc, SalesmanQuotationState>(
            // This screen shares SalesmanQuotationBloc with QuotationEditScreen,
            // so only react to submitStatus while this is the visible route.
            listenWhen: (prev, curr) =>
            prev.deleteStatus != curr.deleteStatus ||
                (prev.submitStatus != curr.submitStatus &&
                    curr.submitStatus != QuotationActionStatus.idle &&
                    ModalRoute.of(context)?.isCurrent == true),
            listener: (context, state) {
              if (state.deleteStatus == QuotationActionStatus.success) {
                AppSnackbar.success('Quotation deleted.');
                _bloc.add(const QuotationActionResultConsumed());
                Navigator.of(context).pop();
              } else if (state.deleteStatus == QuotationActionStatus.failure) {
                _showError(state.deleteError ?? 'Failed to delete quotation.');
                _bloc.add(const QuotationActionResultConsumed());
              } else if (state.submitStatus == QuotationActionStatus.success) {
                AppSnackbar.success(
                    state.submitMessage ?? 'Submitted for approval.');
                _bloc.add(const QuotationActionResultConsumed());
              } else if (state.submitStatus == QuotationActionStatus.failure) {
                _showError(
                    state.submitError ?? 'Failed to submit for approval.');
                _bloc.add(const QuotationActionResultConsumed());
              }
            },
            child: BlocBuilder<SalesmanQuotationBloc, SalesmanQuotationState>(
              buildWhen: (prev, curr) =>
              prev.detailStatus != curr.detailStatus ||
                  prev.detail != curr.detail,
              builder: (context, state) {
                // ---- loading skeleton ----
                // Only when there is nothing to show yet. During a refresh
                // the old data stays on screen.
                if (state.detail == null &&
                    state.detailStatus != QuotationLoadStatus.failure) {
                  return ShimmerListPlaceholder(
                    itemCount: 5,
                    padding: listPadding,
                    separatorHeight: Responsive.h(10),
                    itemBuilder: (context, i) => const _DetailCardSkeleton(),
                  );
                }

                // ---- error ----
                if (state.detail == null) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refresh,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                          child: _ErrorView(
                            message:
                            state.detailError ?? 'Failed to load quotation.',
                            onRetry: () =>
                                _bloc.add(QuotationDetailRequested(widget.id)),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final estimate = state.detail!;
                final isOwner = _isOwner(estimate);
                final isApproved = _isApproved(estimate);
                // Only show these columns if at least one item has a value.
                final hasBoxQty = estimate.items.any((i) => i.boxQuantity > 0);
                final hasPieceQty =
                estimate.items.any((i) => i.pieceQuantity > 0);
                final totalIncentive = estimate.items
                    .fold<double>(0, (s, r) => s + r.incentiveAmount);

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _refresh,
                        child: ListView(
                          // Needed so pull-to-refresh works on short content.
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: listPadding,
                          children: [
                            _QuotationHeader(
                              estimate: estimate,
                              statusColor:
                              _quotationStatusColor(estimate.status),
                            ),
                            SizedBox(height: Responsive.h(14)),
                            if (estimate.notes.isNotEmpty) ...[
                              DetailSection(
                                title: 'Notes',
                                icon: Icons.sticky_note_2_outlined,
                                rows: [
                                  DetailRow('Notes', estimate.notes,
                                      icon: Icons.sticky_note_2_outlined),
                                ],
                              ),
                              SizedBox(height: Responsive.h(14)),
                            ],
                            DetailSection(
                              title: 'Customer Details',
                              icon: Icons.groups_2_outlined,
                              rows: [
                                DetailRow('Name', estimate.customer.name,
                                    icon: Icons.groups_2_outlined),
                                DetailRow('Phone', estimate.customer.phone,
                                    icon: Icons.phone_outlined),
                                DetailRow('Email', estimate.customer.email,
                                    icon: Icons.email_outlined),
                                DetailRow('Address', estimate.customer.address,
                                    icon: Icons.location_on_outlined),
                              ],
                            ),
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Contractor Details',
                              icon: Icons.person_outline,
                              rows: [
                                DetailRow('Name', estimate.contractor.name,
                                    icon: Icons.person_outline),
                                DetailRow('Phone', estimate.contractor.mobile,
                                    icon: Icons.phone_outlined),
                                DetailRow('Email', estimate.contractor.email,
                                    icon: Icons.email_outlined),
                              ],
                            ),
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Salesman',
                              icon: Icons.badge_outlined,
                              rows: [
                                DetailRow('Name', estimate.salesman.name,
                                    icon: Icons.badge_outlined),
                              ],
                            ),
                            SizedBox(height: Responsive.h(18)),

                            _InvoiceTable(
                              items: estimate.items,
                              showBox: hasBoxQty,
                              showPiece: hasPieceQty,
                              showIncentive: !isOwner,
                              currency: currency,
                              number: number,
                            ),
                            SizedBox(height: Responsive.h(14)),

                            // Totals. For approved quotations this also shows
                            // discount, total paid and balance.
                            _SummaryCard(
                              q: estimate,
                              fmt: isApproved ? money : currency,
                              number: number,
                              isApproved: isApproved,
                            ),

                            if (isApproved && estimate.payments.isNotEmpty) ...[
                              SizedBox(height: Responsive.h(14)),
                              _PaymentsCard(payments: estimate.payments, money: money),
                            ],

                            if (!isOwner && totalIncentive > 0) ...[
                              SizedBox(height: Responsive.h(14)),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.w(14),
                                    vertical: Responsive.h(14)),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.success.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconBadge(Icons.percent_rounded,
                                            color: AppColors.success),
                                        SizedBox(width: Responsive.w(10)),
                                        Text('Incentive Total',
                                            style: AppTextStyles.bodyBold(
                                                color: AppColors.success)),
                                      ],
                                    ),
                                    Text(
                                      currency.format(totalIncentive),
                                      style: AppTextStyles.amount(
                                          color: AppColors.success),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ---- Bottom action bar (same container as owner) ----
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      padding: EdgeInsets.fromLTRB(Responsive.w(20),
                          Responsive.h(10), Responsive.w(20), Responsive.h(14)),
                      child: BlocBuilder<SalesmanQuotationBloc,
                          SalesmanQuotationState>(
                        buildWhen: (prev, curr) =>
                        prev.deleteStatus != curr.deleteStatus ||
                            prev.submitStatus != curr.submitStatus,
                        builder: (context, state) {
                          final deleting = state.deleteStatus ==
                              QuotationActionStatus.inProgress;
                          final submitting = state.submitStatus ==
                              QuotationActionStatus.inProgress;
                          final busy = deleting || submitting;
                          final buttonShape = RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14));
                          final buttonHeight = Responsive.h(48);

                          if (estimate.isDraft) {
                            return Row(
                              children: [
                                RoundIconButton(
                                  icon: Icons.edit_outlined,
                                  tooltip: 'Edit',
                                  onPressed:
                                  busy ? null : () => _editQuotation(estimate),
                                ),
                                SizedBox(width: Responsive.w(10)),
                                Expanded(
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _redColor,
                                        side: const BorderSide(color: _redColor),
                                        shape: buttonShape,
                                      ),
                                      onPressed: busy
                                          ? null
                                          : () => _confirmDelete(estimate),
                                      child: deleting
                                          ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _redColor),
                                      )
                                          : Text('Delete',
                                          style: AppTextStyles.bodyBold(
                                              color: _redColor)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(10)),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: buttonShape,
                                      ),
                                      onPressed: busy
                                          ? null
                                          : () => _sendForApproval(estimate),
                                      child: Text(
                                        submitting
                                            ? 'Submitting…'
                                            : 'Submit for Approval',
                                        style: AppTextStyles.bodyBold(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          // Not a draft anymore: informational pill only.
                          final pillColor =
                          isApproved ? AppColors.success : AppColors.textSecondary;
                          return Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: buttonHeight),
                            padding: EdgeInsets.symmetric(
                                vertical: Responsive.h(10),
                                horizontal: Responsive.w(14)),
                            decoration: BoxDecoration(
                              color: pillColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: pillColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isApproved
                                      ? Icons.check_circle_outline
                                      : Icons.lock_outline,
                                  size: 16,
                                  color: pillColor,
                                ),
                                SizedBox(width: Responsive.w(8)),
                                Expanded(
                                  child: Text(
                                    isApproved
                                        ? 'This quotation has been approved.'
                                        : 'This quotation has already been submitted and can no longer be edited or deleted.',
                                    textAlign: TextAlign.center,
                                    style: isApproved
                                        ? AppTextStyles.bodyBold(
                                        color: AppColors.success)
                                        : AppTextStyles.caption(
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
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
// HEADER (same look as the owner estimate header)
// =====================================================================

class _QuotationHeader extends StatelessWidget {
  const _QuotationHeader({required this.estimate, required this.statusColor});
  final QuotationDetailModel estimate;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final dateText = estimate.date != null
        ? DateFormat('dd-MM-yyyy').format(estimate.date!)
        : estimate.dateRaw;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.request_quote_outlined,
                color: AppColors.primary, size: 20),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estimate.quotationNumber.isEmpty
                      ? '#${estimate.id}'
                      : estimate.quotationNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(),
                ),
                SizedBox(height: Responsive.h(2)),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textSecondary),
                    SizedBox(width: Responsive.w(5)),
                    Expanded(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                        AppTextStyles.caption(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          StatusPill(
            label: estimate.status.isEmpty ? '-' : statusLabel(estimate.status),
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SUMMARY CARD
// =====================================================================

/// Not approved: Sq.Ft / Sub Total / Handling Charge / Grand Total.
/// Approved: additionally Total Before Discount + Discount (if any),
/// Grand Total (= amount after discount), Total Paid and a Balance strip.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.q,
    required this.fmt,
    required this.number,
    required this.isApproved,
  });

  final QuotationDetailModel q;
  final NumberFormat fmt;
  final NumberFormat number;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: Responsive.h(10));
    final showDiscount = isApproved && q.hasDiscount;
    final showPayment = isApproved && q.showPaymentSummary;
    final payable = isApproved ? q.amountAfterDiscount : q.grandTotal;
    final hasBalance = q.balanceAmount > 0;
    final balanceColor = hasBalance ? _redColor : AppColors.success;

    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitleBar(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Column(
              children: [
                _SummaryLine('Total Sq.Ft', number.format(q.totalSquareFeet)),
                gap,
                _SummaryLine('Sub Total', fmt.format(q.subtotal)),
                gap,
                _SummaryLine('Handling Charge', fmt.format(q.handlingCharge)),
                if (showDiscount) ...[
                  gap,
                  _SummaryLine('Total Before Discount', fmt.format(q.grandTotal)),
                  gap,
                  _SummaryLine(
                    q.discountLabel,
                    '- ${fmt.format(q.discountAmount)}',
                    valueColor: _redColor,
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                  child: const Divider(height: 1, color: AppColors.border),
                ),
                _SummaryLine(
                  'Grand Total',
                  fmt.format(payable),
                  valueColor: AppColors.primary,
                  large: true,
                ),
                if (showPayment) ...[
                  gap,
                  _SummaryLine('Total Paid', fmt.format(q.totalPaid),
                      valueColor: AppColors.success),
                ],
              ],
            ),
          ),
          // Balance strip: red while money is due, green once fully paid.
          if (showPayment)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(12)),
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.06),
                border: Border(top: BorderSide(color: balanceColor.withOpacity(0.25))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasBalance
                            ? Icons.account_balance_wallet_outlined
                            : Icons.verified_rounded,
                        size: 18,
                        color: balanceColor,
                      ),
                      SizedBox(width: Responsive.w(8)),
                      Text('Balance Due', style: AppTextStyles.bodyBold()),
                    ],
                  ),
                  Text(fmt.format(q.balanceAmount),
                      style: AppTextStyles.amount(color: balanceColor)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Label + value row. The value scales down instead of overflowing when
/// the amount is very large.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value, {this.valueColor, this.large = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final labelStyle = large
        ? AppTextStyles.bodyBold()
        : AppTextStyles.body(color: AppColors.textSecondary);
    final valueStyle = (large
        ? AppTextStyles.amount(color: valueColor ?? AppColors.primary)
        : AppTextStyles.bodyBold(color: valueColor ?? AppColors.textPrimary))
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value, style: valueStyle, maxLines: 1, softWrap: false),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// PAYMENTS CARD
// =====================================================================

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.payments, required this.money});
  final List<dynamic> payments;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final total = payments.fold<double>(0, (s, p) => s + (p.amount as num));

    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitleBar(
            title: 'Payments',
            icon: Icons.payments_outlined,
            trailing: Text(
              '${payments.length} ${payments.length == 1 ? 'entry' : 'entries'}',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ),
          for (var i = 0; i < payments.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(14), vertical: Responsive.h(12)),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 20, color: AppColors.success),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payments[i].methodLabel.toString().isEmpty
                              ? 'Payment'
                              : payments[i].methodLabel.toString(),
                          style: AppTextStyles.bodyBold(),
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Text(
                          _subtitle(payments[i]),
                          style: AppTextStyles.caption(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    money.format(payments[i].amount),
                    style: AppTextStyles.bodyBold(color: AppColors.success).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i != payments.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Received', style: AppTextStyles.bodyBold()),
                Text(money.format(total),
                    style: AppTextStyles.bodyBold(color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "2026-10-05 · Ref: ABC" (date and reference are both optional).
  String _subtitle(dynamic p) {
    final raw = p.date.toString();
    final parsed = DateTime.tryParse(raw);
    final dateText = parsed != null ? DateFormat('yyyy-MM-dd').format(parsed) : raw;
    final ref = p.reference.toString();
    final parts = <String>[
      if (dateText.isNotEmpty) dateText,
      if (ref.isNotEmpty) 'Ref: $ref',
    ];
    return parts.isEmpty ? '-' : parts.join(' · ');
  }
}

/// White card header row (icon badge + title) with a divider underneath.
class _CardTitleBar extends StatelessWidget {
  const _CardTitleBar({required this.title, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            IconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// =====================================================================
// ITEMS TABLE (same look as the owner items table)
// =====================================================================

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({
    required this.items,
    required this.showBox,
    required this.showPiece,
    required this.showIncentive,
    required this.currency,
    required this.number,
  });

  final List<QuotationDetailItem> items;
  final bool showBox, showPiece, showIncentive;
  final NumberFormat currency;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    // label, width, alignment (same column order as the owner table)
    final cols = <(String, double, TextAlign)>[
      ('Sl.No', EstCol.sl, TextAlign.center),
      ('Item', EstCol.text, TextAlign.left),
      ('Company', EstCol.text, TextAlign.left),
      ('Size', EstCol.size, TextAlign.left),
      ('Unit', EstCol.unit, TextAlign.left),
      ('Qty', EstCol.num, TextAlign.right),
      if (showBox) ('Box Qty', EstCol.num, TextAlign.right),
      if (showPiece) ('Piece Qty', EstCol.num, TextAlign.right),
      ('MRP', EstCol.num, TextAlign.right),
      ('Rate', EstCol.num, TextAlign.right),
      ('Amount', EstCol.money, TextAlign.right),
      if (showIncentive) ('Incentive', EstCol.money, TextAlign.right),
    ];

    final amountCol = cols.indexWhere((c) => c.$1 == 'Amount');
    final qtyCol = cols.indexWhere((c) => c.$1 == 'Qty');
    final incentiveCol = cols.indexWhere((c) => c.$1 == 'Incentive');

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(
        0, (s, i) => s + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));

    final cellFont = Responsive.sp(12.5);

    Alignment alignOf(int c) => switch (cols[c].$3) {
      TextAlign.right => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      _ => Alignment.centerLeft,
    };

    // Header stays on one line so every header looks the same.
    Widget headerCell(int c) => Container(
      alignment: alignOf(c),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(12)),
      child: Text(
        cols[c].$1,
        textAlign: cols[c].$3,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyBold(color: AppColors.primary)
            .copyWith(fontSize: cellFont),
      ),
    );

    // Data cells are capped at two lines with an ellipsis.
    Widget dataCell(String text, int c, {bool bold = false, Color? color}) =>
        Container(
          alignment: alignOf(c),
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(10), vertical: Responsive.h(10)),
          child: Text(
            text,
            textAlign: cols[c].$3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body())
                .copyWith(
              color: color,
              fontSize: cellFont,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    TableRow itemRow(int i, QuotationDetailItem it) {
      final values = <String>[
        '${i + 1}',
        it.productName.isEmpty ? '-' : it.productName,
        it.companyName.isNotEmpty ? it.companyName : '-',
        it.productSize.isEmpty ? '-' : it.productSize,
        it.productUnit.isEmpty ? '-' : it.productUnit,
        number.format(it.quantity),
        if (showBox) it.boxQuantity > 0 ? number.format(it.boxQuantity) : '-',
        if (showPiece)
          it.pieceQuantity > 0 ? number.format(it.pieceQuantity) : '-',
        it.mrp > 0 ? currency.format(it.mrp) : '-',
        number.format(it.rate),
        currency.format(it.amount),
        if (showIncentive)
          it.incentiveAmount > 0 ? currency.format(it.incentiveAmount) : '-',
      ];
      return TableRow(
        decoration: BoxDecoration(
          color: i.isEven ? Colors.white : AppColors.background,
        ),
        children: [
          for (var c = 0; c < values.length; c++)
            dataCell(
              values[c],
              c,
              bold: c == 1 ||
                  c == amountCol ||
                  (showIncentive && c == incentiveCol),
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
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const EstimateSectionHeader('Items'),
            StatusPill(
              label: '${items.length} ${items.length == 1 ? 'item' : 'items'}',
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: Responsive.h(10)),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(18)),
            decoration: cardDecoration(),
            child: Text('No items on this quotation.',
                style: AppTextStyles.caption(color: AppColors.textSecondary)),
          )
        else ...[
          Container(
            decoration: cardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder(
                  horizontalInside:
                  BorderSide(color: AppColors.border.withOpacity(0.6)),
                  verticalInside:
                  BorderSide(color: AppColors.border.withOpacity(0.4)),
                ),
                columnWidths: {
                  for (var c = 0; c < cols.length; c++)
                    c: FixedColumnWidth(cols[c].$2),
                },
                children: [
                  TableRow(
                    decoration:
                    BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
                    children: [
                      for (var c = 0; c < cols.length; c++) headerCell(c)
                    ],
                  ),
                  for (var i = 0; i < items.length; i++) itemRow(i, items[i]),
                  totalRow(),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.h(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_rounded, size: 14, color: AppColors.textHint),
              SizedBox(width: Responsive.w(4)),
              Text('Swipe sideways to see all columns',
                  style: AppTextStyles.caption(color: AppColors.textSecondary)
                      .copyWith(fontSize: Responsive.sp(11))),
            ],
          ),
        ],
      ],
    );
  }
}

// =====================================================================
// ERROR / SKELETON (same as owner screen)
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