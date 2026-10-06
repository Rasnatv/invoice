
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../bloc/ownerbloc/owerestimatereport/ownerestimatereport_bloc.dart';
import '../../../bloc/ownerbloc/owerestimatereport/ownerestimatereport_event.dart';
import '../../../bloc/ownerbloc/owerestimatereport/ownerestimatereport_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_reportmodel/estimatereportmodel.dart';
import 'ownerquotation_reportfilterscreen.dart'; // ReportEntityType
import 'ownerreportwidget.dart';

/// Value for the API `type` field. Blank when no person is chosen ("All"),
/// otherwise 'salesman' / 'contractor'.
String _apiTypeFor(ReportEntityType type, String personId) {
  if (personId.trim().isEmpty) return '';
  return type == ReportEntityType.salesman ? 'salesman' : 'contractor';
}

class OwnerEstimateReportScreen extends StatelessWidget {
  const OwnerEstimateReportScreen({
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
      create: (_) => EstimateReportBloc()
        ..add(FetchEstimateReport(
          type: _apiTypeFor(type, personId),
          personId: personId,
          personName: personName,
          fromDate: startDate,
          toDate: endDate,
          status: 'all', // always discover the available statuses first
        )),
      child: _OwnerEstimateReportView(
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
  final String apiValue; // raw backend key, e.g. "despatched"
  final String label; // what the backend wants shown, e.g. "Despatched"
}

class _OwnerEstimateReportView extends StatefulWidget {
  const _OwnerEstimateReportView({
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
  State<_OwnerEstimateReportView> createState() => _OwnerEstimateReportViewState();
}

class _OwnerEstimateReportViewState extends State<_OwnerEstimateReportView> {
  // No chip exists until the API tells us what statuses exist.
  List<_StatusOption> _statusOptions = const [];

  // 'all' here is only ever the query value sent to the API to fetch the
  // unfiltered list on first load — it never becomes a chip.
  String _selectedApiValue = 'all';

  bool get _isAll => widget.personId.trim().isEmpty;

  /// Runs once, on the first ('all') response — pulls every distinct
  /// status straight out of the rows the server actually returned.
  /// The chip list is exactly this set — no extra "All" entry added.
  void _discoverStatusesIfNeeded(List<EstimateListItemModel> rows) {
    if (_statusOptions.isNotEmpty) return; // already discovered, don't overwrite
    // filter value -> status_label, first-seen order.
    //
    // The backend's status FILTER does not accept the raw row status
    // (e.g. "pending_approval" -> "The selected status is invalid.").
    // It accepts the lowercased label instead ("Pending" -> "pending",
    // "Approved" -> "approved", "Despatched" -> "despatched", ...).
    final seen = <String, String>{};
    for (final row in rows) {
      final label = row.statusLabel.trim();
      final filterValue = (label.isNotEmpty ? label : row.status).trim().toLowerCase();
      if (filterValue.isEmpty) continue;
      seen.putIfAbsent(filterValue, () => label.isNotEmpty ? label : row.status);
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
    context.read<EstimateReportBloc>().add(FetchEstimateReport(
      type: _apiTypeFor(widget.type, widget.personId),
      personId: widget.personId,
      personName: widget.personName,
      fromDate: widget.startDate,
      toDate: widget.endDate,
      status: next,
    ));
  }

  /// Builds the labelled lines shown under each estimate number.
  ///
  /// An estimate can have BOTH a salesman and a contractor, so each gets its
  /// own line. In a salesman-specific report the salesman line is skipped
  /// (redundant); in a contractor-specific report the contractor line is
  /// skipped. In the "All" report both are shown when present.
  String _buildSubtitle(EstimateListItemModel row) {
    final lines = <String>[
      'Customer: ${row.customerName.isNotEmpty ? row.customerName : '-'}',
      'Phone: ${row.customerPhone.isNotEmpty ? row.customerPhone : '-'}',
    ];

    final showSalesman = _isAll || widget.type == ReportEntityType.contractor;
    final showContractor = _isAll || widget.type == ReportEntityType.salesman;

    if (showSalesman && row.salesmanName.trim().isNotEmpty) {
      lines.add('Salesman: ${row.salesmanName.trim()}');
    }
    if (showContractor && row.contractorName.trim().isNotEmpty) {
      lines.add('Contractor: ${row.contractorName.trim()}');
    }

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final title = _isAll
        ? 'Estimate Report'
        : widget.type == ReportEntityType.salesman
        ? 'Estimate Salesman Report'
        : 'Estimate Contractor Report';
    final subtitle =
        '${widget.personName} · ${DateFormat('dd').format(widget.startDate)}\u2013${DateFormat('dd MMM yyyy').format(widget.endDate)}';

    return NetworkAwareWrapper(child:Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.h6()),
      ),
      body: BlocConsumer<EstimateReportBloc, EstimateReportState>(
        listener: (context, state) {
          // Only the first ('all') response is used to build the chip set.
          if (state is EstimateReportLoaded && _selectedApiValue == 'all') {
            _discoverStatusesIfNeeded(state.data.list);
          }
        },
        builder: (context, state) {
          if (state is EstimateReportInitial || state is EstimateReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EstimateReportError) {
            // Keep the chips on screen (when statuses are already known) so a
            // failed filter never leaves the user stuck on a blank error page.
            final errorSelectedLabel = _statusOptions
                .firstWhere(
                  (s) => s.apiValue == _selectedApiValue,
              orElse: () => const _StatusOption(apiValue: '', label: ''),
            )
                .label;

            return ListView(
              padding: EdgeInsets.all(Responsive.w(20)),
              children: [
                if (_statusOptions.isNotEmpty) ...[
                  ReportStatusChips(
                    options: _statusOptions.map((s) => s.label).toList(),
                    selected: errorSelectedLabel,
                    onChanged: (label) {
                      final match = _statusOptions.firstWhere((s) => s.label == label);
                      _onChipTap(match.apiValue);
                    },
                  ),
                  SizedBox(height: Responsive.h(40)),
                ] else
                  SizedBox(height: Responsive.h(80)),
                Center(
                  child: Text(
                    state.message ?? '',
                    style: AppTextStyles.caption(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          final loaded = state as EstimateReportLoaded;
          final summary = loaded.data.summary;
          final rows = loaded.data.list;

          // True once at least one estimate exists for this period.
          final hasEstimates =
              rows.isNotEmpty || _statusOptions.isNotEmpty || _selectedApiValue != 'all';

          // No estimates at all -> only the header text and an empty message.
          if (!hasEstimates) {
            return ListView(
              padding: EdgeInsets.all(Responsive.w(20)),
              children: [
                Text(subtitle, style: AppTextStyles.caption()),
                SizedBox(height: Responsive.h(60)),
                Center(
                  child: Text('No estimates in this period', style: AppTextStyles.caption()),
                ),
              ],
            );
          }

          // Empty string = nothing selected yet (initial unfiltered view).
          final selectedLabel = _statusOptions
              .firstWhere(
                (s) => s.apiValue == _selectedApiValue,
            orElse: () => const _StatusOption(apiValue: '', label: ''),
          )
              .label;

          return ListView(
            padding: EdgeInsets.all(Responsive.w(20)),
            children: [
              Text(subtitle, style: AppTextStyles.caption()),
              SizedBox(height: Responsive.h(12)),
              SummaryStatsRow(
                stats: [
                  SummaryStat(value: '${summary.totalEstimates}', label: 'Estimates'),
                  SummaryStat(
                    value: formatIndianCompactCurrency(summary.totalValue),
                    label: 'Total Value',
                    valueColor: AppColors.primary,
                  ),
                  SummaryStat(
                    value: '${summary.convertedCount}',
                    label: 'Converted',
                    valueColor: const Color(0xFF16A34A),
                  ),
                  SummaryStat(
                    value: '${summary.pendingCount}',
                    label: 'Pending',
                    valueColor: const Color(0xFFF59E0B),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(16)),
              // Chip set comes entirely from _statusOptions (built from API rows).
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
                  code: rows[i].estimateNumber,
                  status: rows[i].statusLabel,
                  // Labelled lines: Customer / Phone / Salesman / Contractor
                  subtitle: _buildSubtitle(rows[i]),
                  amountFormatted: currency.format(rows[i].grandTotal),
                  dateFormatted:
                  rows[i].date != null ? DateFormat('dd MMM yyyy').format(rows[i].date!) : '-',
                  onTap: () {
                    // TODO: navigate to the estimate detail screen using rows[i].id.
                  },
                ),
                if (i != rows.length - 1) SizedBox(height: Responsive.h(10)),
              ],
              if (rows.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(30)),
                  child: Center(
                    child: Text('No estimates match this filter', style: AppTextStyles.caption()),
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
