// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import 'ownerreportfilterscreen.dart';
// import 'ownerreportwidget.dart';
//
// class _ReportRow {
//   const _ReportRow({
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
// /// Full performance summary for a single salesman.
// /// Matches mockup frame 3.
// class OwnerSalesmanReportScreen extends StatefulWidget {
//   const OwnerSalesmanReportScreen({
//     super.key,
//     required this.salesmanName,
//     required this.startDate,
//     required this.endDate,
//   });
//
//   final String salesmanName;
//   final DateTime startDate;
//   final DateTime endDate;
//
//   @override
//   State<OwnerSalesmanReportScreen> createState() => _OwnerSalesmanReportScreenState();
// }
//
// class _OwnerSalesmanReportScreenState extends State<OwnerSalesmanReportScreen> {
//   bool _showQuotations = true;
//
//   // TODO: replace all of the below with real data from your
//   // OwnerReportsBloc / repository, filtered by salesman + date range.
//   final _quotations = [
//     _ReportRow(
//       code: 'QUO-202608-118',
//       status: 'Delivered',
//       subtitle: 'Sunrise Interiors · Kozhikode',
//       amount: 64200,
//       date: DateTime(2026, 8, 8),
//     ),
//     _ReportRow(
//       code: 'QUO-202608-117',
//       status: 'Pending',
//       subtitle: 'Green Valley Builders · Wayanad',
//       amount: 128000,
//       date: DateTime(2026, 8, 7),
//     ),
//   ];
//
//   final _estimates = [
//     _ReportRow(
//       code: 'EST-202608-054',
//       status: 'Approved',
//       subtitle: 'Sunrise Interiors · Kozhikode',
//       amount: 58600,
//       date: DateTime(2026, 8, 5),
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
//     final rangeLabel =
//         '${DateFormat('dd').format(widget.startDate)}\u2013${DateFormat('dd MMM yyyy').format(widget.endDate)}';
//
//     final rows = _showQuotations ? _quotations : _estimates;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Column(
//         children: [
//           ReportHeaderBar(
//             title: 'Salesman Report',
//             subtitle: rangeLabel,
//             showBack: true,
//             trailing: EditFilterButton(
//               onTap: () => Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (_) => OwnerReportFilterScreen(
//                     type: ReportPersonType.salesman,
//                     initialPerson: widget.salesmanName,
//                     initialStart: widget.startDate,
//                     initialEnd: widget.endDate,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.all(Responsive.w(20)),
//               children: [
//                 ReportPersonHeaderCard(
//                   name: widget.salesmanName,
//                   subtitle: 'Sales Executive · Kozhikode',
//                   avatarColor: AppColors.primary,
//                 ),
//                 SizedBox(height: Responsive.h(14)),
//                 ReportStatGrid(
//                   tiles: [
//                     const ReportStatTile(value: '42', label: 'Quotations Made'),
//                     const ReportStatTile(value: '18', label: 'Estimates Made'),
//                     ReportStatTile(value: currency.format(802000), label: 'Total Sales'),
//                     const ReportStatTile(value: '43%', label: 'Conversion Rate', valueColor: Color(0xFFF59E0B)),
//                     ReportStatTile(
//                       value: currency.format(41775),
//                       label: 'Incentive Earned',
//                       valueColor: const Color(0xFF16A34A),
//                     ),
//                     const ReportStatTile(value: '80%', label: 'Target Achieved', valueColor: Color(0xFF16A34A)),
//                   ],
//                 ),
//                 SizedBox(height: Responsive.h(18)),
//                 ReportTabSwitcher(
//                   leftLabel: 'Quotations',
//                   rightLabel: 'Estimates',
//                   isLeftSelected: _showQuotations,
//                   onChanged: (isLeft) => setState(() => _showQuotations = isLeft),
//                 ),
//                 SizedBox(height: Responsive.h(14)),
//                 for (int i = 0; i < rows.length; i++) ...[
//                   ReportListItemCard(
//                     code: rows[i].code,
//                     status: rows[i].status,
//                     subtitle: rows[i].subtitle,
//                     amountFormatted: currency.format(rows[i].amount),
//                     dateFormatted: DateFormat('dd MMM yyyy').format(rows[i].date),
//                     onTap: () {
//                       // TODO: navigate to the quotation/estimate detail screen.
//                     },
//                   ),
//                   if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
//                 ],
//                 if (rows.isEmpty)
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
//                     child: Center(
//                       child: Text(
//                         _showQuotations ? 'No quotations in this period' : 'No estimates in this period',
//                         style: AppTextStyles.caption(),
//                       ),
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
import 'package:intl/intl.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_bloc.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_event.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/reportentrymodel.dart';
import 'ownerreportfilterscreen.dart';
import 'ownerreportwidget.dart';

