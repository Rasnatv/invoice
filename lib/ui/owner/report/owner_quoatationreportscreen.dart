
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

const Color _redColor = Color(0xFFDC2626);
const Color _amberColor = Color(0xFFF59E0B);

/// Value for the API `type` field. Blank when no person is chosen ("All"),
/// otherwise 'salesman' / 'contractor'.
String _apiTypeFor(ReportEntityType type, String personId) {
  if (personId.trim().isEmpty) return '';
  return type == ReportEntityType.salesman ? 'salesman' : 'contractor';
}

/// Status colour by backend key. Statuses come from the API, so unknown
/// ones fall back to amber (same as "pending" on the Estimates list).
Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'delivered':
    case 'paid':
    case 'accepted':
      return AppColors.success;
    case 'rejected':
    case 'cancelled':
    case 'expired':
      return _redColor;
    case 'despatched':
    case 'converted':
      return AppColors.primary;
    case 'draft':
      return AppColors.textSecondary;
    default:
      return _amberColor;
  }
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
  State<_OwnerQuotationReportView> createState() =>
      _OwnerQuotationReportViewState();
}

class _OwnerQuotationReportViewState extends State<_OwnerQuotationReportView> {
  // No chip exists until the API tells us what statuses exist.
  List<_StatusOption> _statusOptions = const [];

  // 'all' is only ever the query value sent to the API; it never becomes a chip.
  String _selectedApiValue = 'all';

  final ScrollController _scrollController = ScrollController();

