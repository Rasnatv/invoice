
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimatedetail/estimate_detail_event.dart';
import '../../bloc/salemanbloc/estimatedetail/estimate_detail_state.dart';
import '../../bloc/salemanbloc/estimatedetail/estimatedetail_bloc.dart';
import '../../models/salesmanmodels/estimatedetail.model.dart';
import '../owner/ownerdespatchsheet.dart';

// UI only: standard column widths for the items grid.
class _Col {
  static const double sl = 60; // Sl.No
  static const double text = 180; // Item / Company
  static const double size = 120; // Size
  static const double unit = 190; // Unit
  static const double num = 150; // Qty, Box Qty, Piece Qty, MRP, Rate
  static const double money = 180; // Amount, Incentive
}

class SalesmanEstimateDetailsScreen extends StatefulWidget {
  const SalesmanEstimateDetailsScreen({super.key, required this.id});

  final String id;

  @override
  State<SalesmanEstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
}

class _EstimateDetailsScreenState extends State<SalesmanEstimateDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstimateDetailBloc()..add(EstimateDetailRequested(widget.id)),
      child: _EstimateDetailsView(id: widget.id),
    );
  }
}

class _EstimateDetailsView extends StatefulWidget {
  const _EstimateDetailsView({required this.id});

  final String id;

  @override
  State<_EstimateDetailsView> createState() => _EstimateDetailsViewState();
}

