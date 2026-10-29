
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
// NOTE: adjust this file name/path to where SalesmanProvider lives.
import '../../../Apiprovider/salesmanprovider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import 'ownercontractorreportscreen.dart';
import 'ownersalesmanreportscreen.dart';

enum ReportPersonType { salesman, contractor }

/// Filter screen shown before generating a Salesman/Contractor report.
/// Salesmen are loaded from GET /salesmen (all salesmen, active + inactive).
/// Contractors are loaded from the active contractors endpoint.
class OwnerReportFilterScreen extends StatefulWidget {
  const OwnerReportFilterScreen({
    super.key,
    required this.type,
    this.initialPersonId,
    this.initialStart,
    this.initialEnd,
  });

  final ReportPersonType type;
  final String? initialPersonId;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<OwnerReportFilterScreen> createState() =>
      _OwnerReportFilterScreenState();
}

class _DropdownEntry {
  const _DropdownEntry({
    required this.id,
    required this.label,
    required this.name,
  });

  /// Backend id sent to the report screen.
  final String id;

  /// Unique text shown in the dropdown (may include "(2)" / "(Inactive)").
  final String label;

  /// Clean name passed to the report screen.
  final String name;
}

class _OwnerReportFilterScreenState extends State<OwnerReportFilterScreen> {
  final SalesmanProvider _salesmanProvider = SalesmanProvider();
  final OwnerReportsProvider _reportsProvider = OwnerReportsProvider();

  String? _selectedId;
  late DateTime _startDate;
  late DateTime _endDate;

  bool _loading = true;
  String? _error;
  List<_DropdownEntry> _options = [];

