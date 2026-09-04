
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


// }

/// Estimate Report results screen.
/// Everything shown here — summary numbers, row list, and each row's
/// status label — comes straight from POST /reports/estimates. Nothing
/// is filtered or re-labelled on the client.
///
/// Status chips are NOT hardcoded: the screen fetches with status: 'all'
/// first, reads the distinct status/status_label pairs off the returned
/// rows, and uses that as the chip set. Tapping a chip re-fetches with
/// that status filtered server-side.
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
  final String personId;
  final String personName;
  final DateTime startDate;
  final DateTime endDate;

  String get _apiType => type == ReportEntityType.salesman ? 'salesman' : 'contractor';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstimateReportBloc()
        ..add(FetchEstimateReport(
          type: _apiType,
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

  /// Runs once, on the first ('all') response — pulls every distinct
  /// status straight out of the rows the server actually returned.
  /// The chip list is exactly this set — no extra "All" entry added.
  void _discoverStatusesIfNeeded(List<EstimateListItemModel> rows) {
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
    setState(() => _selectedApiValue = apiValue);
    context.read<EstimateReportBloc>().add(FetchEstimateReport(
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

    return NetworkAwareWrapper(child:Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estimate $title', style: AppTextStyles.h6()),
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
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(20)),
                child: Text(state.message ?? '', style: AppTextStyles.caption(), textAlign: TextAlign.center),
              ),
            );
          }

          final loaded = state as EstimateReportLoaded;
          final summary = loaded.data.summary;
          final rows = loaded.data.list;
          // Empty string = nothing selected yet (initial unfiltered view,
          // before the user has tapped any status chip).
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
                  code: rows[i].estimateNumber,
                  status: rows[i].statusLabel,
                  subtitle: '${rows[i].customerName} · ${rows[i].customerPhone}',
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