
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

/// Value for the API `type` field. Blank when no person is chosen ("All"),
/// otherwise 'salesman' / 'contractor'.
String _apiTypeFor(ReportEntityType type, String personId) {
  if (personId.trim().isEmpty) return '';
  return type == ReportEntityType.salesman ? 'salesman' : 'contractor';
}

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

  /// Empty string = "All" report (type + person_id are sent blank).
  final String personId;
  final String personName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuotationReportBloc()
        ..add(FetchQuotationReport(
          type: _apiTypeFor(type, personId),
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
  final String apiValue; // raw backend key, e.g. "draft"
  final String label; // what the backend wants shown, e.g. "Draft"
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
  // No chip exists until the API tells us what statuses exist.
  // Nothing is added manually (no hardcoded "All" chip).
  List<_StatusOption> _statusOptions = const [];

  // 'all' here is only ever the query value sent to the API to fetch the
  // unfiltered list — it never becomes a chip.
  String _selectedApiValue = 'all';

  bool get _isAll => widget.personId.trim().isEmpty;

  /// Runs once, on the first ('all') response — pulls every distinct
  /// status (status + status_label) straight out of the rows the server
  /// actually returned. The chip list is exactly this set.
  void _discoverStatusesIfNeeded(List<QuotationListItemModel> rows) {
    if (_statusOptions.isNotEmpty) return; // already discovered, don't overwrite
    final seen = <String, String>{}; // status -> status_label, first-seen order
    for (final row in rows) {
      seen.putIfAbsent(row.status, () => row.statusLabel);
    }
    if (seen.isEmpty) return;
    setState(() {
      _statusOptions = [
        for (final e in seen.entries) _StatusOption(apiValue: e.key, label: e.value),
      ];
    });
  }

  void _onChipTap(String apiValue) {
    // Tapping the selected chip again clears the filter (back to everything),
    // since there is no manual "All" chip to go back with.
    final next = apiValue == _selectedApiValue ? 'all' : apiValue;
    setState(() => _selectedApiValue = next);
    context.read<QuotationReportBloc>().add(FetchQuotationReport(
      type: _apiTypeFor(widget.type, widget.personId),
      personId: widget.personId,
      personName: widget.personName,
      fromDate: widget.startDate,
      toDate: widget.endDate,
      status: next,
    ));
  }

  /// Builds the labelled lines shown under each quotation number.
  String _buildSubtitle(QuotationListItemModel row) {
    final lines = <String>[
      'Customer: ${row.customerName.isNotEmpty ? row.customerName : '-'}',
      'Phone: ${row.customerPhone.isNotEmpty ? row.customerPhone : '-'}',
    ];

    // Salesman / Contractor line (only when the row has one).
    // In a specific salesman/contractor report it's redundant, so the
    // owner line is shown for the "All" report only.
    if (_isAll && row.ownerName.isNotEmpty) {
      lines.add('${row.ownerType}: ${row.ownerName}');
    }

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final title = _isAll
        ? 'Quotation Report'
        : widget.type == ReportEntityType.salesman
        ? 'Salesman Report'
        : 'Contractor Report';
    final subtitle =
        '${widget.personName} · ${DateFormat('dd').format(widget.startDate)}\u2013${DateFormat('dd MMM yyyy').format(widget.endDate)}';

    return NetworkAwareWrapper(
      child: Scaffold(
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
                    // '' = All, which the filter screen opens on the All chip.
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
            // 1. Loading -> spinner only, nothing else on screen.
            if (state is QuotationReportInitial || state is QuotationReportLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error -> message only.
            if (state is QuotationReportError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(20)),
                  child: Text(
                    state.message ?? '',
                    style: AppTextStyles.caption(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final loaded = state as QuotationReportLoaded;
            final summary = loaded.data.summary;
            final rows = loaded.data.list;

            // True once at least one bill exists for this period.
            final hasBills =
                rows.isNotEmpty || _statusOptions.isNotEmpty || _selectedApiValue != 'all';

            // 3. No bills at all -> hide stats + chips, show only the header
            //    text and an empty message.
            if (!hasBills) {
              return ListView(
                padding: EdgeInsets.all(Responsive.w(20)),
                children: [
                  Text(subtitle, style: AppTextStyles.caption()),
                  SizedBox(height: Responsive.h(60)),
                  Center(
                    child: Text('No quotations in this period', style: AppTextStyles.caption()),
                  ),
                ],
              );
            }

            // Empty string = nothing selected (unfiltered view).
            final selectedLabel = _statusOptions
                .firstWhere(
                  (s) => s.apiValue == _selectedApiValue,
              orElse: () => const _StatusOption(apiValue: '', label: ''),
            )
                .label;

            // 4. Bills exist -> full UI.
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
                // Chip set comes entirely from _statusOptions, which is
                // built from the API rows (status + status_label).
                if (_statusOptions.isNotEmpty) ...[
                  ReportStatusChips(
                    options: _statusOptions.map((s) => s.label).toList(),
                    selected: selectedLabel,
                    onChanged: (label) {
                      final match = _statusOptions.firstWhere((s) => s.label == label);
                      _onChipTap(match.apiValue);
                    },
                  ),
                  SizedBox(height: Responsive.h(16)),
                ],
                for (int i = 0; i < rows.length; i++) ...[
                  ReportListItemCard(
                    code: rows[i].quotationNumber,
                    status: rows[i].statusLabel,
                    // Labelled lines: Customer / Phone / (Salesman|Contractor)
                    subtitle: _buildSubtitle(rows[i]),
                    amountFormatted: currency.format(rows[i].grandTotal),
                    dateFormatted: rows[i].date != null
                        ? DateFormat('dd MMM yyyy').format(rows[i].date!)
                        : '-',
                    onTap: () {},
                  ),
                  if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
                ],
                if (rows.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                    child: Center(
                      child: Text(
                        'No quotations match this filter',
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
    );
  }
}