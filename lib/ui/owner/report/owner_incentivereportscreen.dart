
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
import 'ownerreportwidget.dart';

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
      status: widget.status.toLowerCase() == 'all' ? null : widget.status,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(const LoadMoreIncentiveReport());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ReportHeaderBar(
            title: 'Incentive Report — ${widget.personName}',
            showBack: true,
          ),
          Expanded(
            child: BlocBuilder<IncentiveReportBloc, IncentiveReportState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is IncentiveReportLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is IncentiveReportError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: _fetch,
                  );
                }

                if (state is IncentiveReportLoaded) {
                  if (state.items.isEmpty) {
                    return Center(
                      child: Text(
                        'No incentives found for this period.',
                        style: AppTextStyles.caption(),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _fetch(),
                    child: ListView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(Responsive.w(20)),
                      children: [
                        _SummaryCard(summary: state.summary),
                        SizedBox(height: Responsive.h(16)),
                        ...state.items.map((IncentiveListItemModel item) => Padding(
                          padding: EdgeInsets.only(bottom: Responsive.h(12)),
                          child: _IncentiveTile(item: item),
                        )),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    ));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final IncentiveSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryStat(label: 'Total Incentive', value: '₹${summary.totalIncentive}'),
          _SummaryStat(label: 'Paid', value: summary.paidCount),
          _SummaryStat(label: 'Pending', value: summary.pendingCount),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3()),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }
}

class _IncentiveTile extends StatelessWidget {
  const _IncentiveTile({required this.item});

  final IncentiveListItemModel item;

  Color _statusColor() {
    switch (item.status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${item.incentiveAmount}', style: AppTextStyles.bodyBold()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusLabel,
                  style: AppTextStyles.caption(color: _statusColor())
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.createdAt, style: AppTextStyles.caption()),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item.notes, style: AppTextStyles.caption(color: AppColors.textPrimary)),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message ?? '', textAlign: TextAlign.center, style: AppTextStyles.caption()),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}