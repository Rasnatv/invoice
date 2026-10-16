
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../bloc/ownerbloc/inecntivereport/incentivereport_bloc.dart';
import '../../../bloc/ownerbloc/inecntivereport/incentivereport_event.dart';
import '../../../bloc/ownerbloc/inecntivereport/incentivereport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/incentivereportmodel.dart';
import 'ownerincentive_reportfilterscreen.dart';

const Color _amberColor = Color(0xFFF59E0B);

/// Shows the result of POST /reports/incentives for the filters chosen on
/// [OwnerIncentiveReportFilterScreen].
class OwnerIncentiveReportScreen extends StatefulWidget {
  const OwnerIncentiveReportScreen({
    super.key,
    required this.type,
    required this.personId,
    required this.personName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final IncentiveEntityType type;
  final String personId;
  final String personName;
  final DateTime startDate;
  final DateTime endDate;

  /// Display value from the filter screen's status chips ('All', 'Paid',
  /// 'Pending'). Converted to the backend's lowercase status key (or
  /// omitted entirely for 'All') inside the bloc/provider.
  final String status;

  @override
  State<OwnerIncentiveReportScreen> createState() =>
      _OwnerIncentiveReportScreenState();
}

class _OwnerIncentiveReportScreenState
    extends State<OwnerIncentiveReportScreen> {
  late final IncentiveReportBloc _bloc;
  late final ScrollController _scrollController;

  static String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _bloc = IncentiveReportBloc();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _fetch() {
    _bloc.add(FetchIncentiveReport(
      type: widget.type == IncentiveEntityType.salesman
          ? 'salesman'
          : 'field_staff',
      personId: widget.personId,
      fromDate: _apiDate(widget.startDate),
      toDate: _apiDate(widget.endDate),
      status: widget.status.toLowerCase() == 'all'
          ? null
          : widget.status.toLowerCase(),
    ));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _bloc.add(const LoadMoreIncentiveReport());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates / Drivers) ----------
        appBar: AppBar(
          title: Text('Incentive Report', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocBuilder<IncentiveReportBloc, IncentiveReportState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is IncentiveReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is IncentiveReportError) {
                return _ErrorView(message: state.message, onRetry: _fetch);
              }

              if (state is IncentiveReportLoaded) {
                if (state.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => _fetch(),
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.savings_outlined,
                                  size: 44,
                                  color:
                                  AppColors.textSecondary.withOpacity(0.4),
                                ),
                                SizedBox(height: Responsive.h(10)),
                                Text('No incentives found for this period.',
                                    style: AppTextStyles.subtitle()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetch(),
                  child: ListView(
                    controller: _scrollController,
                    // Needed so pull-to-refresh works even when content is short
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: listPadding,
                    children: [
                      _SummaryCard(summary: state.summary),
                      SizedBox(height: Responsive.h(18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionHeader('Incentives'),
                          _StatusPill(
                            label:
                            '${state.items.length} ${state.items.length == 1 ? 'entry' : 'entries'}',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(10)),
                      for (var i = 0; i < state.items.length; i++) ...[
                        _IncentiveTile(item: state.items[i]),
                        if (i != state.items.length - 1)
                          SizedBox(height: Responsive.h(10)),
                      ],
                      if (state.isLoadingMore)
                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: Responsive.h(16)),
                          child: const Center(
                              child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared look (same as the Estimate Details / Estimates list)
// ---------------------------------------------------------------------

/// White, radius 16, 1px border, no shadow.
BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: c),
    );
  }
}

/// Square icon tile used on list cards (same as the Estimates list).
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

/// Blue-bar section heading.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(title, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final IncentiveSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar: icon badge + title, divider underneath
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const _IconBadge(Icons.calculate_outlined),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: Text('Summary', style: AppTextStyles.bodyBold()),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryStat(
                  label: 'Total Incentive',
                  value: '₹${summary.totalIncentive}',
                  color: AppColors.primary,
                ),
                const _StatDivider(),
                _SummaryStat(
                  label: 'Paid',
                  value: summary.paidCount,
                  color: AppColors.success,
                ),
                const _StatDivider(),
                _SummaryStat(
                  label: 'Pending',
                  value: summary.pendingCount,
                  color: _amberColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.border);
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextStyles.amount(color: color)),
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Incentive row
// ---------------------------------------------------------------------

class _IncentiveTile extends StatelessWidget {
  const _IncentiveTile({required this.item});

  final IncentiveListItemModel item;

  Color _statusColor() {
    switch (item.status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return _amberColor;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(icon: Icons.savings_rounded),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${item.incentiveAmount}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.amount(color: AppColors.primary),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: AppColors.textSecondary),
                        SizedBox(width: Responsive.w(5)),
                        Expanded(
                          child: Text(
                            item.createdAt,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(label: item.statusLabel, color: color),
            ],
          ),
          if (item.notes.isNotEmpty) ...[
            SizedBox(height: Responsive.h(12)),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: Responsive.h(10)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sticky_note_2_outlined,
                    size: 14, color: AppColors.textSecondary),
                SizedBox(width: Responsive.w(6)),
                Expanded(
                  child: Text(
                    item.notes,
                    style: AppTextStyles.caption(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String? message;
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
            Text(
              (message == null || message!.isEmpty)
                  ? 'Failed to load incentives.'
                  : message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
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