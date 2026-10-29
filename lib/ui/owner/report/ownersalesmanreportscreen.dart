
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_bloc.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_event.dart';
import '../../../bloc/ownerbloc/ownerreportbloc/ownerreport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/reportentrymodel.dart';
import '../ownerestuimatedetailscreen.dart';
import '../quotation_detail_screen.dart';
import 'ownerreportwidget.dart';

final _apiDateFmt = DateFormat('yyyy-MM-dd');

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
    return BlocProvider(
      create: (_) => OwnerReportsBloc()
        ..add(LoadSalesmanReport(
          salesmanId: salesmanId,
          fromDate: _apiDateFmt.format(startDate),
          toDate: _apiDateFmt.format(endDate),
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
  State<_OwnerSalesmanReportView> createState() =>
      _OwnerSalesmanReportViewState();
}

class _OwnerSalesmanReportViewState extends State<_OwnerSalesmanReportView> {
  bool _showQuotations = true;

  // Prevents double taps opening two detail screens.
  bool _isNavigating = false;

  void _reload() {
    context.read<OwnerReportsBloc>().add(LoadSalesmanReport(
      salesmanId: widget.salesmanId,
      fromDate: _apiDateFmt.format(widget.startDate),
      toDate: _apiDateFmt.format(widget.endDate),
    ));
  }

  /// Opens the quotation or estimate detail screen for the tapped row,
  /// depending on which tab is selected.
  Future<void> _openDetail(ReportEntryModel row) async {
    if (_isNavigating) return;
    final id = row.id.toString();
    if (id.isEmpty) return;

    _isNavigating = true;
    try {
      if (_showQuotations) {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => OwnerQuotationDetailsScreen(
              quotationId: id,
              isSalesmanQuotation: true, // these are the salesman's quotations
            ),
          ),
        );
        // Returns true when approve / reject / cancel / edit happened.
        if (changed == true && mounted) _reload();
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OwnerEstimateDetailsScreen(estimateId: id),
          ),
        );
        // Estimate status can change (approve, despatch), so refresh.
        if (mounted) _reload();
      }
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates / Drivers) ----------
        appBar: AppBar(
          title: Text('Salesman Report', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
            builder: (context, state) {
              if (state.salesmanReportStatus == LoadStatus.loading ||
                  state.salesmanReportStatus == LoadStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.salesmanReportStatus == LoadStatus.failure ||
                  state.salesmanReport == null) {
                return ReportErrorView(
                  message: state.salesmanReportError ?? 'Failed to load report.',
                  onRetry: _reload,
                );
              }

              final report = state.salesmanReport!;
              final summary = report.summary;
              // Accumulated rows from all loaded pages.
              final rows = _showQuotations
                  ? state.salesmanQuotations
                  : state.salesmanEstimates;
              final displayName = report.salesmanName.isNotEmpty
                  ? report.salesmanName
                  : widget.salesmanName;

              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    context
                        .read<OwnerReportsBloc>()
                        .add(const LoadMoreSalesmanReport());
                  }
                  return false;
                },
                child: ListView(
                  padding: listPadding,
                  children: [
                    ReportPersonCard(
                      name: displayName,
                      subtitle: 'Sales Executive',
                      avatarColor: AppColors.primary,
                    ),
                    SizedBox(height: Responsive.h(14)),
                    ReportStatsCard(stats: [
                      ReportStat(
                          value: '${summary.quotationsMade}',
                          label: 'Quotations Made'),
                      ReportStat(
                          value: '${summary.estimatesMade}',
                          label: 'Estimates Made'),
                      ReportStat(
                          value: currency.format(summary.totalSales),
                          label: 'Total Sales',
                          color: AppColors.primary),
                      ReportStat(
                        value: '${summary.conversionRate.toStringAsFixed(0)}%',
                        label: 'Conversion Rate',
                        color: const Color(0xFFF59E0B),
                      ),
                      ReportStat(
                        value: currency.format(summary.incentiveEarned),
                        label: 'Incentive Earned',
                        color: AppColors.success,
                      ),
                      ReportStat(
                        value: '${summary.targetAchieved.toStringAsFixed(0)}%',
                        label: 'Target Achieved',
                        color: AppColors.success,
                      ),
                    ]),
                    SizedBox(height: Responsive.h(18)),
                    ReportTabSwitcher(
                      leftLabel: 'Quotations',
                      rightLabel: 'Estimates',
                      isLeftSelected: _showQuotations,
                      onChanged: (isLeft) =>
                          setState(() => _showQuotations = isLeft),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ReportSectionHeader(
                            _showQuotations ? 'Quotations' : 'Estimates'),
                        ReportStatusPill(
                          label: '${rows.length} '
                              '${rows.length == 1 ? (_showQuotations ? 'quotation' : 'estimate') : (_showQuotations ? 'quotations' : 'estimates')}',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(10)),
                    for (int i = 0; i < rows.length; i++) ...[
                      _buildRow(rows[i], currency),
                      if (i != rows.length - 1)
                        SizedBox(height: Responsive.h(10)),
                    ],
                    if (rows.isEmpty)
                      Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: Responsive.h(30)),
                        child: Center(
                          child: Text(
                            _showQuotations
                                ? 'No quotations in this period'
                                : 'No estimates in this period',
                            style: AppTextStyles.subtitle(),
                          ),
                        ),
                      ),
                    if (state.salesmanLoadingMore)
                      Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: Responsive.h(16)),
                        child:
                        const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRow(ReportEntryModel row, NumberFormat currency) {
    return ReportEntryCard(
      code: row.number,
      statusLabel: row.statusLabel,
      subtitle:
      row.contractorName.isNotEmpty ? row.contractorName : row.customerName,
      amountText: currency.format(row.grandTotal),
      dateText:
      row.date != null ? DateFormat('dd MMM yyyy').format(row.date!) : '-',
      onTap: () => _openDetail(row),
    );
  }
}