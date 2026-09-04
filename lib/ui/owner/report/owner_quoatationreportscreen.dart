
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../bloc/ownerbloc/ownerquotationreport/owner_quoatationreport_bloc.dart';
import '../../../bloc/ownerbloc/ownerquotationreport/owner_quoatationreport_event.dart';
import '../../../bloc/ownerbloc/ownerquotationreport/owner_quoatationreport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/quotationreportmodel.dart';
import 'ownerquotation_reportfilterscreen.dart';
import 'ownerreportwidget.dart';

class OwnerQuotationReportScreen extends StatelessWidget {
  const OwnerQuotationReportScreen({
    super.key,
    required this.type,
    required this.personId,
    required this.personName,
    required this.startDate,
    required this.endDate,
  });

  final ReportEntityType type;
  final String personId;
  final String personName;
  final DateTime startDate;
  final DateTime endDate;

  String get _apiType => type == ReportEntityType.salesman ? 'salesman' : 'contractor';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuotationReportBloc()
        ..add(FetchQuotationReport(
          type: _apiType,
          personId: personId,
          personName: personName,
          fromDate: startDate,
          toDate: endDate,
          status: 'all', // always discover everything first
        )),
      child: _OwnerQuotationReportView(
        type: type,
        personId: personId,
        personName: personName,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }
}

/// One status chip's value. Built entirely from API data — never hardcoded.
class _StatusOption {
  const _StatusOption({required this.apiValue, required this.label});
  final String apiValue; // raw backend key, e.g. "sent"
  final String label;    // what the backend wants shown, e.g. "Pending"
}

class _OwnerQuotationReportView extends StatefulWidget {
  const _OwnerQuotationReportView({
    required this.type,
    required this.personId,
    required this.personName,
    required this.startDate,
    required this.endDate,
  });

  final ReportEntityType type;
  final String personId;
  final String personName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  State<_OwnerQuotationReportView> createState() => _OwnerQuotationReportViewState();
}

class _OwnerQuotationReportViewState extends State<_OwnerQuotationReportView> {
  List<_StatusOption> _statusOptions = const [_StatusOption(apiValue: 'all', label: 'All')];
  String _selectedApiValue = 'all';

  /// Runs once, on the first ('all') response — pulls every distinct
  /// status straight out of the rows the server actually returned.
  void _discoverStatusesIfNeeded(List<QuotationListItemModel> rows) {
    if (_statusOptions.length > 1) return; // already discovered, don't overwrite
    final seen = <String, String>{}; // status -> status_label, first-seen order
    for (final row in rows) {
      seen.putIfAbsent(row.status, () => row.statusLabel);
    }
    if (seen.isEmpty) return;
    setState(() {
      _statusOptions = [
        const _StatusOption(apiValue: 'all', label: 'All'),
        for (final e in seen.entries) _StatusOption(apiValue: e.key, label: e.value),
      ];
    });
  }

  void _onChipTap(String apiValue) {
    setState(() => _selectedApiValue = apiValue);
    context.read<QuotationReportBloc>().add(FetchQuotationReport(
      type: widget.type == ReportEntityType.salesman ? 'salesman' : 'contractor',
      personId: widget.personId,
      personName: widget.personName,
      fromDate: widget.startDate,
      toDate: widget.endDate,
      status: apiValue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final title = widget.type == ReportEntityType.salesman ? 'Salesman Report' : 'Contractor Report';
    final subtitle =
        '${widget.personName} · ${DateFormat('dd').format(widget.startDate)}\u2013${DateFormat('dd MMM yyyy').format(widget.endDate)}';

    return NetworkAwareWrapper(child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.h6()),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Edit filter',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OwnerQuotationReportFilterScreen(
                  initialType: widget.type,
                  initialPersonId: widget.personId,
                  initialPerson: widget.personName,
                  initialStart: widget.startDate,
                  initialEnd: widget.endDate,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<QuotationReportBloc, QuotationReportState>(
        listener: (context, state) {
          // Only the first ('all') response is used to build the chip set.
          if (state is QuotationReportLoaded && _selectedApiValue == 'all') {
            _discoverStatusesIfNeeded(state.data.list);
          }
        },
        builder: (context, state) {
          if (state is QuotationReportInitial || state is QuotationReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuotationReportError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(20)),
                child: Text(state.message ?? '', style: AppTextStyles.caption(), textAlign: TextAlign.center),
              ),
            );
          }

          final loaded = state as QuotationReportLoaded;
          final summary = loaded.data.summary;
          final rows = loaded.data.list;
          final selectedLabel =
              _statusOptions.firstWhere((s) => s.apiValue == _selectedApiValue).label;

          return ListView(
            padding: EdgeInsets.all(Responsive.w(20)),
            children: [
              Text(subtitle, style: AppTextStyles.caption()),
              SizedBox(height: Responsive.h(12)),
              SummaryStatsRow(
                stats: [
                  SummaryStat(value: '${summary.totalQuotations}', label: 'Quotations'),
                  SummaryStat(
                    value: formatIndianCompactCurrency(summary.totalValue),
                    label: 'Total Value',
                    valueColor: AppColors.primary,
                  ),
                  SummaryStat(
                    value: '${summary.pendingCount}',
                    label: 'Pending',
                    valueColor: const Color(0xFFF59E0B),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(16)),
              // Chip set + count come entirely from _statusOptions,
              // which is built from API rows — nothing hardcoded here.
              ReportStatusChips(
                options: _statusOptions.map((s) => s.label).toList(),
                selected: selectedLabel,
                onChanged: (label) {
                  final match = _statusOptions.firstWhere((s) => s.label == label);
                  _onChipTap(match.apiValue);
                },
              ),
              SizedBox(height: Responsive.h(16)),
              for (int i = 0; i < rows.length; i++) ...[
                ReportListItemCard(
                  code: rows[i].quotationNumber,
                  status: rows[i].statusLabel,
                  subtitle: '${rows[i].customerName} · ${rows[i].customerPhone}',
                  amountFormatted: currency.format(rows[i].grandTotal),
                  dateFormatted:
                  rows[i].date != null ? DateFormat('dd MMM yyyy').format(rows[i].date!) : '-',
                  onTap: () {},
                ),
                if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
              ],
              if (rows.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                  child: Center(
                    child: Text('No quotations match this filter', style: AppTextStyles.caption()),
                  ),
                ),
              SizedBox(height: Responsive.h(20)),
            ],
          );
        },
      ),
    ));
  }
}