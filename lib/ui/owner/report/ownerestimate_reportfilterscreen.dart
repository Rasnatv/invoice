import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tileshop/ui/no%20internetconnection/no_connection.dart';
import '../../../Apiprovider/ownerreportprovider.dart';
// NOTE: adjust this file name/path to where SalesmanProvider lives.
import '../../../Apiprovider/salesmanprovider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/owner_models/salesmanmodel.dart';
import '../../../models/owner_reportmodel/activecontractormodel.dart';
import 'ownerestimatereportscreen.dart';
import 'ownerquotation_reportfilterscreen.dart'; // ReportEntityType

class OwnerEstimateReportFilterScreen extends StatefulWidget {
  const OwnerEstimateReportFilterScreen({
    super.key,
    this.initialType,
    this.initialPersonId,
    this.initialPerson,
    this.initialStart,
    this.initialEnd,
  });

  final ReportEntityType? initialType;
  final String? initialPersonId;
  final String? initialPerson;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<OwnerEstimateReportFilterScreen> createState() =>
      _OwnerEstimateReportFilterScreenState();
}

class _OwnerEstimateReportFilterScreenState
    extends State<OwnerEstimateReportFilterScreen> {
  // Type chips: All | Salesman | Contractor.
  static const String _chipAll = 'All';
  static const String _chipSalesman = 'Salesman';
  static const String _chipContractor = 'Contractor';
  static const List<String> _typeChips = [_chipAll, _chipSalesman, _chipContractor];

  final OwnerReportsProvider _reportsProvider = OwnerReportsProvider();

  /// Used for the full salesman list (GET /salesmen).
  final SalesmanProvider _salesmanProvider = SalesmanProvider();

  /// True when the "All" chip is selected: no person dropdown, and the report
  /// is requested with type = "" and person_id = "".
  late bool _isAll;

  /// Salesman / Contractor — only used when [_isAll] is false.
  late ReportEntityType _type;
  late DateTime _startDate;
  late DateTime _endDate;

  bool _loadingPeople = false;
  String? _peopleError;
  List<HSalesmanModel> _salesmen = [];
  List<ActiveContractorModel> _contractors = [];

  String? _selectedPersonId;
  String? _selectedPersonName;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? ReportEntityType.salesman;
    final now = DateTime.now();
    _startDate = widget.initialStart ?? DateTime(now.year, now.month, 1);
    _endDate = widget.initialEnd ?? DateTime(now.year, now.month + 1, 0);
    _selectedPersonId = widget.initialPersonId;
    _selectedPersonName = widget.initialPerson;

    // Opens on "All" unless a specific person was passed in.
    _isAll = widget.initialPersonId == null || widget.initialPersonId!.isEmpty;
    if (!_isAll) _loadPeople();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadPeople() async {
    setState(() {
      _loadingPeople = true;
      _peopleError = null;
    });

    if (_type == ReportEntityType.salesman) {
      // All salesmen (active + inactive) from GET /salesmen.
      final result = await _salesmanProvider.getSalesmen();
      if (!mounted) return;
      if (result.success) {
        setState(() {
          // Drop blank-name records so they never show as selectable rows.
          _salesmen =
              result.salesmen.where((s) => s.name.trim().isNotEmpty).toList();
          _loadingPeople = false;
          _syncSelection();
        });
      } else {
        setState(() {
          _loadingPeople = false;
          _peopleError = result.errorMessage ?? 'Failed to load salesmen.';
        });
      }
    } else {
      final result = await _reportsProvider.getActiveContractors();
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _contractors = result.contractors
              .where((c) => c.name.trim().isNotEmpty)
              .toList();
          _loadingPeople = false;
          _syncSelection();
        });
      } else {
        setState(() {
          _loadingPeople = false;
          _peopleError = result.errorMessage ?? 'Failed to load contractors.';
        });
      }
    }
  }

  /// Makes sure the selected person exists in the freshly loaded list;
  /// otherwise clears it so the dropdown shows its hint. Call inside setState.
  void _syncSelection() {
    final ids = _peopleIds;
    final names = _rawNames;

    final index = ids.indexOf(_selectedPersonId ?? '');
    if (index != -1) {
      _selectedPersonName = names[index];
      return;
    }
    _selectedPersonId = null;
    _selectedPersonName = null;
  }

  // ---------------------------------------------------------------------------
  // Dropdown helpers
  // ---------------------------------------------------------------------------

  List<String> get _rawNames => _type == ReportEntityType.salesman
      ? _salesmen.map((s) => s.name.trim()).toList()
      : _contractors.map((c) => c.name.trim()).toList();

  // HSalesmanModel.id is already a String.
  List<String> get _peopleIds => _type == ReportEntityType.salesman
      ? _salesmen.map((s) => s.id).toList()
      : _contractors.map((c) => c.id.toString()).toList();

  /// Unique dropdown labels: "rasna", "rasna (2)", ... so two people with the
  /// same name never produce duplicate DropdownMenuItem values or resolve
  /// to the wrong id. Inactive salesmen get an " (Inactive)" suffix.
  List<String> get _peopleNames {
    final seen = <String, int>{};
    final raw = _rawNames;
    final isSalesman = _type == ReportEntityType.salesman;

    return List.generate(raw.length, (i) {
      final n = raw[i];
      final count = (seen[n] ?? 0) + 1;
      seen[n] = count;
      var label = count == 1 ? n : '$n ($count)';
      if (isSalesman && !_salesmen[i].isActive) label += ' (Inactive)';
      return label;
    });
  }

  String? get _selectedLabel {
    final i = _peopleIds.indexOf(_selectedPersonId ?? '');
    return i == -1 ? null : _peopleNames[i];
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  String get _selectedChip {
    if (_isAll) return _chipAll;
    return _type == ReportEntityType.salesman ? _chipSalesman : _chipContractor;
  }

  void _onTypeChipChanged(String chip) {
    if (chip == _selectedChip) return;

    if (chip == _chipAll) {
      setState(() {
        _isAll = true;
        _selectedPersonId = null;
        _selectedPersonName = null;
        _peopleError = null;
        _loadingPeople = false;
      });
      return;
    }

    setState(() {
      _isAll = false;
      _type = chip == _chipSalesman
          ? ReportEntityType.salesman
          : ReportEntityType.contractor;
      _selectedPersonId = null;
      _selectedPersonName = null;
    });
    _loadPeople();
  }

  /// Selects by index in the unique-label list, so duplicate names still
  /// resolve to the correct backend id.
  void _onPersonChanged(String label) {
    final i = _peopleNames.indexOf(label);
    if (i == -1) return;
    setState(() {
      _selectedPersonId = _peopleIds[i];
      _selectedPersonName = _rawNames[i];
    });
  }

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

  // "All" needs no person; Salesman / Contractor need one picked.
  bool get _canGenerate =>
      _isAll || (_selectedPersonId != null && _selectedPersonName != null);

  void _generate() {
    if (!_canGenerate) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OwnerEstimateReportScreen(
          type: _type,
          // '' for "All" — the API then gets type "" and person_id "".
          personId: _isAll ? '' : _selectedPersonId!,
          personName: _isAll ? 'All' : _selectedPersonName!,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final names = _peopleNames;
    final isSalesman = _type == ReportEntityType.salesman;

    return NetworkAwareWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // ---------- APPBAR (same as Estimates / Drivers) ----------
        appBar: AppBar(
          title: Text('Estimate Report', style: AppTextStyles.h6()),
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
                        const _FieldLabel('Select Type'),
                        SizedBox(height: Responsive.h(8)),
                        Wrap(
                          spacing: Responsive.w(8),
                          runSpacing: Responsive.h(8),
                          children: [
                            for (final c in _typeChips)
                              _OptionChip(
                                label: c,
                                selected: c == _selectedChip,
                                onTap: () => _onTypeChipChanged(c),
                              ),
                          ],
                        ),

                        // Person dropdown only for Salesman / Contractor.
                        if (!_isAll) ...[
                          SizedBox(height: Responsive.h(16)),
                          _FieldLabel(isSalesman
                              ? 'Select Salesman'
                              : 'Select Contractor'),
                          SizedBox(height: Responsive.h(8)),
                          if (_loadingPeople)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(),
                              ),
                            )
                          else if (_peopleError != null)
                            Text(_peopleError!,
                                style: AppTextStyles.caption(
                                    color: AppColors.error))
                          else if (names.isEmpty)
                              Text(
                                isSalesman
                                    ? 'No salesmen found.'
                                    : 'No active contractors found.',
                                style: AppTextStyles.caption(
                                    color: AppColors.textSecondary),
                              )
                            else
                              _DropdownField(
                                options: names,
                                value: _selectedLabel,
                                hint: isSalesman
                                    ? 'Select Salesman'
                                    : 'Select Contractor',
                                onChanged: _onPersonChanged,
                              ),
                        ],

                        SizedBox(height: Responsive.h(16)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Start Date'),
                                  SizedBox(height: Responsive.h(8)),
                                  _DateField(
                                    date: _startDate,
                                    onTap: () => _pickDate(isStart: true),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: Responsive.w(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('End Date'),
                                  SizedBox(height: Responsive.h(8)),
                                  _DateField(
                                    date: _endDate,
                                    onTap: () => _pickDate(isStart: false),
                                  ),
                                ],
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
                    onPressed: _canGenerate ? _generate : null,
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

/// Same pill look as the filter chips on the Estimates list.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
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
            horizontal: Responsive.w(16), vertical: Responsive.h(8)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
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
    );
  }
}

/// Field look from the dialogs: filled, no border, radius 14.
BoxDecoration _fieldDecoration() => BoxDecoration(
  color: AppColors.background,
  borderRadius: BorderRadius.circular(14),
);

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.options,
    required this.value,
    required this.hint,
    required this.onChanged,
  });
  final List<String> options;
  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value) ? value : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(14)),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          hint: Text(hint,
              style: AppTextStyles.body(color: AppColors.textHint)),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          style: AppTextStyles.body(),
          items: options
              .map((o) => DropdownMenuItem(
            value: o,
            child: Text(o, style: AppTextStyles.body()),
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
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                DateFormat('dd MMM yyyy').format(date),
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
    );
  }
}