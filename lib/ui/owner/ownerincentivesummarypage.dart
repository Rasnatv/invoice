
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/incentive/ownerincentive_bloc.dart';
import '../../bloc/ownerbloc/incentive/ownerincentive_event.dart';
import '../../bloc/ownerbloc/incentive/ownerincentive_state.dart';
import '../../models/salesmanmodels/activeslaesman_model.dart';
import '../../models/salesmanmodels/salesmanowner_incentivemodel.dart';
import '../../widgets/appsnackbar.dart';
import 'allincentiveproductlistpage.dart';
import 'billpage.dart';

/// Same amber used for "pending" states on the Estimates screen.
const Color _amber = Color(0xFFF59E0B);

/// Input decoration that uses the app font (dialog fields).
InputDecoration _dec(String label) => InputDecoration(
  labelText: label,
  labelStyle: AppTextStyles.body(color: AppColors.textHint),
  hintStyle: AppTextStyles.body(color: AppColors.textHint),
  errorStyle: AppTextStyles.caption(color: AppColors.error),
);

/// Last day of the selected month (calculated, not hard-coded).
/// e.g. Oct 2026 -> 31 Oct 2026, Feb 2027 -> 28 Feb 2027.
DateTime _lastDayOfMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0);

/// True from the LAST DAY of the selected month onwards, with NO upper limit.
/// So October payment is possible on 31 Oct, 1 Nov, 15 Nov, 10 Dec ...
///
/// To allow payment only from the 1st of the next month, change the return to:
///   today.isAfter(last)
bool _isMonthEnded(DateTime month) {
  final last = _lastDayOfMonth(month);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return !today.isBefore(last);
}
//bool _isMonthEnded(DateTime month) => true; // TEST ONLY
/// Simple alert box (used for info / success messages).
Future<void> _showInfoAlert(
    BuildContext context, {
      required String title,
      required String message,
      IconData icon = Icons.info_outline_rounded,
      Color color = _amber,
    }) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(icon, color: color, size: 44),
      title: Text(title, style: AppTextStyles.h6(), textAlign: TextAlign.center),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.body(),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 40),
            backgroundColor: AppColors.primary,
          ),
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('OK', style: AppTextStyles.bodyBold(color: Colors.white)),
        ),
      ],
    ),
  );
}

class OwnerSalesmanIncentiveScreen extends StatelessWidget {
  const OwnerSalesmanIncentiveScreen({
    super.key,
    this.isOwner = true,
    this.initialSalesmanId,
    this.initialSalesmanName,
    this.role = 'Sales Executive',
  });

  final bool isOwner;
  final String? initialSalesmanId;
  final String? initialSalesmanName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerIncentiveBloc(
        isOwner: isOwner,
        initialSalesmanId: initialSalesmanId,
        initialSalesmanName: initialSalesmanName,
      )..add(isOwner
          ? const LoadActiveSalesmen()
          : const LoadIncentiveSummary()),
      child: _OwnerSalesmanIncentiveView(role: role),
    );
  }
}

class _OwnerSalesmanIncentiveView extends StatelessWidget {
  const _OwnerSalesmanIncentiveView({required this.role});

  final String role;