  bool get _isAll => widget.personId.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Ask the bloc for the next page when the user is near the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<QuotationReportBloc>().add(const LoadMoreQuotationReport());
    }
  }

  /// If the loaded rows don't fill the screen there is nothing to scroll,
  /// so the scroll listener would never fire. Load the next page directly.
  void _loadMoreIfNotScrollable(QuotationReportLoaded state) {
    if (!state.hasMore || state.isLoadingMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        context
            .read<QuotationReportBloc>()
            .add(const LoadMoreQuotationReport());
      }
    });
  }

  /// Runs once, on the first ('all') response — pulls every distinct
  /// status (status + status_label) from the rows the server returned.
  void _discoverStatusesIfNeeded(List<QuotationListItemModel> rows) {
    if (_statusOptions.isNotEmpty) return;
    final seen = <String, String>{}; // status -> status_label, first-seen order
    for (final row in rows) {
      seen.putIfAbsent(row.status, () => row.statusLabel);
    }
    if (seen.isEmpty) return;
    setState(() {
      _statusOptions = [
        for (final e in seen.entries)
          _StatusOption(apiValue: e.key, label: e.value),
      ];
    });
  }

  void _fetch(String status) {
    context.read<QuotationReportBloc>().add(FetchQuotationReport(
      type: _apiTypeFor(widget.type, widget.personId),
      personId: widget.personId,
      personName: widget.personName,
      fromDate: widget.startDate,
      toDate: widget.endDate,
      status: status,
    ));
  }

  void _onChipTap(String apiValue) {
    // Tapping the selected chip again clears the filter.
    final next = apiValue == _selectedApiValue ? 'all' : apiValue;
    setState(() => _selectedApiValue = next);
    _fetch(next);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final title = _isAll
        ? 'Quotation Report'
        : widget.type == ReportEntityType.salesman
        ? 'Salesman Report'
        : 'Contractor Report';
    final subtitle =
        '${widget.personName} · ${DateFormat('dd').format(widget.startDate)}–${DateFormat('dd MMM yyyy').format(widget.endDate)}';

    final listPadding = EdgeInsets.fromLTRB(
        Responsive.w(20), Responsive.h(14), Responsive.w(20), Responsive.h(24));

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates / Drivers) ----------
        appBar: AppBar(
          title: Text(title, style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: BlocConsumer<QuotationReportBloc, QuotationReportState>(
            listener: (context, state) {
              if (state is! QuotationReportLoaded) return;

              // Only the first ('all') response builds the chip set.
              if (_selectedApiValue == 'all') {
                _discoverStatusesIfNeeded(state.rows);
              }

              // Short first page -> nothing to scroll -> fetch next page.
              _loadMoreIfNotScrollable(state);
            },
            builder: (context, state) {
              // 1. Loading -> spinner only.
              if (state is QuotationReportInitial ||
                  state is QuotationReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Error.
              if (state is QuotationReportError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => _fetch(_selectedApiValue),
                );
              }

              final loaded = state as QuotationReportLoaded;
              final summary = loaded.data.summary;
              final rows = loaded.rows; // accumulated across all pages

              final hasBills = rows.isNotEmpty ||
                  _statusOptions.isNotEmpty ||
                  _selectedApiValue != 'all';

              // 3. No bills at all -> header + empty message.
              if (!hasBills) {
                return RefreshIndicator(
                  onRefresh: () async => _fetch(_selectedApiValue),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: listPadding,
                    children: [
                      _PeriodHeader(text: subtitle),
                      SizedBox(height: Responsive.h(60)),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.description_outlined,
                                size: 44,
                                color: AppColors.textSecondary
                                    .withOpacity(0.4)),
                            SizedBox(height: Responsive.h(10)),
                            Text('No quotations in this period',
                                style: AppTextStyles.subtitle()),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final selectedLabel = _statusOptions
                  .firstWhere(
                    (s) => s.apiValue == _selectedApiValue,
                orElse: () =>
                const _StatusOption(apiValue: '', label: ''),
              )
                  .label;

              // 4. Bills exist -> full UI.
              return RefreshIndicator(
                onRefresh: () async => _fetch(_selectedApiValue),
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: listPadding,
                  children: [
                    _PeriodHeader(text: subtitle),
                    SizedBox(height: Responsive.h(14)),
                    _SummaryCard(stats: [
                      _Stat(
                        value: '${summary.totalQuotations}',
                        label: 'Quotations',
                        color: AppColors.textPrimary,
                      ),
                      _Stat(
                        value: _compactCurrency(summary.totalValue),
                        label: 'Total Value',
                        color: AppColors.primary,
                      ),
                      _Stat(
                        value: '${summary.pendingCount}',
                        label: 'Pending',
                        color: _amberColor,
                      ),
                    ]),
                    SizedBox(height: Responsive.h(14)),

                    // Chip set comes entirely from _statusOptions.
                    if (_statusOptions.isNotEmpty) ...[
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusOptions.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final s = _statusOptions[i];
                            return _FilterChip(
                              label: s.label,
                              selected: s.label == selectedLabel,
                              onTap: () => _onChipTap(s.apiValue),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: Responsive.h(14)),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader('Quotations'),
                        // Show the server's total, not just what's loaded.
                        _StatusPill(
                          label: _countLabel(
                            loaded: rows.length,
                            total: summary.totalQuotations,
                            filtered: _selectedApiValue != 'all',
                          ),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(10)),

                    for (int i = 0; i < rows.length; i++) ...[
                      _QuotationCard(
                        row: rows[i],
                        showOwner: _isAll,
                        amountText: currency.format(rows[i].grandTotal),
                        dateText: rows[i].date != null
                            ? DateFormat('dd MMM yyyy').format(rows[i].date!)
                            : '-',
                      ),
                      if (i != rows.length - 1)
                        SizedBox(height: Responsive.h(10)),
                    ],
                    if (rows.isEmpty)
                      Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: Responsive.h(30)),
                        child: Center(
                          child: Text('No quotations match this filter',
                              style: AppTextStyles.subtitle()),
                        ),
                      ),

                    // Footer: spinner while the next page is loading.
                    if (loaded.isLoadingMore)
                      Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: Responsive.h(16)),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
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
}

/// "10 of 42 quotations" while more pages remain, "42 quotations" once
/// everything is loaded. When a status filter is on, the summary total
/// may cover all statuses, so only the loaded count is shown.
String _countLabel({
  required int loaded,
  required int total,
  required bool filtered,
}) {
  final noun = loaded == 1 ? 'quotation' : 'quotations';
  if (!filtered && total > loaded) return '$loaded of $total quotations';
  return '$loaded $noun';
}

/// Compact Indian format: ₹18.4L / ₹1.2Cr / ₹9,400.
String _compactCurrency(num value) {
  final v = value.toDouble();
  if (v >= 10000000) {
    return '₹${(v / 10000000).toStringAsFixed(v % 10000000 == 0 ? 0 : 1)}Cr';
  }
  if (v >= 100000) {
    return '₹${(v / 100000).toStringAsFixed(v % 100000 == 0 ? 0 : 1)}L';
  }
  return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
      .format(v);
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

/// White, radius 16, 1px border, no shadow.
BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
);

/// "Salesman · 01–31 Oct 2026" line, shown in a small card.
class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assessment_outlined,
                color: AppColors.primary, size: 20),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyBold(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Text(title, style: AppTextStyles.bodyBold()),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: Responsive.sp(10.5),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12), vertical: Responsive.h(6)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(11.5),
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        SizedBox(width: Responsive.w(6)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: Responsive.sp(11),
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------

class _Stat {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14), vertical: Responsive.h(12)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calculate_outlined,
                      size: 16, color: AppColors.primary),
                ),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: Text('Summary', style: AppTextStyles.bodyBold()),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  Expanded(
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(stats[i].value,
                              style:
                              AppTextStyles.amount(color: stats[i].color)),
                        ),
                        SizedBox(height: Responsive.h(4)),
                        Text(
                          stats[i].label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (i != stats.length - 1)
                    Container(width: 1, height: 32, color: AppColors.border),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Quotation card (same layout as the Estimates list card)
// ---------------------------------------------------------------------

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.row,
    required this.showOwner,
    required this.amountText,
    required this.dateText,
  });

  final QuotationListItemModel row;

  /// Salesman / Contractor line is only shown on the "All" report; in a
  /// specific person's report it would be redundant.
  final bool showOwner;
  final String amountText;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(row.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(14)),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- top: icon, number + customer, status ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description_outlined,
                    color: AppColors.primary, size: 20),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.quotationNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      row.customerName.isNotEmpty ? row.customerName : '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              _StatusPill(label: row.statusLabel, color: color),
            ],
          ),

          // ---- phone / owner ----
          SizedBox(height: Responsive.h(10)),
          _InfoRow(
            icon: Icons.phone_outlined,
            text: row.customerPhone.isNotEmpty ? row.customerPhone : '-',
          ),
          if (showOwner && row.ownerName.isNotEmpty) ...[
            SizedBox(height: Responsive.h(6)),
            _InfoRow(
              icon: Icons.badge_outlined,
              text: '${row.ownerType}: ${row.ownerName}',
            ),
          ],

          SizedBox(height: Responsive.h(12)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: Responsive.h(10)),

          // ---- bottom: date, total ----
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.textSecondary),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.textSecondary),
                ),
              ),
              Text(
                amountText,
                style: AppTextStyles.amount(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 38),
            SizedBox(height: Responsive.h(10)),
            Text(
              (message == null || message!.isEmpty)
                  ? 'Failed to load quotations.'
                  : message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(),
            ),
            SizedBox(height: Responsive.h(10)),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.bodyBold()),
            ),
          ],
        ),
      ),
    );
  }
}