  bool get _isSalesman => widget.type == ReportPersonType.salesman;
  String get _label => _isSalesman ? 'Select Salesman' : 'Select Contractor';
  String get _hint => _isSalesman ? 'Select Salesman' : 'Select Contractor';

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialPersonId;
    final now = DateTime.now();
    _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);
    _loadOptions();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (_isSalesman) {
      // All salesmen (active + inactive) from GET /salesmen.
      final result = await _salesmanProvider.getSalesmen();
      if (!mounted) return;
      if (result.success) {
        // Skip blank-name records; keep id/name pairs together.
        final people = result.salesmen
            .where((s) => s.name.trim().isNotEmpty)
            .map((s) => (
        id: s.id,
        name: s.name.trim(),
        inactive: !s.isActive,
        ))
            .toList();
        _applyOptions(people);
      } else {
        setState(() {
          _loading = false;
          _error = result.errorMessage ?? 'Failed to load salesmen.';
        });
      }
    } else {
      final result = await _reportsProvider.getActiveContractors();
      if (!mounted) return;
      if (result.success) {
        final people = result.contractors
            .where((c) => c.name.trim().isNotEmpty)
            .map((c) => (
        id: c.id.toString(),
        name: c.name.trim(),
        inactive: false,
        ))
            .toList();
        _applyOptions(people);
      } else {
        setState(() {
          _loading = false;
          _error = result.errorMessage ?? 'Failed to load contractors.';
        });
      }
    }
  }

  /// Builds unique dropdown labels ("rasna", "rasna (2)", ...) so duplicate
  /// names never create duplicate DropdownMenuItem values, and clears a
  /// previously selected id that is no longer in the list.
  void _applyOptions(
      List<({String id, String name, bool inactive})> people) {
    final seen = <String, int>{};
    final entries = people.map((p) {
      final count = (seen[p.name] ?? 0) + 1;
      seen[p.name] = count;
      var label = count == 1 ? p.name : '${p.name} ($count)';
      if (p.inactive) label += ' (Inactive)';
      return _DropdownEntry(id: p.id, label: label, name: p.name);
    }).toList();

    setState(() {
      _options = entries;
      _loading = false;
      if (_selectedId != null && entries.every((e) => e.id != _selectedId)) {
        _selectedId = null;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _generate() {
    final id = _selectedId;
    if (id == null) return;

    final match = _options.where((o) => o.id == id);
    final name = match.isNotEmpty ? match.first.name : '';

    if (_isSalesman) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OwnerSalesmanReportScreen(
            salesmanId: id,
            salesmanName: name,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OwnerContractorReportScreen(
            contractorId: id,
            contractorName: name,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final dateFmt = DateFormat('dd MMM yyyy');

    final isEmpty = !_loading && _error == null && _options.isEmpty;

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates / Drivers) ----------
        appBar: AppBar(
          title: Text('Reports', style: AppTextStyles.h6()),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(Responsive.w(20),
                      Responsive.h(14), Responsive.w(20), Responsive.h(24)),
                  child: _FilterCard(
                    title: 'Filters',
                    icon: Icons.tune_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(_label),
                        SizedBox(height: Responsive.h(8)),
                        if (_loading)
                          Container(
                            height: Responsive.h(52),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(14)),
                            decoration: _fieldDecoration(),
                            child: const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (_error != null)
                          Text(_error!,
                              style: AppTextStyles.caption(
                                  color: AppColors.error))
                        else if (isEmpty)
                          // Never render DropdownButton with an empty
                          // items list — it throws RangeError.
                            Container(
                              height: Responsive.h(52),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.w(14)),
                              decoration: _fieldDecoration(),
                              child: Text(
                                _isSalesman
                                    ? 'No salesmen found'
                                    : 'No active contractors found',
                                style: AppTextStyles.body(
                                    color: AppColors.textSecondary),
                              ),
                            )
                          else
                            _DropdownField(
                              value: _selectedId,
                              hint: _hint,
                              options: _options,
                              onChanged: (v) => setState(() => _selectedId = v),
                            ),
                        SizedBox(height: Responsive.h(16)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DateField(
                                label: 'Start Date',
                                dateLabel: dateFmt.format(_startDate),
                                onTap: () => _pickDate(isStart: true),
                              ),
                            ),
                            SizedBox(width: Responsive.w(12)),
                            Expanded(
                              child: _DateField(
                                label: 'End Date',
                                dateLabel: dateFmt.format(_endDate),
                                onTap: () => _pickDate(isStart: false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- BOTTOM BAR (same as Estimate Details) ----------
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: EdgeInsets.fromLTRB(Responsive.w(20),
                    Responsive.h(10), Responsive.w(20), Responsive.h(14)),
                child: SizedBox(
                  width: double.infinity,
                  height: Responsive.h(48),
                  child: ElevatedButton(
                    onPressed: _selectedId == null ? null : _generate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Generate Report',
                        style: AppTextStyles.bodyBold(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// SMALL REUSABLE PIECES (private to this file)
// =====================================================================

/// Field look from the dialogs: filled, no border, radius 14.
BoxDecoration _fieldDecoration() => BoxDecoration(
  color: AppColors.background,
  borderRadius: BorderRadius.circular(14),
);

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.title, required this.child, this.icon});
  final String title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
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
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: AppColors.primary),
                  ),
                  SizedBox(width: Responsive.w(10)),
                ],
                Expanded(child: Text(title, style: AppTextStyles.bodyBold())),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(14)),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.caption(color: AppColors.textSecondary));
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  final String? value;
  final String? hint;
  final List<_DropdownEntry> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Safety net: never let DropdownButton render with empty options.
    if (options.isEmpty) {
      return Container(
        height: Responsive.h(52),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
        decoration: _fieldDecoration(),
        child: Text('No options available',
            style: AppTextStyles.body(color: AppColors.textSecondary)),
      );
    }

    // If value doesn't match any item, DropdownButton asserts. Fall back
    // to null (shows hint) instead of crashing.
    final safeValue = options.any((o) => o.id == value) ? value : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          hint: hint != null
              ? Text(hint!,
              style: AppTextStyles.body(color: AppColors.textHint))
              : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          style: AppTextStyles.body(),
          items: options
              .map((o) => DropdownMenuItem(
            value: o.id,
            child: Text(o.label, style: AppTextStyles.body()),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.dateLabel,
    required this.onTap,
  });

  final String label;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        SizedBox(height: Responsive.h(8)),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(12), vertical: Responsive.h(14)),
            decoration: _fieldDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(),
                  ),
                ),
                SizedBox(width: Responsive.w(6)),
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}