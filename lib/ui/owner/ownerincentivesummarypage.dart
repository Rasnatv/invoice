import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../bloc/ownerbloc/incentive/ownerincentive_bloc.dart';
import '../../bloc/ownerbloc/incentive/ownerincentive_event.dart';
import '../../bloc/ownerbloc/incentive/ownerincentive_state.dart';
import '../../models/salesmanmodels/activeslaesman_model.dart';
import '../../models/salesmanmodels/salesmanowner_incentivemodel.dart';
import 'billpage.dart';



/// Owner-facing salesman incentive summary screen.
///
/// Replaces the old dummy [SalesmanIncentiveScreen]. Pass [isOwner]=false
/// (and no dropdown will show) to reuse this same screen for a salesman
/// looking at their own incentives — the bloc simply omits `salesman_id`
/// from every request in that mode.
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
      )
        ..add(isOwner ? const LoadActiveSalesmen() : const LoadIncentiveSummary()),
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
                            style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(18)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: isCurrentYear ? null : () => setModalState(() => pickedYear++),
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
                        final isSelected = pickedYear == current.year && m == current.month;
                        final label = DateFormat('MMM').format(DateTime(pickedYear, m));

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isFuture ? null : () => Navigator.of(ctx).pop(DateTime(pickedYear, m, 1)),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : isFuture
                                  ? AppColors.border.withOpacity(0.25)
                                  : AppColors.border.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? null : Border.all(color: AppColors.border.withOpacity(0.6)),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: Responsive.sp(13.5),
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : isFuture
                                    ? AppColors.textSecondary.withOpacity(0.4)
                                    : AppColors.textSecondary,
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

  Future<void> _pickSalesman(BuildContext context, List<ActiveSalesmanModel> salesmen) async {
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
                Text('Select Salesman', style: AppTextStyles.bodyBold().copyWith(fontSize: Responsive.sp(16))),
                SizedBox(height: Responsive.h(10)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: salesmen.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) {
                      final s = salesmen[i];
                      return ListTile(
                        title: Text(s.name, style: AppTextStyles.bodyBold()),
                        subtitle: s.designationDisplay.isNotEmpty ? Text(s.designationDisplay) : null,
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
        SelectSalesman(salesmanId: selected.id, salesmanName: selected.name),
      );
    }
  }

  Future<void> _openMarkPaidDialog(BuildContext context) async {
    final refController = TextEditingController();
    final notesController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return AlertDialog(
              title: const Text('Mark Incentive as Paid'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: refController,
                      decoration: const InputDecoration(labelText: 'Payment Reference'),
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
                        if (picked != null) setState(() => paymentDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Payment Date'),
                        child: Text(DateFormat('dd MMM yyyy').format(paymentDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: refController.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(dialogCtx).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<OwnerIncentiveBloc>().add(
        MarkIncentiveAsPaid(
          paymentReference: refController.text.trim(),
          paymentDate: DateFormat('yyyy-MM-dd').format(paymentDate),
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return BlocConsumer<OwnerIncentiveBloc, OwnerIncentiveState>(
      listenWhen: (prev, curr) => prev.markPaidStatus != curr.markPaidStatus,
      listener: (context, state) {
        if (state.markPaidStatus == MarkPaidStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.markPaidMessage ?? 'Incentive marked as paid.')),
          );
          context.read<OwnerIncentiveBloc>().add(const ClearMarkPaidStatus());
        } else if (state.markPaidStatus == MarkPaidStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.markPaidMessage ?? 'Failed to mark as paid.')),
          );
          context.read<OwnerIncentiveBloc>().add(const ClearMarkPaidStatus());
        }
      },
      builder: (context, state) {
        final summary = state.summary;
        final salesFraction = summary == null
            ? 0.0
            : (summary.totalSalesValue / (summary.target.targetAmountValue == 0 ? 1 : summary.target.targetAmountValue))
            .clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<OwnerIncentiveBloc>().add(const RefreshIncentiveSummary());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _IncentiveHeader(
                    isOwner: state.isOwner,
                    salesmanName: state.selectedSalesmanName ?? summary?.salesmanName ?? '-',
                    role: role,
                    selectedMonth: state.selectedMonth,
                    onTapMonth: () => _pickMonth(context, state.selectedMonth),
                    onTapSalesman: state.isOwner ? () => _pickSalesman(context, state.activeSalesmen) : null,
                    loadingSalesmen: state.loadingSalesmen,
                    onBack: () => Navigator.of(context).maybePop(),
                    totalSales: currency.format(summary?.totalSalesValue ?? 0),
                    totalIncentive: currency.format(summary?.totalIncentiveValue ?? 0),
                    onTapMarkPaid: state.canLoadSummary ? () => _openMarkPaidDialog(context) : null,
                    markingPaid: state.markPaidStatus == MarkPaidStatus.submitting,
                  ),
                ),
                if (!state.canLoadSummary)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: Responsive.h(70)),
                      child: Center(
                        child: Text(
                          'Select a salesman to view their incentives.',
                          style: AppTextStyles.caption(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                else if (state.status == SalesmanIncentiveStatus.loading && summary == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: Responsive.h(90)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (state.status == SalesmanIncentiveStatus.error && summary == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.only(top: Responsive.h(80)),
                        child: Center(
                          child: Text(
                            state.errorMessage ?? 'Failed to load incentive summary.',
                            style: AppTextStyles.caption(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: Responsive.h(66)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Product Wise Incentive', style: AppTextStyles.h3()),
                            ],
                          ),
                          SizedBox(height: Responsive.h(10)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: state.productList.isEmpty
                                ? Padding(
                              padding: EdgeInsets.all(Responsive.w(20)),
                              child: Text(
                                'No product sales for this period.',
                                style: AppTextStyles.caption(color: AppColors.textSecondary),
                              ),
                            )
                                : Column(
                              children: [
                                for (int i = 0; i < state.productList.length; i++) ...[
                                  _ProductIncentiveTile(
                                    item: state.productList[i],
                                    currency: currency,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => OwnerProductBillsPage(
                                            product: state.productList[i],
                                            month: state.selectedMonth,
                                            salesmanId: state.isOwner ? state.selectedSalesmanId : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (i != state.productList.length - 1)
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
                          SizedBox(height: Responsive.h(20)),
                          if (summary != null)
                            _TargetProgressCard(
                              title: 'Monthly Sales Target',
                              icon: Icons.track_changes_rounded,
                              color: AppColors.success,
                              headlineValue: currency.format(summary.target.targetAmountValue),
                              achievedAmount: currency.format(summary.totalSalesValue),
                              targetTotal: currency.format(summary.target.targetAmountValue),
                              fraction: summary.target.progressFraction,
                              achievedLabel: summary.target.achieved,
                              bonusDisplay: summary.target.bonusDisplay,
                            ),
                          SizedBox(height: Responsive.h(50)),
                        ]),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IncentiveHeader extends StatelessWidget {
  const _IncentiveHeader({
    required this.isOwner,
    required this.salesmanName,
    required this.role,
    required this.selectedMonth,
    required this.onTapMonth,
    required this.onTapSalesman,
    required this.loadingSalesmen,
    required this.onBack,
    required this.totalSales,
    required this.totalIncentive,
    required this.onTapMarkPaid,
    required this.markingPaid,
  });

  final bool isOwner;
  final String salesmanName;
  final String role;
  final DateTime selectedMonth;
  final VoidCallback onTapMonth;
  final VoidCallback? onTapSalesman;
  final bool loadingSalesmen;
  final VoidCallback onBack;
  final String totalSales;
  final String totalIncentive;
  final VoidCallback? onTapMarkPaid;
  final bool markingPaid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(8),
            Responsive.h(4),
            Responsive.w(20),
            Responsive.h(70),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Salesman Incentives',
                        style: AppTextStyles.bodyBold(color: Colors.white).copyWith(fontSize: Responsive.sp(17)),
                      ),
                    ),
                    // Mark-as-paid button lives in the header so it's always reachable.
                    IconButton(
                      tooltip: 'Mark as Paid',
                      onPressed: markingPaid ? null : onTapMarkPaid,
                      icon: markingPaid
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.paid_rounded, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                Padding(
                  padding: EdgeInsets.only(left: Responsive.w(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onTapSalesman,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      salesmanName.isEmpty ? '-' : salesmanName,
                                      style: AppTextStyles.bodyBold(color: Colors.white)
                                          .copyWith(fontSize: Responsive.sp(19)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isOwner) ...[
                                    SizedBox(width: Responsive.w(4)),
                                    loadingSalesmen
                                        ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                        : const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                                  ],
                                ],
                              ),
                              SizedBox(height: Responsive.h(2)),
                              Text(
                                role,
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: Responsive.sp(13)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onTapMonth,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(10), vertical: Responsive.h(8)),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                              SizedBox(width: Responsive.w(6)),
                              Text(
                                DateFormat('MMMM yyyy').format(selectedMonth),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(12.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Positioned(
          left: Responsive.w(20),
          right: Responsive.w(20),
          bottom: -Responsive.h(50),
          child: _SummaryCard(totalSales: totalSales, totalIncentive: totalIncentive),
        ),
      ],
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
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Monthly Incentive Summary', style: AppTextStyles.bodyBold())),
              Container(
                padding: EdgeInsets.all(Responsive.w(8)),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded, color: AppColors.success, size: 20),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(label: 'Total Sales', value: totalSales, sub: 'This Month', color: AppColors.primary),
              ),
              Container(width: 1, height: 50, color: AppColors.border, margin: EdgeInsets.symmetric(horizontal: Responsive.w(6))),
              Expanded(
                child: _SummaryStat(
                  label: 'Total Incentive Earned',
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
  const _SummaryStat({required this.label, required this.value, required this.sub, required this.color});

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
        Text(label, style: AppTextStyles.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: Responsive.h(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.h3(color: color)),
        ),
        SizedBox(height: Responsive.h(1)),
        Text(sub, style: AppTextStyles.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ProductIncentiveTile extends StatelessWidget {
  const _ProductIncentiveTile({required this.item, required this.currency, required this.onTap});

  final IncentiveProductModel item;
  final NumberFormat currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(14), vertical: Responsive.h(12)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: Responsive.w(10)),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: AppTextStyles.bodyBold(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'Incentive: ${item.incentiveRate}%',
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
                  Text(currency.format(item.totalSalesValue), style: AppTextStyles.body(), textAlign: TextAlign.right),
                  SizedBox(height: Responsive.h(2)),
                  Text('${item.totalUnitsInt} Units', style: AppTextStyles.caption(), textAlign: TextAlign.right),
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
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    this.bonusDisplay,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String headlineValue;
  final String achievedAmount;
  final String targetTotal;
  final double fraction;
  final String achievedLabel;
  final String? bonusDisplay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(10)),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(headlineValue, style: AppTextStyles.h3(color: color)),
                          ),
                        ],
                      ),
                    ),
                    if (bonusDisplay != null && bonusDisplay!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(8), vertical: Responsive.h(4)),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Bonus $bonusDisplay', style: AppTextStyles.caption(color: color)),
                      ),
                  ],
                ),
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
                      child: Text('$achievedAmount / $targetTotal', style: AppTextStyles.caption(), overflow: TextOverflow.ellipsis),
                    ),
                    Text(achievedLabel, style: AppTextStyles.caption(color: color)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}