  Future<void> _pickMonth(BuildContext context, DateTime current) async {
    final now = DateTime.now();
    int pickedYear = current.year;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isCurrentYear = pickedYear == now.year;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => setModalState(() => pickedYear--),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            '$pickedYear',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyBold()
                                .copyWith(fontSize: Responsive.sp(17)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: isCurrentYear
                              ? null
                              : () => setModalState(() => pickedYear++),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(14)),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                      children: List.generate(12, (i) {
                        final m = i + 1;
                        final isFuture = isCurrentYear && m > now.month;
                        final isSelected =
                            pickedYear == current.year && m == current.month;
                        final label =
                        DateFormat('MMM').format(DateTime(pickedYear, m));

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: isFuture
                              ? null
                              : () => Navigator.of(ctx)
                              .pop(DateTime(pickedYear, m, 1)),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: Responsive.sp(12.5),
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : isFuture
                                    ? AppColors.textSecondary
                                    .withOpacity(0.4)
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<OwnerIncentiveBloc>().add(SelectMonth(picked));
    }
  }

  Future<void> _pickSalesman(
      BuildContext context, List<ActiveSalesmanModel> salesmen) async {
    final selected = await showModalBottomSheet<ActiveSalesmanModel>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text('Select Salesman', style: AppTextStyles.h6()),
                SizedBox(height: Responsive.h(10)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: salesmen.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) {
                      final s = salesmen[i];
                      return ListTile(
                        title: Text(s.name, style: AppTextStyles.bodyBold()),
                        subtitle: s.designationDisplay.isNotEmpty
                            ? Text(
                          s.designationDisplay,
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(s),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && context.mounted) {
      context.read<OwnerIncentiveBloc>().add(
        SelectSalesman(
            salesmanId: selected.id, salesmanName: selected.name),
      );
    }
  }

  /// Payment is possible from MONTH END onwards (no upper limit), but only
  /// ONE time per month. It covers product incentive + target bonus together.
  ///
  /// On tap:
  ///  1. nothing to pay      -> alert
  ///  2. already paid        -> alert (one time only)
  ///  3. month end not yet   -> alert with the date payment opens
  ///  4. otherwise           -> payment box. On OK the payment is marked and
  ///                            the "Payment Updated" alert box is shown.
  Future<void> _openMarkPaidDialog(
      BuildContext context,
      String totalIncentive,
      String productIncentive,
      String? bonusAmount,
      ) async {
    final state = context.read<OwnerIncentiveBloc>().state;
    final summary = state.summary;
    final total = summary?.totalPayableValue ?? 0;

    // 1. Nothing to pay.
    if (total <= 0) {
      await _showInfoAlert(
        context,
        title: 'No Incentive',
        message: 'There is no incentive to pay for this period.',
      );
      return;
    }

    // 2. Already paid -> one time only, even if target amount is given again.
    if (summary?.bonusStatus.isPaid == true) {
      await _showInfoAlert(
        context,
        title: 'Already Paid',
        message: 'Payment is already given for this month. It can be marked '
            'only one time, even if the target amount is given again.',
        icon: Icons.lock_outline_rounded,
      );
      return;
    }

    // 3. Month end not reached yet.
    if (!_isMonthEnded(state.selectedMonth)) {
      final lastDay = _lastDayOfMonth(state.selectedMonth);
      await _showInfoAlert(
        context,
        title: 'Payment Not Possible Now',
        message: 'Payment can be marked only at month end or later. For '
            '${DateFormat('MMMM yyyy').format(state.selectedMonth)} it opens on '
            '${DateFormat('dd MMM yyyy').format(lastDay)}. Product incentive '
            'and target bonus are paid together in one entry.',
        icon: Icons.event_busy_rounded,
      );
      return;
    }

    if (!context.mounted) return;

    final refController = TextEditingController();
    final notesController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return AlertDialog(
              title: Text('Payment Given', style: AppTextStyles.h6(color: Colors.black)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Payable',
                              style: AppTextStyles.caption(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(totalIncentive,
                              style:
                              AppTextStyles.amount(color: AppColors.success)),
                          const SizedBox(height: 2),
                          Text(
                            bonusAmount == null
                                ? 'Product incentive $productIncentive'
                                : 'Product $productIncentive + Bonus $bonusAmount',
                            style: AppTextStyles.caption(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: refController,
                      style: AppTextStyles.body(),
                      onChanged: (_) => setState(() {}),
                      decoration: _dec('Payment Reference'),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogCtx,
                          initialDate: paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => paymentDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: _dec('Payment Date'),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(paymentDate),
                          style: AppTextStyles.body(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      style: AppTextStyles.body(),
                      decoration: _dec('Notes (optional)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text('Cancel', style: AppTextStyles.bodyBold()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: refController.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(dialogCtx).pop(true),
                  child: Text('OK',
                      style: AppTextStyles.bodyBold(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    // OK tapped -> payment is marked. The success alert box is shown by the
    // BlocConsumer listener once the API call succeeds.
    if (confirmed == true && context.mounted) {
      context.read<OwnerIncentiveBloc>().add(
        MarkIncentiveAsPaid(
          paymentReference: refController.text.trim(),
          paymentDate: DateFormat('yyyy-MM-dd').format(paymentDate),
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return BlocConsumer<OwnerIncentiveBloc, OwnerIncentiveState>(
      listenWhen: (prev, curr) => prev.markPaidStatus != curr.markPaidStatus,
      listener: (context, state) {
        if (state.markPaidStatus == MarkPaidStatus.success) {
          context.read<OwnerIncentiveBloc>().add(const ClearMarkPaidStatus());
          // Alert box after a successful payment update.
          _showInfoAlert(
            context,
            title: 'Payment Updated',
            message: state.markPaidMessage ??
                'Incentive for '
                    '${DateFormat('MMMM yyyy').format(state.selectedMonth)} '
                    'has been marked as paid.',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          );
        } else if (state.markPaidStatus == MarkPaidStatus.error) {
          AppSnackbar.error(state.markPaidMessage ?? 'Failed to mark as paid.');
          context.read<OwnerIncentiveBloc>().add(const ClearMarkPaidStatus());
        }
      },
      builder: (context, state) {
        final summary = state.summary;

        // Designation of the currently selected salesman (owner mode).
        String designation = '';
        if (state.isOwner && (state.selectedSalesmanId?.isNotEmpty ?? false)) {
          for (final s in state.activeSalesmen) {
            if (s.id.toString() == state.selectedSalesmanId) {
              designation = s.designationDisplay;
              break;
            }
          }
        }

        final salesmanLabel = state.selectedSalesmanName?.isNotEmpty == true
            ? state.selectedSalesmanName!
            : 'Select Salesman';

        return NetworkAwareWrapper(
          child: Scaffold(
            backgroundColor: AppColors.background,

            // ---------- APPBAR (same as Estimates) ----------
            appBar: AppBar(
              title: Text('Salesman Incentives', style: AppTextStyles.h6()),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),

            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<OwnerIncentiveBloc>()
                      .add(const RefreshIncentiveSummary());
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ---- filters + summary ----
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(Responsive.w(20),
                            Responsive.h(14), Responsive.w(20), 0),
                        child: Column(
                          children: [
                            // Only the owner sees the salesman selector.
                            if (state.isOwner) ...[
                              _FilterTile(
                                icon: Icons.person_outline_rounded,
                                title: salesmanLabel,
                                subtitle: designation,
                                loading: state.loadingSalesmen,
                                onTap: () =>
                                    _pickSalesman(context, state.activeSalesmen),
                              ),
                              SizedBox(height: Responsive.h(10)),
                            ],
                            _FilterTile(
                              icon: Icons.calendar_today_rounded,
                              title: DateFormat('MMMM yyyy')
                                  .format(state.selectedMonth),
                              onTap: () =>
                                  _pickMonth(context, state.selectedMonth),
                            ),
                            SizedBox(height: Responsive.h(14)),
                            _SummaryCard(
                              totalSales:
                              currency.format(summary?.totalSalesValue ?? 0),
                              // total_incentive already = product incentive + bonus.
                              totalIncentive: currency
                                  .format(summary?.totalPayableValue ?? 0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (!state.canLoadSummary)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(Responsive.w(24)),
                            child: Text(
                              'Select a salesman to view their incentives.',
                              style: AppTextStyles.subtitle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    else if (state.status == SalesmanIncentiveStatus.loading &&
                        summary == null)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.status == SalesmanIncentiveStatus.error &&
                          summary == null)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(Responsive.w(24)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline_rounded,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.5),
                                      size: 38),
                                  SizedBox(height: Responsive.h(10)),
                                  Text(
                                    state.errorMessage ??
                                        'Failed to load incentive summary.',
                                    style: AppTextStyles.subtitle(),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: Responsive.h(10)),
                                  TextButton(
                                    onPressed: () => context
                                        .read<OwnerIncentiveBloc>()
                                        .add(const RefreshIncentiveSummary()),
                                    child: Text('Try again',
                                        style: AppTextStyles.bodyBold()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding:
                          EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              SizedBox(height: Responsive.h(18)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Product Wise Incentive',
                                    style: AppTextStyles.bodyBold().copyWith(
                                        fontSize: Responsive.sp(15)),
                                  ),
                                  // Opens the full paginated list from
                                  // POST /salesman-incentives/products - same
                                  // API for owner and salesman, salesman_id is
                                  // simply omitted in salesman mode.
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => AllProductsScreen(
                                            salesmanId: state.isOwner
                                                ? int.tryParse(
                                                state.selectedSalesmanId ??
                                                    '')
                                                : null,
                                            salesmanName:
                                            state.selectedSalesmanName ??
                                                summary?.salesmanName ??
                                                '-',
                                            month: state.selectedMonth,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View All',
                                      style: AppTextStyles.bodyBold(
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.h(6)),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: state.productList.isEmpty
                                    ? Padding(
                                  padding:
                                  EdgeInsets.all(Responsive.w(20)),
                                  child: Center(
                                    child: Text(
                                      'No product sales for this period.',
                                      style: AppTextStyles.caption(
                                          color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                                    : Column(
                                  children: [
                                    for (int i = 0;
                                    i < state.productList.length;
                                    i++) ...[
                                      _ProductIncentiveTile(
                                        item: state.productList[i],
                                        currency: currency,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  OwnerProductBillsPage(
                                                    product:
                                                    state.productList[i],
                                                    month: state.selectedMonth,
                                                    salesmanId: state.isOwner
                                                        ? state
                                                        .selectedSalesmanId
                                                        : null,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (i !=
                                          state.productList.length - 1)
                                        Divider(
                                          height: 1,
                                          indent: Responsive.w(16),
                                          endIndent: Responsive.w(16),
                                          color: AppColors.border,
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: Responsive.h(16)),
                              if (summary != null) ...[
                                Builder(builder: (_) {
                                  final productIncentive =
                                      summary.productIncentiveValue;
                                  final bonusAmount = summary.bonusAmountValue;
                                  final totalPayable = summary.totalPayableValue;

                                  final hasIncentive = totalPayable > 0;
                                  final isPaid =
                                      hasIncentive && summary.bonusStatus.isPaid;
                                  final monthEnded =
                                  _isMonthEnded(state.selectedMonth);

                                  return Column(
                                    children: [
                                      // Target / bonus card. The API can return
                                      // target_amount = 0 and bonus_display = "None"
                                      // even when a bonus was earned, so the real
                                      // bonus comes from
                                      // bonus_status.month_bonus_amount.
                                      if (summary.target.targetAmountValue > 0 ||
                                          summary.bonusAmountValue > 0) ...[
                                        _TargetProgressCard(
                                          title: 'Monthly Sales Target',
                                          icon: Icons.track_changes_rounded,
                                          color: AppColors.success,
                                          headlineValue:
                                          summary.target.targetAmountValue > 0
                                              ? currency.format(summary
                                              .target.targetAmountValue)
                                              : 'Not set',
                                          achievedAmount: currency
                                              .format(summary.totalSalesValue),
                                          targetTotal: currency.format(
                                              summary.target.targetAmountValue),
                                          fraction:
                                          summary.target.progressFraction,
                                          achievedLabel: summary.target.achieved,
                                          hasTarget:
                                          summary.target.targetAmountValue > 0,
                                          bonusDisplay: summary
                                              .bonusAmountValue >
                                              0
                                              ? currency.format(
                                              summary.bonusAmountValue)
                                              : summary.target.bonusDisplay,
                                          // After payment the month is locked.
                                          paidLocked: isPaid,
                                        ),
                                        SizedBox(height: Responsive.h(16)),
                                      ],

                                      // total_incentive from the API already
                                      // = product incentive + bonus, so it is NOT
                                      // added again.
                                      _IncentivePaymentCard(
                                        productIncentive:
                                        currency.format(productIncentive),
                                        bonusAmount: bonusAmount > 0
                                            ? currency.format(bonusAmount)
                                            : null,
                                        totalPayable:
                                        currency.format(totalPayable),
                                        hasIncentive: hasIncentive,
                                        isPaid: isPaid,
                                        // Only meaningful once paid.
                                        paidAmount: currency.format(isPaid
                                            ? summary.bonusStatus.totalPaidValue
                                            : 0),
                                        paidAt: summary.bonusStatus.paidAt,
                                        paymentReference:
                                        summary.bonusStatus.paymentReference,
                                        // Button is ALWAYS shown for the owner when
                                        // there is an unpaid incentive. Month-end
                                        // and one-time rules are checked on tap.
                                        canMarkPaid:
                                        state.isOwner && hasIncentive && !isPaid,
                                        // Hint text only, before month end.
                                        waitingForMonthEnd: !monthEnded,
                                        markingPaid: state.markPaidStatus ==
                                            MarkPaidStatus.submitting,
                                        onTapMarkPaid: () => _openMarkPaidDialog(
                                          context,
                                          currency.format(totalPayable),
                                          currency.format(productIncentive),
                                          bonusAmount > 0
                                              ? currency.format(bonusAmount)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                              SizedBox(height: Responsive.h(30)),
                            ]),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =====================================================================
// FILTER TILES + SUMMARY
// =====================================================================

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle = '',
    this.loading = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(14),
            vertical: Responsive.h(12),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              SizedBox(width: Responsive.w(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(
                            color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalSales, required this.totalIncentive});

  final String totalSales;
  final String totalIncentive;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    color: AppColors.success, size: 18),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: Text('Monthly Incentive Summary',
                    style: AppTextStyles.bodyBold()),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'Total Sales',
                  value: totalSales,
                  sub: 'This Month',
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.border,
                margin: EdgeInsets.symmetric(horizontal: Responsive.w(8)),
              ),
              Expanded(
                child: _SummaryStat(
                  label: 'Incentive Earned',
                  value: totalIncentive,
                  sub: 'This Month',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: Responsive.h(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.amount(color: color)),
        ),
        SizedBox(height: Responsive.h(1)),
        Text(sub,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// =====================================================================
// PRODUCT TILE
// =====================================================================

class _ProductIncentiveTile extends StatelessWidget {
  const _ProductIncentiveTile({
    required this.item,
    required this.currency,
    required this.onTap,
  });

  final IncentiveProductModel item;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(14), vertical: Responsive.h(12)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: AppColors.primary, size: 20),
            ),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'Incentive: ${item.incentiveRateDisplay}%',
                    style: AppTextStyles.caption(color: AppColors.success),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(item.totalSalesValue),
                      style: AppTextStyles.body(), textAlign: TextAlign.right),
                  SizedBox(height: Responsive.h(2)),
                  Text('${item.totalUnitsInt} Units',
                      style:
                      AppTextStyles.caption(color: AppColors.textSecondary),
                      textAlign: TextAlign.right),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(4)),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      currency.format(item.incentiveEarnedValue),
                      style: AppTextStyles.bodyBold(color: AppColors.success),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// TARGET PROGRESS CARD
// =====================================================================

/// Monthly target card. The bonus badge shows only when there is a real bonus,
/// and the progress / achieved status shows only when a target amount is set.
///
/// When [paidLocked] is true (month already paid) an info line explains that
/// giving the target amount again will not allow another payment.
class _TargetProgressCard extends StatelessWidget {
  const _TargetProgressCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.headlineValue,
    required this.achievedAmount,
    required this.targetTotal,
    required this.fraction,
    required this.achievedLabel,
    required this.hasTarget,
    this.bonusDisplay,
    this.paidLocked = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String headlineValue;
  final String achievedAmount;
  final String targetTotal;
  final double fraction;
  final String achievedLabel;
  final bool hasTarget;
  final String? bonusDisplay;
  final bool paidLocked;

  bool get _hasBonus {
    final b = bonusDisplay?.trim() ?? '';
    if (b.isEmpty) return false;
    final lower = b.toLowerCase();
    if (lower == 'none' || lower == 'null' || lower == 'n/a' || lower == '-') {
      return false;
    }
    final value = double.tryParse(b.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (value != null && value <= 0) return false;
    return true;
  }

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.bodyBold()),
                          SizedBox(height: Responsive.h(2)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(headlineValue,
                                style: AppTextStyles.amount(color: color)),
                          ),
                        ],
                      ),
                    ),
                    if (_hasBonus)
                      _Pill(label: 'Bonus $bonusDisplay', color: color),
                  ],
                ),
                if (hasTarget) ...[
                  SizedBox(height: Responsive.h(10)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  SizedBox(height: Responsive.h(6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '$achievedAmount / $targetTotal',
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (achievedLabel.isNotEmpty)
                        Text(achievedLabel,
                            style: AppTextStyles.caption(color: color)),
                    ],
                  ),
                ],
                if (paidLocked) ...[
                  SizedBox(height: Responsive.h(10)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 14, color: AppColors.textSecondary),
                      SizedBox(width: Responsive.w(6)),
                      Expanded(
                        child: Text(
                          'Payment already given for this month. If the target '
                              'amount is given again, payment cannot be done again.',
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(10.5),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncentivePaymentCard extends StatelessWidget {
  const _IncentivePaymentCard({
    required this.productIncentive,
    this.bonusAmount,
    required this.totalPayable,
    required this.hasIncentive,
    required this.isPaid,
    required this.paidAmount,
    this.paidAt,
    required this.paymentReference,
    required this.canMarkPaid,
    this.waitingForMonthEnd = false,
    required this.markingPaid,
    this.onTapMarkPaid,
  });

  final String productIncentive;
  final String? bonusAmount; // null -> no bonus, row hidden
  final String totalPayable;
  final bool hasIncentive; // false -> nothing to pay, no paid status
  final bool isPaid;
  final String paidAmount;
  final String? paidAt;
  final String paymentReference;
  final bool canMarkPaid;
  final bool waitingForMonthEnd; // true -> hint under the button
  final bool markingPaid;
  final VoidCallback? onTapMarkPaid;

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold
              ? AppTextStyles.bodyBold()
              : AppTextStyles.body(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: bold
              ? AppTextStyles.bodyBold(color: color ?? AppColors.textPrimary)
              : AppTextStyles.body(),
        ),
      ],
    );
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                Text('Incentive Payment', style: AppTextStyles.bodyBold()),
              ),
              _Pill(
                label: !hasIncentive
                    ? 'No Incentive'
                    : (isPaid ? 'Paid' : 'Unpaid'),
                color: !hasIncentive
                    ? AppColors.textSecondary
                    : (isPaid ? AppColors.success : _amber),
                icon: hasIncentive && isPaid
                    ? Icons.check_circle_rounded
                    : null,
              ),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(12)),

          _row('Product Incentive', productIncentive),
          if (bonusAmount != null) ...[
            SizedBox(height: Responsive.h(6)),
            _row('Bonus Amount', bonusAmount!),
          ],
          SizedBox(height: Responsive.h(10)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),
          _row('Total Payable', totalPayable,
              bold: true, color: AppColors.success),

          if (!hasIncentive) ...[
            SizedBox(height: Responsive.h(10)),
            Text(
              'No incentive earned for this period, so no payment is due.',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ] else if (isPaid) ...[
            SizedBox(height: Responsive.h(10)),
            _row('Amount Paid', paidAmount),
            if ((paidAt?.isNotEmpty ?? false) ||
                paymentReference.isNotEmpty) ...[
              SizedBox(height: Responsive.h(6)),
              Text(
                [
                  if (paidAt != null && paidAt!.isNotEmpty) paidAt!,
                  if (paymentReference.isNotEmpty) 'Ref: $paymentReference',
                ].join(' • '),
                style: AppTextStyles.caption(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: Responsive.h(10)),




          ] else if (canMarkPaid) ...[
            SizedBox(height: Responsive.h(14)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // Disabled only while a payment request is in progress, which
                // also prevents a double tap.
                onPressed: markingPaid ? null : onTapMarkPaid,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: markingPaid
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.paid_rounded, size: 18),
                label: Text(
                  'Payment Given • $totalPayable',
                  style: AppTextStyles.bodyBold(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(8)),
            Text(
              waitingForMonthEnd
                  ? 'Payment can be marked at month end or later, one time only.'
                  : 'Payment can be marked one time only for this month.',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}