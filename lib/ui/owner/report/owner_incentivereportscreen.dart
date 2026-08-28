// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tileshop/ui/owner/report/ownerincentive_reportfilterscreen.dart';
// import 'package:tileshop/ui/owner/report/ownerreportwidget.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
//
//
// class _IncentiveRow {
//   const _IncentiveRow({
//     required this.code,
//     required this.status,
//     required this.subtitle,
//     required this.amount,
//     required this.date,
//   });
//
//   final String code;
//   final String status;
//   final String subtitle;
//   final double amount;
//   final DateTime date;
// }
//
// /// Incentive Report results screen. Not shown in the supplied mockup —
// /// built to match the same header / summary-strip / list pattern used
// /// by the Quotation and Estimate report result screens.
// class OwnerIncentiveReportScreen extends StatelessWidget {
//   const OwnerIncentiveReportScreen({
//     super.key,
//     required this.type,
//     required this.personName,
//     required this.startDate,
//     required this.endDate,
//     required this.status,
//   });
//
//   final IncentiveEntityType type;
//   final String personName;
//   final DateTime startDate;
//   final DateTime endDate;
//   final String status;
//
//   // TODO: replace with real data from your OwnerReportsBloc / repository,
//   // filtered by type + person + date range + status.
//   static final List<_IncentiveRow> _allRows = [
//     _IncentiveRow(
//       code: 'INC-202608-021',
//       status: 'Paid',
//       subtitle: 'Against QUO-202608-118',
//       amount: 3210,
//       date: DateTime(2026, 8, 10),
//     ),
//     _IncentiveRow(
//       code: 'INC-202608-020',
//       status: 'Pending',
//       subtitle: 'Against QUO-202608-117',
//       amount: 6400,
//       date: DateTime(2026, 8, 7),
//     ),
//   ];
//
//   List<_IncentiveRow> get _filteredRows {
//     if (status == 'All') return _allRows;
//     return _allRows.where((r) => r.status == status).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final rows = _filteredRows;
//
//     final totalEarned = _allRows.fold<double>(0, (sum, r) => sum + r.amount);
//     final paidCount = _allRows.where((r) => r.status == 'Paid').length;
//     final subtitle =
//         '$personName · ${DateFormat('dd').format(startDate)}\u2013${DateFormat('dd MMM yyyy').format(endDate)} · $status';
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Column(
//         children: [
//           ReportHeaderBar(
//             title: 'Incentive Report',
//             subtitle: subtitle,
//             showBack: true,
//             trailing: EditFilterButton(
//               onTap: () => Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (_) => OwnerIncentiveReportFilterScreen(
//                     initialType: type,
//                     initialPerson: personName,
//                     initialStart: startDate,
//                     initialEnd: endDate,
//                     initialStatus: status,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.all(Responsive.w(20)),
//               children: [
//                 SummaryStatsRow(
//                   stats: [
//                     SummaryStat(
//                       value: currency.format(totalEarned),
//                       label: 'Total Incentive',
//                       valueColor: const Color(0xFF16A34A),
//                     ),
//                     SummaryStat(value: '${_allRows.length}', label: 'Entries'),
//                     SummaryStat(
//                       value: '$paidCount',
//                       label: 'Paid',
//                       valueColor: AppColors.primary,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: Responsive.h(16)),
//                 for (int i = 0; i < rows.length; i++) ...[
//                   ReportListItemCard(
//                     code: rows[i].code,
//                     status: rows[i].status,
//                     subtitle: rows[i].subtitle,
//                     amountFormatted: currency.format(rows[i].amount),
//                     dateFormatted: DateFormat('dd MMM yyyy').format(rows[i].date),
//                     onTap: () {
//                       // TODO: navigate to the incentive entry detail screen.
//                     },
//                   ),
//                   if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
//                 ],
//                 if (rows.isEmpty)
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
//                     child: Center(
//                       child: Text('No incentive entries match this filter', style: AppTextStyles.caption()),
//                     ),
//                   ),
//                 SizedBox(height: Responsive.h(20)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ownerbloc/inecntivereport/incentivereport_bloc.dart';
import '../../../bloc/ownerbloc/inecntivereport/incentivereport_event.dart';
import '../../../bloc/ownerbloc/inecntivereport/incentivereport_state.dart';
import '../../../core/constants/app_colors.dart';
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

    return Scaffold(
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
                    return const Center(child: Text('No incentives found for this period.'));
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
    );
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
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
              Text('₹${item.incentiveAmount}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(color: _statusColor(), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item.notes, style: const TextStyle(fontSize: 12)),
          ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}