/// Full performance summary for a single salesman.
/// Matches mockup frame 3. Data now comes from
/// POST /reports/salesman-performance via OwnerReportsBloc.
class OwnerSalesmanReportScreen extends StatelessWidget {
  const OwnerSalesmanReportScreen({
    super.key,
    required this.salesmanId,
    required this.salesmanName,
    required this.startDate,
    required this.endDate,
  });

  final String salesmanId;
  final String salesmanName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    final apiDateFmt = DateFormat('yyyy-MM-dd');
    // If OwnerReportsBloc is already provided higher up your widget tree,
    // swap this for BlocProvider.value(value: context.read<OwnerReportsBloc>(), ...)
    return BlocProvider(
      create: (_) => OwnerReportsBloc()
        ..add(LoadSalesmanReport(
          salesmanId: salesmanId,
          fromDate: apiDateFmt.format(startDate),
          toDate: apiDateFmt.format(endDate),
        )),
      child: _OwnerSalesmanReportView(
        salesmanId: salesmanId,
        salesmanName: salesmanName,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }
}

class _OwnerSalesmanReportView extends StatefulWidget {
  const _OwnerSalesmanReportView({
    required this.salesmanId,
    required this.salesmanName,
    required this.startDate,
    required this.endDate,
  });

  final String salesmanId;
  final String salesmanName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  State<_OwnerSalesmanReportView> createState() => _OwnerSalesmanReportViewState();
}

class _OwnerSalesmanReportViewState extends State<_OwnerSalesmanReportView> {
  bool _showQuotations = true;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final rangeLabel =
        '${DateFormat('dd').format(widget.startDate)}\u2013${DateFormat('dd MMM yyyy').format(widget.endDate)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:  AppBar(
        title: Text('Salesman Report', style: AppTextStyles.h6())),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
              builder: (context, state) {
                if (state.salesmanReportStatus == LoadStatus.loading ||
                    state.salesmanReportStatus == LoadStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.salesmanReportStatus == LoadStatus.failure || state.salesmanReport == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.w(20)),
                      child: Text(
                        state.salesmanReportError ?? 'Failed to load report.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(),
                      ),
                    ),
                  );
                }

                final report = state.salesmanReport!;
                final summary = report.summary;
                final rows = _showQuotations ? report.quotations : report.estimates;
                final displayName = report.salesmanName.isNotEmpty ? report.salesmanName : widget.salesmanName;

                return ListView(
                  padding: EdgeInsets.all(Responsive.w(20)),
                  children: [
                    ReportPersonHeaderCard(
                      name: displayName,
                      subtitle: 'Sales Executive',
                      avatarColor: AppColors.primary,
                    ),
                    SizedBox(height: Responsive.h(14)),
                    ReportStatGrid(
                      tiles: [
                        ReportStatTile(value: '${summary.quotationsMade}', label: 'Quotations Made'),
                        ReportStatTile(value: '${summary.estimatesMade}', label: 'Estimates Made'),
                        ReportStatTile(value: currency.format(summary.totalSales), label: 'Total Sales'),
                        ReportStatTile(
                          value: '${summary.conversionRate.toStringAsFixed(0)}%',
                          label: 'Conversion Rate',
                          valueColor: const Color(0xFFF59E0B),
                        ),
                        ReportStatTile(
                          value: currency.format(summary.incentiveEarned),
                          label: 'Incentive Earned',
                          valueColor: const Color(0xFF16A34A),
                        ),
                        ReportStatTile(
                          value: '${summary.targetAchieved.toStringAsFixed(0)}%',
                          label: 'Target Achieved',
                          valueColor: const Color(0xFF16A34A),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(18)),
                    ReportTabSwitcher(
                      leftLabel: 'Quotations',
                      rightLabel: 'Estimates',
                      isLeftSelected: _showQuotations,
                      onChanged: (isLeft) => setState(() => _showQuotations = isLeft),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    for (int i = 0; i < rows.length; i++) ...[
                      _buildRow(rows[i], currency),
                      if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
                    ],
                    if (rows.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                        child: Center(
                          child: Text(
                            _showQuotations ? 'No quotations in this period' : 'No estimates in this period',
                            style: AppTextStyles.caption(),
                          ),
                        ),
                      ),
                    SizedBox(height: Responsive.h(20)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(ReportEntryModel row, NumberFormat currency) {
    return ReportListItemCard(
      code: row.number,
      status: row.statusLabel,
      subtitle: row.contractorName.isNotEmpty ? row.contractorName : row.customerName,
      amountFormatted: currency.format(row.grandTotal),
      dateFormatted: row.date != null ? DateFormat('dd MMM yyyy').format(row.date!) : '-',
      onTap: () {
        // TODO: navigate to the quotation/estimate detail screen using row.id.
      },
    );
  }
}