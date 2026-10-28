
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
import 'ownerreportwidget.dart';

final _apiDateFmt = DateFormat('yyyy-MM-dd');

class OwnerContractorReportScreen extends StatelessWidget {
  const OwnerContractorReportScreen({
    super.key,
    required this.contractorId,
    required this.contractorName,
    required this.startDate,
    required this.endDate,
  });

  final String contractorId;
  final String contractorName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerReportsBloc()
        ..add(LoadContractorReport(
          contractorId: contractorId,
          fromDate: _apiDateFmt.format(startDate),
          toDate: _apiDateFmt.format(endDate),
        )),
      child: _OwnerContractorReportView(
        contractorId: contractorId,
        contractorName: contractorName,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }
}

class _OwnerContractorReportView extends StatefulWidget {
  const _OwnerContractorReportView({
    required this.contractorId,
    required this.contractorName,
    required this.startDate,
    required this.endDate,
  });

  final String contractorId;
  final String contractorName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  State<_OwnerContractorReportView> createState() =>
      _OwnerContractorReportViewState();
}

class _OwnerContractorReportViewState
    extends State<_OwnerContractorReportView> {
  bool _showQuotations = true;

  void _reload() {
    context.read<OwnerReportsBloc>().add(LoadContractorReport(
      contractorId: widget.contractorId,
      fromDate: _apiDateFmt.format(widget.startDate),
      toDate: _apiDateFmt.format(widget.endDate),
    ));
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
          title: Text('Contractor Report', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
            builder: (context, state) {
              if (state.contractorReportStatus == LoadStatus.loading ||
                  state.contractorReportStatus == LoadStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.contractorReportStatus == LoadStatus.failure ||
                  state.contractorReport == null) {
                return ReportErrorView(
                  message:
                  state.contractorReportError ?? 'Failed to load report.',
                  onRetry: _reload,
                );
              }

              final report = state.contractorReport!;
              final summary = report.summary;
              // Accumulated rows from all loaded pages.
              final rows = _showQuotations
                  ? state.contractorQuotations
                  : state.contractorEstimates;
              final displayName = report.contractorName.isNotEmpty
                  ? report.contractorName
                  : widget.contractorName;
              final lastOrderDate = summary.lastOrderDate;

              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    context
                        .read<OwnerReportsBloc>()
                        .add(const LoadMoreContractorReport());
                  }
                  return false;
                },
                child: ListView(
                  padding: listPadding,
                  children: [
                    ReportPersonCard(
                      name: displayName,
                      subtitle: 'Contractor',
                      avatarColor: const Color(0xFFB45309),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    ReportStatsCard(stats: [
                      ReportStat(
                          value: '${summary.quotationsMade}',
                          label: 'Quotations'),
                      ReportStat(
                          value: '${summary.estimatesMade}',
                          label: 'Estimates'),
                      ReportStat(
                        value: currency.format(
                            summary.estimatesValue),
                        label: 'Total Business',
                        color: AppColors.primary,
                      ),
                      ReportStat(
                        value: currency.format(summary.outstanding),
                        label: 'Outstanding Balance',
                        color: const Color(0xFFDC2626),
                      ),
                      ReportStat(
                        value: lastOrderDate != null
                            ? DateFormat('dd MMM yyyy').format(lastOrderDate)
                            : '-',
                        label: 'Last Order Date',
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
                    if (state.contractorLoadingMore)
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
      subtitle: row.salesmanName.isNotEmpty
          ? 'Handled by ${row.salesmanName}'
          : row.customerName,
      amountText: currency.format(row.grandTotal),
      dateText:
      row.date != null ? DateFormat('dd MMM yyyy').format(row.date!) : '-',
      onTap: () {
        // TODO: navigate to the quotation/estimate detail screen using row.id.
      },
    );
  }
}