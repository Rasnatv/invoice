import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import 'package:tileshop/ui/owner/widget/ownerestimatedetailscreenwidget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/salemanbloc/estimatedetail/estimate_detail_event.dart';
import '../../bloc/salemanbloc/estimatedetail/estimate_detail_state.dart';
import '../../bloc/salemanbloc/estimatedetail/estimatedetail_bloc.dart';
import '../../models/salesmanmodels/estimatedetail.model.dart';
import '../../widgets/owner_estimateshimmer.dart';
import '../owner/ownerdespatchsheet.dart';

class SalesmanEstimateDetailsScreen extends StatefulWidget {
  const SalesmanEstimateDetailsScreen({super.key, required this.id});

  final String id;

  @override
  State<SalesmanEstimateDetailsScreen> createState() =>
      _EstimateDetailsScreenState();
}

class _EstimateDetailsScreenState extends State<SalesmanEstimateDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      EstimateDetailBloc()..add(EstimateDetailRequested(widget.id)),
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

  /// Manual refresh (pull-to-refresh). Waits until the bloc finishes
  /// loading so the RefreshIndicator spinner stays visible.
  Future<void> _refresh() async {
    _bloc.add(EstimateDetailRequested(widget.id));

    await _bloc.stream
        .firstWhere((s) => s.status != EstimateDetailStatus.loading)
        .timeout(const Duration(seconds: 20), onTimeout: () => _bloc.state);
  }

  /// Derived from the API's `created_by_details.role_label`. When the
  /// estimate was created by an Owner, the Incentive column is hidden;
  /// for a Salesman-created estimate it stays visible.
  bool _isOwner(EstimateDetailModel estimate) {
    return estimate.createdByDetails.roleLabel.trim().toLowerCase() == 'owner';
  }

  bool _isDelivered(EstimateDetailModel estimate) {
    final s = estimate.status.trim().toLowerCase();
    return s == 'delivered' || s == 'despatched' || s == 'dispatched';
  }

  void _openDespatchSheet(
      BuildContext context, EstimateDetailModel estimate) async {
    final despatched = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OwnerDespatchSheetScreen(estimateId: estimate.id),
      ),
    );

    if (despatched == true && context.mounted) {
      // Pop this screen too, returning to the screen that opened it
      // (e.g. Approved Bills) instead of the dashboard.
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final number = NumberFormat.decimalPattern('en_IN');

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as owner) ----------
        appBar: AppBar(
          title: Text('Estimate Detail', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocBuilder<EstimateDetailBloc, EstimateDetailState>(
            builder: (context, state) {
              // ---- loading skeleton ----
              // Only when there is nothing to show yet. During a refresh
              // the old data stays on screen.
              if (state.detail == null &&
                  state.status != EstimateDetailStatus.failure) {
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
                          message: state.error ?? 'Failed to load estimate.',
                          onRetry: () => context
                              .read<EstimateDetailBloc>()
                              .add(EstimateDetailRequested(widget.id)),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final estimate = state.detail!;
              final isOwner = _isOwner(estimate);

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refresh,
                      child: ListView(
                        // Needed so pull-to-refresh works even when content is short
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: listPadding,
                        children: [
                          EstimateHeader(detail: estimate),
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
                              DetailRow('Name', estimate.customerName,
                                  icon: Icons.groups_2_outlined),
                              DetailRow('Phone', estimate.customerPhone,
                                  icon: Icons.phone_outlined),
                              DetailRow('Email', estimate.customerEmail,
                                  icon: Icons.email_outlined),
                              DetailRow('Address', estimate.customerAddress,
                                  icon: Icons.location_on_outlined),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),
                          DetailSection(
                            title: 'Contractor Details',
                            icon: Icons.person_outline,
                            rows: [
                              DetailRow('Name', estimate.customer.name,
                                  icon: Icons.person_outline),
                              DetailRow('Phone', estimate.customer.phone,
                                  icon: Icons.phone_outlined),
                              DetailRow('Email', estimate.customer.email,
                                  icon: Icons.email_outlined),
                            ],
                          ),
                          SizedBox(height: Responsive.h(14)),
                          // Salesman section: always shown, including for owners.
                          DetailSection(
                            title: 'Salesman',
                            icon: Icons.badge_outlined,
                            rows: [
                              DetailRow('Name', estimate.salesman.name,
                                  icon: Icons.badge_outlined),
                            ],
                          ),
                          if (estimate.siteVisit.id.isNotEmpty) ...[
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Site Visit',
                              icon: Icons.location_history_outlined,
                              rows: [
                                DetailRow('Visit Date',
                                    estimate.siteVisit.visitDate,
                                    icon: Icons.event_outlined),
                                DetailRow('Status',
                                    estimate.siteVisit.statusLabel,
                                    icon: Icons.flag_outlined),
                                DetailRow('Field Staff',
                                    estimate.siteVisit.fieldStaffName,
                                    icon: Icons.engineering_outlined),
                              ],
                            ),
                          ],
                          if (estimate.isApproved) ...[
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Approval',
                              icon: Icons.check_circle_outline,
                              rows: [
                                DetailRow(
                                  'Approved By',
                                  estimate.approvedByDetails.name.isNotEmpty
                                      ? estimate.approvedByDetails.name
                                      : estimate.approvedBy,
                                  icon: Icons.check_circle_outline,
                                ),
                                if (estimate.approvedAt.isNotEmpty)
                                  DetailRow('Approved At', estimate.approvedAt,
                                      icon: Icons.event_outlined),
                                if (estimate.approvalNotes.isNotEmpty)
                                  DetailRow('Notes', estimate.approvalNotes,
                                      icon: Icons.info_outline),
                              ],
                            ),
                          ],
                          if (estimate.quotation.exists) ...[
                            SizedBox(height: Responsive.h(14)),
                            DetailSection(
                              title: 'Linked Quotation',
                              icon: Icons.description_outlined,
                              rows: [
                                DetailRow('Quotation No.',
                                    estimate.quotation.quotationNumber,
                                    icon: Icons.description_outlined),
                                DetailRow('Status', estimate.quotation.status,
                                    icon: Icons.flag_outlined),
                              ],
                            ),
                          ],
                          SizedBox(height: Responsive.h(18)),
                          EstimateItemsTable(
                              detail: estimate,
                              number: number,
                              isOwner: isOwner),
                          SizedBox(height: Responsive.h(14)),

                          // Discount, payment and balance only mean something
                          // once the estimate is approved. While pending those
                          // fields are still zero on the server, so show a
                          // plain totals card instead of misleading zeros.
                          if (estimate.isApproved)
                            EstimateSummary(detail: estimate, number: number)
                          else
                            DetailSection(
                              title: 'Summary',
                              icon: Icons.calculate_outlined,
                              rows: [
                                DetailRow('Total Sq.Ft',
                                    number.format(estimate.totalSquareFeet)),
                                DetailRow('Subtotal',
                                    currencyFmt.f(estimate.subtotal)),
                                DetailRow('Handling',
                                    currencyFmt.f(estimate.handlingCharge)),
                                DetailRow('Total',
                                    currencyFmt.f(estimate.grandTotal)),
                              ],
                            ),

                          if (estimate.payments.isNotEmpty) ...[
                            SizedBox(height: Responsive.h(14)),
                            EstimatePayments(detail: estimate),
                          ],
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
  // Bottom bar (same container as the owner screen)
  // ---------------------------------------------------------------------

  Widget _buildBottomBar(BuildContext context, EstimateDetailModel estimate) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(Responsive.w(20), Responsive.h(10),
            Responsive.w(20), Responsive.h(14)),
        child: SizedBox(
          width: double.infinity,
          height: Responsive.h(48),
          child: ElevatedButton.icon(
            onPressed: () => _openDespatchSheet(context, estimate),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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

// =====================================================================
// ERROR / SKELETON (private to this file, same as owner screen)
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