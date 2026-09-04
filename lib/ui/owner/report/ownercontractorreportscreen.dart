
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
import 'ownerreportfilterscreen.dart';
import 'ownerreportwidget.dart';

/// Business summary for a single contractor.
/// Matches mockup frame 4. Data now comes from
/// POST /reports/contractor-performance via OwnerReportsBloc.
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
    final apiDateFmt = DateFormat('yyyy-MM-dd');
    // If OwnerReportsBloc is already provided higher up your widget tree,
    // swap this for BlocProvider.value(value: context.read<OwnerReportsBloc>(), ...)
    return BlocProvider(
      create: (_) => OwnerReportsBloc()
        ..add(LoadContractorReport(
          contractorId: contractorId,
          fromDate: apiDateFmt.format(startDate),
          toDate: apiDateFmt.format(endDate),
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
  State<_OwnerContractorReportView> createState() => _OwnerContractorReportViewState();
}

class _OwnerContractorReportViewState extends State<_OwnerContractorReportView> {
  bool _showQuotations = true;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final rangeLabel =
        '${DateFormat('dd').format(widget.startDate)}\u2013${DateFormat('dd MMM yyyy').format(widget.endDate)}';

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar:  AppBar(
          title: Text('Contractor Report', style: AppTextStyles.h6())),
      body: Column(
        children: [

          Expanded(
            child: BlocBuilder<OwnerReportsBloc, OwnerReportsState>(
              builder: (context, state) {
                if (state.contractorReportStatus == LoadStatus.loading ||
                    state.contractorReportStatus == LoadStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.contractorReportStatus == LoadStatus.failure || state.contractorReport == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.w(20)),
                      child: Text(
                        state.contractorReportError ?? 'Failed to load report.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(),
                      ),
                    ),
                  );
                }

                final report = state.contractorReport!;
                final summary = report.summary;
                final rows = _showQuotations ? report.quotations : report.estimates;
                final displayName =
                report.contractorName.isNotEmpty ? report.contractorName : widget.contractorName;
                final lastOrderDate = summary.lastOrderDate;

                return ListView(
                  padding: EdgeInsets.all(Responsive.w(20)),
                  children: [
                    ReportPersonHeaderCard(
                      name: displayName,
                      subtitle: 'Contractor',
                      avatarColor: const Color(0xFFB45309),
                    ),
                    SizedBox(height: Responsive.h(14)),
                    ReportStatGrid(
                      tiles: [
                        ReportStatTile(value: '${summary.quotationsMade}', label: 'Quotations'),
                        ReportStatTile(value: '${summary.estimatesMade}', label: 'Estimates'),
                        ReportStatTile(
                          value: currency.format(summary.quotationsValue + summary.estimatesValue),
                          label: 'Total Business',
                        ),
                        ReportStatTile(
                          value: currency.format(summary.outstanding),
                          label: 'Outstanding',
                          valueColor: const Color(0xFFDC2626),
                        ),
                        ReportStatTile(
                          value: lastOrderDate != null
                              ? DateFormat('dd MMM yyyy').format(lastOrderDate)
                              : '-',
                          label: 'Last Order',
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
    ));
  }

  Widget _buildRow(ReportEntryModel row, NumberFormat currency) {
    return ReportListItemCard(
      code: row.number,
      status: row.statusLabel,
      subtitle: row.salesmanName.isNotEmpty ? 'Handled by ${row.salesmanName}' : row.customerName,
      amountFormatted: currency.format(row.grandTotal),
      dateFormatted: row.date != null ? DateFormat('dd MMM yyyy').format(row.date!) : '-',
      onTap: () {
        // TODO: navigate to the quotation/estimate detail screen using row.id.
      },
    );
  }
}