class _EstimateDetailsViewState extends State<_EstimateDetailsView>
    with WidgetsBindingObserver {
  late final EstimateDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<EstimateDetailBloc>();
    // Auto refresh: reload whenever the app comes back to the foreground.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _bloc.add(EstimateDetailRequested(widget.id));
    }
  }

  /// Manual refresh (pull-to-refresh + app bar button).
  /// Waits until the bloc finishes loading so the RefreshIndicator spinner
  /// stays visible for the right duration.
  Future<void> _refresh() async {
    _bloc.add(EstimateDetailRequested(widget.id));

    await _bloc.stream
        .firstWhere((s) => s.status != EstimateDetailStatus.loading)
        .timeout(const Duration(seconds: 20), onTimeout: () => _bloc.state);
  }

  /// Derived straight from the API response's `created_by_details.role_label`
  /// (e.g. "Owner" vs "Salesman") — no manual flag needed. When the estimate
  /// was created by an Owner, the Incentive column is hidden; for a
  /// Salesman-created estimate, it stays visible.
  bool _isOwner(EstimateDetailModel estimate) {
    return estimate.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
  }

  bool _isDelivered(EstimateDetailModel estimate) {
    final s = estimate.status.trim().toLowerCase();
    return s == 'delivered' || s == 'despatched' || s == 'dispatched';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'delivered':
        return AppColors.success;
      case 'pending_approval':
        return Colors.orange;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending_approval':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  void _openDespatchSheet(BuildContext context, EstimateDetailModel estimate) async {
    final despatched = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(estimateId: estimate.id),
      ),
    );

    if (despatched == true && context.mounted) {
      // Pop this Estimate Detail screen too, returning to the screen
      // that opened it (e.g. Approved Bills) instead of the dashboard.
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final number = NumberFormat.decimalPattern('en_IN');

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Estimate Detail', style: AppTextStyles.h6()),
        ),
        body: SafeArea(
          child: BlocBuilder<EstimateDetailBloc, EstimateDetailState>(
            builder: (context, state) {
              // Full-screen loader only when there is nothing to show yet.
              // During a refresh the old data stays on screen.
              if (state.status == EstimateDetailStatus.loading && state.detail == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == EstimateDetailStatus.failure && state.detail == null) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: Responsive.h(180)),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 40, color: AppColors.error),
                            SizedBox(height: Responsive.h(10)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(24)),
                              child: Text(
                                state.error ?? 'Failed to load estimate.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body(color: AppColors.error),
                              ),
                            ),
                            SizedBox(height: Responsive.h(10)),
                            TextButton(
                              onPressed: () => context
                                  .read<EstimateDetailBloc>()
                                  .add(EstimateDetailRequested(widget.id)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final estimate = state.detail;
              if (estimate == null) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 300)],
                  ),
                );
              }

              final statusColor = _statusColor(estimate.status);
              final isOwner = _isOwner(estimate);

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        // Needed so pull-to-refresh works even when content is short
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(Responsive.w(18)),
                        children: [
                          // ---- Header card ----
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Responsive.w(16)),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.10),
                                  AppColors.primary.withOpacity(0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.16)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _IconBadge(Icons.receipt_long_rounded, size: 20),
                                    // Status pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: statusColor.withOpacity(0.35)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_statusIcon(estimate.status),
                                              size: 14, color: statusColor),
                                          SizedBox(width: Responsive.w(6)),
                                          Text(
                                            _statusLabel(estimate.status),
                                            style: AppTextStyles.bodyBold(color: statusColor)
                                                .copyWith(fontSize: Responsive.sp(12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.h(14)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('REFERENCE NO.',
                                              style: AppTextStyles.caption()
                                                  .copyWith(letterSpacing: 0.8)),
                                          SizedBox(height: Responsive.h(4)),
                                          Text(
                                            estimate.estimateNumber.isEmpty
                                                ? '#${estimate.id}'
                                                : estimate.estimateNumber,
                                            style: AppTextStyles.bodyBold()
                                                .copyWith(fontSize: Responsive.sp(16)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: Responsive.w(12)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('DATE',
                                            style: AppTextStyles.caption()
                                                .copyWith(letterSpacing: 0.8)),
                                        SizedBox(height: Responsive.h(4)),
                                        Text(
                                          estimate.date != null
                                              ? DateFormat('dd-MM-yyyy')
                                              .format(estimate.date!)
                                              : estimate.dateRaw,
                                          style: AppTextStyles.bodyBold(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Responsive.h(16)),

                          _DetailSection(
                            title: 'Customer Details',
                            icon: Icons.groups_2_outlined,
                            rows: [
                              _Row(' Name', estimate.customerName,
                                  icon: Icons.groups_2_outlined),
                              _Row('Address', estimate.customerAddress,
                                  icon: Icons.location_on_outlined),
                              _Row('Contact No.', estimate.customerPhone,
                                  icon: Icons.phone_outlined),
                              _Row('Email', estimate.customerEmail,
                                  icon: Icons.alternate_email),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),
                          _DetailSection(
                            title: 'Contractor Details',
                            icon: Icons.person_outline,
                            rows: [
                              _Row(' Name', estimate.customer.name,
                                  icon: Icons.groups_2_outlined),
                              _Row('Contact No.', estimate.customer.phone,
                                  icon: Icons.phone_outlined),
                              _Row('Email', estimate.customer.email,
                                  icon: Icons.alternate_email),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),
                          // Salesman section — always shown, including for owners.
                          _DetailSection(
                            title: 'Salesman',
                            icon: Icons.badge_outlined,
                            rows: [
                              _Row('Name', estimate.salesman.name,
                                  icon: Icons.badge_outlined),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),

                          if (estimate.siteVisit.id.isNotEmpty)
                            _DetailSection(
                              title: 'Site Visit',
                              icon: Icons.location_history_outlined,
                              rows: [
                                _Row('Visit Date', estimate.siteVisit.visitDate,
                                    icon: Icons.event_outlined),
                                _Row('Status', estimate.siteVisit.statusLabel,
                                    icon: Icons.flag_outlined),
                                _Row('Field Staff', estimate.siteVisit.fieldStaffName,
                                    icon: Icons.engineering_outlined),
                              ],
                            ),
                          SizedBox(height: Responsive.h(20)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const _IconBadge(Icons.list_alt_rounded),
                                  SizedBox(width: Responsive.w(10)),
                                  Text('Items', style: AppTextStyles.h3()),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.w(12),
                                    vertical: Responsive.h(5)),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Total Items: ${estimate.itemsCount}',
                                  style: AppTextStyles.bodyBold(color: AppColors.primary)
                                      .copyWith(fontSize: Responsive.sp(12)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.h(12)),

                          _buildItemsTable(estimate, number, isOwner),
                          SizedBox(height: Responsive.h(16)),

                          if (estimate.notes.isNotEmpty) ...[
                            _DetailSection(
                              title: 'Notes',
                              icon: Icons.sticky_note_2_outlined,
                              rows: [_Row('', estimate.notes)],
                            ),
                            SizedBox(height: Responsive.h(14)),
                          ],

                          _buildSummaryCard(estimate, number),
                          SizedBox(height: Responsive.h(12)),

                          if (estimate.isApproved) _buildPaymentStatus(estimate),
                        ],
                      ),
                    ),
                  ),
                  if (estimate.isApproved && !_isDelivered(estimate))
                    _buildBottomBar(context, estimate),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Items table — standard column widths (UI only), same data as before
  // ---------------------------------------------------------------------

  Widget _buildItemsTable(EstimateDetailModel estimate, NumberFormat number, bool isOwner) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final items = estimate.items;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.w(18)),
        decoration: _cardDecoration(),
        child: Text('No items on this estimate.', style: AppTextStyles.caption()),
      );
    }

    final totalQty = items.fold<double>(0, (s, i) => s + i.quantity);
    final totalAmount = items.fold<double>(0, (s, i) => s + i.amount);
    final totalIncentive = items.fold<double>(
        0, (s, i) => s + (i.incentiveAmount > 0 ? i.incentiveAmount : 0));

    final hasBoxQty = items.any((i) => i.boxQuantity > 0);
    final hasPieceQty = items.any((i) => i.pieceQuantity > 0);
    final showIncentive = !isOwner;

    // Column widths are keyed by index, so build the map dynamically —
    // the index of every column after Unit shifts depending on which
    // optional columns are shown.
    final widths = <int, TableColumnWidth>{};
    var col = 0;
    widths[col++] = const FixedColumnWidth(_Col.sl); // Sl.No
    widths[col++] = const FixedColumnWidth(_Col.text); // Item
    widths[col++] = const FixedColumnWidth(_Col.text); // Company
    widths[col++] = const FixedColumnWidth(_Col.size); // Size
    widths[col++] = const FixedColumnWidth(_Col.num); // Qty
    widths[col++] = const FixedColumnWidth(_Col.unit); // Unit
    if (hasBoxQty) widths[col++] = const FixedColumnWidth(_Col.num); // Box Qty
    if (hasPieceQty) widths[col++] = const FixedColumnWidth(_Col.num); // Piece Qty
    widths[col++] = const FixedColumnWidth(_Col.num); // MRP
    widths[col++] = const FixedColumnWidth(_Col.num); // Rate
    widths[col++] = const FixedColumnWidth(_Col.money); // Amount
    if (showIncentive) widths[col++] = const FixedColumnWidth(_Col.money); // Incentive

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: _cardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.45)),
                verticalInside: BorderSide(color: AppColors.border.withOpacity(0.30)),
              ),
              columnWidths: widths,
              children: [
                // ---- Header row ----
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    border: Border(
                      bottom: BorderSide(
                          color: AppColors.primary.withOpacity(0.35), width: 1.4),
                    ),
                  ),
                  children: [
                    _headerCell('Sl.No', align: TextAlign.center),
                    _headerCell('Item'),
                    _headerCell('Company'),
                    _headerCell('Size'),
                    _headerCell('Qty', align: TextAlign.right),
                    _headerCell('Unit'),
                    if (hasBoxQty) _headerCell('Box Qty', align: TextAlign.right),
                    if (hasPieceQty) _headerCell('Piece Qty', align: TextAlign.right),
                    _headerCell('MRP', align: TextAlign.right),
                    _headerCell('Rate', align: TextAlign.right),
                    _headerCell('Amount', align: TextAlign.right),
                    if (showIncentive) _headerCell('Incentive', align: TextAlign.right),
                  ],
                ),

                // ---- Data rows ----
                for (var i = 0; i < items.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? AppColors.surface
                          : AppColors.surfaceAlt.withOpacity(0.45),
                    ),
                    children: [
                      _dataCell('${i + 1}', align: TextAlign.center),
                      _dataCell(items[i].productName.isEmpty ? '-' : items[i].productName,
                          bold: true),
                      _dataCell(items[i].companyName.isEmpty ? '-' : items[i].companyName),
                      _dataCell(items[i].productSize.isEmpty ? '-' : items[i].productSize),
                      _dataCell(number.format(items[i].quantity), align: TextAlign.right),
                      _dataCell(items[i].unitName.isEmpty ? '-' : items[i].unitName),
                      if (hasBoxQty)
                        _dataCell(
                          items[i].boxQuantity > 0
                              ? number.format(items[i].boxQuantity)
                              : '-',
                          align: TextAlign.right,
                        ),
                      if (hasPieceQty)
                        _dataCell(
                          items[i].pieceQuantity > 0
                              ? number.format(items[i].pieceQuantity)
                              : '-',
                          align: TextAlign.right,
                        ),
                      _dataCell(
                        items[i].mrp > 0 ? currency.format(items[i].mrp) : '-',
                        align: TextAlign.right,
                      ),
                      _dataCell(number.format(items[i].rate), align: TextAlign.right),
                      _dataCell(currency.format(items[i].amount),
                          align: TextAlign.right, bold: true),
                      if (showIncentive)
                        _dataCell(
                          items[i].incentiveAmount > 0
                              ? currency.format(items[i].incentiveAmount)
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
                    color: AppColors.primary.withOpacity(0.07),
                    border: Border(
                      top: BorderSide(
                          color: AppColors.primary.withOpacity(0.35), width: 1.2),
                    ),
                  ),
                  children: [
                    _dataCell(''),
                    _dataCell('Total', bold: true),
                    _dataCell(''),
                    _dataCell(''),
                    _dataCell(number.format(totalQty), align: TextAlign.right, bold: true),
                    _dataCell(''),
                    if (hasBoxQty) _dataCell(''),
                    if (hasPieceQty) _dataCell(''),
                    _dataCell(''),
                    _dataCell(''),
                    _dataCell(currency.format(totalAmount),
                        align: TextAlign.right, bold: true, color: AppColors.primary),
                    if (showIncentive)
                      _dataCell(currency.format(totalIncentive),
                          align: TextAlign.right, bold: true, color: AppColors.success),
                  ],
                ),
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
                style: AppTextStyles.caption().copyWith(fontSize: Responsive.sp(11))),
          ],
        ),
      ],
    );
  }

  // One font size shared by the header and every data cell
  double get _cellFontSize => Responsive.sp(12.5);

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(12)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyBold(color: AppColors.primary).copyWith(
          fontSize: _cellFontSize,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _dataCell(
      String text, {
        TextAlign align = TextAlign.left,
        bool bold = false,
        Color? color,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(10), vertical: Responsive.h(10)),
      child: Text(
        text,
        textAlign: align,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: (bold ? AppTextStyles.bodyBold() : AppTextStyles.body()).copyWith(
          color: color,
          fontSize: _cellFontSize,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Summary card — same rows and conditions as before
  // ---------------------------------------------------------------------

  Widget _buildSummaryCard(EstimateDetailModel estimate, NumberFormat number) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(title: 'Summary', icon: Icons.calculate_outlined),
          Padding(
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Column(
              children: [
                _totalRow('Total Sq.Ft', number.format(estimate.totalSquareFeet)),
                SizedBox(height: Responsive.h(10)),
                _totalRow('Subtotal', currency.format(estimate.subtotal)),
                SizedBox(height: Responsive.h(10)),
                _totalRow('Handling Charge', currency.format(estimate.handlingCharge)),
                SizedBox(height: Responsive.h(10)),
                _totalRow('Total Before Discount', currency.format(estimate.grandTotal)),

                // Discount, payment, and balance are only meaningful once
                // the estimate is approved — while pending, these fields
                // are still zero/unset on the server, so showing them
                // would just display misleading zeros.
                if (estimate.isApproved && estimate.hasDiscount) ...[
                  SizedBox(height: Responsive.h(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Discount (${estimate.discountTypeLabel})',
                            style: AppTextStyles.body()),
                      ),
                      Text(
                        '- ${currency.format(estimate.discountAmount)}',
                        style: AppTextStyles.bodyBold(color: Colors.red).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],

                if (estimate.isApproved) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(12)),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _totalRow(
                    large: true,
                    'Grand Total',
                    currency.format(estimate.amountAfterDiscount),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  _totalRow('Total Paid', currency.format(estimate.totalPaid),
                      valueColor: AppColors.success),
                ],
              ],
            ),
          ),
          // Balance strip — only meaningful once approved.
          if (estimate.isApproved)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(16), vertical: Responsive.h(14)),
              decoration: BoxDecoration(
                color: (estimate.balanceAmount > 0 ? Colors.red : AppColors.success)
                    .withOpacity(0.08),
                border: Border(
                  top: BorderSide(
                    color: (estimate.balanceAmount > 0 ? Colors.red : AppColors.success)
                        .withOpacity(0.25),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Balance Due', style: AppTextStyles.h3()),
                  Text(
                    currency.format(estimate.balanceAmount),
                    style: AppTextStyles.h2(
                        color: estimate.balanceAmount > 0 ? Colors.red : AppColors.success),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {Color? valueColor, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: large
              ? AppTextStyles.h3().copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.body(),
        ),
        Text(
          value,
          style: (large
              ? AppTextStyles.h2(color: valueColor ?? AppColors.primary)
              .copyWith(fontWeight: FontWeight.w800)
              : AppTextStyles.body(color: valueColor ?? Colors.black))
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Payment status banner
  // ---------------------------------------------------------------------

  Widget _buildPaymentStatus(EstimateDetailModel estimate) {
    final color = estimate.isFullyPaid ? AppColors.success : Colors.orange;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(14)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _IconBadge(
                estimate.isFullyPaid
                    ? Icons.check_circle_outline
                    : Icons.hourglass_bottom_outlined,
                color: color,
              ),
              SizedBox(width: Responsive.w(10)),
              Text('Payment Status', style: AppTextStyles.bodyBold(color: color)),
            ],
          ),
          Text(estimate.balanceStatusLabel, style: AppTextStyles.h3(color: color)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------

  Widget _buildBottomBar(BuildContext context, EstimateDetailModel estimate) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            Responsive.w(18), Responsive.h(12), Responsive.w(18), Responsive.h(16)),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openDespatchSheet(context, estimate),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.local_shipping_outlined, size: 18),
            label: Text('Create Despatch Sheet',
                style: AppTextStyles.bodyBold(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared look (UI only)
// ---------------------------------------------------------------------

BoxDecoration _cardDecoration({double radius = 14}) => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border.withOpacity(0.8)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {this.color, this.size = 16});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, this.icon});
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14), vertical: Responsive.h(12)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.7))),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            _IconBadge(icon!),
            SizedBox(width: Responsive.w(10)),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyBold(color: AppColors.primary)
                  .copyWith(fontSize: Responsive.sp(14)),
            ),
          ),
        ],
      ),
    );
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
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(title: title, icon: icon),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(4)),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rows[i].icon != null) ...[
                          Icon(rows[i].icon, size: 16, color: AppColors.textHint),
                          SizedBox(width: Responsive.w(10)),
                        ],
                        if (rows[i].label.isNotEmpty) ...[
                          SizedBox(
                            width: 92,
                            child: Text(rows[i].label, style: AppTextStyles.caption()),
                          ),
                          SizedBox(width: Responsive.w(8)),
                        ],
                        Expanded(
                          child: Text(
                            rows[i].value.isEmpty ? '-' : rows[i].value,
                            style: AppTextStyles.bodyBold(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != rows.length - 1)
                    Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}