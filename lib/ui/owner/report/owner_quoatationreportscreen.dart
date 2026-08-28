// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/responsive.dart';
// import 'ownerquotation_reportfilterscreen.dart';
// import 'ownerreportwidget.dart';
//
// class _QuotationRow {
//   const _QuotationRow({
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
// /// Quotation Report results screen.
// /// Matches "3 · Report results" in the mockup.
// class OwnerQuotationReportScreen extends StatelessWidget {
//   const OwnerQuotationReportScreen({
//     super.key,
//     required this.type,
//     required this.personName,
//     required this.startDate,
//     required this.endDate,
//     required this.status,
//   });
//
//   final ReportEntityType type;
//   final String personName;
//   final DateTime startDate;
//   final DateTime endDate;
//   final String status;
//
//   // TODO: replace with real data from your OwnerReportsBloc / repository,
//   // filtered by type + person + date range + status.
//   static final List<_QuotationRow> _allRows = [
//     _QuotationRow(
//       code: 'QUO-202608-118',
//       status: 'Delivered',
//       subtitle: 'Sunrise Interiors · Kozhikode',
//       amount: 64200,
//       date: DateTime(2026, 8, 8),
//     ),
//     _QuotationRow(
//       code: 'QUO-202608-117',
//       status: 'Pending',
//       subtitle: 'Green Valley Builders · Wayanad',
//       amount: 128000,
//       date: DateTime(2026, 8, 7),
//     ),
//     _QuotationRow(
//       code: 'QUO-202608-116',
//       status: 'Draft',
//       subtitle: 'Nizar Constructions · Malappuram',
//       amount: 42750,
//       date: DateTime(2026, 8, 6),
//     ),
//   ];
//
//   List<_QuotationRow> get _filteredRows {
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
//     final totalValue = _allRows.fold<double>(0, (sum, r) => sum + r.amount);
//     final pendingCount = _allRows.where((r) => r.status == 'Pending').length;
//     final subtitle =
//         '$personName · ${DateFormat('dd').format(startDate)}\u2013${DateFormat('dd MMM yyyy').format(endDate)} · $status';
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Column(
//         children: [
//           ReportHeaderBar(
//             title: 'Quotation Report',
//             subtitle: subtitle,
//             showBack: true,
//             trailing: EditFilterButton(
//               onTap: () => Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (_) => OwnerQuotationReportFilterScreen(
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
//                     SummaryStat(value: '${_allRows.length}', label: 'Quotations'),
//                     SummaryStat(
//                       value: formatIndianCompactCurrency(totalValue),
//                       label: 'Total Value',
//                       valueColor: AppColors.primary,
//                     ),
//                     SummaryStat(
//                       value: '$pendingCount',
//                       label: 'Pending',
//                       valueColor: const Color(0xFFF59E0B),
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
//                       // TODO: navigate to the quotation detail screen.
//                     },
//                   ),
//                   if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
//                 ],
//                 if (rows.isEmpty)
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
//                     child: Center(
//                       child: Text('No quotations match this filter', style: AppTextStyles.caption()),
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

    return Scaffold(
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

          if (state is QuotationReportUnauthorized) {
            return Center(
              child: Text('Session expired. Please log in again.', style: AppTextStyles.caption()),
            );
          }

          if (state is QuotationReportError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(20)),
                child: Text(state.message, style: AppTextStyles.caption(), textAlign: TextAlign.center),
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
    );
  }
}